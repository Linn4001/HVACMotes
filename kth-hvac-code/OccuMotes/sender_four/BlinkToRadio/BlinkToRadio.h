// $Id: BlinkToRadio.h,v 1.4 2006-12-12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 50,
  AM_TEST_LOCALTIME_MSG = 88,
 };

typedef nx_struct BlinkToRadioMsg {
  nx_uint8_t Event1;
  nx_uint32_t TS1;
  nx_uint8_t Event2;
  nx_uint32_t TS2;
  nx_uint8_t Event3;
  nx_uint32_t TS3;
  nx_uint8_t Event4;
  nx_uint32_t TS4;
  nx_uint16_t Number_Event;
  } BlinkToRadioMsg;


#endif
