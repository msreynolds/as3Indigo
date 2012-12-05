/**
 * Mountain Labs, LLC
 * www.mtnlabs.com
 * copyright 2012
 * author: Matthew Reynolds
 * matt at mtnlabs dot com
 * Date: 12/4/12
 * Time: 7:29 PM
 */
package com.perceptiveautomation.indigo.device
{
    import flash.events.Event;

    public class CameraDevice extends BaseIndigoDevice implements IIndigoCameraDevice
    {
        private var _isOn:Boolean;

        public function CameraDevice(xmlNode:Object)
        {
            super(xmlNode);

            if (xmlNode.hasOwnProperty('IsOn'))
            {
                this._isOn = xmlNode.IsOn.toLowerCase() == "true";
            }

            if (xmlNode.hasOwnProperty('isOn'))
            {
                this._isOn = xmlNode.isOn.toLowerCase() == "true";
            }
        }

        [Bindable(event='isOnChanged')]
        public function get isOn():Boolean
        {
            return this._isOn;
        }

        public function set isOn(value:Boolean):void
        {
            if (this._isOn != value)
            {
                this._isOn = value;
                dispatchEvent(new Event('isOnChanged'));
            }
        }
    }
}
