package com.perceptiveautomation.indigo.delegates
{
	import com.perceptiveautomation.indigo.HashUtil;
	import com.perceptiveautomation.indigo.control.IndigoComBroker;
	import com.perceptiveautomation.indigo.device.events.IndigoDeviceEvent;
	import com.perceptiveautomation.indigo.events.IndigoConnectEvent;
	import com.perceptiveautomation.indigo.events.IndigoEvents;
	import com.perceptiveautomation.indigo.events.IndigoUpdateTimeEvent;
	import com.perceptiveautomation.indigo.model.IndigoModel;
	import com.perceptiveautomation.indigo.variable.events.IndigoVariableEvent;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoActionGroup;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoDevice;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoTimeDateTrigger;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoTrigger;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoVariable;
	import com.perceptiveautomation.indigo.vo.IndigoDeviceFactory;
	import com.perceptiveautomation.indigo.vo.IndigoLogin;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.XMLSocket;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.utils.StringUtil;
	
	public class IndigoDelegate
	{
		private var _model:IndigoModel = IndigoModel.getInstance();
		private var _broker:IndigoComBroker;
		
		//Constructor
		public function IndigoDelegate()
		{
			this._broker = IndigoComBroker.getInstance();	
		}
		
		/*************************************************************************/
		//CONNECTION FUNCTIONS
		/*************************************************************************/		
			
		public function loadFlashConnectionPrefs():void
		{
			/* 	Upon entering the the start state (Login) try to setup a request for the connection information from the Indigo server. 
				If this fails, try to load the connection information from a shared object created in a previous session. This will
				only work if the client is being hosted on the Indigo web server.
			*/
	  		var request:URLRequest;
	  		var variables:URLLoader;
	  		
	  		request = new URLRequest("/flash_conn_prefs");
	 	  	variables = new URLLoader();
	  	  	variables.dataFormat = URLLoaderDataFormat.VARIABLES;
	  	  	variables.addEventListener(Event.COMPLETE, loadFlashConnectionPrefsHandler);
	  	  	variables.addEventListener(IOErrorEvent.IO_ERROR, loadFlashConnectionPrefsErrorHandler);
	  	  	variables.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFlashConnectionPrefsErrorHandler);
	  	  	try
	  	  	{
	  	    	variables.load(request);
	  	  	} 
	  	  	catch (e:Error)
	  	  	{
	        	trace("Unable to load URL: " + e);
	  	  	}
	   	}
	   
		private function loadFlashConnectionPrefsHandler(event:Event):void
		{
	   		// If the /flash_conn_prefs request was successful then assign the returned variables.
	   		var loader:URLLoader;
	   		
	   		loader = URLLoader(event.target);
	    	this._model.xmlServerIP = loader.data.XmlServer_IP;
	    	this._model.xmlServerPort = loader.data.XmlServer_Port;
	 		this._model.xmlServerUser = loader.data.XmlServer_User;
	    	this._model.xmlServerHash = loader.data.XmlServer_Hash;
	    	connectXMLSocket(this._model.xmlServerIP, this._model.xmlServerPort);
		}
	   
	   	private function loadFlashConnectionPrefsErrorHandler(event:Event):void
	   	{
	   		/* 	If the request for the /flash_conn_prefs file from Indigo failed for any reason try to load the connection information 
	   			from a shared object created in a previous session and populate the login form.
	   		*/
	    	var mySo:SharedObject;
	    	
	    	try
	    	{
	    		mySo = SharedObject.getLocal("Pref");
	    		//HostTxt.text = mySo.data.host;
	    		//PasswordTxt.text = mySo.data.password;
	    		//UsernameTxt.text = mySo.data.userName;
	    	} catch (e:Error){
	    		trace("Unable to load Shared Object: " + e);
	    	}
	    	
	    	//UsernameTxt.setFocus();
	    }
	    
	    public function savePref():void
	    {
	    	/* 	If the user clicked the "Remember me button on the login form, create a shared object and write the connection infomation to it.
	    	*/
	    	var mySo:SharedObject;
	    	
	    	mySo = SharedObject.getLocal("Pref");
	    	//mySo.data.host = HostTxt.text;
	    	mySo.data.host = "192.168.1.201";
	    	//mySo.data.password = PasswordTxt.text;
	    	mySo.data.password = "";
	    	//mySo.data.userName = UsernameTxt.text;
	    	mySo.data.userName = "";
	    	
	    	mySo.flush();
	    }
		
		public function connect(data:IndigoLogin):void
		{
			/*	When the user clicks the connect button on the login form, assign the info entered on the login form to the corrent variables
				and submit a request to create a connection with the server.
			*/
			//this._model.XmlServer_User = UsernameTxt.text;
			this._model.xmlServerUser = data.username;
			
	    	//this._model.XmlServer_Password = PasswordTxt.text;
	    	this._model.xmlServerPassword = data.password;
	    	
	    	//this._model.XmlServer_IP = HostTxt.text; 
	    	this._model.xmlServerIP = data.host;
	    	
	    	//TO-DO:
	    	//leave it hard coded for now
	    	//this._model.xmlServerPort = data.port; 
	    	
	   		connectXMLSocket(this._model.xmlServerIP, this._model.xmlServerPort);
	   		
	   		//this.currentState = '';
	   		this._model.applicationState = "";
	    }
	   	
	   	private function sendAuthenticateKnock():void{
	   		/* Create and send an AuthenticateKnock packet
	   		*/ 
	    	var authenticatePacket:XML;									
	    	// Create the authenticate packet type in XML format.
	    		
	    	authenticatePacket = <Packet />;
	      	authenticatePacket.@type = 'dict';
	      	authenticatePacket.Type = 'Authenticate';
	      	authenticatePacket.Type.@type = 'string';
	    	authenticatePacket.Name = 'KnockKnock';
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
	   		authenticatePacket.Type = 'Authenticate';
	   		authenticatePacket.Type.@type = 'string';
	   		authenticatePacket.Name = 'AttemptAuthentication';
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
	     	this._model.indigoSocket = new XMLSocket();
	     	configureListeners(this._model.indigoSocket);
	     	this._model.indigoSocket.connect(this._model.xmlServerIP, this._model.xmlServerPort);
	     	  	
		}
		
	
		/************************************************************************************/
		// INDIGO EVENT LISTENERS
		/***********************************************************************************/ 
		private function configureListeners(dispatcher:IEventDispatcher):void 
		{
			/* Configure event listeners to handle any response from the server.
			*/
	    	dispatcher.addEventListener(Event.CLOSE, connectClosedHandler);
	    	dispatcher.addEventListener(Event.CONNECT, connectCompleteHandler);
	    	dispatcher.addEventListener(DataEvent.DATA, packetHandler);
	    	dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); 
	    	dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	    	dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	    }
	        
	        
		/************************************************************************************/
		// EVENT HANDLERS
		/***********************************************************************************/         
	    private function connectClosedHandler(event:Event):void 
	    {
			/*	If the connection to the server closes, return to the login page.*/
			this._model.applicationState = "Login";
			
			//Fire ComBroker event
			//this.globals.broker.dispatchEvent(new IndigoEvent(IndigoEvents.INDIGO_CONNECTION_CLOSED,null));
	    }
	
	   	private function connectCompleteHandler(event:Event):void 
	   	{
	   		/* Once the connection is complete send the Authenticate Knock packet to begin the autentication process.*/
			sendAuthenticateKnock();
			
			//Fire ComBroker event
			//this.globals.broker.dispatchEvent(new IndigoEvent(IndigoEvents.INDIGO_CONNECTION_COMPLETE,null));
		}
	
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			/*	If there was an error connecting to the server return to the login page.*/
	   	 	this._model.applicationState = "Login";	
	   	 	
	   	 	//Fire ComBroker event
			//this.globals.broker.dispatchEvent(new IndigoEvent(IndigoEvents.INDIGO_CONNECTION_CLOSED,null));
		}
	
	
	   	private function securityErrorHandler(event:SecurityErrorEvent):void 
	   	{
	   		/*	If there was an error connecting to the server return to the login page.*/
			this._model.applicationState = "Login";
			
			//Fire ComBroker event
			//this.globals.broker.dispatchEvent(new IndigoEvent(IndigoEvents.INDIGO_CONNECTION_CLOSED,null));
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
	   		/* Handle the different packet types returned by the server.
	   		*/
	   		var packetData:XMLList; // The data node's descendants striped from the response packet.
	   		var packetName:String;  // The packet name.
	   		var packetType:String;  // The type of packet.
	   		var responsePacket:XML  // The entire packet as returned by the server.
	  			
	   		responsePacket = new XML(event.data); 				//Store the entire response packet from the server.
	   		packetType = responsePacket.Type.toString();		//Strip out the packet type so we can determine how to process it.
	   		packetName = responsePacket.Name.toString(); 		//Strip out the packet name so we can determine how to process it's contents later.
	   		packetData = responsePacket.descendants("Data");	//Strip out the data node's descendets so we can process them later.
	   		if (packetType == "Authenticate"){						//If the packet type is "Authenticate" pass the packet name and data to 
	   			 handleAuthenticatePacket(packetName, packetData);	//the correct function.
	   		}
	  		
	   		if (packetType == "Broadcast"){							//If the packet type is "Broadcast" pass the packet name and data to
	   			 handleBroadcast(packetName, packetData);			//the correct function.
	   		}
	      		       		
	   		if (packetType == "Response"){							//If the packet type is "Response" pass the packet name and data to
	   			 handleResponse(packetName, packetData);			//the correct function.
			}
	   	}
	   	
	   	private function handleAuthenticatePacket(packetName:String, packetData:XMLList):void 
	   	{
			/* Handle the authentication process.
			*/
			trace(packetData);
			
			if (packetName == "IPFailed") 
			{ 					
				//Indigo Server is not allowing this IP address.
				//Application.application.currentState = 'Login';	
				
				this._model.applicationState = 'Login'
				
				// Not much we can do about this failure -- Indigo
				// Server is about to disconnect us.
			} 
			else if (packetName == "NeedPassword") 
			{									
				this._model.indigoServerSalt = packetData.toString();
				
				//gSaltFromServer = packetData.toString(); 
				// Store random salt passed by server. We'll will concat
				// this on to the user's raw password before we crypto-
 				// hash it.
				if (this._model.xmlServerUser != "" && this._model.xmlServerHash != "") 
				{
					sendAuthenticatePassword(this._model.xmlServerUser, null , this._model.xmlServerHash);    
					// The Indigo web server was nice enough to give us the 
					// user name and password hash since we already authenticated 
					// against it. We can directly connect without prompting 
					// the user.
				}
				else if (this._model.xmlServerUser != "" && this._model.xmlServerPassword != "")
				{
					sendAuthenticatePassword(this._model.xmlServerUser, this._model.xmlServerPassword , null);
					// If we didn't get the connection info from Indigo but 
					// instead from the login form. Pass the raw information to
					// the encryption function. 
				}
				else
				{
					this._model.applicationState = 'Login';	
					// If we have no connection info from any source we 
					// need to prompt for the user name and password.
				}
			} 
			else if (packetName == "PasswordFailed") 
			{
				this._model.applicationState = 'Login';
				//Application.application.currentState = 'Login';
						
				// Password was incorrect, but Indigo Server is letting
				// us try again before disconnect. We re-use the salt
				// originally passed to us by the "NeedPassword" packet and 
				// return the user to the login form to re-enter their 
				// information.
			} 
			else if (packetName == "Success") 
			{
				requestCache();									
				this._model.applicationState = 'Welcome';		
				this._broker.dispatchEvent(new IndigoConnectEvent());
				// The client successfully logged into the server. 
				//Request the cache and set the client state to the base state.
			}
		}
		
		private function handleBroadcast(packetName:String, packetData:XMLList):void 
		{
	   		/* Handle broadcast packets from the server
	   		*/
	   		if (packetName == "UpdatedRegInfo")
	   		{													
	   			// Handle "UpdatedRegInfo" packet.
				// Not used. Add code here if 
				// needed.
				
	     	} 
	     	else if (packetName == "UpdatedTimeInfo") 
	     	{			
     			this._broker.dispatchEvent(new IndigoUpdateTimeEvent(packetData[0].CurrentTime));
			} 
			else if (packetName == "LogStream") 
			{
				//this._model.indigoLogStream = addItem(packetData, Application.application.gLogStream, 'Message', 'TimeCount');
											
				// Handle adding a 
				// "LogStream" item. Append the 
				// packetData in the
				// 'Message' element to 
				// "Application.application.gLogStream" 
		       	// and sort the data by 'TimeCount'.
				// ------------------------
			} 
			else if (packetName == "AddedDevice") 
			{
				//Application.application.gDeviceListCache = addItem(packetData, Application.application.gDeviceListCache, 'Device', 'Name'); 					
				
				// Handle adding a 
				// "DeviceListCache" item. Add 
				// the packetData in the 
				// 'Device' element to 
				// "Application.application.gDeviceListCache" 
				// and sort by 'Name'.
			} 
			else if (packetName == "AddedTrigger") 
			{
				//Application.application.gTriggerListCache = addItem(packetData, Application.application.gTriggerListCache, 'Trigger', 'Name');					
				
				// Handle adding a 
				// "TriggerListCache" item. Add 
				// the packetData in the 
				// 'Trigger' element to 
				// "Application.application.gTriggerListCache"
				// and sort by 'Name'.
			} 
			else if (packetName == "AddedTDTrigger") 
			{
				//Application.application.gTDTriggerListCache = addItem(packetData, Application.application.gTDTriggerListCache, 'TDTrigger', 'Name');			
				
				// Handle adding a 
				// "TDTriggerListCache" item. Add 
				// the packetData in the 
				// 'TDTrigger' element to 
				// "Application.application.gTDTriggerListCache" 
				// and sort by 'Name'.
			}
			else if (packetName == "AddedActionGroup") 
			{
				//Application.application.gActionGroupListCache = addItem(packetData, Application.application.gActionGroupListCache, 'ActionGroup', 'Name');		
				
				// Handle adding a 
				// "ActionGroupListCache" item. Add 
			    // the packetData in the 
			    // 'ActionGroup' element to
				// "Application.application.gActionGroupListCache" 
				// and sort by 'Name'.
			} 
			else if (packetName == "AddedVariable") 
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
			else if (packetName == "RemovedDevice") 
			{
				//Application.application.gDeviceListCache = removeItem(packetData, Application.application.gDeviceListCache, 'Device', 'Name');
				
				// Handle removing a 
				// "DeviceListCache" item. 
				// Remove the packetData in the
				// 'Device' element from 
				// 'Application.application.gDeviceListCache' and
				// sort by 'Name'.
			} 
			else if (packetName == "RemovedTrigger") 
			{
				//Application.application.gTriggerListCache = removeItem(packetData, Application.application.gTriggerListCache, 'Trigger', 'Name');	
				
				// Handle removing a 
				// "TriggerListCache" item. 
				// Remove the packetData in the 
				// 'Trigger' element from 
				// 'Application.application.gTriggerListCache' and 
				// sort by 'Name'.
			} 
			else if (packetName == "RemovedTDTrigger") 
			{
				//Application.application.gTDTriggerListCache = removeItem(packetData, Application.application.gTDTriggerListCache, 'TDTrigger', 'Name');		
				
				// Handle removing a 
				// "TDTriggerListCache" item. 
				// Remove the packetData in the 
				// 'TDTrigger' element from 
				// 'Application.application.gTDTriggerListCache' and 
				// sort by 'Name'.
			} 
			else if (packetName == "RemovedActionGroup") 
			{
				//Application.application.gActionGroupListCache = removeItem(packetData, Application.application.gActionGroupListCache, 'ActionGroup', 'Name');	
				
				// Handle removing a 
				// "ActionGroupListCache" 
				// item. Remove the packetData in 
				// the 'ActionGroup' element from
				// 'Application.application.gActionGroupListCache' and 
				// sort by 'Name'.
			} 
			else if (packetName == "RemovedVariable") 
			{
				//Application.application.gVariableListCache = removeItem(packetData, Application.application.gVariableListCache, 'Variable', 'Name');			// Handle removing a 
				
				// "VariableListCache"
				// item. Remove the packetData in
				// the 'Variable' element from
				// 'gApplication.application.gVariableListCache' and
				// sort by 'Name'.
				// ------------------------
			} 
			else if (packetName == "ReplacedDevice") 
			{
				replaceDevice(packetData, _model.indigoDeviceList, 'Name');
			} 
			else if (packetName == "ReplacedTrigger") 
			{
				//replaceTrigger(packetData, model.indigoTriggerList, 'None');
			} 
			else if (packetName == "ReplacedTDTrigger") 
			{
				//replaceTDTrigger(packetData, model.indigoTimeDateTriggerList, 'Name');
			} 
			else if (packetName == "ReplacedActionGroup") 
			{
				//replaceActionGroup(packetData, model.indigoActionGroupList, 'Name');
			} 
			else if (packetName == "ReplacedVariable") 
			{
				replaceVariable(packetData, _model.indigoVariableList, 'Name');
			}
		}
		
		
		//FUNCTION TO TEST DEVICE OBJECT CREATION
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
			var tempActionGroup:AbstractIndigoActionGroup;
			for(var i:int=0; i<len;i++)
			{
				tempActionGroup = new AbstractIndigoActionGroup(xml..ActionGroup[i]);
				tempActionGroupCollection.addItem(tempActionGroup);
			}
			return tempActionGroupCollection;
		}
		
		private function createVariableList(xml:XML):ArrayCollection
		{
			var len:int = xml..Variable.length();
			var tempVariableCollection:ArrayCollection = new ArrayCollection();
			var tempVariable:AbstractIndigoVariable;
			for(var i:int=0; i<len;i++)
			{
				tempVariable = new AbstractIndigoVariable(xml..Variable[i]);
				tempVariableCollection.addItem(tempVariable);
			}
			return tempVariableCollection;
		}
		
		private function createTDTriggerList(xml:XML):ArrayCollection
		{
			var len:int = xml..TDTrigger.length();
			var tempTDTriggerCollection:ArrayCollection = new ArrayCollection();
			var tempTDTrigger:AbstractIndigoTimeDateTrigger;
			for(var i:int=0; i<len;i++)
			{
				tempTDTrigger = new AbstractIndigoTimeDateTrigger(xml..TDTrigger[i]);
				tempTDTriggerCollection.addItem(tempTDTrigger);
			}
			return tempTDTriggerCollection;
		}
		
		private function createTriggerList(xml:XML):ArrayCollection
		{
			var len:int = xml..Trigger.length();
			var tempTriggerCollection:ArrayCollection = new ArrayCollection();
			var tempTrigger:AbstractIndigoTrigger;
			for(var i:int=0; i<len;i++)
			{
				tempTrigger = new AbstractIndigoTrigger(xml..Trigger[i]);
				tempTriggerCollection.addItem(tempTrigger);
			}			
			return tempTriggerCollection;
		}
		
		private function handleResponse(packetName:String, packetData:XMLList):void 
		{
			/* Handle the various request list commands
			*/
			if (packetName == "GetDeviceList") 
			{
				this._model.indigoDeviceList = createDeviceList(handleList(packetData, 'Device', 'Name'));	
				
				var deviceSort:Sort = new Sort();
				deviceSort.fields = [new SortField('name')];
				this._model.indigoDeviceList.sort = deviceSort;
				this._model.indigoDeviceList.refresh();
				this._broker.dispatchEvent( new Event(IndigoEvents.INDIGO_DEVICE_LIST_UPDATE_EVENT) );
			} 
			else if (packetName == "GetActionGroupList") 
			{
				this._model.indigoActionGroupList = createActionGroupList(handleList(packetData, 'ActionGroup', 'Name'));
				
				var actionGroupSort:Sort = new Sort();
				actionGroupSort.fields = [new SortField('name')];
				this._model.indigoActionGroupList.sort = actionGroupSort;
				this._model.indigoActionGroupList.refresh();
				this._broker.dispatchEvent( new Event(IndigoEvents.INDIGO_ACTION_GROUP_LIST_UPDATE_EVENT) );
			} 
			else if (packetName == "GetVariableList") 
			{
				this._model.indigoVariableList = createVariableList(handleList(packetData, 'Variable', 'Name'));
				
				var variableSort:Sort = new Sort();
				variableSort.fields = [new SortField('name')];
				this._model.indigoVariableList.sort = variableSort;
				this._model.indigoVariableList.refresh();
				this._broker.dispatchEvent( new Event(IndigoEvents.INDIGO_VARIABLE_LIST_UPDATE_EVENT) );
			} 
			else if (packetName == "GetTDTriggerList") 
			{
				this._model.indigoTimeDateTriggerList = createTDTriggerList(handleList(packetData, 'TDTrigger', 'Name'));
				
				var tdTriggerSort:Sort = new Sort();
				tdTriggerSort.fields = [new SortField('name')];
				this._model.indigoTimeDateTriggerList.sort = tdTriggerSort;
				this._model.indigoTimeDateTriggerList.refresh();
			} 
			else if (packetName == "GetTriggerList") 
			{
				this._model.indigoTriggerList = createTriggerList(handleList(packetData, 'Trigger', 'Name'));
				
				var triggerSort:Sort = new Sort();
				triggerSort.fields = [new SortField('name')];
				this._model.indigoTriggerList.sort = triggerSort;
				this._model.indigoTriggerList.refresh();
			}
		}
		
		//This function handles the packet formating / Marshalling for IndigoPakcets
		private function handleList(packetData:XMLList, node:String, sortBy:String):XML
		{
			/* Handle the parsing for the Get'x'List request.
			*/
	    	var listCache:XML; 						// Stores the sorted list.
	    	var listTemp:XMLListCollection;			// Stores a collection of XML nodes defined by the calling code.
	    	listTemp = new XMLListCollection(packetData[node]);
	    	listCache = new XML('<Data type="dict">' + (sortData(listTemp, sortBy)).toXMLString() + '</Data>');
	   		return listCache;
		}
		
		
		
		/************************************************************************************/
		// SERVER REQUEST FUNCTIONS
	 	/***********************************************************************************/ 	
		private function requestCache():void{
	    	/* Intially request all lists to populate the data providers for each UI control.
	    	*/
	       	requestList('GetDeviceList');
	       	requestList('GetActionGroupList');
	      	requestList('GetTDTriggerList');
	      	requestList('GetTriggerList');
	   	  	requestList('GetVariableList');
	   	}
				
		public function refreshDevices():void
		{
			requestList('GetDeviceList');
		}
		
		public function refreshVariables():void
		{
			requestList('GetVariableList');
		}
		
		private function requestList(listType:String):void{
	   	   	/* Create a send a Get'x'List request packet.
	   	   	*/
	   	   	
	   	   	var getListPacket:XML;										
	   	   	// Create the get list packet type in XML format.
	   	   	
	   	   	getListPacket = <Packet />;
	   	   	getListPacket.@type = 'dict';
	   	   	getListPacket.Type = 'Request';
	   	   	getListPacket.Type.@type = 'string';
	   	   	getListPacket.Name = listType;
	   	   	getListPacket.Name.@type = 'string';
	   	   	sendPacket(getListPacket);
	    }
	
		
		/************************************************************************************/
		// PACKET PUSHER (FOR OUTGOING PACKETS)
	 	/***********************************************************************************/ 	
		private function sendPacket(packet:XML):void{
	   		/* Format the packet before being sent to the server.
	   		*/
	    	var formattedPacket:String = '';
	    	var packetString:String = packet.toString();								// Convert the XML packet to a string.
	    	var packetArray:Array = packetString.split("\n");							// Split the string at the new line 
	    																				// character and load each line into and array.
	     		            					
			for (var i:int = 0; i < packetArray.length; i++){							// For each item in the array strip leading or trailing
				formattedPacket = formattedPacket + StringUtil.trim(packetArray[i]);    // white spaces and append to formatted packet.
			}
				this._model.indigoSocket.send(formattedPacket);							// Send the formated packet.
		}
	
	    
	    
		/************************************************************************************/
		// INDIGO BASE COMMAND FUNCTION
		/***********************************************************************************/        
	   	public function sendCommand(name:String, command:String, value:Number):void
	   	{
	    	/* Create and send a command packet to the Indigo server
	    	*/
	       	var sendCommandPacket:XML;									// Create the command packet type in XML format.
	    	   	
	       	sendCommandPacket = <Packet />;													
	       	sendCommandPacket.@type = 'dict';
	      	sendCommandPacket.Type = 'Command';
	      	sendCommandPacket.Type.@type = 'string';
	      	sendCommandPacket.Name = command;
	     	sendCommandPacket.Name.@type = 'string';
	     	if(command == 'SetBrightness' || command == 'Dim' || command == 'Brighten'){	//Determine if the device is dimmable
	    		sendCommandPacket.Data.@type = 'dict';
	    		sendCommandPacket.Data.Name = name;
	    		sendCommandPacket.Data.Name.@type = 'string';
	    		sendCommandPacket.Data.Amount = value;
	    		sendCommandPacket.Data.Amount.@type = 'string';
	    	} else {
	    		sendCommandPacket.Data = name;
	    		sendCommandPacket.Data.@type = 'string';
	    	}
	    	sendPacket(sendCommandPacket);
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
	    	listCache = XML('<Data type="dict">' + (sortData(listTemp, sortBy)).toXMLString() + '</Data>');
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
	       	listCache = XML('<Data type="dict">' + (sortData(listTemp, sortBy)).toXMLString() + '</Data>');
			return listCache;
		}
		
		private function removeObject():ArrayCollection
		{
			var tempCollection:ArrayCollection = new ArrayCollection();
			
			return tempCollection;
		}
			
		private function replaceDevice(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
		{
	       	var updatedIndigoDevice:AbstractIndigoDevice = new AbstractIndigoDevice(packetData.Device);
	       	var tempIndigoDevice:AbstractIndigoDevice;
	       	var len:int = collection.length;
	       	for (var i:int = 0; i < len; i++)
	       	{
	       		tempIndigoDevice = collection.getItemAt(i) as AbstractIndigoDevice;
	     		if (updatedIndigoDevice.name == tempIndigoDevice.name)
	     		{
					tempIndigoDevice.fill(updatedIndigoDevice);
	     			this._broker.dispatchEvent(new IndigoDeviceEvent(tempIndigoDevice));
	     		}  		
	       	}
		}
		
		private function replaceVariable(packetData:XMLList, collection:ArrayCollection, sortBy:String):void
		{
	       	var updatedIndigoVariable:AbstractIndigoVariable = new AbstractIndigoVariable(packetData.Variable);
	       	var tempIndigoVariable:AbstractIndigoVariable;
	       	var len:int = collection?collection.length:0;
	       	for (var i:int = 0; i < len; i++)
	       	{
	       		tempIndigoVariable = collection.getItemAt(i) as AbstractIndigoVariable;
	     		if (updatedIndigoVariable.name == tempIndigoVariable.name)
	     		{
	     			tempIndigoVariable.value = updatedIndigoVariable.value;
	     			_model.indigoVariableDictionary[updatedIndigoVariable.name] = updatedIndigoVariable.value;
	     			this._broker.dispatchEvent(new IndigoVariableEvent(tempIndigoVariable));
	     		}  		
	       	}
		}
	   		 
	   
	   		
		/************************************************************************************/
		// PRIVATE HELPER FUNCTIONS
		/***********************************************************************************/       	
//	    private function formatIsOn(item:Object, column:DataGridColumn):String
//	    {
//			var returnStr:String;
//			
//			if (item..IsOn == 'true'){
//				returnStr = 'On';
//			} else {
//				returnStr = 'Off';
//			}
//			return returnStr;
//		}
//	
//		private function formatUpdateTimeInfo(time:Number):String
//		{
//	   		var includeSecs:Boolean;
//	   		var hours:Number;
//	   		var mins:int;
//	   		var returnStr:String;
//	   		var seconds:int
//	   		var timeCount:Number;
//	   		var timePortion:Number;
//	   		
//	   		timeCount = time;
//	   		timePortion = timeCount-(int(timeCount/(24*3600))*24*3600);
//			hours = int(timePortion/3600);
//			if (hours<10) {
//				returnStr = "0" + hours;
//			} else {
//				returnStr += hours;
//			}
//			mins = int((timePortion-hours*3600)/60);
//			if (mins<10) {
//				returnStr += ":" + "0" + mins;
//			} else {
//				returnStr += ":" + mins;
//			}
//			if (includeSecs) {
//				seconds = int(timePortion-hours*3600-mins*60);
//				if (seconds<10) {
//					returnStr += ":" + "0" + seconds;
//				} else {
//					returnStr += ":" + seconds;
//				}
//			}
//			return returnStr;
//	   	}	
			
		
		private function sortData(list:XMLListCollection, field:String):XMLListCollection 
		{
			var sort:Sort;
				
			sort = new Sort();
			sort.fields = [new SortField(field, true)];
			list.sort = sort;
			list.refresh();
			return list;
		}
	}
}