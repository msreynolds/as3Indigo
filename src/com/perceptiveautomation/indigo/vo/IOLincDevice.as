package com.perceptiveautomation.indigo.vo
{
	import flash.events.Event;

	public class IOLincDevice extends AbstractIndigoDevice
	{
		private var _isOn:Boolean;
		
		public function IOLincDevice(xmlNode:Object)
		{
			super(xmlNode);
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