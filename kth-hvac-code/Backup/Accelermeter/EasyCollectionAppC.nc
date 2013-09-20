configuration EasyCollectionAppC {}
implementation {
  components EasyCollectionC as App;
  components MainC, LedsC, ActiveMessageC;
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);
  components new TimerMilliC();
  
  App.Boot -> MainC;
  App.RadioControl -> ActiveMessageC;
  App.RoutingControl -> Collector;
  App.Leds -> LedsC;
  App.Timer -> TimerMilliC;
  App.Send -> CollectionSenderC;
  App.RootControl -> Collector;
  App.Receive -> Collector.Receive[0xee];
  //App.RadioPacket -> Collector.Packet;

  components SerialActiveMessageC as AM;
  App.SerialControl -> AM;
  App.AMSend -> AM.AMSend[AM_TEST_SERIAL_MSG];
  App.SerialPacket -> AM;

  components new ADXL345C();
  App.Zaxis -> ADXL345C.Z;
  App.Yaxis -> ADXL345C.Y;
  App.Xaxis -> ADXL345C.X;
  App.AccelControl -> ADXL345C.SplitControl;

  components UserButtonC;
  App.UserButton -> UserButtonC;

}
