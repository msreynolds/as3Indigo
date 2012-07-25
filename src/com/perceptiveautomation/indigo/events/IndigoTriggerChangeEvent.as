/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 9:01 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.events
{
    import com.perceptiveautomation.indigo.trigger.IIndigoTrigger;

    import flash.events.Event;

    public class IndigoTriggerChangeEvent extends Event
    {
        public static const TYPE:String = "com.perceptiveautomation.indigo.events.IndigoTriggerChangeEvent";

        private var _trigger:IIndigoTrigger;

        public function IndigoTriggerChangeEvent(trigger:IIndigoTrigger)
        {
            super(TYPE);
            _trigger = trigger;
        }

        public function get trigger():IIndigoTrigger
        {
            return _trigger;
        }
    }
}
