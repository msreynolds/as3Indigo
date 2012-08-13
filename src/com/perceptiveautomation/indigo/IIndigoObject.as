/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 8/3/12
 * Time: 5:31 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo
{
    import flash.events.IEventDispatcher;

    [Bindable]
    public interface IIndigoObject extends IEventDispatcher
    {
        function get name():String;
        function set name(value:String):void;
    }
}
