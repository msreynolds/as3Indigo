/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 9:04 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.events
{
    import com.perceptiveautomation.indigo.device.IIndigoDevice;

    import flash.events.Event;

    public class IndigoDeviceChangeEvent extends Event
    {
        public static const TYPE:String = "com.perceptiveautomation.indigo.events.IndigoDeviceChangeEvent";

        private var _indigoDevice:IIndigoDevice;

        public function IndigoDeviceChangeEvent(device:IIndigoDevice)
        {
            super(TYPE);

            _indigoDevice = device;
        }

        public function get indigoDevice():IIndigoDevice
        {
            return _indigoDevice;
        }
    }
}
