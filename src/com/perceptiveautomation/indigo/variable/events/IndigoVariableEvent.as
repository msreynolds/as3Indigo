package com.perceptiveautomation.indigo.variable.events
{
	import com.perceptiveautomation.indigo.events.IndigoEvents;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoVariable;
	
	import flash.events.Event;

	public class IndigoVariableEvent extends Event
	{
		private var _variable:AbstractIndigoVariable;
		
		public function IndigoVariableEvent(variable:AbstractIndigoVariable)
		{
			super(IndigoEvents.INDIGO_VARIABLE_CHANGE_EVENT);
			this._variable = variable;
		}
		
		public function get variable():AbstractIndigoVariable
		{
			return this._variable;
		}
	}
}