/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 9:02 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.events
{
    import com.perceptiveautomation.indigo.schedule.IIndigoSchedule;

    import flash.events.Event;

    public class IndigoScheduleChangeEvent extends Event
    {
        public static const TYPE:String = "com.perceptiveautomation.indigo.events.IndigoScheduleChangeEvent";

        private var _schedule:IIndigoSchedule;

        public function IndigoScheduleChangeEvent(schedule:IIndigoSchedule)
        {
            _schedule = schedule;
            super(TYPE);
        }

        public function get schedule():IIndigoSchedule
        {
            return _schedule;
        }

    }
}
