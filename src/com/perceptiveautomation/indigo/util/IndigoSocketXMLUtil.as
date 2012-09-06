/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 8/12/12
 * Time: 9:20 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.util
{
    import com.perceptiveautomation.indigo.constants.IndigoSocketConstants;

    import mx.collections.XMLListCollection;

    public class IndigoSocketXMLUtil
    {
        public function IndigoSocketXMLUtil()
        {
        }

        public static function addItem(packetData:XMLList, listCache:XML, node:String):XML
        {
            var listTemp:XMLListCollection;

            packetData.setLocalName(node);
            listCache..appendChild(packetData);
            listTemp = new XMLListCollection(listCache[node]);
            listCache = XML('<Data type="dict">' + listTemp.toXMLString() + '</Data>');
            return listCache;
        }

        public static function removeItem(packetData:XMLList, listCache:XML, node:String):XML
        {
            var listTemp:XMLListCollection;

            for (var i:int=0; i < listCache[node].length(); i++){
                if (listCache[node].Name[i].text() == packetData.text()) {
                    delete listCache[node][i];
                }
            }
            listTemp = new XMLListCollection(listCache[node]);
            listCache = XML('<Data type="dict">' + listTemp.toXMLString() + '</Data>');
            return listCache;
        }

        public static function createAuthenticatePasswordPacket(user:String, password:String):XML
        {
            var authenticatePacket:XML;

            authenticatePacket = <Packet />;
            authenticatePacket.@type = 'dict';
            authenticatePacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_AUTHENTICATE;
            authenticatePacket.Type.@type = 'string';
            authenticatePacket.Name = IndigoSocketConstants.INDIGO_PACKET_AUTH_ATTEMPT_AUTHENTICATION;
            authenticatePacket.Name.@type = 'string';
            authenticatePacket.Data;
            authenticatePacket.Data.@type = 'dict';
            authenticatePacket.Data.UserName = user;
            authenticatePacket.Data.UserName.@type = 'string';
            authenticatePacket.Data.PasswordHash = password;
            authenticatePacket.Data.PasswordHash.@type = 'string';

            return authenticatePacket;
        }

        public static function createAuthenticateKnockPacket():XML
        {
            var authenticatePacket:XML;

            authenticatePacket = <Packet />;
            authenticatePacket.@type = 'dict';
            authenticatePacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_AUTHENTICATE;
            authenticatePacket.Type.@type = 'string';
            authenticatePacket.Name = IndigoSocketConstants.INDIGO_PACKET_AUTH_KNOCK_KNOCK;
            authenticatePacket.Name.@type = 'string';
            authenticatePacket.Data;
            authenticatePacket.Data.@type = 'dict';
            authenticatePacket.Data.ClientType = '2';
            authenticatePacket.Data.ClientType.@type = 'string';
            authenticatePacket.Data.DoBroadcasts = 'true';
            authenticatePacket.Data.DoBroadcasts.@type = 'string';

            return authenticatePacket;
        }

        public static function createActionGroupCommandPacket(name:String):XML
        {
            var commandPacket:XML;

            commandPacket = <Packet />;
            commandPacket.@type = 'dict';
            commandPacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_COMMAND;
            commandPacket.Type.@type = 'string';
            commandPacket.Target = IndigoSocketConstants.INDIGO_PACKET_TARGET_SERVER;
            commandPacket.Target.@type = 'string';
            commandPacket.Name = IndigoSocketConstants.INDIGO_COMMAND_ACTIONGROUP_EXECUTE;
            commandPacket.Name.@type = 'string';
            commandPacket.Data.@type = 'dict';
            commandPacket.Data.Name = name;
            commandPacket.Data.Name.@type = 'string';

            return commandPacket;

        }

        public static function createDeviceCommandPacket(name:String, command:String, value:String):XML
        {
            var commandPacket:XML;

            commandPacket = <Packet />;
            commandPacket.@type = 'dict';
            commandPacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_COMMAND;
            commandPacket.Type.@type = 'string';
            commandPacket.Name = command;
            commandPacket.Name.@type = 'string';
            commandPacket.Data.@type = 'dict';
            commandPacket.Data.Name = name;
            commandPacket.Data.Name.@type = 'string';

            if(command == 'SetBrightness')// || command == 'Dim' || command == 'Brighten')
            {

                commandPacket.Data.Amount = value;
                commandPacket.Data.Amount.@type = 'string';
            }

            return commandPacket;
        }

        public static function createRequestObjectListPacket(listType:String):XML
        {
            // Create Request Packet for list of data
            var getListPacket:XML;
            // Create the get list packet type in XML format.

            getListPacket = <Packet />;
            getListPacket.@type = 'dict';
            getListPacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_REQUEST;
            getListPacket.Type.@type = 'string';
            getListPacket.Name = listType;
            getListPacket.Name.@type = 'string';
            return getListPacket;
        }

        public static function createSubscribeCommandPacket():XML
        {
            // Create and send a command packet to the Indigo server
            var commandPacket:XML;

            commandPacket = <Packet />;
            commandPacket.@type = 'dict';
            commandPacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_COMMAND;
            commandPacket.Type.@type = 'string';
            commandPacket.Target = IndigoSocketConstants.INDIGO_PACKET_TARGET_SERVER;
            commandPacket.Target.@type = 'string';
            commandPacket.Name = IndigoSocketConstants.INDIGO_COMMAND_SUBSCRIBE_TO_BROADCASTS;
            commandPacket.Name.@type = 'string';

            // The set of "channels" to subscribe to
            commandPacket.Data = new XMLList(<Data type='vector'/>);

            commandPacket.Data.appendChild(<Name type="string">AddedDevice</Name>);
            commandPacket.Data.appendChild(<Name type="string">RemovedDevice</Name>);
            commandPacket.Data.appendChild(<Name type="string">ReplacedDevice</Name>);
            commandPacket.Data.appendChild(<Name type="string">AddedTrigger</Name>);
            commandPacket.Data.appendChild(<Name type="string">RemovedTrigger</Name>);
            commandPacket.Data.appendChild(<Name type="string">ReplacedTrigger</Name>);
            commandPacket.Data.appendChild(<Name type="string">AddedTDTrigger</Name>);
            commandPacket.Data.appendChild(<Name type="string">RemovedTDTrigger</Name>);
            commandPacket.Data.appendChild(<Name type="string">ReplacedTDTrigger</Name>);
            commandPacket.Data.appendChild(<Name type="string">AddedVariable</Name>);
            commandPacket.Data.appendChild(<Name type="string">RemovedVariable</Name>);
            commandPacket.Data.appendChild(<Name type="string">ReplacedVariable</Name>);
            commandPacket.Data.appendChild(<Name type="string">LogStream</Name>);

            return commandPacket;
        }

        public static function createVariableCommandPacket(name:String, value:String):XML
        {
            var commandPacket:XML;

            commandPacket = <Packet />;
            commandPacket.@type = 'dict';
            commandPacket.Type = IndigoSocketConstants.INDIGO_PACKET_TYPE_COMMAND;
            commandPacket.Type.@type = 'string';
            commandPacket.Target = IndigoSocketConstants.INDIGO_PACKET_TARGET_SERVER;
            commandPacket.Target.@type = 'string';
            commandPacket.Name = IndigoSocketConstants.INDIGO_COMMAND_VARIABLE_SET_VALUE;
            commandPacket.Name.@type = 'string';
            commandPacket.Data.@type = 'dict';
            commandPacket.Data.Name = name;
            commandPacket.Data.Name.@type = 'string';
            commandPacket.Data.Value = value;
            commandPacket.Data.Value.@type = "string";

            return commandPacket;

        }




    }
}
