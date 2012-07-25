package com.perceptiveautomation.indigo.events
{
import com.perceptiveautomation.indigo.variable.IndigoVariable;

import flash.events.Event;

public class IndigoVariableChangeEvent extends Event
	{
        public static const TYPE:String = "com.perceptiveautomation.indigo.events.IndigoVariableChangeEvent";

        private var _variable:IndigoVariable;
		
		public function IndigoVariableChangeEvent(variable:IndigoVariable)
		{
			super(TYPE);
			this._variable = variable;
		}
		
		public function get variable():IndigoVariable
		{
			return this._variable;
		}
	}
}