package com.perceptiveautomation.indigo.device
{
	import com.perceptiveautomation.indigo.device.IIndigoDevice;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Bindable]
	public class AbstractIndigoDevice extends EventDispatcher implements IIndigoDevice
	{		
		private var _name:String;
		private var _description:String;
		
		public function AbstractIndigoDevice(xmlNode:Object)
		{
			this._name = xmlNode.Name;
			this._description = xmlNode.Description;
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
	
		[Bindable(event='descriptionChanged')]
		public function get description():String
		{
			return this._description;
		}
		
		public function set description(value:String):void
		{
			if (this._description != value)
			{
				this._description = value;
				dispatchEvent(new Event('descriptionChanged'));
			}
		}	
		
		public function fill(value:IIndigoDevice):void
		{
			this.name = value.name;
			this.description = value.description;
		}
	}
}