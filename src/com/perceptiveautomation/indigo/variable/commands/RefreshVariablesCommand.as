package com.perceptiveautomation.indigo.variable.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.delegates.IndigoDelegate;
	import com.perceptiveautomation.indigo.variable.events.RefreshVariablesEvent;

	public class RefreshVariablesCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var evt:RefreshVariablesEvent = RefreshVariablesEvent(event);
			var delegate:IndigoDelegate = new IndigoDelegate();
						
			delegate.refreshVariables(); 
		}
		
	}
}