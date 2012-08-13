package com.perceptiveautomation.indigo.actiongroup
{
	public interface IIndigoActionGroup
	{
		function get name():String;
		function set name(value:String):void;

        function get description():String;
        function set description(value:String):void;

        function get folder():String;
        function set folder(value:String):void;

        function runNow():void;
	}
}