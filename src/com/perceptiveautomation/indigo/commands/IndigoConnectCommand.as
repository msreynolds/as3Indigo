package com.perceptiveautomation.indigo.commands
{
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.delegates.IndigoDelegate;
	import com.perceptiveautomation.indigo.events.IndigoConnectEvent;

	public class IndigoConnectCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void
		{
			var evt:IndigoConnectEvent = IndigoConnectEvent(event);
			var delegate:IndigoDelegate = new IndigoDelegate();
			//delegate.loadFlashConnectionPrefs();
			
			delegate.connect(evt._loginData); 
		}
		
	}
}