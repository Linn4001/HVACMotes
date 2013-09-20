// $Id: BlinkToRadioC.nc,v 1.6 2010-06-29 22:07:40 scipio Exp $

/*
 * Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/**
 * Implementation of the BlinkToRadio application.  A counter is
 * incremented and a radio message is sent whenever a timer fires.
 * Whenever a radio message is received, the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
 */
#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface LocalTime<TMilli>;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;

  //ADC  
  uses interface Resource;
  uses interface Msp430Adc12MultiChannel as MultiChannel;
  provides interface AdcConfigure<const msp430adc12_channel_config_t*>;
}
implementation {

  
  uint16_t Sens1=0xffff;
  uint16_t Sens2=0xffff;
  uint16_t DoorVal=0xffff;

  uint16_t buffer[3];
  uint8_t event1=0xff;
  uint8_t event2=0xff;
  uint8_t event3=0xff;
  uint8_t event4=0xff;
  uint32_t time1=0xffffffff;
  uint32_t time2=0xffffffff;
  uint32_t time3=0xffffffff;
  uint32_t time4=0xffffffff;
  uint32_t time5=0xffffffff;
  uint32_t time6=0xffffffff;

  uint32_t TS1=0xffffffff;
  uint32_t TS2=0xffffffff;
  uint32_t TS3=0xffffffff;
  uint32_t TS4=0xffffffff;

  bool DoorOpen  = FALSE;
  bool DoorClose = FALSE;
  bool PassSens1 = FALSE;
  bool PassSens2 = FALSE;
  bool Full = FALSE;

  message_t pkt;
  bool busy = FALSE;
  uint16_t *data_ADC;
  const msp430adc12_channel_config_t config = {
		INPUT_CHANNEL_A0, REFERENCE_VREFplus_AVss, REFVOLT_LEVEL_1_5,
		SHT_SOURCE_ACLK, SHT_CLOCK_DIV_1, SAMPLE_HOLD_4_CYCLES,
		SAMPCON_SOURCE_SMCLK, SAMPCON_CLOCK_DIV_1};

 
 task void sendMessageTask();
 task void ProcessFunction();
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  async command const msp430adc12_channel_config_t* AdcConfigure.getConfiguration()
	{
		return &config;
	}


  event void Resource.granted()
	{
		adc12memctl_t memctl[] = {{INPUT_CHANNEL_A1, REFERENCE_VREFplus_AVss}, {INPUT_CHANNEL_A2, REFERENCE_VREFplus_AVss}};
		if (call MultiChannel.configure(&config, memctl, 2, buffer, 3,0) == SUCCESS) {
			call MultiChannel.getData();
		}
	}  


 async event void MultiChannel.dataReady(uint16_t *buf, uint16_t numSamples)
	{
	atomic {
		data_ADC = buf;
                Sens1=data_ADC[0];
                Sens2=data_ADC[1];
		DoorVal=data_ADC[2];
                               
              }                
          }

task void ProcessFunction()
{ 

             
if(DoorOpen == FALSE&&DoorVal<3180)
                  {
                   
                   DoorOpen = TRUE;
                   time1 = call LocalTime.get();
                   if(event1==0xff)
                     {
                     event1=1;
                     TS1=time1;                     
                     }
                     else if(event1!=0xff&&event2==0xff)
                     {
                     event2=1;
                     TS2=time1;                     
                     }
                     else if(event1!=0xff&&event2!=0xff&&event3==0xff)
                     {
                     event3=1;
                     TS3=time1;
                     }
                     
                     else if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4==0xff)
                     {
                     event4=1;
                     TS4=time1;
                     }
                  }
            
                        
if(DoorOpen == TRUE&&DoorVal>=3180)
                  {
                    
                    DoorOpen = FALSE;
                    time2 = call LocalTime.get();
                   if(event1==0xff)
                     {
                     event1=2;
                     TS1=time2;
                     }
                     else if(event1!=0xff&&event2==0xff)
                     {
                     event2=2;
                     TS2=time2;
                     }
                     else if(event1!=0xff&&event2!=0xff&&event3==0xff)
                     {
                     event3=2;
                     TS3=time2;
                     }
                     
                     else if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4==0xff)
                     {
                     event4=2;
                     TS4=time2;
                     }                    
               }

                if(PassSens1==FALSE&&Sens1<50)
                  { 
                    
                    PassSens1 = TRUE;
                    time3 = call LocalTime.get();
                   if(event1==0xff)
                     {
                     event1=3;
                     TS1=time3;
                     }
                     else if(event1!=0xff&&event2==0xff)
                     {
                     event2=3;
                     TS2=time3;
                     }
                     else if(event1!=0xff&&event2!=0xff&&event3==0xff)
                     {
                     event3=3;
                     TS3=time3;
                     }                     
                     else if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4==0xff)
                     {
                     event4=3;
                     TS4=time3;
                     }
                  }

  if(PassSens1==TRUE&&Sens1>=50)
                  {
                    PassSens1 = FALSE;
                    time4 = call LocalTime.get();
                   if(event1==0xff)
                     {
                     event1=4;
                     TS1=time4;
                     }
                     else if(event1!=0xff&&event2==0xff)
                     {
                     event2=4;
                     TS2=time4;
                     }
                     else if(event1!=0xff&&event2!=0xff&&event3==0xff)
                     {
                     event3=4;
                     TS3=time4;
                     }                     
                     else if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4==0xff)
                     {
                     event4=4;
                     TS4=time4;
                     }
                  }


                if(PassSens2==FALSE&&Sens2<50)
                  {
                    PassSens2 = TRUE;
                    time5 = call LocalTime.get();
                   if(event1==0xff)
                     {
                     event1=5;
                     TS1=time5;
                     }
                     else if(event1!=0xff&&event2==0xff)
                     {
                     event2=5;
                     TS2=time5;
                     }
                     else if(event1!=0xff&&event2!=0xff&&event3==0xff)
                     {
                     event3=5;
                     TS3=time5;
                     }
                     
                     else if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4==0xff)
                     {
                     event4=5;
                     TS4=time5;
                     }
                  }

              if(PassSens2==TRUE&&Sens2>=50)
                  {
                    PassSens2 = FALSE;
                    time6 = call LocalTime.get();
                   if(event1==0xff)
                     {
                     event1=6;
                     TS1=time6;
                     }
                     else if(event1!=0xff&&event2==0xff)
                     {
                     event2=6;
                     TS2=time6;
                     }
                     else if(event1!=0xff&&event2!=0xff&&event3==0xff)
                     {
                     event3=6;
                     TS3=time6;
                     }
                     
                     else if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4==0xff)
                     {
                     event4=6;
                     TS4=time6;
                     }
                  }
            
            if(event1!=0xff&&event2!=0xff&&event3!=0xff&&event4!=0xff)
                 {Full=TRUE; call Leds.led0Toggle();}
            else
              {Full=FALSE;}
         
}



  event void Timer0.fired() {
    
    if (!busy) {

       if (!call Resource.isOwner()) {
					call Resource.request();
                                        post ProcessFunction();
                                        if(Full)
				         {post sendMessageTask();                                          
                                         }
				}
				else {
					call MultiChannel.getData();
					post ProcessFunction();
                                        if(Full)
				         {post sendMessageTask();                                      
                                          }
				}
   
  }
}

task void sendMessageTask(){

 BlinkToRadioMsg* btrpkt = 
	(BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      if (btrpkt == NULL) {
	return;
      }
      btrpkt->event1 = event1 ;
      btrpkt->TS1 = TS1;
      btrpkt->event2 = event2 ;
      btrpkt->TS2 = TS2;
      btrpkt->event3 = event3 ;
      btrpkt->TS3 = TS3;
      btrpkt->event4 = event4 ;
      btrpkt->TS4 = TS4;  
     if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
}





  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      Full = FALSE;
      call Leds.led1Toggle();
      event1=0xff;
      event2=0xff;
      event3=0xff;
      event4=0xff;
      TS1=0xffffffff;
      TS2=0xffffffff;
      TS3=0xffffffff;
      TS4=0xffffffff; 
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    return msg;
  }
}
