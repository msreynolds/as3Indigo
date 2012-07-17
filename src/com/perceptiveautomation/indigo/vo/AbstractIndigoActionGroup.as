package com.perceptiveautomation.indigo.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Meta(event='ActionGroupTriggered')]
	
	[Bindable]
	public class AbstractIndigoActionGroup extends EventDispatcher
	{		
		public function AbstractIndigoActionGroup(xmlNode:XML)
		{
			this._name = xmlNode.Name;
		}
	
		private var _name:String;
		
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
		
		public function trigger():void
		{
			dispatchEvent(new Event('ActionGroupTriggered'));	
   		}
	}
}