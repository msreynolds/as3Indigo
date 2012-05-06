package com.perceptiveautomation.indigo.actiongroup.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.perceptiveautomation.indigo.control.IndigoController;
	
	public class IndigoActionGroupEvent extends CairngormEvent
	{
		private var _actionGroupName:String;
		
		public function IndigoActionGroupEvent(actionGroupName:String)
		{
			super(IndigoController.INDIGO_ACTION_GROUP_EVENT);
			this._actionGroupName = actionGroupName;
		}
		
		public function get actionGroupName():String
		{
			return this._actionGroupName;
		}
	}
}