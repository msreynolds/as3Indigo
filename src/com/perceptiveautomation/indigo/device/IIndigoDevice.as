package com.perceptiveautomation.indigo.device
{
	

	public interface IIndigoDevice
	{
		function get name():String;
		function set name(value:String):void;
		
		function get description():String;
		function set description(value:String):void;
		
		function fill(value:IIndigoDevice):void;
	}
}