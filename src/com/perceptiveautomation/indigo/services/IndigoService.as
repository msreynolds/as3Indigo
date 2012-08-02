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
    import com.perceptiveautomation.indigo.util.SortUtil;
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
                this._model.indigoUser = data.username;

                this._model.indigoPassword = data.password;

                this._model.indigoHost = data.host;

                this._model.indigoPort = parseInt(data.port);

                connectXMLSocket(this._model.indigoHost, this._model.indigoPort);
            }
            else if (api == IndigoConstants.INDIGO_API_RESTFUL)
            {
                // TODO: implement the Indigo RESTful API with HTTPService calls
                _indigoHTTPService = new HTTPService(_model.indigoHost,"" );

                // Request Devices, Variables, et al.
            }
	    }

        // PUBLIC COMMANDS
        public function runActionGroup(actionGroup:IIndigoActionGroup):void
        {
            sendCommand(actionGroup.name, 'TriggerActionGroup', 0);
        }

        public function turnOn(device:IIndigoOnOffDevice):void
        {
            sendCommand(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_ONOFF_TURN_ON, 100);
        }

        public function turnOff(device:IIndigoOnOffDevice):void
        {
            sendCommand(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_ONOFF_TURN_OFF, 0);
        }

        public function setBrightness(device:IIndigoDimmerDevice):void
        {
            sendCommand(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_DIMMER_SET_BRIGHTNESS, device.brightness);
        }

        public function setHeatPoint(device:IIndigoThermostatDevice):void
        {
            sendCommand(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_HEAT_POINT, device.heatPoint);
        }

        public function setCoolPoint(device:IIndigoThermostatDevice):void
        {
            sendCommand(device.name, IndigoConstants.INDIGO_COMMAND_DEVICE_THERMOSTAT_SET_COOL_POINT, device.coolPoint);
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

        // BASE COMMAND FUNCTION
        protected function sendCommand(name:String, command:String, value:Number):void
        {
            // Create and send a command packet to the Indigo server
            var sendCommandPacket:XML;

            sendCommandPacket = <Packet />;
            sendCommandPacket.@type = 'dict';
            sendCommandPacket.Type = IndigoConstants.INDIGO_PACKET_TYPE_COMMAND;
            sendCommandPacket.Type.@type = 'string';
            sendCommandPacket.Name = command;
            sendCommandPacket.Name.@type = 'string';
            if(command == 'SetBrightness' || command == 'Dim' || command == 'Brighten')
            {
                //Determine if the device is dimmable
                sendCommandPacket.Data.@type = 'dict';
                sendCommandPacket.Data.Name = name;
                sendCommandPacket.Data.Name.@type = 'string';
                sendCommandPacket.Data.Amount = value;
                sendCommandPacket.Data.Amount.@type = 'string';
            }
            else
            {
                sendCommandPacket.Data = name;
                sendCommandPacket.Data.@type = 'string';
            }

            sendPacket(sendCommandPacket);
        }


    private function sendAuthenticateKnock():void{
	   		/* Create and send an AuthenticateKnock packet
	   		*/ 
	    	var authenticatePacket:XML;									
	    	// Create the authenticate packet type in XML format.
	    		
	    	authenticatePacket = <Packet />;
	      	authenticatePacket.@type = 'dict';
	      	authenticatePacket.Type = IndigoConstants.INDIGO_PACKET_TYPE_AUTHENTICATE;
	      	authenticatePacket.Type.@type = 'string';
	    	authenticatePacket.Name = IndigoConstants.INDIGO_PACKET_AUTH_KNOCK_KNOCK;
	     	authenticatePacket.Name.@type = 'string';
	     	authenticatePacket.Data;
	     	authenticatePacket.Data.@type = 'dict';
	     	authenticatePacket.Data.ClientType = '2';
	     	authenticatePacket.Data.ClientType.@type = 'string';
	     	authenticatePacket.Data.DoBroadcasts = 'true';
	     	authenticatePacket.Data.DoBroadcasts.@type = 'string';
	     	sendPacket(authenticatePacket);
	  	}
	  	
	  	private	function sendAuthenticatePassword(rawUser:String, rawPassword:String, hashPassword:String):void 
	  	{
	  		// Create the authenticate packet type in XML format.
			var authenticatePacket:XML;														
			
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
			hashPasswordWithSalt = hashPassword + this._model.indigoServerSalt;
			// And re-hash everything again:
			totalHash = crypt.hex_sha1(hashPasswordWithSalt);
			// And finally, pass it off to the server for authentication:
			authenticatePacket = <Packet />;
	   		authenticatePacket.@type = 'dict';
	   		authenticatePacket.Type = IndigoConstants.INDIGO_PACKET_TYPE_AUTHENTICATE;
	   		authenticatePacket.Type.@type = 'string';
	   		authenticatePacket.Name = IndigoConstants.INDIGO_PACKET_AUTH_ATTEMPT_AUTHENTICATION;
	   		authenticatePacket.Name.@type = 'string';
	   		authenticatePacket.Data;
	   		authenticatePacket.Data.@type = 'dict';
	   		authenticatePacket.Data.UserName = rawUser;
	   		authenticatePacket.Data.UserName.@type = 'string';
	   		authenticatePacket.Data.PasswordHash = totalHash;
	   		authenticatePacket.Data.PasswordHash.@type = 'string';
	   		sendPacket(authenticatePacket);
		}
	   	
		private function connectXMLSocket(XmlServer_IP:String, XmlServer_Port:int):void
		{
			/* Create a XML socket connection with the server at the specified IP and port. 
			*/ 
	     	this._indigoSocket = new XMLSocket();
	     	configureSocketListeners(this._indigoSocket);
	     	this._indigoSocket.connect(this._model.indigoHost, this._model.indigoPort);
		}
		
	
		/************************************************************************************/
		// INDIGO EVENT LISTENERS for Socket API
		/***********************************************************************************/ 
		private function configureSocketListeners(socket:IEventDispatcher):void
		{
			// Configure event listeners to handle responses from the server.

	    	socket.addEventListener(Event.CLOSE, connectClosedHandler);
            socket.addEventListener(Event.CONNECT, connectCompleteHandler);
            socket.addEventListener(DataEvent.DATA, packetHandler);
            socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            socket.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	    }
	        
	        
		/************************************************************************************/
		// EVENT HANDLERS
		/***********************************************************************************/         
	    private function connectClosedHandler(event:Event):void 
	    {
            this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
	    }
	
	   	private function connectCompleteHandler(event:Event):void 
	   	{
			sendAuthenticateKnock();
		}
	
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
            // TODO: Try to determine what the error was and return a more specific state constant
            this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
		}
	
	
	   	private function securityErrorHandler(event:SecurityErrorEvent):void 
	   	{
            // TODO: Try to determine what the error was and return a more specific state constant
			this._model.indigoState = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
	   	}
	   	
		private function progressHandler(event:ProgressEvent):void 
		{
			//trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
	   	}
	   	
		/************************************************************************************/
		// PACKET HANDLERS (FOR RECEIVED PACKETS)
		/***********************************************************************************/ 	
	   	private function packetHandler(event:DataEvent):void 
	   	{
	   		// Handle the different packet types returned by the server.

	   		var packetType:String;  // The type of packet.
	   		var packetName:String;  // The packet name.
	   		var packetData:XMLList; // The data node's descendants striped from the response packet.
	   		var responsePacket:XML  // The entire packet as returned by the server.
	  			
	   		responsePacket = new XML(event.data); 				//Store the entire response packet from the server.
	   		packetType = responsePacket.Type.toString();		//Strip out the packet type so we can determine how to process it.
	   		packetName = responsePacket.Name.toString(); 		//Strip out the packet name so we can determine how to process it's contents later.
	   		packetData = responsePacket.descendants("Data");	//Strip out the data node's descendets so we can process them later.

            trace(packetType);
            trace(packetName);
            trace(packetData);
            trace("");

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
	   	
	   	private function handleAuthenticatePacket(packetName:String, packetData:XMLList):void 
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

				this._model.indigoServerSalt = packetData.toString();

				// saltFromServer = packetData.toString();
				// Store saltFromServer
				// Concat this on to the user's raw password
				// Crypto-hash the composite string.
				if (this._model.indigoUser != "" && this._model.indigoAuthHash != "")
				{
					// The Indigo web server was nice enough to give us the
					// user name and password hash since we already authenticated
					// against it. We can directly connect without prompting
					// the user.
					sendAuthenticatePassword(this._model.indigoUser, null , this._model.indigoAuthHash);
				}
				else if (this._model.indigoUser != "" && this._model.indigoPassword != "")
				{
					// If we didn't get the connection info from Indigo but
					// instead from the login form. Pass the raw information to
					// the encryption function.
					sendAuthenticatePassword(this._model.indigoUser, this._model.indigoPassword , null);
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

                requestCache();
			}
		}
		
		private function handleBroadcast(packetName:String, packetData:XMLList):void 
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
				this._model.indigoLogStream.addItem(packetData);
											
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
				replaceDevice(packetData, _model.indigoDeviceList, 'Name');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_TRIGGER)
			{
				replaceTrigger(packetData, _model.indigoTriggerList, 'None');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_SCHEDULE)
			{
				replaceSchedule(packetData, _model.indigoScheduleList, 'Name');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_ACTION_GROUP)
			{
				replaceActionGroup(packetData, _model.indigoActionGroupList, 'Name');
			} 
			else if (packetName == IndigoConstants.INDIGO_PACKET_BROADCAST_REPLACED_VARIABLE)
			{
				replaceVariable(packetData, _model.indigoVariableList, 'Name');
			}
		}
		
		
		//LIST MARSHALING FUNCTIONS
		private function createDeviceList(xml:XML):ArrayCollection
		{
			var len:int = xml..Device.length();
			var tempDeviceCollection:ArrayCollection = new ArrayCollection();
			var tempDevice:AbstractIndigoDevice;
			for(var i:int=0; i<len;i++)
			{
				tempDevice = IndigoDeviceFactory.getIndigoDevice(xml..Device[i]);
				tempDeviceCollection.addItem(tempDevice);
			}
			
			return tempDeviceCollection;
		}
		
		private function createActionGroupList(xml:XML):ArrayCollection
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
		
		private function createVariableList(xml:XML):ArrayCollection
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
		
		private function createTriggerList(xml:XML):ArrayCollection
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

        private function createScheduleList(xml:XML):ArrayCollection
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

		private function handleResponse(packetName:String, packetData:XMLList):void
		{
			// Handle Response Packets for requested lists of data

			if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE)
			{
				this._model.indigoDeviceList = createDeviceList(handleList(packetData, 'Device', 'Name'));

				var deviceSort:Sort = new Sort();
				deviceSort.fields = [new SortField('name')];
				this._model.indigoDeviceList.sort = deviceSort;
				this._model.indigoDeviceList.refresh();
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP)
			{
				this._model.indigoActionGroupList = createActionGroupList(handleList(packetData, 'ActionGroup', 'Name'));

				var actionGroupSort:Sort = new Sort();
				actionGroupSort.fields = [new SortField('name')];
				this._model.indigoActionGroupList.sort = actionGroupSort;
				this._model.indigoActionGroupList.refresh();
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE)
			{
				this._model.indigoVariableList = createVariableList(handleList(packetData, 'Variable', 'Name'));

				var variableSort:Sort = new Sort();
				variableSort.fields = [new SortField('name')];
				this._model.indigoVariableList.sort = variableSort;
				this._model.indigoVariableList.refresh();
			}
			else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER)
			{
				this._model.indigoTriggerList = createTriggerList(handleList(packetData, 'Trigger', 'Name'));

				var triggerSort:Sort = new Sort();
				triggerSort.fields = [new SortField('name')];
				this._model.indigoTriggerList.sort = triggerSort;
				this._model.indigoTriggerList.refresh();
			}
            else if (packetName == IndigoConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE)
			{
				this._model.indigoScheduleList = createScheduleList(handleList(packetData, 'TDTrigger', 'Name'));

				var scheduleSort:Sort = new Sort();
                scheduleSort.fields = [new SortField('name')];
				this._model.indigoScheduleList.sort = scheduleSort;
				this._model.indigoScheduleList.refresh();
			}
		}

		//This function handles the packet formating / Marshalling for IndigoPakcets
		private function handleList(packetData:XMLList, node:String, sortBy:String):XML
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
		private function requestCache():void
        {
	    	// Request all data lists
	       	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_ACTION_GROUP);
	       	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_DEVICE);
	      	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_TRIGGER);
	   	  	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_SCHEDULE);
	   	  	requestList(IndigoConstants.INDIGO_PACKET_REQUEST_LIST_VARIABLE);
	   	}
				
		private function requestList(listType:String):void
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
	   	   	sendPacket(getListPacket);
	    }
	

        /************************************************************************************/
        // PACKET PUSHER (FOR OUTGOING PACKETS)
        /***********************************************************************************/
        private function sendPacket(packet:XML):void
        {
           // Format the packet before being sent to the server.
           var formattedPacket:String = '';
           var packetString:String = packet.toString();
           var packetArray:Array = packetString.split("\n");

           for (var i:int = 0; i < packetArray.length; i++)
           {
               formattedPacket = formattedPacket + StringUtil.trim(packetArray[i]);
           }

           this._indigoSocket.send(formattedPacket);
        }
	
		/************************************************************************************/
		// XML LIST CACHE AND ARRAYCOLLECTION MODIFIERS
		/***********************************************************************************/ 	
		private function addItem(packetData:XMLList, listCache:XML, node:String, sortBy:String):XML
		{
			var listTemp:XMLListCollection;
				
			packetData.setLocalName(node);
	   		listCache..appendChild(packetData);
			listTemp = new XMLListCollection(listCache[node]);
	    	listCache = XML('<Data type="dict">' + (SortUtil.sortData(listTemp, sortBy)).toXMLString() + '</Data>');
			return listCache;
		}
		
		private function addObject():ArrayCollection
		{
			var tempCollection:ArrayCollection = new ArrayCollection();
			
			return tempCollection;
		}
			
		private function removeItem(packetData:XMLList, listCache:XML, node:String, sortBy:String):XML
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
		
		private function removeObject():ArrayCollection
		{
			var tempCollection:ArrayCollection = new ArrayCollection();
			
			return tempCollection;
		}
			
		private function replaceDevice(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
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
		
		private function replaceVariable(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
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
	     			_model.indigoVariableDictionary[updatedIndigoVariable.name] = updatedIndigoVariable.value;
	     			dispatchEvent(new IndigoVariableChangeEvent(tempIndigoVariable));
	     		}  		
	       	}
		}

        private function replaceActionGroup(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
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

        private function replaceTrigger(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
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

        private function replaceSchedule(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
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