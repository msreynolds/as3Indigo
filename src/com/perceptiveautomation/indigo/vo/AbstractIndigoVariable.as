package com.perceptiveautomation.indigo.vo
{
	import flash.events.EventDispatcher;

	[Bindable]
	public class AbstractIndigoVariable extends EventDispatcher
	{
		private var _name:String;
		private var _value:Object;
		
		public function AbstractIndigoVariable(xmlNode:Object)
		{
			this._name = xmlNode.Name;
			this._value = xmlNode.Value;
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