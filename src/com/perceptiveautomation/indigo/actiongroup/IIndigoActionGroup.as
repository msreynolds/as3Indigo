package com.perceptiveautomation.indigo.actiongroup
{
    import com.perceptiveautomation.indigo.IIndigoObject;

    public interface IIndigoActionGroup extends IIndigoObject
	{
        function get description():String;
        function set description(value:String):void;

        function get folder():String;
        function set folder(value:String):void;

        function runNow():void;
	}
}