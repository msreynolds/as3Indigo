package com.perceptiveautomation.indigo.device.events
{
	import com.perceptiveautomation.indigo.events.IndigoEvents;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoDevice;
	
	import flash.events.Event;

	public class IndigoDeviceEvent extends Event
	{
		private var _device:AbstractIndigoDevice;
		
		public function IndigoDeviceEvent(device:AbstractIndigoDevice)
		{
			super(IndigoEvents.INDIGO_DEVICE_CHANGE_EVENT);
			this._device = device;
		}
		
		public function get device():AbstractIndigoDevice
		{
			return this._device;
		}
	}
}