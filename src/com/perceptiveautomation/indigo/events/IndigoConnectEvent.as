package com.perceptiveautomation.indigo.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.control.IndigoController;
	import com.perceptiveautomation.indigo.vo.IndigoLogin;
	
	import flash.events.Event;
	
	public class IndigoConnectEvent extends CairngormEvent
	{
		public var _loginData:IndigoLogin;
		
		public function IndigoConnectEvent(data:IndigoLogin=null)
		{
			super(IndigoController.INDIGO_CONNECT_EVENT);
			this._loginData = data;
		}
		
		public function get loginData():IndigoLogin
		{
			return this._loginData;
		}
		
		override public function clone():Event
		{
			var event:IndigoConnectEvent = new IndigoConnectEvent(this._loginData);
			return Event(event);
		}
	}
}