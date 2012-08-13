package com.perceptiveautomation.indigo.device
{
    public class IndigoDeviceFactory
	{

		public function IndigoDeviceFactory()
		{
		}
		
		public static function getIndigoDevice(xmlNode:XML):AbstractIndigoDevice
		{
			if ( xmlNode.TypeName.indexOf('Thermostat') > -1 || xmlNode.TypeName.indexOf('Venstar T1800') > -1 )
			{
				return new ThermostatDevice(xmlNode);
			}
			
			else if (xmlNode.TypeName.indexOf('Dimmer') > -1 || xmlNode.TypeName.indexOf('LampLinc V2') > -1 )
			{
				return new DimmerDevice(xmlNode);
			}
			
			else if (xmlNode.IsOn == "true" || xmlNode.IsOn == "false")
			{
				return new OnOffDevice(xmlNode);	
			}
			
			else if (xmlNode.TypeName.indexOf("IR-Linc Transmitter") > -1)
			{
				return new IRTransmitterDevice(xmlNode);		
			}
			
			else if (xmlNode.TypeName.indexOf("Timer") > -1)
			{
				return new TimerDevice(xmlNode);		
			}
			
			else if (xmlNode.TypeName.indexOf("I/O-Linc") > -1)
			{
				return new IOLincDevice(xmlNode);		
			}

            else if (xmlNode.TypeName.indexOf("EZIO8SA") > -1)
            {
                return new IOLincDevice(xmlNode);
            }

            return new BaseIndigoDevice(xmlNode);

			// Will throw Error
			//return AbstractIndigoDevice(xmlNode);
		}
	}
}