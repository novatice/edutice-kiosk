#include "inactivity-filter.h"

bool InactivityFilter::eventFilter(QObject *obj, QEvent *event) {
  // maybe filter event ?

  switch (event->type()) {
    // those events are considered activity
    /* Mouse events */
  case QEvent::MouseButtonDblClick:
  case QEvent::MouseButtonPress:
  case QEvent::MouseButtonRelease:
  case QEvent::MouseMove:
  case QEvent::Wheel:
    /* Drag n drop events */
  case QEvent::DragEnter:
  case QEvent::DragLeave:
  case QEvent::DragMove:
  case QEvent::Drop:
    /* Keyboard events */
  case QEvent::KeyPress:
  case QEvent::KeyRelease:
    /*Touch events*/
  case QEvent::TouchBegin:
  case QEvent::TouchCancel:
  case QEvent::TouchEnd:
  case QEvent::TouchUpdate:
    /* Misc events */
  case QEvent::Resize:
  case QEvent::ScrollPrepare:
  case QEvent::Scroll:
    // qDebug("%d", event->type());
    Q_EMIT eventRaised(event->type());
    break;
  default:
    break;
  }

  return QObject::eventFilter(obj, event);
}
