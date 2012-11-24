package com.perceptiveautomation.indigo.services
{
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.constants.IndigoAPIMode;
    import com.perceptiveautomation.indigo.constants.IndigoRestConstants;
    import com.perceptiveautomation.indigo.constants.IndigoSocketConstants;
    import com.perceptiveautomation.indigo.device.IIndigoDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDimmerDevice;
    import com.perceptiveautomation.indigo.device.IIndigoOnOffDevice;
    import com.perceptiveautomation.indigo.device.IIndigoThermostatDevice;
    import com.perceptiveautomation.indigo.events.IndigoActionGroupChangeEvent;
    import com.perceptiveautomation.indigo.events.IndigoDeviceChangeEvent;
    import com.perceptiveautomation.indigo.events.IndigoScheduleChangeEvent;
    import com.perceptiveautomation.indigo.events.IndigoTriggerChangeEvent;
    import com.perceptiveautomation.indigo.events.IndigoVariableChangeEvent;
    import com.perceptiveautomation.indigo.model.IndigoModel;
    import com.perceptiveautomation.indigo.schedule.IIndigoSchedule;
    import com.perceptiveautomation.indigo.trigger.IIndigoTrigger;
    import com.perceptiveautomation.indigo.util.HashUtil;
    import com.perceptiveautomation.indigo.util.IndigoObjectUtil;
    import com.perceptiveautomation.indigo.util.IndigoSocketXMLUtil;
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;

    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.XMLSocket;

    import mx.rpc.events.FaultEvent;
    import mx.utils.StringUtil;

    public class IndigoService extends EventDispatcher
	{
        private var _model:IndigoModel = IndigoModel.getInstance();

        private var _apiMode:String = IndigoAPIMode.INDIGO_API_MODE_SOCKET;
        private var _indigoSocket:XMLSocket;
        private var _indigoUrlLoader:URLLoader;

		//Constructor
		public function IndigoService()
		{
			//
		}

        /************************************************************************************/
        // INDIGO OBJECT MANAGEMENT FUNCTIONS
        /***********************************************************************************/
        protected function addAllActionGroupListeners():void
        {
            const len:int = this._model.actionGroupList.length;
            var tempActionGroup:IIndigoActionGroup;
            for (var i:int = 0; i < len; i++)
            {
                tempActionGroup = this._model.actionGroupList.getItemAt(i) as IIndigoActionGroup;
                addActionGroupListeners(tempActionGroup);
            }
        }

        protected function removeAllActionGroupListeners():void
        {
            const len:int = this._model.actionGroupList.length;
            var tempActionGroup:IIndigoActionGroup;
            for (var i:int = 0; i < len; i++)
            {
                tempActionGroup = this._model.actionGroupList.getItemAt(i) as IIndigoActionGroup;
                removeActionGroupListeners(tempActionGroup);
            }
        }

        protected function addActionGroupListeners(actionGroup:IIndigoActionGroup):void
        {
            actionGroup.addEventListener("runNow", handleActionGroupRunNow);
        }

        protected function removeActionGroupListeners(actionGroup:IIndigoActionGroup):void
        {
            actionGroup.removeEventListener("runNow", handleActionGroupRunNow);
        }


        protected function addAllDeviceListeners():void
        {
            const len:int = this._model.deviceList.length;
            var tempDevice:IIndigoDevice;
            for (var i:int = 0; i < len; i++)
            {
                tempDevice = this._model.deviceList.getItemAt(i) as IIndigoDevice;
                addDeviceListeners(tempDevice);
            }
        }

        protected function removeAllDeviceListeners():void
        {
            const len:int = this._model.deviceList.length;
            var tempDevice:IIndigoDevice;
            for (var i:int = 0; i < len; i++)
            {
                tempDevice = this._model.deviceList.getItemAt(i) as IIndigoDevice;
                removeDeviceListeners(tempDevice);
            }
        }

        protected function addDeviceListeners(device:IIndigoDevice):void
        {
            device.addEventListener("isOnChanged", handleDeviceIsOnChange);
            device.addEventListener("brightnessChanged", handleDeviceBrightnessChange);
        }

        protected function removeDeviceListeners(device:IIndigoDevice):void
        {
            device.removeEventListener("isOnChanged", handleDeviceIsOnChange);
            device.removeEventListener("brightnessChanged", handleDeviceBrightnessChange);
        }


        protected function addAllScheduleListeners():void
        {
            const len:int = this._model.scheduleList.length;
            var tempSchedule:IIndigoSchedule;
            for (var i:int = 0; i < len; i++)
            {
                tempSchedule = this._model.scheduleList.getItemAt(i) as IIndigoSchedule;
                addScheduleListeners(tempSchedule);
            }
        }

        protected function removeAllScheduleListeners():void
        {
            const len:int = this._model.scheduleList.length;
            var tempSchedule:IIndigoSchedule;
            for (var i:int = 0; i < len; i++)
            {
                tempSchedule = this._model.scheduleList.getItemAt(i) as IIndigoSchedule;
                removeScheduleListeners(tempSchedule);
            }
        }

        protected function addScheduleListeners(schedule:IIndigoSchedule):void
        {
        }

        protected function removeScheduleListeners(schedule:IIndigoSchedule):void
        {
        }


        protected function addAllTriggerListeners():void
        {
            // There are no trigger listeners currently
//            const len:int = this._model.triggerList.length;
//            var tempTrigger:IIndigoTrigger;
//            for (var i:int = 0; i < len; i++)
//            {
//                tempTrigger = this._model.triggerList.getItemAt(i) as IIndigoTrigger;
//                addTriggerListeners(tempTrigger);
//            }
        }

        protected function removeAllTriggerListeners():void
        {
            // There are no trigger listeners currently
//            const len:int = this._model.triggerList.length;
//            var tempTrigger:IIndigoTrigger;
//            for (var i:int = 0; i < len; i++)
//            {
//                tempTrigger = this._model.triggerList.getItemAt(i) as IIndigoTrigger;
//                removeTriggerListeners(tempTrigger);
//            }
        }

        protected function addTriggerListeners(trigger:IIndigoTrigger):void
        {
        }

        protected function removeTriggerListeners(trigger:IIndigoTrigger):void
        {
        }


        protected function addAllVariableListeners():void
        {
            const len:int = this._model.variableList.length;
            var tempVariable:IIndigoVariable;
            for (var i:int = 0; i < len; i++)
            {
                tempVariable = this._model.variableList.getItemAt(i) as IIndigoVariable;
                addVariableListeners(tempVariable);
            }
        }

        protected function removeAllVariableListeners():void
        {
            const len:int = this._model.variableList.length;
            var tempVariable:IIndigoVariable;
            for (var i:int = 0; i < len; i++)
            {
                tempVariable = this._model.variableList.getItemAt(i) as IIndigoVariable;
                removeVariableListeners(tempVariable);
            }
        }

        protected function addVariableListeners(variable:IIndigoVariable):void
        {
            variable.addEventListener("valueChanged", handleVariableValueChange);
        }

        protected function removeVariableListeners(variable:IIndigoVariable):void
        {
            variable.removeEventListener("valueChanged", handleVariableValueChange);
        }

        /************************************************************************************/
        // Internal Indigo Object Operation handlers for Managed Objects
        /***********************************************************************************/
        protected function handleDeviceBrightnessChange(event:Event):void
        {
            if (event.target is IIndigoDimmerDevice)
            {
                setBrightness(event.target as IIndigoDimmerDevice)
            }
        }

        protected function handleDeviceIsOnChange(event:Event):void
        {
            if (event.target is IIndigoOnOffDevice)
            {
                if ( IIndigoOnOffDevice(event.target).isOn )
                {
                    turnOn(event.target as IIndigoOnOffDevice);
                }
                else
                {
                    turnOff(event.target as IIndigoOnOffDevice);
                }
            }
        }

        protected function handleActionGroupRunNow(event:Event):void
        {
            if (event.target is IIndigoActionGroup)
            {
                runNow(event.target as IIndigoActionGroup);
            }
        }

        protected function handleVariableValueChange(event:Event):void
        {
            if (event.target is IIndigoVariable)
            {
                setVariableValue(event.target as IIndigoVariable);
            }
        }



		/*************************************************************************/
		// PUBLIC API
		/*************************************************************************/

        // Getters and Setters
        public function get apiMode():String {
            return _apiMode;
        }

        public function set apiMode(value:String):void {
            _apiMode = value;
        }

		// CONNECTION FUNCTION
		public function connect(host:String="127.0.0.1", port:String="1176", username:String="", password:String=""):void
		{
            this._model.username = username
            this._model.password = password;
            this._model.host = host;
            this._model.port = parseInt(port);

            if (apiMode == IndigoAPIMode.INDIGO_API_MODE_SOCKET)
            {
                this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_CONNECTING;
                connectSocket(this._model.host, this._model.port);
            }
            else if (apiMode == IndigoAPIMode.INDIGO_API_MODE_RESTFUL)
            {
                this._model.indigoState = IndigoRestConstants.INDIGO_REST_STATE_CONNECTING;
                connectUrl();
            }
	    }

        // PUBLIC COMMANDS
        public function subscribeToBroadcasts():void
        {
            sendSubscribeCommandPacket();
        }

        public function runNow(actionGroup:IIndigoActionGroup):void
        {
            sendActionGroupCommandPacket(actionGroup.name);
        }

        public function turnOn(device:IIndigoOnOffDevice):void
        {
            sendDeviceCommandPacket(device.name, IndigoSocketConstants.INDIGO_COMMAND_DEVICE_ONOFF_TURN_ON, 100);
        }

        public function turnOff(device:IIndigoOnOffDevice):void
        {
            sendDeviceCommandPacket(device.name, IndigoSocketConstants.INDIGO_COMMAND_DEVICE_ONOFF_TURN_OFF, 0);
        }

        public function setBrightness(device:IIndigoDimmerDevice):void
        {
            sendDeviceCommandPacket(device.name, IndigoSocketConstants.INDIGO_COMMAND_DEVICE_DIMMER_SET_BRIGHTNESS, device.brightness);
        }

        public function setVariableValue(variable:IIndigoVariable):void
        {
            sendVariableCommandPacket(variable.name, variable.value.toString())
        }

        public function setHeatPoint(device:IIndigoThermostatDevice):void
        {
            sendDeviceCommandPacket(device.name, IndigoSocketConstants.INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_HEAT_POINT, device.heatPoint);
        }

        public function setCoolPoint(device:IIndigoThermostatDevice):void
        {
            sendDeviceCommandPacket(device.name, IndigoSocketConstants.INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_COOL_POINT, device.coolPoint);
        }

        // REFRESH COMMANDS
        public function refreshDevices():void
        {
            if (_apiMode == IndigoAPIMode.INDIGO_API_MODE_SOCKET)
            {
                outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE));
            }
            else if (_apiMode == IndigoAPIMode.INDIGO_API_MODE_RESTFUL)
            {
                sendUrlRequest(IndigoRestConstants.INDIGO_REST_ENDPOINT_DEVICES);
            }
        }

        public function refreshActionGroups():void
        {
            if (_apiMode == IndigoAPIMode.INDIGO_API_MODE_SOCKET)
            {
                outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP));
            }
            else if (_apiMode == IndigoAPIMode.INDIGO_API_MODE_RESTFUL)
            {
                sendUrlRequest(IndigoRestConstants.INDIGO_REST_ENDPOINT_ACTION_GROUPS);
            }
        }

        public function refreshVariables():void
        {
            if (_apiMode == IndigoAPIMode.INDIGO_API_MODE_SOCKET)
            {
                outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE));
            }
            else if (_apiMode == IndigoAPIMode.INDIGO_API_MODE_RESTFUL)
            {
                sendUrlRequest(IndigoRestConstants.INDIGO_REST_ENDPOINT_VARIABLES);
            }
        }

        public function refreshTriggers():void
        {
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER));
        }

        public function refreshSchedules():void
        {
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE));
        }

        public function removeAllActionGroups():void
        {
            removeAllActionGroupListeners();

            this._model.actionGroupList.removeAll();

            addAllActionGroupListeners();
        }

        public function removeAllDevices():void
        {
            removeAllDeviceListeners();

            this._model.deviceList.removeAll();

            addAllDeviceListeners();
        }

        public function removeAllSchedules():void
        {
            removeAllScheduleListeners();

            this._model.scheduleList.removeAll();

            addAllScheduleListeners();
        }

        public function removeAllTriggers():void
        {
            removeAllTriggerListeners();

            this._model.triggerList.removeAll();

            addAllTriggerListeners();
        }

        public function removeAllVariables():void
        {
            removeAllVariableListeners();

            this._model.variableList.removeAll();

            addAllVariableListeners();
        }


        /*************************************************************************/
        // SOCKET API FUNCTIONS
        /*************************************************************************/
        protected function connectSocket(host:String, port:int):void
        {
            if (this._indigoSocket != null)
            {
                removeSocketListeners();
            }

            this._indigoSocket = new XMLSocket();

            addSocketListeners();

            this._indigoSocket.connect(this._model.host, this._model.port);
        }

        /************************************************************************************/
        // INDIGO EVENT LISTENERS for Socket API
        /***********************************************************************************/
        protected function addSocketListeners():void
        {
            // Configure event listeners to handle responses from the server.

            _indigoSocket.addEventListener(Event.CLOSE, connectClosedHandler);
            _indigoSocket.addEventListener(Event.CONNECT, connectCompleteHandler);
            _indigoSocket.addEventListener(DataEvent.DATA, incomingPacketHandler);
            _indigoSocket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _indigoSocket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            _indigoSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }

        protected function removeSocketListeners():void
        {
            // Configure event listeners to handle responses from the server.

            _indigoSocket.removeEventListener(Event.CLOSE, connectClosedHandler);
            _indigoSocket.removeEventListener(Event.CONNECT, connectCompleteHandler);
            _indigoSocket.removeEventListener(DataEvent.DATA, incomingPacketHandler);
            _indigoSocket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _indigoSocket.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            _indigoSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }

        protected function connectCompleteHandler(event:Event):void
        {
            sendAuthenticateKnock();
        }

        protected function connectClosedHandler(event:Event):void
        {
            this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
        }

        protected function ioErrorHandler(event:IOErrorEvent):void
        {
            // TODO: Try to determine what the error was and return a more specific state constant
            this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
            trace(event.toString());
        }

        protected function securityErrorHandler(event:SecurityErrorEvent):void
        {
            // TODO: Try to determine what the error was and return a more specific state constant
            this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
            trace(event.toString());
        }

        protected function progressHandler(event:ProgressEvent):void
        {
            // TODO: Try to determine progress data
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }


        /*************************************************************************/
        // OUTGOING SOCKET COMMANDS/PACKETS
        /*************************************************************************/
        // SUBSCRIBE COMMAND
        protected function sendSubscribeCommandPacket():void
        {
            // Create and send a command packet to the Indigo server
            outgoingPacketHandler(IndigoSocketXMLUtil.createSubscribeCommandPacket());
        }

        // ACTION GROUP COMMAND
        protected function sendActionGroupCommandPacket(name:String):void
        {
            // Create and send a command packet to the Indigo server
            outgoingPacketHandler(IndigoSocketXMLUtil.createActionGroupCommandPacket(name));
        }

        // DEVICE COMMAND
        protected function sendDeviceCommandPacket(name:String, command:String, value:*):void
        {
            // Create and send a command packet to the Indigo server
            outgoingPacketHandler(IndigoSocketXMLUtil.createDeviceCommandPacket(name, command, value));
        }

        // VARIABLE COMMAND
        protected function sendVariableCommandPacket(name:String, value:String):void
        {
            // Create and send a command packet to the Indigo server
            outgoingPacketHandler(IndigoSocketXMLUtil.createVariableCommandPacket(name, value));
        }

        // AUTHENTICATION KNOCK KNOCK COMMAND
        protected function sendAuthenticateKnock():void
        {
	   		// Create and send an AuthenticateKnock packet
	     	outgoingPacketHandler(IndigoSocketXMLUtil.createAuthenticateKnockPacket());
	  	}

        // AUTHENTICATION PASSWORD COMMAND
        protected function sendAuthenticatePassword(rawUser:String, rawPassword:String, hashPassword:String):void
	  	{
			// Create an instance of the HashUtil class.
			var crypt:Object = new HashUtil();

			// Stores the hashed password concat with the salt from the server
			var hashPasswordWithSalt:String;

			// Stores the final hash of the raw password.
			var totalHash:String

			// First, calculate the hash of the password by itself:
			if (hashPassword == null)
            {
				hashPassword = crypt.hex_sha1(rawUser + ":Indigo Control Server:" + rawPassword);
			}

	 		// Then add the salt from the server onto it:
			hashPasswordWithSalt = hashPassword + this._model.serverSalt;

			// And re-hash everything again:
			totalHash = crypt.hex_sha1(hashPasswordWithSalt);

            // Create the authenticate packet type in XML format.
            const authenticatePacket:XML = IndigoSocketXMLUtil.createAuthenticatePasswordPacket(rawUser, totalHash);

            outgoingPacketHandler(authenticatePacket);
		}

        /************************************************************************************/
        // REQUEST INDIGO OBJECTS
        /***********************************************************************************/
        protected function requestIndigoObjectLists():void
        {
            // Request all data lists
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP));
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE));
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER));
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE));
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE));
        }

        /************************************************************************************/
        // PACKET PUSHER (FOR OUTGOING PACKETS)
        /***********************************************************************************/
        protected function outgoingPacketHandler(packet:XML):void
        {
            // Format the packet before being sent to the server.
            var formattedPacket:String = '';
            var packetString:String = packet.toString();
            var packetArray:Array = packetString.split("\n");

            for (var i:int = 0; i < packetArray.length; i++)
            {
                formattedPacket = formattedPacket + StringUtil.trim(packetArray[i]);
            }

            this._model.packetStreamOutgoing += packet + '\n';
            this._indigoSocket.send(formattedPacket);
        }

        /************************************************************************************/
        // INDIGO SOCKET PACKET HANDLERS (FOR RECEIVED SOCKET PACKETS)
        /***********************************************************************************/
        protected function incomingPacketHandler(event:DataEvent):void
        {
            // Handle the different packet types returned by the server.

            //Store the entire response packet from the server.
            const responsePacket:XML = new XML(event.data);

            const packetType:String = responsePacket.Type.toString();

            const packetName:String = responsePacket.Name.toString();
            const packetData:XMLList = responsePacket.descendants("Data");


            this._model.packetStreamIncoming += responsePacket + '\n';

            if (packetType == IndigoSocketConstants.INDIGO_PACKET_TYPE_AUTHENTICATE)
            {
                handleAuthenticatePacket(packetName, packetData);
            }

            if (packetType == IndigoSocketConstants.INDIGO_PACKET_TYPE_BROADCAST)
            {
                handleBroadcastPacket(packetName, packetData);
            }

            if (packetType == IndigoSocketConstants.INDIGO_PACKET_TYPE_RESPONSE)
            {
                handleResponsePacket(packetName, packetData);
            }
        }

        protected function handleAuthenticatePacket(packetName:String, packetData:XMLList):void
        {
            /* Handle the authentication process.
             */

            // Capture socket connection state in the model
            //this._model.indigoState = packetName;

            if (packetName == IndigoSocketConstants.INDIGO_PACKET_AUTH_IP_FAILED)
            {
                // Indigo Server is not allowing this IP address.
                // Indigo Server will issue disconnect.
                this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_AUTH_PASSWORD_FAILED)
            {
                // Password was incorrect.
                // Re-enter credentials and try again.
                // Re-use the salt originally passed to us by the "NeedPassword" packet.
                this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_CONNECTING;
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_AUTH_PASSWORD_REQUIRED)
            {
                this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_CONNECTING;

                this._model.serverSalt = packetData.toString();

                // saltFromServer = packetData.toString();
                // Store saltFromServer
                // Concat this on to the user's raw password
                // Crypto-hash the composite string.
                if (this._model.username != "" && this._model.authHash != "")
                {
                    // The Indigo web server was nice enough to give us the
                    // user name and password hash since we already authenticated
                    // against it. We can directly connect without prompting
                    // the user.
                    sendAuthenticatePassword(this._model.username, null , this._model.authHash);
                }
                else if (this._model.username != "" && this._model.password != "")
                {
                    // If we didn't get the connection info from Indigo but
                    // instead from the login form. Pass the raw information to
                    // the encryption function.
                    sendAuthenticatePassword(this._model.username, this._model.password , null);
                }
                else
                {
                    // Need to get login information from user
                    this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
                }
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_AUTH_SUCCESS)
            {
                this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_CONNECTED;
                this._model.logStream += "Client authenticated" + "\n";

                // Subscribe to Broadcasts
                subscribeToBroadcasts();

                // Request Managed Indigo Object Lists
                requestIndigoObjectLists();
            }
        }

        protected function handleBroadcastPacket(packetName:String, packetData:XMLList):void
        {
            /* Handle broadcast packets from the server	*/

            if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_UPDATED_REG_INFO)
            {
                // Handle "UpdatedRegInfo" packet.
                // Not used. Add code here if
                // needed.

            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_UPDATED_TIME_INFO)
            {
                _model.updateTimeInfo = packetData[0].CurrentTime;
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_LOG_STREAM)
            {
                this._model.logStream += packetData.Message + "\n";

                // Handle adding a
                // "LogStream" item. Append the
                // packetData in the
                // 'Message' element to
                // "Application.application.gLogStream"
                // and sort the data by 'TimeCount'.
                // ------------------------
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_ADDED_DEVICE)
            {
                //Application.application.gDeviceListCache = addItem(packetData, Application.application.gDeviceListCache, 'Device', 'Name');

                // Handle adding a
                // "DeviceListCache" item. Add
                // the packetData in the
                // 'Device' element to
                // "Application.application.gDeviceListCache"
                // and sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_ADDED_TRIGGER)
            {
                //Application.application.gTriggerListCache = addItem(packetData, Application.application.gTriggerListCache, 'Trigger', 'Name');

                // Handle adding a
                // "TriggerListCache" item. Add
                // the packetData in the
                // 'Trigger' element to
                // "Application.application.gTriggerListCache"
                // and sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_ADDED_SCHEDULE)
            {
                //Application.application.gTDTriggerListCache = addItem(packetData, Application.application.gTDTriggerListCache, 'TDTrigger', 'Name');

                // Handle adding a
                // "TDTriggerListCache" item. Add
                // the packetData in the
                // 'TDTrigger' element to
                // "Application.application.gTDTriggerListCache"
                // and sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_ADDED_ACTION_GROUP)
            {
                //Application.application.gActionGroupListCache = addItem(packetData, Application.application.gActionGroupListCache, 'ActionGroup', 'Name');

                // Handle adding a
                // "ActionGroupListCache" item. Add
                // the packetData in the
                // 'ActionGroup' element to
                // "Application.application.gActionGroupListCache"
                // and sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_ADDED_VARIABLE)
            {
                //Application.application.gVariableListCache = addItem(packetData, Application.application.gVariableListCache, 'Variable', 'Name');

                // Handle adding a
                // "VariableListCache" item. Add
                // the packetData in the
                // 'Variable' element to
                // "Application.application.gVariableListCache"
                // and sort by 'Name'.
                // ------------------------
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REMOVED_DEVICE)
            {
                //Application.application.gDeviceListCache = removeItem(packetData, Application.application.gDeviceListCache, 'Device', 'Name');

                // Handle removing a
                // "DeviceListCache" item.
                // Remove the packetData in the
                // 'Device' element from
                // 'Application.application.gDeviceListCache' and
                // sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REMOVED_TRIGGER)
            {
                //Application.application.gTriggerListCache = removeItem(packetData, Application.application.gTriggerListCache, 'Trigger', 'Name');

                // Handle removing a
                // "TriggerListCache" item.
                // Remove the packetData in the
                // 'Trigger' element from
                // 'Application.application.gTriggerListCache' and
                // sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REMOVED_SCHEDULE)
            {
                //Application.application.gTDTriggerListCache = removeItem(packetData, Application.application.gTDTriggerListCache, 'TDTrigger', 'Name');

                // Handle removing a
                // "TDTriggerListCache" item.
                // Remove the packetData in the
                // 'TDTrigger' element from
                // 'Application.application.gTDTriggerListCache' and
                // sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REMOVED_ACTION_GROUP)
            {
                //Application.application.gActionGroupListCache = removeItem(packetData, Application.application.gActionGroupListCache, 'ActionGroup', 'Name');

                // Handle removing a
                // "ActionGroupListCache"
                // item. Remove the packetData in
                // the 'ActionGroup' element from
                // 'Application.application.gActionGroupListCache' and
                // sort by 'Name'.
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REMOVED_VARIABLE)
            {
                //Application.application.gVariableListCache = removeItem(packetData, Application.application.gVariableListCache, 'Variable', 'Name');			// Handle removing a

                // "VariableListCache"
                // item. Remove the packetData in
                // the 'Variable' element from
                // 'gApplication.application.gVariableListCache' and
                // sort by 'Name'.
                // ------------------------
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_ACTION_GROUP)
            {
                addOrReplaceActionGroupFromXML(packetData.ActionGroup as XML);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_DEVICE)
            {
                addOrReplaceDeviceFromXML(packetData.Device as XML);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_SCHEDULE)
            {
                addOrReplaceScheduleFromXML(packetData.Schedule as XML);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_TRIGGER)
            {
                addOrReplaceTriggerFromXML(packetData.Trigger as XML);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_VARIABLE)
            {
                addOrReplaceVariableFromXML(packetData.Variable as XML);
            }
        }

        protected function handleResponsePacket(packetName:String, packetData:XMLList):void
        {
            // Handle Response Packets for requested lists of data

            if (packetName == IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE)
            {
                rebuildAllDevicesFromXML(packetData);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP)
            {
                this._model.actionGroupList = IndigoObjectUtil.createActionGroupList(packetData);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE)
            {
                this._model.variableList = IndigoObjectUtil.createVariableList(packetData);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER)
            {
                this._model.triggerList = IndigoObjectUtil.createTriggerList(packetData);
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE)
            {
                this._model.scheduleList = IndigoObjectUtil.createScheduleList(packetData);
            }
        }




        /************************************************************************************/
        // RESTful API FUNCTIONS
        /***********************************************************************************/
        protected function connectUrl():void
        {
            sendUrlRequest(IndigoRestConstants.INDIGO_REST_ENDPOINT_ACTION_GROUPS);
            sendUrlRequest(IndigoRestConstants.INDIGO_REST_ENDPOINT_DEVICES);
            sendUrlRequest(IndigoRestConstants.INDIGO_REST_ENDPOINT_VARIABLES);
            // No endpoints for these two as of yet, boo :-(
//            sendUrlRequest(_model.host+":"+_model.port, IndigoRestConstants.INDIGO_REST_ENDPOINT_SCHEDULES);
//            sendUrlRequest(_model.host+":"+_model.port, IndigoRestConstants.INDIGO_REST_ENDPOINT_TRIGGERS);
        }

        protected function sendUrlRequest(resource:String):void
        {

            var fullUrl:String = _model.host;
            if (_model.port >= 0 && _model.port != 80)
            {
                fullUrl += ":" + _model.port;
            }

            var request: URLRequest = new URLRequest(fullUrl + resource);
            request.method = "GET";
            request.contentType = "application/xml";

            _indigoUrlLoader = new URLLoader(request);
            _indigoUrlLoader.dataFormat = "xml";
            _indigoUrlLoader.load(request);
            this._model.packetStreamOutgoing += request.url + '\n';
            addRestListeners();
        }

        protected function addRestListeners():void
        {
            _indigoUrlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, handleRestStatusCode);
            _indigoUrlLoader.addEventListener(Event.COMPLETE, handleRestResult);
            _indigoUrlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleRESTFault);
            _indigoUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleRESTFault);
        }

        protected function removeRestListeners():void
        {
            _indigoUrlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, handleRestStatusCode);
            _indigoUrlLoader.removeEventListener(Event.COMPLETE, handleRestResult);
            _indigoUrlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleRESTFault);
            _indigoUrlLoader.removeEventListener(IOErrorEvent.IO_ERROR, handleRESTFault);
        }

        protected function handleRestStatusCode(event:Event):void
        {

        }

        protected function handleRestResult(resultEvent:Event):void
        {
            var result:XML = new XML(resultEvent.target.data);
            var resultsList:XMLList;

            this._model.packetStreamIncoming += result.toXMLString() + '\n';

            if (result != null)
            {
                if ( result.localName() == "actions" ||
                     result.localName() == "devices" ||
                     result.localName() == "variables"
                     //result.localName() == "schedules" ||
                     //result.localName() == "triggers" ||
                   )
                {
                    resultsList = XML(result).children();
                    processRestObjectListResult(resultsList);
                    return;
                }

                if (result.localName() == "action")
                {
                    addOrReplaceActionGroupFromXML(result);
                    return;
                }

                if (result.localName() == "device")
                {
                    addOrReplaceDeviceFromXML(result);
                    return;
                }

                if (result.localName() == "variable")
                {
                    addOrReplaceVariableFromXML(result);
                    return;
                }
//                if (result.localName() == "trigger")
//                {
//                    addOrReplaceTriggerFromXML(result);
//                    return;
//                }

//                if (result.localName() == "schedule")
//                {
//                    addOrReplaceScheduleFromXML(result);
//                    return;
//                }

            }

            return;

        }

        protected function handleRESTFault(fault:FaultEvent):void
        {
            trace(fault.fault);
        }

        protected function processRestObjectListResult(resultList:XMLList):void
        {
            for each (var node:XML in resultList)
            {
                sendUrlRequest(node.@href);
            }
        }


        // REBUILD LIST FROM XML
        protected function rebuildAllActionGroupsFromXML(xmlData:XMLList):void
        {
            removeAllActionGroupListeners();

            this._model.actionGroupList.removeAll();
            this._model.actionGroupList = IndigoObjectUtil.createActionGroupList(xmlData);

            addAllActionGroupListeners();
        }

        protected function rebuildAllDevicesFromXML(xmlData:XMLList):void
        {
            removeAllDeviceListeners();

            this._model.deviceList.removeAll();
            this._model.deviceList = IndigoObjectUtil.createDeviceList(xmlData);

            addAllDeviceListeners();
        }

        protected function rebuildAllSchedulesFromXML(xmlData:XMLList):void
        {
            removeAllScheduleListeners();

            this._model.scheduleList.removeAll();
            this._model.scheduleList = IndigoObjectUtil.createScheduleList(xmlData);

            addAllScheduleListeners();
        }

        protected function rebuildAllTriggersFromXML(xmlData:XMLList):void
        {
            removeAllTriggerListeners();

            this._model.triggerList.removeAll();
            this._model.triggerList = IndigoObjectUtil.createTriggerList(xmlData);

            addAllTriggerListeners();
        }

        protected function rebuildAllVariablesFromXML(xmlData:XMLList):void
        {
            removeAllVariableListeners();

            this._model.variableList.removeAll();
            this._model.variableList = IndigoObjectUtil.createVariableList(xmlData);

            addAllVariableListeners();
        }


        // ADD OR REPLACE FROM XML
        protected function addOrReplaceActionGroupFromXML(actionGroupXML:XML):void
        {
            var tempActionGroup:IIndigoActionGroup = IndigoObjectUtil.createIndigoActionGroup(actionGroupXML);
            removeAllActionGroupListeners();
            tempActionGroup = IndigoObjectUtil.addOrReplaceActionGroup(tempActionGroup, _model.actionGroupList);
            addAllActionGroupListeners();
            dispatchEvent(new IndigoActionGroupChangeEvent(tempActionGroup));
        }

        protected function addOrReplaceDeviceFromXML(deviceXML:XML):void
        {
            var tempDevice:IIndigoDevice = IndigoObjectUtil.createIndigoDevice(deviceXML);
            removeAllDeviceListeners();
            tempDevice = IndigoObjectUtil.addOrReplaceDevice(tempDevice, _model.deviceList);
            addAllDeviceListeners();
            dispatchEvent(new IndigoDeviceChangeEvent(tempDevice));
        }

        protected function addOrReplaceScheduleFromXML(scheduleXML:XML):void
        {
            var tempSchedule:IIndigoSchedule = IndigoObjectUtil.createIndigoSchedule(scheduleXML);
            removeAllScheduleListeners();
            tempSchedule = IndigoObjectUtil.addOrReplaceSchedule(tempSchedule, _model.scheduleList);
            addAllScheduleListeners();
            dispatchEvent(new IndigoScheduleChangeEvent(tempSchedule));
        }

        protected function addOrReplaceTriggerFromXML(triggerXML:XML):void
        {
            var tempTrigger:IIndigoTrigger = IndigoObjectUtil.createIndigoTrigger(triggerXML);
            removeAllTriggerListeners();
            tempTrigger = IndigoObjectUtil.addOrReplaceTrigger(tempTrigger, _model.triggerList);
            addAllTriggerListeners();
            dispatchEvent(new IndigoTriggerChangeEvent(tempTrigger));
        }

        protected function addOrReplaceVariableFromXML(variableXML:XML):void
        {
            var tempVariable:IIndigoVariable = IndigoObjectUtil.createIndigoVariable(variableXML);
            removeAllVariableListeners();
            tempVariable = IndigoObjectUtil.addOrReplaceVariable(tempVariable, _model.variableList);
            addAllVariableListeners();
            dispatchEvent(new IndigoVariableChangeEvent(tempVariable));
        }
    }
}