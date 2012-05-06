package com.perceptiveautomation.indigo.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
	import com.perceptiveautomation.indigo.device.IIndigoDevice;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoDevice;
	import com.perceptiveautomation.indigo.vo.AbstractIndigoVariable;
	import com.perceptiveautomation.indigo.vo.IndigoRegInfo;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.XMLSocket;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class IndigoModel extends EventDispatcher implements IModelLocator
	{
		private static var _instance:IndigoModel;
		private static var _canInit:Boolean;
		
		public function IndigoModel()
		{
			if (!_canInit || _instance)
				throw new IllegalOperationError("IndigoModel can only be instantiated using IndigoModel.getInstance()");
				
			return;	
		}
		
		public static function getInstance():IndigoModel
		{
			_canInit = true;
			
			if (!_instance)
				_instance = new IndigoModel();
				
			return _instance;
		}
		
		public var applicationStatusMessage:String;
		
		public var applicationState:String ='Login';
		
		//XML socket connection to the Indigo server.
		public var indigoSocket:XMLSocket;			
		
		//Hash salt retrieved during the authtication process. Used to encrypt the raw password.   
		public var indigoServerSalt:String;		   
		
		//Host server derived from the Indigo server, Flash shared object, or login form.
		public var xmlServerIP:String = "";	   
		
		//Host port derived from the Indigo server if present or set statically here.
		public var xmlServerPort:int = 1176;	   
		
		//Host password hash derived from the Indigo server if present.
		public var xmlServerHash:String = "";	   
		
		//Host raw password derived from Falsh shared object or login form.
		public var xmlServerPassword:String = ""; 
		
		//Host username derived from the Indigo server, Falsh shared object, or login form.
		public var xmlServerUser:String = "";	   
		
		//Local cache of the Device list. Bound to the deviceList datagrid UI control.
		private var _indigoDeviceList:ArrayCollection;
		
		[Bindable(event='indigoDeviceListChanged')]
		public function get indigoDeviceList():ArrayCollection
		{
			return this._indigoDeviceList;		
		}
				
		public function set indigoDeviceList(value:ArrayCollection):void
		{
			if (_indigoDeviceList !=  value)
			{
				_indigoDeviceList = value;	
				
				indigoDeviceDictionary = new Dictionary(true);
				
				var len:int = _indigoDeviceList?_indigoDeviceList.length:0;
				var tempDevice:IIndigoDevice;
				for (var i:int=0; i < len; i++)
				{
					tempDevice = _indigoDeviceList.getItemAt(i) as IIndigoDevice;
					if (tempDevice)
					{
						indigoDeviceDictionary[tempDevice.name] = tempDevice;
					}
				}	
			}
					
			dispatchEvent( new Event('indigoDeviceListChanged') );
		}
		
		public var indigoDeviceDictionary:Dictionary;
				
		
		public function getDevicesByType(type:String):ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			var len:int = this._indigoDeviceList?this._indigoDeviceList.length:0;
			var tempDevice:AbstractIndigoDevice;
			for (var i:int=0; i < len; i++)
			{
				tempDevice = this._indigoDeviceList.getItemAt(i) as AbstractIndigoDevice;
				if (tempDevice && tempDevice.description.indexOf(type) > -1)
				{
					result.addItem( tempDevice );
				}
			}
			
			return result;
		}
		
		//Local cache of the Action Group list. Bound to the actionList datagrid UI control.
		private var _indigoActionGroupList:ArrayCollection;
		
		[Bindable(event='indigoActionGroupListChanged')]
		public function get indigoActionGroupList():ArrayCollection
		{
			return this._indigoActionGroupList;		
		}
				
		public function set indigoActionGroupList(value:ArrayCollection):void
		{
			if (_indigoActionGroupList !=  value)
			{
				_indigoActionGroupList = value;		
				
				indigoActionGroupDictionary = new Dictionary(true);
				
				var len:int = _indigoActionGroupList?_indigoActionGroupList.length:0;
				var tempActionGroup:IIndigoActionGroup;
				for (var i:int=0; i < len; i++)
				{
					tempActionGroup = _indigoActionGroupList.getItemAt(i) as IIndigoActionGroup;
					if (tempActionGroup)
					{
						indigoActionGroupDictionary[tempActionGroup.name] = tempActionGroup;
					}
				}	
			}
					
			dispatchEvent( new Event('indigoActionGroupListChanged') );
		} 
		
		public var indigoActionGroupDictionary:Dictionary;
		
		//Local cache of the Log stream. Bound to the logList datagrid UI control.
		public var indigoLogStream:ArrayCollection;
		public var logStream:XML = <Data/>;
		
		//Local cache of the Registration info. Not used in the UI.
		public var indigoRegInfo:IndigoRegInfo;
		public var regInfoCache:XML;			
		
		//Local cache of the Time and Data Trigger List.
		public var indigoTimeDateTriggerList:ArrayCollection;
		//public var timeDateTriggerListCache:XML;		
		
		//Local cache of the Trigger List.
		public var indigoTriggerList:ArrayCollection;
		//public var triggerListCache:XML;		
		
		//Local cache of the Variable list.
		public var indigoVariableDictionary:Dictionary;
		
		private var _indigoVariableList:ArrayCollection;
		
		[Bindable(event='indigoVariableListChanged')]
		public function get indigoVariableList():ArrayCollection
		{
			return this._indigoVariableList;
		}
		
		public function set indigoVariableList(value:ArrayCollection):void
		{
			if (!this._indigoVariableList)
				this._indigoVariableList = new ArrayCollection();
				
			if (value)	
			{	
				this._indigoVariableList.source = value.source;
				
				indigoVariableDictionary = new Dictionary(true);
				
				var tempVariable:AbstractIndigoVariable;	
				var len:int = value.length;
				for (var i:int=0; i < len; i++)
				{
					tempVariable = value.getItemAt(i) as AbstractIndigoVariable;
					indigoVariableDictionary[tempVariable.name] = tempVariable.value;
				}	
				
				this._indigoVariableList.refresh();
			}
			else
				this._indigoVariableList.source = null;
				
			
			dispatchEvent(new Event('indigoVariableListChanged'));
		}
			
		//Local cache of the Update Time. Bound to the corresponding display labels in the base state.
		//public var indigoUpdateTimeInfoList:ArrayCollection;	
		
		
		public var updateTimeInfo:String; 
	}
}