/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 5:30 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.constants
{
    public class IndigoRestConstants
    {
        // Indigo Connection Status
        public static const INDIGO_REST_STATE_DISCONNECTED:String = "Connecting to RESTful service failed";
        public static const INDIGO_REST_STATE_CONNECTING:String = "Connecting to RESTful service";
        public static const INDIGO_REST_STATE_CONNECTED:String = "Connecting to RESTful service resulted";

        //Indigo RESTful endpoints
        public static const INDIGO_REST_ENDPOINT_ACTION_GROUPS:String = "/actions.xml";
        public static const INDIGO_REST_ENDPOINT_DEVICES:String = "/devices.xml";
        public static const INDIGO_REST_ENDPOINT_DEVICE:String = "/devices/";
        public static const INDIGO_REST_ENDPOINT_SCHEDULES:String = "/schedules.xml";
        public static const INDIGO_REST_ENDPOINT_TRIGGERS:String = "/triggers.xml";
        public static const INDIGO_REST_ENDPOINT_VARIABLES:String = "/variables.xml";

    }
}
