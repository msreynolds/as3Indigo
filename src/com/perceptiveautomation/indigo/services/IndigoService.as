package com.perceptiveautomation.indigo.services
{
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.actiongroup.IndigoActionGroup;
    import com.perceptiveautomation.indigo.constants.IndigoConstants;
    import com.perceptiveautomation.indigo.device.AbstractIndigoDevice;
    import com.perceptiveautomation.indigo.device.BaseIndigoDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDimmerDevice;
    import com.perceptiveautomation.indigo.device.IIndigoOnOffDevice;
    import com.perceptiveautomation.indigo.device.IIndigoThermostatDevice;
    import com.perceptiveautomation.indigo.device.IndigoDeviceFactory;
    import com.perceptiveautomation.indigo.events.IndigoDeviceChangeEvent;
    import com.perceptiveautomation.indigo.events.IndigoVariableChangeEvent;
    import com.perceptiveautomation.indigo.model.IndigoModel;
    import com.perceptiveautomation.indigo.schedule.IndigoSchedule;
    import com.perceptiveautomation.indigo.trigger.IndigoTrigger;
    import com.perceptiveautomation.indigo.util.HashUtil;
    import com.perceptiveautomation.indigo.util.IndigoXMLUtil;
    import com.perceptiveautomation.indigo.util.SortUtil;
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;
    import com.perceptiveautomation.indigo.variable.IndigoVariable;
    import com.perceptiveautomation.indigo.vo.IndigoLoginData;

    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.XMLSocket;

    import mx.collections.ArrayCollection;
    import mx.collections.XMLListCollection;
    import mx.rpc.http.HTTPService;
    import mx.utils.StringUtil;

    import spark.collections.Sort;
    import spark.collections.SortField;

    public class IndigoService extends EventDispatcher
	{
        private var _model:IndigoModel = IndigoModel.getInstance();
        private var _api:String = IndigoConstants.INDIGO_API_SOCKET;
        private var _indigoSocket:XMLSocket;
        private var _indigoHTTPService:HTTPService;

		//Constructor
		public function IndigoService()
		{
			//
		}

		/*************************************************************************/
		//PUBLIC API
		/*************************************************************************/

        // Getters and Setters
        public function get api():String {
            return _api;
        }

        public function set api(value:String):void {
            _api = value;
        }

		// CONNECTION FUNCTION
		public function connect(data:IndigoLoginData):void
		{
			// Accept IndigoLoginData object and use values to connect to Indigo Server

            this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_CONNECTING;

            if (api == IndigoConstants.INDIGO_API_SOCKET)
            {
                this._model.username = data.username;

                this._model.password = data.password;

                this._model.host = data.host;

                this._model.port = parseInt(data.port);

                connectXMLSocket(this._model.host, this._model.port);
            }
            else if (api == IndigoConstants.INDIGO_API_RESTFUL)
            {
                // TODO: implement the Indigo RESTful API with HTTPService calls
                _indigoHTTPService = new HTTPService(_model.host,"" );

                // Request Devices, Variables, et al.
            }
	    }

        // PUBLIC COMMANDS
        public function subscribeToBroadcasts():void
        {
            sendSubscribeCommandPacket();
        }

        public function runActionGroup(actionGroup:IIndigoActionGroup):void
        {
            sendCommandPacket(actionGroup.name, 'TriggerActionGroup', 0);
        }

        public function turnOn(device:IIndigoOnOffDevice):void
        {
            sendCommandPacket(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_ONOFF_TURN_ON, 100);
        }

        public function turnOff(device:IIndigoOnOffDevice):void
        {
            sendCommandPacket(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_ONOFF_TURN_OFF, 0);
        }

        public function setBrightness(device:IIndigoDimmerDevice):void
        {
            sendCommandPacket(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_DIMMER_SET_BRIGHTNESS, device.brightness);
        }

        public function setVariableValue(variable:IIndigoVariable):void
        {
            sendCommandPacket(variable.name, IndigoConstants.INDIGO_COMMAND_VARIABLE_SET_VALUE, variable.value.toString())
        }

        public function setHeatPoint(device:IIndigoThermostatDevice):void
        {
            sendCommandPacket(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_HEAT_POINT, device.heatPoint);
        }

        public function setCoolPoint(device:IIndigoThermostatDevice):void
        {
            sendCommandPacket(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_COOL_POINT, device.coolPoint);
        }

        // REFRESH COMMANDS
        public function refreshDevices():void
        {
            requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE);
        }

        public function refreshActionGroups():void
        {
            requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP);
        }

        public function refreshVariables():void
        {
            requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE);
        }

        public function refreshTriggers():void
        {
            requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER);
        }

        public function refreshSchedules():void
        {
            requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE);
        }

        // SUBSCRIBE COMMAND FUNCTION
        protected function sendSubscribeCommandPacket():void
        {
            // Create and send a command packet to the Indigo server
            var sendCommandPacket:XML = IndigoXMLUtil.createSubscribeCommandPacket();

            outgoingPacketHandler(sendCommandPacket);
        }

        // COMMAND PACKET CREATOR FUNCTIONS
        protected function sendCommandPacket(name:String, command:String, value:*):void
        {
            // Create and send a command packet to the Indigo server
            var sendCommandPacket:XML = IndigoXMLUtil.createDeviceCommandPacket(name, command, value);

            outgoingPacketHandler(sendCommandPacket);
        }

        protected function sendAuthenticateKnock():void
        {
	   		/* Create and send an AuthenticateKnock packet
	   		*/ 
	    	const authenticatePacket:XML = IndigoXMLUtil.createAuthenticateKnockPacket();

	     	outgoingPacketHandler(authenticatePacket);
	  	}

        protected	function sendAuthenticatePassword(rawUser:String, rawPassword:String, hashPassword:String):void
	  	{
			// Create an instance of the HashUtil class.
			var crypt:Object = new HashUtil();									
			
			// Stores the hashed password concat with the salt from the server
			var hashPasswordWithSalt:String;												
			
			// Stores the final hash of the raw password.																				
			var totalHash:String															
			
			// First, calculate the hash of the password by itself:
			if (hashPassword == null) {
				hashPassword = crypt.hex_sha1(rawUser + ":Indigo Control Server:" + rawPassword);
			}

	 		// Then add the salt from the server onto it:
			hashPasswordWithSalt = hashPassword + this._model.serverSalt;

			// And re-hash everything again:
			totalHash = crypt.hex_sha1(hashPasswordWithSalt);

            // Create the authenticate packet type in XML format.
            const authenticatePacket:XML = IndigoXMLUtil.createAuthenticatePasswordPacket(rawUser, totalHash);

            outgoingPacketHandler(authenticatePacket);
		}

        protected function connectXMLSocket(XmlServer_IP:String, XmlServer_Port:int):void
		{
			/* Create a XML socket connection with the server at the specified IP and port. 
			*/

            if (this._indigoSocket != null)
            {
	     	    removeSocketListeners(this._indigoSocket);
            }

            this._indigoSocket = new XMLSocket();

            addSocketListeners(this._indigoSocket);

	     	this._indigoSocket.connect(this._model.host, this._model.port);
		}
		
	
		/************************************************************************************/
		// INDIGO EVENT LISTENERS for Socket API
		/***********************************************************************************/
        protected function addSocketListeners(socket:IEventDispatcher):void
		{
			// Configure event listeners to handle responses from the server.

	    	socket.addEventListener(Event.CLOSE, connectClosedHandler);
            socket.addEventListener(Event.CONNECT, connectCompleteHandler);
            socket.addEventListener(DataEvent.DATA, incomingPacketHandler);
            socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            socket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }

        protected function removeSocketListeners(socket:IEventDispatcher):void
		{
			// Configure event listeners to handle responses from the server.

	    	socket.removeEventListener(Event.CLOSE, connectClosedHandler);
            socket.removeEventListener(Event.CONNECT, connectCompleteHandler);
            socket.removeEventListener(DataEvent.DATA, incomingPacketHandler);
            socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            socket.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	    }
	        
	        
		/************************************************************************************/
		// EVENT HANDLERS
		/***********************************************************************************/
        protected function connectClosedHandler(event:Event):void
	    {
            this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
	    }

        protected function connectCompleteHandler(event:Event):void
	   	{
			sendAuthenticateKnock();
		}

        protected function ioErrorHandler(event:IOErrorEvent):void
		{
            // TODO: Try to determine what the error was and return a more specific state constant
            this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
		}


        protected function securityErrorHandler(event:SecurityErrorEvent):void
	   	{
            // TODO: Try to determine what the error was and return a more specific state constant
			this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
	   	}

        protected function progressHandler(event:ProgressEvent):void
		{
			//trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
	   	}
	   	
		/************************************************************************************/
		// PACKET HANDLERS (FOR RECEIVED PACKETS)
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

            if (packetType == IndigoConstants.INDIGO_PACKET_TYPE_AUTHENTICATE)
            {
	   			 handleAuthenticatePacket(packetName, packetData);
	   		}
	  		
	   		if (packetType == IndigoConstants.INDIGO_PACKET_TYPE_BROADCAST)
            {
	   			 handleBroadcast(packetName, packetData);
	   		}
	      		       		
	   		if (packetType == IndigoConstants.INDIGO_PACKET_TYPE_RESPONSE)
            {
	   			 handleResponse(packetName, packetData);
			}
	   	}

        protected function handleAuthenticatePacket(packetName:String, packetData:XMLList):void
	   	{
			/* Handle the authentication process.
			*/

            // Capture socket connection state in the model
            //this._model.indigoState = packetName;

			if (packetName == IndigoConstants.INDIGO_PACKET_AUTH_IP_FAILED)
			{
				// Indigo Server is not allowing this IP address.
				// Indigo Server will issue disconnect.
                this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_AUTH_PASSWORD_FAILED)
			{
				// Password was incorrect.
				// Re-enter credentials and try again.
				// Re-use the salt originally passed to us by the "NeedPassword" packet.
                this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_CONNECTING;
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_AUTH_PASSWORD_REQUIRED)
			{
                this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_CONNECTING;

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
					this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
				}
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_AUTH_SUCCESS)
			{
                this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_CONNECTED;
                this._model.logStream += "Client authenticated" + "\n";

                // Subscribe to Broadcasts
                subscribeToBroadcasts();

                // Request Managed Indigo Object Lists
                requestObjectLists();
			}
		}

        protected function handleBroadcast(packetName:String, packetData:XMLList):void
		{
	   		/* Handle broadcast packets from the server	*/

	   		if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_UPDATED_REG_INFO)
	   		{													
	   			// Handle "UpdatedRegInfo" packet.
				// Not used. Add code here if 
				// needed.
				
	     	}
	     	else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_UPDATED_TIME_INFO)
	     	{			
     			_model.updateTimeInfo = packetData[0].CurrentTime;
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_LOG_STREAM)
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
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_ADDED_DEVICE)
			{
				//Application.application.gDeviceListCache = addItem(packetData, Application.application.gDeviceListCache, 'Device', 'Name'); 					
				
				// Handle adding a 
				// "DeviceListCache" item. Add 
				// the packetData in the 
				// 'Device' element to 
				// "Application.application.gDeviceListCache" 
				// and sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_ADDED_TRIGGER)
			{
				//Application.application.gTriggerListCache = addItem(packetData, Application.application.gTriggerListCache, 'Trigger', 'Name');					
				
				// Handle adding a 
				// "TriggerListCache" item. Add 
				// the packetData in the 
				// 'Trigger' element to 
				// "Application.application.gTriggerListCache"
				// and sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_ADDED_SCHEDULE)
			{
				//Application.application.gTDTriggerListCache = addItem(packetData, Application.application.gTDTriggerListCache, 'TDTrigger', 'Name');			
				
				// Handle adding a 
				// "TDTriggerListCache" item. Add 
				// the packetData in the 
				// 'TDTrigger' element to 
				// "Application.application.gTDTriggerListCache" 
				// and sort by 'Name'.
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_ADDED_ACTION_GROUP)
			{
				//Application.application.gActionGroupListCache = addItem(packetData, Application.application.gActionGroupListCache, 'ActionGroup', 'Name');		
				
				// Handle adding a 
				// "ActionGroupListCache" item. Add 
			    // the packetData in the 
			    // 'ActionGroup' element to
				// "Application.application.gActionGroupListCache" 
				// and sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_ADDED_VARIABLE)
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
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REMOVED_DEVICE)
			{
				//Application.application.gDeviceListCache = removeItem(packetData, Application.application.gDeviceListCache, 'Device', 'Name');
				
				// Handle removing a 
				// "DeviceListCache" item. 
				// Remove the packetData in the
				// 'Device' element from 
				// 'Application.application.gDeviceListCache' and
				// sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REMOVED_TRIGGER)
			{
				//Application.application.gTriggerListCache = removeItem(packetData, Application.application.gTriggerListCache, 'Trigger', 'Name');	
				
				// Handle removing a 
				// "TriggerListCache" item. 
				// Remove the packetData in the 
				// 'Trigger' element from 
				// 'Application.application.gTriggerListCache' and 
				// sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REMOVED_SCHEDULE)
			{
				//Application.application.gTDTriggerListCache = removeItem(packetData, Application.application.gTDTriggerListCache, 'TDTrigger', 'Name');		
				
				// Handle removing a 
				// "TDTriggerListCache" item. 
				// Remove the packetData in the 
				// 'TDTrigger' element from 
				// 'Application.application.gTDTriggerListCache' and 
				// sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REMOVED_ACTION_GROUP)
			{
				//Application.application.gActionGroupListCache = removeItem(packetData, Application.application.gActionGroupListCache, 'ActionGroup', 'Name');	
				
				// Handle removing a 
				// "ActionGroupListCache" 
				// item. Remove the packetData in 
				// the 'ActionGroup' element from
				// 'Application.application.gActionGroupListCache' and 
				// sort by 'Name'.
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REMOVED_VARIABLE)
			{
				//Application.application.gVariableListCache = removeItem(packetData, Application.application.gVariableListCache, 'Variable', 'Name');			// Handle removing a 
				
				// "VariableListCache"
				// item. Remove the packetData in
				// the 'Variable' element from
				// 'gApplication.application.gVariableListCache' and
				// sort by 'Name'.
				// ------------------------
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_DEVICE)
			{
				replaceDevice(packetData, _model.deviceList, 'Name');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_TRIGGER)
			{
				replaceTrigger(packetData, _model.triggerList, 'None');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_SCHEDULE)
			{
				replaceSchedule(packetData, _model.scheduleList, 'Name');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_ACTION_GROUP)
			{
				replaceActionGroup(packetData, _model.actionGroupList, 'Name');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_VARIABLE)
			{
				replaceVariable(packetData, _model.variableList, 'Name');
			}
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

            this._model.packetStreamOutgoing += formattedPacket + '\n';
            this._indigoSocket.send(formattedPacket);
        }
		
		
		//LIST MARSHALING FUNCTIONS
        protected function createDeviceList(xml:XML):ArrayCollection
		{
			var len:int = xml..Device.length();
			var tempDeviceCollection:ArrayCollection = new ArrayCollection();
			var tempDevice:AbstractIndigoDevice;
			for(var i:int=0; i<len;i++)
			{
				tempDevice = IndigoDeviceFactory.getIndigoDevice(xml..Device[i]);

                if (tempDevice is IIndigoOnOffDevice)
                    tempDevice.addEventListener( "isOnChanged", handleDeviceIsOnChange, false, 0, true );

                if (tempDevice is IIndigoDimmerDevice)
                    tempDevice.addEventListener( "brightnessChanged", handleDeviceBrightnessChange, false, 0, true );

				tempDeviceCollection.addItem(tempDevice);
			}
			
			return tempDeviceCollection;
		}

        protected function createActionGroupList(xml:XML):ArrayCollection
		{
			var len:int = xml..ActionGroup.length();
			var tempActionGroupCollection:ArrayCollection = new ArrayCollection();
			var tempActionGroup:IndigoActionGroup;
			for(var i:int=0; i<len;i++)
			{
				tempActionGroup = new IndigoActionGroup(xml..ActionGroup[i]);
				tempActionGroupCollection.addItem(tempActionGroup);
			}
			return tempActionGroupCollection;
		}

        protected function createVariableList(xml:XML):ArrayCollection
		{
			var len:int = xml..Variable.length();
			var tempVariableCollection:ArrayCollection = new ArrayCollection();
			var tempVariable:IndigoVariable;
			for(var i:int=0; i<len;i++)
			{
				tempVariable = new IndigoVariable(xml..Variable[i]);
				tempVariableCollection.addItem(tempVariable);
			}
			return tempVariableCollection;
		}

        protected function createTriggerList(xml:XML):ArrayCollection
		{
			var len:int = xml..Trigger.length();
			var tempTriggerCollection:ArrayCollection = new ArrayCollection();
			var tempTrigger:IndigoTrigger;
			for(var i:int=0; i<len;i++)
			{
				tempTrigger = new IndigoTrigger(xml..Trigger[i]);
				tempTriggerCollection.addItem(tempTrigger);
			}			
			return tempTriggerCollection;
		}

        protected function createScheduleList(xml:XML):ArrayCollection
		{
			var len:int = xml..TDTrigger.length();
			var tempScheduleCollection:ArrayCollection = new ArrayCollection();
			var tempSchedule:IndigoSchedule;
			for(var i:int=0; i<len;i++)
			{
				tempSchedule = new IndigoSchedule(xml..TDTrigger[i]);
				tempScheduleCollection.addItem(tempSchedule);
			}
			return tempScheduleCollection;
		}

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

        protected function handleResponse(packetName:String, packetData:XMLList):void
		{
			// Handle Response Packets for requested lists of data

			if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE)
			{
				this._model.deviceList = createDeviceList(handleList(packetData, 'Device', 'Name'));

				var deviceSort:Sort = new Sort();
				deviceSort.fields = [new SortField('name')];
				this._model.deviceList.sort = deviceSort;
				this._model.deviceList.refresh();
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP)
			{
				this._model.actionGroupList = createActionGroupList(handleList(packetData, 'ActionGroup', 'Name'));

				var actionGroupSort:Sort = new Sort();
				actionGroupSort.fields = [new SortField('name')];
				this._model.actionGroupList.sort = actionGroupSort;
				this._model.actionGroupList.refresh();
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE)
			{
				this._model.variableList = createVariableList(handleList(packetData, 'Variable', 'Name'));

				var variableSort:Sort = new Sort();
				variableSort.fields = [new SortField('name')];
				this._model.variableList.sort = variableSort;
				this._model.variableList.refresh();
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER)
			{
				this._model.triggerList = createTriggerList(handleList(packetData, 'Trigger', 'Name'));

				var triggerSort:Sort = new Sort();
				triggerSort.fields = [new SortField('name')];
				this._model.triggerList.sort = triggerSort;
				this._model.triggerList.refresh();
			}
            else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE)
			{
				this._model.scheduleList = createScheduleList(handleList(packetData, 'TDTrigger', 'Name'));

				var scheduleSort:Sort = new Sort();
                scheduleSort.fields = [new SortField('name')];
				this._model.scheduleList.sort = scheduleSort;
				this._model.scheduleList.refresh();
			}
		}

		//This function handles the packet formating / Marshalling for IndigoPakcets
        protected function handleList(packetData:XMLList, node:String, sortBy:String):XML
		{
			// Parse Response Packet for requested list of data
	    	var listCache:XML;
	    	var listTemp:XMLListCollection;
	    	listTemp = new XMLListCollection(packetData[node]);
	    	listCache = new XML('<Data type="dict">' + (SortUtil.sortData(listTemp, sortBy)).toXMLString() + '</Data>');
	   		return listCache;
		}
		

		/************************************************************************************/
		// SERVER REQUEST FUNCTIONS
	 	/***********************************************************************************/ 	
		protected function requestObjectLists():void
        {
	    	// Request all data lists
	       	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP);
	       	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE);
	      	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER);
	   	  	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE);
	   	  	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE);
	   	}
				
		protected function requestList(listType:String):void
        {
	   	    // Create Request Packet for list of data
	   	   	var getListPacket:XML;										
	   	   	// Create the get list packet type in XML format.
	   	   	
	   	   	getListPacket = <Packet />;
	   	   	getListPacket.@type = 'dict';
	   	   	getListPacket.Type = IndigoConstants.INDIGO_PACKET_TYPE_REQUEST;
	   	   	getListPacket.Type.@type = 'string';
	   	   	getListPacket.Name = listType;
	   	   	getListPacket.Name.@type = 'string';
	   	   	outgoingPacketHandler(getListPacket);
	    }
	

		/************************************************************************************/
		// XML LIST CACHE AND ARRAYCOLLECTION MODIFIERS
		/***********************************************************************************/
        protected function addItem(packetData:XMLList, listCache:XML, node:String, sortBy:String):XML
		{
			var listTemp:XMLListCollection;
				
			packetData.setLocalName(node);
	   		listCache..appendChild(packetData);
			listTemp = new XMLListCollection(listCache[node]);
	    	listCache = XML('<Data type="dict">' + (SortUtil.sortData(listTemp, sortBy)).toXMLString() + '</Data>');
			return listCache;
		}

        protected function addObject():ArrayCollection
		{
			var tempCollection:ArrayCollection = new ArrayCollection();
			
			return tempCollection;
		}

        protected function removeItem(packetData:XMLList, listCache:XML, node:String, sortBy:String):XML
		{
			var listTemp:XMLListCollection;
				
			for (var i:int=0; i < listCache[node].length(); i++){
	           	if (listCache[node].Name[i].text() == packetData.text()) {
	               	delete listCache[node][i];
	           	}
			}
	 		listTemp = new XMLListCollection(listCache[node]);
	       	listCache = XML('<Data type="dict">' + (SortUtil.sortData(listTemp, sortBy)).toXMLString() + '</Data>');
			return listCache;
		}

        protected function removeObject():ArrayCollection
		{
			var tempCollection:ArrayCollection = new ArrayCollection();
			
			return tempCollection;
		}

        protected function replaceDevice(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
		{
	       	var updatedIndigoDevice:BaseIndigoDevice = new BaseIndigoDevice(packetData.Device);
	       	var tempIndigoDevice:BaseIndigoDevice;
	       	var len:int = collection.length;
	       	for (var i:int = 0; i < len; i++)
	       	{
	       		tempIndigoDevice = collection.getItemAt(i) as BaseIndigoDevice;
	     		if (updatedIndigoDevice.name == tempIndigoDevice.name)
	     		{
					tempIndigoDevice.fill(updatedIndigoDevice);
	     			dispatchEvent(new IndigoDeviceChangeEvent(tempIndigoDevice));
	     		}  		
	       	}
		}

        protected function replaceVariable(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
		{
	       	var updatedIndigoVariable:IndigoVariable = new IndigoVariable(packetData.Variable);
	       	var tempIndigoVariable:IndigoVariable;
	       	var len:int = collection?collection.length:0;
	       	for (var i:int = 0; i < len; i++)
	       	{
	       		tempIndigoVariable = collection.getItemAt(i) as IndigoVariable;
	     		if (updatedIndigoVariable.name == tempIndigoVariable.name)
	     		{
	     			tempIndigoVariable.value = updatedIndigoVariable.value;
	     			_model.variableDictionary[updatedIndigoVariable.name] = updatedIndigoVariable.value;
	     			dispatchEvent(new IndigoVariableChangeEvent(tempIndigoVariable));
	     		}  		
	       	}
		}

        protected function replaceActionGroup(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
        {
            // TODO:
//            var updatedIndigoVariable:IndigoVariable = new IndigoVariable(packetData.Variable);
//            var tempIndigoVariable:IndigoVariable;
//            var len:int = collection?collection.length:0;
//            for (var i:int = 0; i < len; i++)
//            {
//                tempIndigoVariable = collection.getItemAt(i) as IndigoVariable;
//                if (updatedIndigoVariable.name == tempIndigoVariable.name)
//                {
//                    tempIndigoVariable.value = updatedIndigoVariable.value;
//                    _model.indigoVariableDictionary[updatedIndigoVariable.name] = updatedIndigoVariable.value;
//                    dispatchEvent(new IndigoActionGroupChangeEvent(tempIndigoVariable));
//                }
//            }
        }

        protected function replaceTrigger(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
        {
            // TODO:
//            var updatedIndigoVariable:IndigoVariable = new IndigoVariable(packetData.Variable);
//            var tempIndigoVariable:IndigoVariable;
//            var len:int = collection?collection.length:0;
//            for (var i:int = 0; i < len; i++)
//            {
//                tempIndigoVariable = collection.getItemAt(i) as IndigoVariable;
//                if (updatedIndigoVariable.name == tempIndigoVariable.name)
//                {
//                    tempIndigoVariable.value = updatedIndigoVariable.value;
//                    _model.indigoVariableDictionary[updatedIndigoVariable.name] = updatedIndigoVariable.value;
//                    dispatchEvent(new IndigoTriggerChangeEvent(tempIndigoVariable));
//                }
//            }
        }

        protected function replaceSchedule(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
        {
            // TODO:
//            var updatedIndigoVariable:IndigoVariable = new IndigoVariable(packetData.Variable);
//            var tempIndigoVariable:IndigoVariable;
//            var len:int = collection?collection.length:0;
//            for (var i:int = 0; i < len; i++)
//            {
//                tempIndigoVariable = collection.getItemAt(i) as IndigoVariable;
//                if (updatedIndigoVariable.name == tempIndigoVariable.name)
//                {
//                    tempIndigoVariable.value = updatedIndigoVariable.value;
//                    _model.indigoVariableDictionary[updatedIndigoVariable.name] = updatedIndigoVariable.value;
//                    dispatchEvent(new IndigoScheduleChangeEvent(tempIndigoVariable));
//                }
//            }
        }
    }
}