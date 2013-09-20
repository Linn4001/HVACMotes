// $Id: BlinkToRadio.h,v 1.4 2006-12-12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 1000,
 };

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t sensorval1;
  nx_uint16_t sensorval2;
  nx_uint16_t sensorval3;
} BlinkToRadioMsg;

#endif