/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 9/4/12
 * Time: 7:10 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.device
{
    import com.perceptiveautomation.indigo.device.OnOffDevice;

    import mx.collections.ArrayCollection;
    import mx.collections.IList;

    public class IndigoDeviceFactory
    {
        public function IndigoDeviceFactory()
        {
        }

        public static function createIndigoDevice(xmlData:XML):IIndigoDevice
        {
            var socketTypeCode:String = "TypeName";
            var restTypeCode:String = "type";

            var socketIsOnCode:String = "IsOn";
            var restIsOnCode:String = "isOn";

            var typeCode:String = xmlData.hasOwnProperty(socketTypeCode) ? socketTypeCode : restTypeCode;
            var isOnCode:String = xmlData.hasOwnProperty(socketIsOnCode) ? socketIsOnCode : restIsOnCode;


            if ( xmlData[typeCode].indexOf('Thermostat') > -1)
            {
                return new ThermostatDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf('Dimmer') > -1 || xmlData[typeCode].indexOf('LampLinc') > -1 )
            {
                return new DimmerDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf('Motion Detector') > -1)
            {
                return new MotionDetectorDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf('Camera') > -1)
            {
                return new CameraDevice(xmlData);
            }

            else if ( xmlData.hasOwnProperty(isOnCode))
            {
                return new OnOffDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf("IR-Linc Transmitter") > -1)
            {
                return new IRTransmitterDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf("Timer") > -1)
            {
                return new TimerDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf("I/O-Linc") > -1)
            {
                return new IOLincDevice(xmlData);
            }

            else if (xmlData[typeCode].indexOf("EZIO8SA") > -1)
            {
                return new IOLincDevice(xmlData);
            }

            // Unless we have every single device type listed here, we need to keep this around as a safety net.
            // But we'd prefer to never instantiate a Base object directly
            return new BaseIndigoDevice(xmlData);
        }

        public static function createIndigoDeviceList(xmlData:XMLList):IList
        {
            var deviceList:ArrayCollection = new ArrayCollection();

            var len:int = xmlData..Device.length();
            var tempDevice:IIndigoDevice;
            for(var i:int=0; i<len;i++)
            {
                tempDevice = createIndigoDevice(xmlData..Device[i]);
                deviceList.addItem(tempDevice);
            }

            return deviceList;
        }
    }
}
