package com.perceptiveautomation.indigo.variable
{
    import com.perceptiveautomation.indigo.IIndigoObject;

    [Bindable]
    public interface IIndigoVariable extends IIndigoObject
	{
		function get value():Object;
		function set value(value:Object):void;
	}
}