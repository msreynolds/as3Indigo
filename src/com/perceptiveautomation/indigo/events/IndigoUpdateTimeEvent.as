package com.perceptiveautomation.indigo.events
{
	import flash.events.Event;

	public class IndigoUpdateTimeEvent extends Event
	{
		private var _time:Number;
		
		public function IndigoUpdateTimeEvent(time:Number)
		{
			super(IndigoEvents.INDIGO_UPDATE_TIME_EVENT);
			
			_time = time;
		}
		
		public function get time():Number
		{
			return this._time;
		}
	}
}