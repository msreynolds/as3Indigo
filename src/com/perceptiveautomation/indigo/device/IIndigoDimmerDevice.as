/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 9:24 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.device
{
    public interface IIndigoDimmerDevice extends IIndigoOnOffDevice
    {
        function get brightness():Number;
        function set brightness(value:Number):void;
    }
}
