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
  uses interface Timer<TMilli> as Timer1;
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
  uint16_t Number_Event=0;

  uint16_t buffer[15];
  uint8_t Event[20];   
  uint32_t TS[20];
  uint8_t Event_Send[4];   
  uint32_t TS_Send[4];
  
  uint8_t i=0;
  uint8_t j=0;
  bool DoorOpen  = FALSE;
  bool DoorClose = FALSE;
  bool PassSens1 = FALSE;
  bool PassSens2 = FALSE;
  
  message_t pkt;
  bool busy = FALSE;
  uint16_t *data_ADC;
  const msp430adc12_channel_config_t config = {
		INPUT_CHANNEL_A0, REFERENCE_VREFplus_AVss, REFVOLT_LEVEL_1_5,
		SHT_SOURCE_ACLK, SHT_CLOCK_DIV_1, SAMPLE_HOLD_4_CYCLES,
		SAMPCON_SOURCE_SMCLK, SAMPCON_CLOCK_DIV_1};

 
 task void sendMessageTask();
 

  event void Boot.booted() {
    call AMControl.start();
    call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    call Timer1.startPeriodic(1000);
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      
      for(j=0;j<20;j++)
    {
     Event[j]=0xff;
     TS[j]=0xffffffff;
    }
      
      
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
		if (call MultiChannel.configure(&config, memctl, 2, buffer, 15,0) == SUCCESS) {
			call MultiChannel.getData();
		}
	}  


 async event void MultiChannel.dataReady(uint16_t *buf, uint16_t numSamples)
	{
	atomic {
		data_ADC = buf;
                Sens1=(data_ADC[0]+data_ADC[3]+data_ADC[6]+data_ADC[9]+data_ADC[12])/5;
                Sens2=(data_ADC[1]+data_ADC[4]+data_ADC[7]+data_ADC[10]+data_ADC[13])/5;
                DoorVal=(data_ADC[2]+data_ADC[5]+data_ADC[8]+data_ADC[11]+data_ADC[14])/5;
                                          
              }                
 
if(DoorOpen == FALSE&&DoorVal<3160)
                  {                   
                   DoorOpen = TRUE;
                   Event[i] = 1;
                   TS[i] = call LocalTime.get();
                   i++;
                   Number_Event++;                                  
                  }
            
                        
if(DoorOpen == TRUE&&DoorVal>=3160)
                  {
                    
                    DoorOpen = FALSE;
                    TS[i] = call LocalTime.get();
                    Event[i] = 2;
                    i++;
                    Number_Event++;                                    
               }

if(PassSens1==FALSE&&Sens1<50)
                  { 
                    
                    PassSens1 = TRUE;
                    TS[i] = call LocalTime.get();
                    Event[i] = 3;
                    i++; 
                    Number_Event++;
                  }

  if(PassSens1==TRUE&&Sens1>=50)
                  {
                    PassSens1 = FALSE;
                    TS[i] = call LocalTime.get();
                    Event[i] = 4;
                    i++;
                    Number_Event++;
                  }

 if(PassSens2==FALSE&&Sens2<50)
                  {
                    PassSens2 = TRUE;
                    TS[i] = call LocalTime.get();
                    Event[i] = 5;
                    i++;
                    Number_Event++;                  
                  }

 if(PassSens2==TRUE&&Sens2>=50)
                  {
                    PassSens2 = FALSE;
                    TS[i] = call LocalTime.get();
                    Event[i] = 6;
                    i++;
                    Number_Event++;                  
                  }
  }


  event void Timer0.fired() {
    
       call Leds.led0Toggle();
       if (!call Resource.isOwner()) {
					call Resource.request();                                                                           
                                     }
				else {
					call MultiChannel.getData();
                                      }
   
}


event void Timer1.fired() {

for(j=0;j<4;j++)
    {
     Event_Send[j]=Event[j];
     TS_Send[j]=TS[j];
    }

  for(j=0;j<16;j++)
    {
     Event[j]=Event[j+4];
     TS[j]=TS[j+4];
    }

  if(i-4>=0)
   {i=i-4;}
  else {i=0;}  

if(Event_Send[0]!=0xff||Event_Send[1]!=0xff||Event_Send[2]!=0xff||Event_Send[3]!=0xff)
{post sendMessageTask();}

}


task void sendMessageTask(){
if(!busy){
 BlinkToRadioMsg* btrpkt = 
	(BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
      if (btrpkt == NULL) {
	return;
      }
      btrpkt->Event1 = Event_Send[0] ;
      btrpkt->TS1 = TS_Send[0];
      btrpkt->Event2 = Event_Send[1] ;
      btrpkt->TS2 = TS_Send[1];
      btrpkt->Event3 = Event_Send[2] ;
      btrpkt->TS3 = TS_Send[2];
      btrpkt->Event4 = Event_Send[3] ;
      btrpkt->TS4 = TS_Send[3];
      btrpkt->Number_Event = Number_Event;
      
     if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        busy = TRUE;
      }
    } 
}

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
      call Leds.led1Toggle();
       }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    return msg;
  }
}
