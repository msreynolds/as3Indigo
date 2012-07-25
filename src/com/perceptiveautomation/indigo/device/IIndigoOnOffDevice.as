/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 8:42 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.device
{

    public interface IIndigoOnOffDevice extends IIndigoDevice
    {
        function get isOn():Boolean;
        function set isOn(value:Boolean):void;
        function turnOn():void;
        function turnOff():void;
    }
}
