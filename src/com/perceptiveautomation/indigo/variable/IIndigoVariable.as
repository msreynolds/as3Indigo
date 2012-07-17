package com.perceptiveautomation.indigo.variable
{
	public interface IIndigoVariable
	{
		function get name():String;
		function set name(value:String):void;
		
		function get value():*;
		function set value(value:*):void;
	}
}