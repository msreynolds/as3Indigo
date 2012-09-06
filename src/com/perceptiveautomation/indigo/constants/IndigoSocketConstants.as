/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 5:30 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.constants
{
    public class IndigoSocketConstants
    {


        //Indigo Socket State Names
        public static const INDIGO_SOCKET_STATE_DISCONNECTED:String = "Disconnected from socket";
        public static const INDIGO_SOCKET_STATE_CONNECTING:String = "Connecting to socket";
        public static const INDIGO_SOCKET_STATE_CONNECTED:String = "Connected to socket";

        // Indigo Packet Types
        public static const INDIGO_PACKET_TYPE_AUTHENTICATE:String = "Authenticate";
        public static const INDIGO_PACKET_TYPE_BROADCAST:String = "Broadcast";
        public static const INDIGO_PACKET_TYPE_REQUEST:String = "Request";
        public static const INDIGO_PACKET_TYPE_COMMAND:String = "Command";
        public static const INDIGO_PACKET_TYPE_RESPONSE:String = "Response";

         // Indigo Packet Targets
        public static const INDIGO_PACKET_TARGET_SERVER:String = "Server";
        //public static const INDIGO_PACKET_TARGET_CLIENT:String = "Client";


        // Indigo Authenticate Packet Names
        // Outgoing
        public static const INDIGO_PACKET_AUTH_KNOCK_KNOCK:String = "KnockKnock";
        public static const INDIGO_PACKET_AUTH_ATTEMPT_AUTHENTICATION:String = "AttemptAuthentication";
        // Incoming
        public static const INDIGO_PACKET_AUTH_PASSWORD_REQUIRED:String = "NeedPassword";
        public static const INDIGO_PACKET_AUTH_PASSWORD_FAILED:String = "PasswordFailed";
        public static const INDIGO_PACKET_AUTH_IP_FAILED:String = "IPFailed";
        public static const INDIGO_PACKET_AUTH_SUCCESS:String = "Success";


        // Indigo Request Packet Names
        public static const INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP:String = "GetActionGroupList";
        public static const INDIGO_PACKET_REQUEST_LIST_DEVICE:String = "GetDeviceList";
        public static const INDIGO_PACKET_REQUEST_LIST_SCHEDULE:String = "GetEventScheduleList";
        public static const INDIGO_PACKET_REQUEST_LIST_TRIGGER:String = "GetEventTriggerList";
        public static const INDIGO_PACKET_REQUEST_LIST_VARIABLE:String = "GetVariableList";


        // Indigo Broadcast Packet Names
        public static const INDIGO_PACKET_BROADCAST_UPDATED_REG_INFO:String = "UpdatedRegInfo";
        public static const INDIGO_PACKET_BROADCAST_UPDATED_TIME_INFO:String = "UpdatedTimeInfo";
        public static const INDIGO_PACKET_BROADCAST_LOG_STREAM:String = "LogStream";

        public static const INDIGO_PACKET_BROADCAST_ADDED_DEVICE:String = "AddedDevice";
        public static const INDIGO_PACKET_BROADCAST_ADDED_TRIGGER:String = "AddedEventTrigger";
        public static const INDIGO_PACKET_BROADCAST_ADDED_SCHEDULE:String = "AddedEventSchedule";
        public static const INDIGO_PACKET_BROADCAST_ADDED_ACTION_GROUP:String = "AddedActionGroup";
        public static const INDIGO_PACKET_BROADCAST_ADDED_VARIABLE:String = "AddedVariable";

        public static const INDIGO_PACKET_BROADCAST_REMOVED_DEVICE:String = "RemovedDevice";
        public static const INDIGO_PACKET_BROADCAST_REMOVED_TRIGGER:String = "RemovedEventTrigger";
        public static const INDIGO_PACKET_BROADCAST_REMOVED_SCHEDULE:String = "RemovedEventSchedule";
        public static const INDIGO_PACKET_BROADCAST_REMOVED_ACTION_GROUP:String = "RemovedActionGroup";
        public static const INDIGO_PACKET_BROADCAST_REMOVED_VARIABLE:String = "RemovedVariable";

        public static const INDIGO_PACKET_BROADCAST_REPLACED_DEVICE:String = "ReplacedDevice";
        public static const INDIGO_PACKET_BROADCAST_REPLACED_TRIGGER:String = "ReplacedEventTrigger";
        public static const INDIGO_PACKET_BROADCAST_REPLACED_SCHEDULE:String = "ReplacedEventSchedule";
        public static const INDIGO_PACKET_BROADCAST_REPLACED_ACTION_GROUP:String = "ReplacedActionGroup";
        public static const INDIGO_PACKET_BROADCAST_REPLACED_VARIABLE:String = "ReplacedVariable";


        // Indigo Server Commands
        // Subscribe Command
        public static const INDIGO_COMMAND_SUBSCRIBE_TO_BROADCASTS:String = "SubscribeToServerBroadcasts";
        // Execute Action Group Command
        public static const INDIGO_COMMAND_ACTIONGROUP_EXECUTE:String = "ExecuteActionGroup";

        // On Off Device commands
        public static const INDIGO_COMMAND_DEVICE_ONOFF_TURN_ON:String = "TurnOn";
        public static const INDIGO_COMMAND_DEVICE_ONOFF_TURN_OFF:String = "TurnOff";

        // Dimmer Device commands
        public static const INDIGO_COMMAND_DEVICE_DIMMER_SET_BRIGHTNESS:String = "SetBrightness";
        public static const INDIGO_COMMAND_DEVICE_DIMMER_DIM:String = "Dim";
        public static const INDIGO_COMMAND_DEVICE_DIMMER_BRIGHTEN:String = "Brighten";

        // Thermostat Device commands
        public static const INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_HEAT_POINT:String = "SetHeatPoint";
        public static const INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_COOL_POINT:String = "SetCoolPoint";

        // Variable Commands
        public static const INDIGO_COMMAND_VARIABLE_SET_VALUE:String = "SetVariableValue";
    }
}
