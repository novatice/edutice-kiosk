#ifndef PRINT_HELPER_H
#define PRINT_HELPER_H

#include <QObject>

class PrintHelper : public QObject {
  Q_OBJECT
public:
  enum class PrintResult {
    Ok,        // job sent to a physical printer
    NoPrinter, // no physical printer available
    Error      // anything else (blocked, bad PDF, paint failure)
  };
  Q_ENUM(PrintResult)

  explicit PrintHelper(QObject *parent = nullptr);

  // Returns an empty string when printing is not allowed on this device.
  Q_INVOKABLE QString tempPdfPath();
  // Prints a PDF previously generated with WebEngineView.printToPdf().
  // The temp file is always deleted, whatever the result.
  Q_INVOKABLE PrintResult printPdf(const QString &filePath);
};

#endif // PRINT_HELPER_H
