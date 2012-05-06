package com.perceptiveautomation.indigo.device.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.control.IndigoController;
	
	public class IndigoDeviceActionEvent extends CairngormEvent
	{
		public static const TURN_ON:String = "TurnOn";
		public static const TURN_OFF:String = "TurnOff";
		public static const SET_BRIGHTNESS:String = "SetBrightness";
		public static const SET_HEAT_POINT:String = "SetHeatPoint";
		public static const SET_COOL_POINT:String = "SetCoolPoint";
		
		private var _deviceName:String;
		private var _deviceValue:int;
		private var _action:String;
		
		public function IndigoDeviceActionEvent(action:String, name:String, value:int)
		{
			super(IndigoController.INDIGO_DEVICE_EVENT);
			
			this._action = action;
			this._deviceName = name;
			this._deviceValue = value;
		}
		
		public function get action():String
		{
			return this._action;
		}
		
		public function get deviceName():String
		{
			return this._deviceName;	
		}
		
		public function get deviceValue():int
		{
			return this._deviceValue;
		}
	}
}