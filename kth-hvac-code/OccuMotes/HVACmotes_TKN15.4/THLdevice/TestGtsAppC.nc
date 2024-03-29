/*
 * Copyright (c) 2010, KTH Royal Institute of Technology
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 *  - Redistributions of source code must retain the above copyright notice, this list
 * 	  of conditions and the following disclaimer.
 *
 * 	- Redistributions in binary form must reproduce the above copyright notice, this
 *    list of conditions and the following disclaimer in the documentation and/or other
 *	  materials provided with the distribution.
 *
 * 	- Neither the name of the KTH Royal Institute of Technology nor the names of its
 *    contributors may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */
/**
 * @author Aitor Hernandez <aitorhh@kth.se>
 * @version  $Revision: 1.0 Date: 2010/06/05 $ 
 * @modified 2010/11/29 
 */

#include "app_profile.h"
configuration TestGtsAppC
{
}implementation {
	components MainC, LedsC, Ieee802154BeaconEnabledC as MAC, RandomC;
	components new Alarm62500hz32VirtualizedC() as EndAlarm;

	components TestDeviceSenderC as App;
	App.MLME_SCAN -> MAC;
	App.MLME_SYNC -> MAC;
	App.MLME_BEACON_NOTIFY -> MAC;
	App.MLME_SYNC_LOSS -> MAC;
	App.MCPS_DATA -> MAC;
	App.MLME_GTS -> MAC;
	App.Random -> RandomC;

	App.Frame -> MAC;
	App.BeaconFrame -> MAC;
	App.GtsUtility -> MAC;
	App.Packet -> MAC;

	MainC.Boot <- App;
	App.Leds -> LedsC;
	App.MLME_RESET -> MAC;
	App.MLME_SET -> MAC;
	App.MLME_GET -> MAC;

	App.IsEndSuperframe -> MAC;
	App.IsGtsOngoing -> MAC.IsGtsOngoing;
        
        //components new SensirionSht11C() as Sensor;
        //components new HamamatsuS10871TsrC() as LightSensor;

        //App.ReadHumi -> Sensor.Humidity;
        //App.ReadTemp -> Sensor.Temperature;
        //App.ReadLight->LightSensor;

        components new TimerMilliC() as Timer0;
        App.Timer0 -> Timer0;
    
        components new TimerMilliC(), LocalTimeMilliC;
        App.LocalTime -> LocalTimeMilliC;

        components new Msp430Adc12ClientAutoRVGC() as AutoAdc; 
	App.Resource -> AutoAdc;
	AutoAdc.AdcConfigure -> App;
	App.MultiChannel -> AutoAdc.Msp430Adc12MultiChannel;

}
