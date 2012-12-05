package com.perceptiveautomation.indigo.device
{
    import com.perceptiveautomation.indigo.IIndigoObject;

    [Bindable]
    public interface IIndigoDevice extends IIndigoObject
	{
		function get description():String;
		function set description(value:String):void;

        function get model():String;
        function set model(value:String):void;
		
		function fill(value:IIndigoDevice):void;
	}
}