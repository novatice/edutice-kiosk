#include "print-helper.h"
#include "config.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QImage>
#include <QPainter>
#include <QPdfDocument>
#include <QPrinter>
#include <QPrinterInfo>
#include <QStandardPaths>
#include <QUuid>

PrintHelper::PrintHelper(QObject *parent) : QObject{parent} {}

// Virtual printers (PDF/XPS writers, fax queues, OneNote) do not print:
// they pop up a native "Save as" dialog instead. A kiosk has no one to
// dismiss such dialogs, so never send jobs to them.
static bool isVirtualPrinter(const QString &printerName) {
  const QString lower = printerName.toLower();
  return lower.contains(QStringLiteral("pdf")) || lower.contains(QStringLiteral("xps")) ||
         lower.contains(QStringLiteral("fax")) || lower.contains(QStringLiteral("onenote")) ||
         lower.contains(QStringLiteral("document writer"));
}

// Deletes the WebEngine-generated temp PDF when leaving scope, so it is
// always cleaned up whatever the outcome (success, failure, early return).
struct TempPdfCleanup {
  explicit TempPdfCleanup(const QString &path) : filePath(path) {}
  ~TempPdfCleanup() {
    if (!filePath.isEmpty()) {
      QFile::remove(filePath);
    }
  }
  QString filePath;
};

QString PrintHelper::tempPdfPath() {
  Config *config = Config::GetDeviceConfig();
  if (config == nullptr || !config->GetPrintAllowed()) {
    return QString();
  }

  QString tempDir =
      QStandardPaths::writableLocation(QStandardPaths::TempLocation);
  if (tempDir.isEmpty()) {
    qWarning() << "No writable temp location for printing";
    return QString();
  }
  QDir().mkpath(tempDir);
  return tempDir + "/edutice-kiosk-print-" +
         QUuid::createUuid().toString(QUuid::WithoutBraces) + ".pdf";
}

PrintHelper::PrintResult PrintHelper::printPdf(const QString &filePath) {
  const TempPdfCleanup cleanup(filePath);

  Config *config = Config::GetDeviceConfig();
  if (config == nullptr || !config->GetPrintAllowed()) {
    qWarning() << "Printing blocked: not allowed on this device";
    return PrintResult::Error;
  }
  if (filePath.isEmpty() || !QFile::exists(filePath)) {
    qWarning() << "Printing failed: PDF file missing:" << filePath;
    return PrintResult::Error;
  }
  // Physical printers only: default printer first, then any installed
  // physical printer. Virtual queues (PDF/XPS/Fax/OneNote) pop up a native
  // dialog nobody can dismiss on a kiosk: never use them, and never keep
  // the PDF around either.
  QString printerName = QPrinterInfo::defaultPrinterName();
  if (!printerName.isEmpty() && isVirtualPrinter(printerName)) {
    qWarning() << "Default printer is virtual, looking for a physical one:"
               << printerName;
    printerName.clear();
  }
  if (printerName.isEmpty()) {
    const QList<QPrinterInfo> printers = QPrinterInfo::availablePrinters();
    for (const QPrinterInfo &info : printers) {
      if (!isVirtualPrinter(info.printerName())) {
        printerName = info.printerName();
        break;
      }
    }
  }

  if (printerName.isEmpty()) {
    qWarning() << "Printing failed: no physical printer available";
    return PrintResult::NoPrinter;
  }

  QPrinter printer(QPrinter::HighResolution);
  printer.setPrinterName(printerName);
  printer.setDocName(QStringLiteral("Edutice Kiosk"));
  printer.setFullPage(true);
  printer.setResolution(300);

  PrintResult result = PrintResult::Error;
  {
    // NB: the QPdfDocument must be destroyed before printPdf returns: it
    // keeps the file open for on-demand page reads, and Windows refuses to
    // delete open files (TempPdfCleanup above handles the deletion).
    QPdfDocument document;
    if (document.load(filePath) != QPdfDocument::Error::None) {
      qWarning() << "Printing failed: unable to load PDF:" << filePath;
    } else if (document.pageCount() == 0) {
      qWarning() << "Printing failed: PDF is empty:" << filePath;
    } else {
      QPainter painter(&printer);
      if (!painter.isActive()) {
        qWarning() << "Printing failed: unable to paint on printer";
      } else {
        result = PrintResult::Ok;
        for (int page = 0; page < document.pageCount(); ++page) {
          if (page > 0) {
            printer.newPage();
          }
          QSize target = printer.pageRect(QPrinter::DevicePixel).size().toSize();
          if (target.isEmpty()) {
            target = QSize(2480, 3508); // ~A4 @300dpi fallback
          }
          QImage image = document.render(page, target);
          if (image.isNull()) {
            qWarning() << "Printing failed: unable to render PDF page" << page;
            result = PrintResult::Error;
            break;
          }
          QRectF pageRect = printer.pageRect(QPrinter::DevicePixel);
          painter.drawImage(pageRect.topLeft(),
                            image.scaled(pageRect.size().toSize(),
                                         Qt::KeepAspectRatio,
                                         Qt::SmoothTransformation));
        }
        painter.end();
      }
    }
  }

  if (result == PrintResult::Ok) {
    qInfo() << "Print job sent to" << printerName;
  }
  return result;
}
