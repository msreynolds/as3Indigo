package com.perceptiveautomation.indigo.variable
{
import com.perceptiveautomation.indigo.variable.IIndigoVariable;

import flash.events.Event;
import flash.events.EventDispatcher;

	[Bindable]
	public class IndigoVariable extends EventDispatcher implements IIndigoVariable
	{
		private var _id:String;
        private var _name:String;
		private var _value:Object;
		
		public function IndigoVariable(xmlNode:Object)
		{
            if (xmlNode.hasOwnProperty('ID'))
            {
                this._id = xmlNode.ID;
            }

            if (xmlNode.hasOwnProperty('id'))
            {
                this._id = xmlNode.id;
            }

            if (xmlNode.hasOwnProperty('Name'))
            {
                this._name = xmlNode.Name;
            }

            if (xmlNode.hasOwnProperty('name'))
            {
                this._name = xmlNode.name;
            }

			this._value = xmlNode.Value;
		}

        [Bindable(event="idChanged")]
        public function get id():String
        {
            return _id;
        }

        public function set id(value:String):void
        {
            if (_id == value) return;
            _id = value;
            dispatchEvent(new Event("idChanged"));
        }

		[Bindable(event='nameChanged')]
		public function get name():String
		{
			return this._name;
		}

		public function set name(value:String):void
		{
			if (this._name != value)
			{
				this._name = value;
				dispatchEvent(new Event('nameChanged'));
			}
		}

		[Bindable(event='valueChanged')]
		public function get value():Object
		{
			return this._value;
		}

		public function set value(value:Object):void
		{
			if (this._value != value)
			{
				this._value = value;
				dispatchEvent(new Event('valueChanged'));
			}
		}

    }
}