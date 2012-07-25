/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/20/12
 * Time: 12:06 AM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.schedule
{
    public interface IIndigoSchedule
    {
        function get name():String;
        function set name(value:String):void;

        function get description():String;
        function set description(value:String):void;

        function get folder():String;
        function set folder(value:String):void;

        function get nextExecuteDate():String;
        function set nextExecuteDate(value:String):void;
    }
}
