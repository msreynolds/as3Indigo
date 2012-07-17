package com.perceptiveautomation.indigo.actiongroup.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.actiongroup.events.IndigoActionGroupEvent;
	import com.perceptiveautomation.indigo.delegates.IndigoDelegate;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoActionGroup;

	public class IndigoActionGroupCommand implements ICommand
	{
		
		public function execute(event:CairngormEvent):void
		{
			var evt:IndigoActionGroupEvent = event as IndigoActionGroupEvent;
						
			var delegate:IndigoDelegate = new IndigoDelegate();
			delegate.sendCommand(evt.actionGroupName, 'TriggerActionGroup', 0);
		}
		
	}
}