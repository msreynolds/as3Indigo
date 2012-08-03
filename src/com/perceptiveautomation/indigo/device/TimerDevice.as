package com.perceptiveautomation.indigo.device
{
import com.perceptiveautomation.indigo.device.AbstractIndigoDevice;

import flash.events.Event;

	public class TimerDevice extends BaseIndigoDevice
	{
		private var _isOn:Boolean;
		private var _timeLeft:int;
		
		public function TimerDevice(xmlNode:Object)
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
		
		[Bindable(event='timeLeftChanged')]
		public function get timeLeft():int
		{
			return this._timeLeft;
		}
		
		public function set timeLeft(value:int):void
		{
			if (this._timeLeft != value)
			{
				this._timeLeft = value;
				dispatchEvent(new Event('timeLeftChanged'));
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