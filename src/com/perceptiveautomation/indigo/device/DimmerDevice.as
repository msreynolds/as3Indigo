package com.perceptiveautomation.indigo.device
{
    import flash.events.Event;

    public class DimmerDevice extends OnOffDevice implements IIndigoDimmerDevice
	{
		private var _brightness:Number;
		
		public function DimmerDevice(xmlNode:XML)
		{
			super(xmlNode);

            if (xmlNode.hasOwnProperty("BrightValue"))
            {
                brightness = xmlNode.BrightValue/10;
            }

            if (xmlNode.hasOwnProperty("brightness"))
            {
                brightness = xmlNode.brightness;
            }
		}

		[Bindable(event='brightnessChanged')]
		public function get brightness():Number
		{
			return this._brightness;
		}

		public function set brightness(value:Number):void
		{
			if (this._brightness != value)
			{
				this._brightness = value;

                if (!this._brightness)
                {
                    this._brightness = 0;
                }
                if (this._brightness > 100)
                {
                    this._brightness = 100;
                }

				this.dispatchEvent(new Event('brightnessChanged'));
			}
		}
		
		override public function turnOn():void
		{
			super.turnOn();
			this.brightness = 100;
		}
		
		override public function turnOff():void
		{
			super.turnOff()
			this.brightness = 0;
		}
	}
}