package com.perceptiveautomation.indigo.services
{
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.constants.IndigoAPIMode;
    import com.perceptiveautomation.indigo.constants.IndigoRestConstants;
    import com.perceptiveautomation.indigo.constants.IndigoSocketConstants;
    import com.perceptiveautomation.indigo.device.BaseIndigoDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDevice;
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
    import com.perceptiveautomation.indigo.schedule.IIndigoSchedule;
    import com.perceptiveautomation.indigo.trigger.IIndigoTrigger;
    import com.perceptiveautomation.indigo.trigger.IIndigoTrigger;
    import com.perceptiveautomation.indigo.util.HashUtil;
    import com.perceptiveautomation.indigo.util.IndigoObjectUtil;
    import com.perceptiveautomation.indigo.util.IndigoObjectUtil;
    import com.perceptiveautomation.indigo.util.IndigoRestXMLUtil;
    import com.perceptiveautomation.indigo.util.IndigoSocketXMLUtil;
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;
    import com.perceptiveautomation.indigo.variable.IndigoVariable;

    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.XMLSocket;
    import flash.xml.XMLNode;

    import mx.collections.ArrayCollection;
    import mx.collections.XMLListCollection;
    import mx.rpc.AsyncToken;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;
    import mx.utils.StringUtil;

    import spark.collections.Sort;
    import spark.collections.SortField;

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
        protected function createDeviceList(packetData:XMLList):void
        {
            this._model.deviceList = IndigoObjectUtil.createDeviceList(packetData);
            addDeviceListeners();
        }

        protected function destroyDeviceList():void
        {
            const len:int = this._model.deviceList.length;
            var indigoDevice:IIndigoDevice;
            for (var i:int = 0; i < len; i++)
            {
                indigoDevice = this._model.deviceList.getItemAt(i) as IIndigoDevice;
                indigoDevice.removeEventListener("isOnChanged", handleDeviceIsOnChange);
                indigoDevice.removeEventListener("brightnessChanged", handleDeviceBrightnessChange);
            }

            this._model.deviceList.removeAll();

            for each (var key:String in this._model.deviceDictionary)
            {
                delete this._model.deviceDictionary[key];
            }
        }

        protected function addDeviceListeners():void
        {
            const len:int = this._model.deviceList.length;
            var indigoDevice:IIndigoDevice;
            for (var i:int = 0; i < len; i++)
            {
                indigoDevice = this._model.deviceList.getItemAt(i) as IIndigoDevice;
                indigoDevice.addEventListener("isOnChanged", handleDeviceIsOnChange);
                indigoDevice.addEventListener("brightnessChanged", handleDeviceBrightnessChange);
            }
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
                //connectUrl(_model.host+":"+_model.port, IndigoRESTConstants.INDIGO_REST_ENDPOINT_ACTION_GROUPS);
                //connectUrl(_model.host+":"+_model.port, IndigoRestConstants.INDIGO_REST_ENDPOINT_DEVICES);
                connectUrl(_model.host+":"+_model.port, "/devices/aquariumhood.xml");
                //connectUrl(_model.host+":"+_model.port, IndigoRESTConstants.INDIGO_REST_ENDPOINT_SCHEDULES);
                //connectUrl(_model.host+":"+_model.port, IndigoRESTConstants.INDIGO_REST_ENDPOINT_TRIGGERS);
                //connectUrl(_model.host+":"+_model.port, IndigoRESTConstants.INDIGO_REST_ENDPOINT_VARIABLES);
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
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE));
        }

        public function refreshActionGroups():void
        {
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP));
        }

        public function refreshVariables():void
        {
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE));
        }

        public function refreshTriggers():void
        {
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER));
        }

        public function refreshSchedules():void
        {
            outgoingPacketHandler(IndigoSocketXMLUtil.createRequestObjectListPacket(IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE));
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
        }

        protected function securityErrorHandler(event:SecurityErrorEvent):void
        {
            // TODO: Try to determine what the error was and return a more specific state constant
            this._model.indigoState = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
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
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_DEVICE)
            {
                var device:IIndigoDevice = IndigoObjectUtil.replaceDevice(packetData, _model.deviceList);
                dispatchEvent(new IndigoDeviceChangeEvent(device));
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_TRIGGER)
            {
                var trigger:IIndigoTrigger = IndigoObjectUtil.replaceTrigger(packetData, _model.triggerList);
                dispatchEvent(new IndigoTriggerChangeEvent(trigger));
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_SCHEDULE)
            {
                var schedule:IIndigoSchedule = IndigoObjectUtil.replaceSchedule(packetData, _model.scheduleList);
                dispatchEvent(new IndigoScheduleChangeEvent(schedule));
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_ACTION_GROUP)
            {
                var actionGroup:IIndigoActionGroup = IndigoObjectUtil.replaceActionGroup(packetData, _model.actionGroupList);
                dispatchEvent(new IndigoActionGroupChangeEvent(actionGroup));
            }
            else if (packetName == IndigoSocketConstants.INDIGO_PACKET_BROADCAST_REPLACED_VARIABLE)
            {
                var variable:IIndigoVariable = IndigoObjectUtil.replaceVariable(packetData, _model.variableList);
                dispatchEvent(new IndigoVariableChangeEvent(variable));
            }
        }

        protected function handleResponsePacket(packetName:String, packetData:XMLList):void
        {
            // Handle Response Packets for requested lists of data

            if (packetName == IndigoSocketConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE)
            {
                destroyDeviceList();
                createDeviceList(packetData);
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

        protected function connectUrl(url:String, resource:String):void
        {
            var request: URLRequest = new URLRequest(url + resource);
            request.method = "GET";
            request.contentType = "application/xml";

            _indigoUrlLoader = new URLLoader(request);
            _indigoUrlLoader.dataFormat = "xml";
            _indigoUrlLoader.load(request);
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
            var resultsList:Array;

            if (result != null)
            {
                if (result.localName() == "actiongroups")
                {
                    resultsList = XMLNode(result).childNodes;
                    //processRestResultList(resultsList);
                    return;
                }

                if (result.localName() == "devices")
                {
                    resultsList = XMLNode(result).childNodes;
                    processRestObjectListResult(resultsList);
                    return;
                }

                if (result.localName() == "schedules")
                {
                    resultsList = XMLNode(result).childNodes;
                    //processRestResultList(resultsList);
                    return;
                }

                if (result.localName() == "triggers")
                {
                    resultsList = XMLNode(result).childNodes;
                    //processRestResultList(resultsList);
                    return;
                }

                if (result.localName() == "variables")
                {
                    resultsList = XMLNode(result).childNodes;
                    //processRestResultList(resultsList);
                    return;
                }


                if (result.localName() == "device")
                {
                    //resultsList = XMLNode(result.result).childNodes;
                    processRestResultDevice(result);
                    return;
                }
            }
            else if (result.result is XML)
            {

            }

            // TODO: Individual List Item result processors
            trace(result.result.toXMLString());
            return;

        }

        protected function processRestObjectListResult(resultList:Array):void
        {
            for each (var node:XMLNode in resultList)
            {
                var href:String = XML(node).@href;
                connectUrl(_model.host+":"+_model.port, href);
                break;
            }
        }

        protected function processRestResultActionGroup(actionGroup:XML):void
        {
            var indigoActionGroup:IIndigoActionGroup = IndigoObjectUtil.createIndigoActionGroup(actionGroup);
        }

        protected function processRestResultDevice(device:XML):void
        {
            var indigoDevice:IIndigoDevice = IndigoObjectUtil.createIndigoDevice(device);
        }

        protected function processRestResultSchedule(schedule:XML):void
        {
            var indigoSchedule:IIndigoSchedule = IndigoObjectUtil.createIndigoSchedule(schedule);
        }

        protected function processRestResultTrigger(trigger:XML):void
        {
            var indigoTrigger:IIndigoTrigger = IndigoObjectUtil.createIndigoTrigger(trigger);
        }

        protected function processRestResultVariable(variable:XML):void
        {
            var indigoVariable:IIndigoVariable = IndigoObjectUtil.createIndigoVariable(variable);
        }

        protected function handleRESTFault(fault:FaultEvent):void
        {
            trace(fault.fault);
        }
    }
}