/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/19/12
 * Time: 10:02 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.trigger
{
    import com.perceptiveautomation.indigo.IIndigoObject;

    [Bindable]
    public interface IIndigoTrigger extends IIndigoObject
    {
        function get type():String;
        function set type(value:String):void;

        function get folder():String;
        function set folder(value:String):void;
    }
}
