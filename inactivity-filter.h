#ifndef INACTIVITYFILTER_H
#define INACTIVITYFILTER_H

#include "qcoreevent.h"
#include "qobject.h"
#include "qobjectdefs.h"

class InactivityFilter : public QObject {
  Q_OBJECT

protected:
  bool eventFilter(QObject *obj, QEvent *event) override;

signals:
  void eventRaised(QEvent::Type eventType);
};

#endif // INACTIVITYFILTER_H
