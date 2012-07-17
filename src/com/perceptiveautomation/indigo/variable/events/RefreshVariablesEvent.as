package com.perceptiveautomation.indigo.variable.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.control.IndigoController;

	public class RefreshVariablesEvent extends CairngormEvent
	{
		public function RefreshVariablesEvent()
		{
			super(IndigoController.INDIGO_REFRESH_VARIABLES_EVENT);
		}
		
	}
}