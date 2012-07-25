/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 9:27 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.device
{
    public interface IIndigoThermostatDevice extends IIndigoOnOffDevice
    {
        function get heatPoint():Number;
        function set heatPoint(value:Number):void;

        function get coolPoint():Number;
        function set coolPoint(value:Number):void;

        function get temperature():Number;
    }
}
