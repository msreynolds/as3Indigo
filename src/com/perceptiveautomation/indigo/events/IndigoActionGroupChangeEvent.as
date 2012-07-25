/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 9:05 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.events
{
    import flash.events.Event;

    public class IndigoActionGroupChangeEvent extends Event
    {
        public static const TYPE:String = "com.perceptiveautomation.indigo.events.IndigoActionGroupChangeEvent";

        public function IndigoActionGroupChangeEvent()
        {
            super(TYPE);
        }
    }
}
