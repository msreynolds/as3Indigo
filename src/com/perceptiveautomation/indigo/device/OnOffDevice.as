package com.perceptiveautomation.indigo.device
{
    import flash.events.Event;

    public class OnOffDevice extends BaseIndigoDevice implements IIndigoOnOffDevice
	{
		private var _isOn:Boolean;
		
		public function OnOffDevice(xmlNode:Object)
		{
			super(xmlNode);

            if (xmlNode.hasOwnProperty('IsOn'))
            {
                this.isOn = xmlNode.IsOn.toLowerCase() == "true";
            }

            if (xmlNode.hasOwnProperty('isOn'))
            {
                this.isOn = xmlNode.isOn.toLowerCase() == "true";
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
		
		public function turnOn():void
		{
			this.isOn = true;
		}
		
		public function turnOff():void
		{
			this.isOn = false;
		}
	}
}