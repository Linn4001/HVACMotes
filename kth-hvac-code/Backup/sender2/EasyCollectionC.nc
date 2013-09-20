#include <Timer.h>
#define CC2420_DEF_CHANNEL 15
#define CC2420_DEF_RFPOWER 31

module EasyCollectionC {
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  uses interface StdControl as RoutingControl;
  uses interface Send;
  uses interface Leds;
  uses interface Timer<TMilli>;
  uses interface RootControl;
  uses interface Receive;

  uses interface Read<uint16_t> as Zaxis;  
  uses interface Read<uint16_t> as Yaxis;  
  uses interface Read<uint16_t> as Xaxis;  
  uses interface SplitControl as AccelControl;  
}
implementation {
  message_t packet;
  bool sendBusy = FALSE;
  uint16_t xdata = 0;
  uint16_t ydata = 0;
  uint16_t zdata = 0;
  uint16_t data = 0xffff;

  typedef nx_struct EasyCollectionMsg {
    nx_uint8_t Node_ID;
    nx_uint16_t data1;
    nx_uint16_t data2;
    nx_uint16_t data3;
    nx_uint16_t data4;
  } EasyCollectionMsg;

  event void Boot.booted() {
    call RadioControl.start();
    call AccelControl.start();
  }
  
  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS)
      call RadioControl.start();
    else {
      call RoutingControl.start();
      if (TOS_NODE_ID == 0) 
	call RootControl.setRoot();
      else
	call Timer.startPeriodic(2000);
    }
  }



event void AccelControl.startDone(error_t err) {
     }

 event void AccelControl.stopDone(error_t err) {
 
  }

  event void RadioControl.stopDone(error_t err) {}

  void sendMessage() {
    EasyCollectionMsg* msg =
      (EasyCollectionMsg*)call Send.getPayload(&packet, sizeof(EasyCollectionMsg));
    msg->Node_ID = TOS_NODE_ID;
    msg->data1 = xdata;
    msg->data2 = ydata;
    msg->data3 = zdata;
    msg->data4 = 0xffff;
    
    if (call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
      call Leds.led0On();
    else 
      sendBusy = TRUE;
  }
  event void Timer.fired() {

    call Xaxis.read();
    
   
  }

 event void Xaxis.readDone(error_t result, uint16_t data){
  	call Yaxis.read();
        xdata = data;
  }

  event void Yaxis.readDone(error_t result, uint16_t data){
       call Zaxis.read();
       ydata = data;
  }

   event void Zaxis.readDone(error_t result, uint16_t data){
      zdata = data; 
      
      if (!sendBusy)
      sendMessage();
      }
  
  event void Send.sendDone(message_t* m, error_t err) {
    if (err != SUCCESS) 
      call Leds.led0On();
    sendBusy = FALSE;
    call Leds.led2Toggle();
  }
  
  event message_t* 
  Receive.receive(message_t* msg, void* payload, uint8_t len) {
    call Leds.led1Toggle();    
    return msg;
  }
}
