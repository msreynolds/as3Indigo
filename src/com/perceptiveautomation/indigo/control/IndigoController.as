package com.perceptiveautomation.indigo.control
{
	import com.adobe.cairngorm.control.FrontController;
	import com.perceptiveautomation.indigo.actiongroup.commands.IndigoActionGroupCommand;
	import com.perceptiveautomation.indigo.commands.IndigoConnectCommand;
	import com.perceptiveautomation.indigo.device.commands.IndigoDeviceActionCommand;
	import com.perceptiveautomation.indigo.variable.commands.RefreshVariablesCommand;

	public class IndigoController extends FrontController
	{
		public function IndigoController()
		{
			super();
			this.initCommands();
		}
		
		private function initCommands():void
		{
			this.addCommand(INDIGO_CONNECT_EVENT, IndigoConnectCommand);
			this.addCommand(INDIGO_REFRESH_VARIABLES_EVENT, RefreshVariablesCommand);
			this.addCommand(INDIGO_DEVICE_EVENT, IndigoDeviceActionCommand);
			this.addCommand(INDIGO_ACTION_GROUP_EVENT, IndigoActionGroupCommand);
		}
		
		public static var INDIGO_REFRESH_DEVICES_EVENT:String = "com.perceptiveautomation.device.events.RefreshDevicesEvent";
		public static var INDIGO_REFRESH_VARIABLES_EVENT:String = "com.perceptiveautomation.variable.events.RefreshVariablesEvent";
		
		public static var INDIGO_DEVICE_EVENT:String = "com.perceptiveautomation.indigo.device.events.IndigoDeviceEvent";
		public static var INDIGO_ACTION_GROUP_EVENT:String = "com.perceptiveautomation.indigo.actiongroup.events.IndigoActionGroupEvent";
		public static var INDIGO_CONNECT_EVENT:String = "com.perceptiveautomation.indigo.events.IndigoConnectEvent";
	}
}