configuration EasyCollectionAppC {}
implementation {
  components EasyCollectionC, MainC, LedsC, ActiveMessageC;
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);
  components new TimerMilliC();

  EasyCollectionC.Boot -> MainC;
  EasyCollectionC.RadioControl -> ActiveMessageC;
  EasyCollectionC.RoutingControl -> Collector;
  EasyCollectionC.Leds -> LedsC;
  EasyCollectionC.Timer -> TimerMilliC;
  EasyCollectionC.Send -> CollectionSenderC;
  EasyCollectionC.RootControl -> Collector;
  EasyCollectionC.Receive -> Collector.Receive[0xee];

  components new ADXL345C();
  EasyCollectionC.Zaxis -> ADXL345C.Z;
  EasyCollectionC.Yaxis -> ADXL345C.Y;
  EasyCollectionC.Xaxis -> ADXL345C.X;
  EasyCollectionC.AccelControl -> ADXL345C.SplitControl;

}
