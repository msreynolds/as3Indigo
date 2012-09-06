package com.perceptiveautomation.indigo.events
{
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;

    import flash.events.Event;

    public class IndigoVariableChangeEvent extends Event
	{
        public static const TYPE:String = "com.perceptiveautomation.indigo.events.IndigoVariableChangeEvent";

        private var _variable:IIndigoVariable;
		
		public function IndigoVariableChangeEvent(variable:IIndigoVariable)
		{
			super(TYPE);
			this._variable = variable;
		}
		
		public function get variable():IIndigoVariable
		{
			return this._variable;
		}
	}
}