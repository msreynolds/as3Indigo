package com.perceptiveautomation.indigo.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AbstractIndigoTimeDateTrigger extends EventDispatcher
	{
		private var _name:String;
		
		public function AbstractIndigoTimeDateTrigger(xmlNode:Object)
		{
			this._name = xmlNode.Name;
			
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
		
	}
}