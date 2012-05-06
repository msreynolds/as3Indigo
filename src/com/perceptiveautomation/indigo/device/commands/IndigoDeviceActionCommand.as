package com.perceptiveautomation.indigo.device.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.delegates.IndigoDelegate;
	import com.perceptiveautomation.indigo.device.events.IndigoDeviceActionEvent;

	public class IndigoDeviceActionCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var evt:IndigoDeviceActionEvent = event as IndigoDeviceActionEvent;
			
			var delegate:IndigoDelegate = new IndigoDelegate();
			delegate.sendCommand(evt.deviceName, evt.action, evt.deviceValue);
		}
		
	}
}