package com.perceptiveautomation.indigo.model
{
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.constants.IndigoConstants;
    import com.perceptiveautomation.indigo.device.AbstractIndigoDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDevice;
    import com.perceptiveautomation.indigo.schedule.IndigoSchedule;
    import com.perceptiveautomation.indigo.trigger.IndigoTrigger;
    import com.perceptiveautomation.indigo.variable.IndigoVariable;
    import com.perceptiveautomation.indigo.vo.IndigoRegInfo;

    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class IndigoModel extends EventDispatcher
	{
		private static var _instance:IndigoModel;
		protected static var _canInit:Boolean;
		
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
		
		public var indigoState:String = IndigoConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
		
		//Hash salt retrieved during the authtication process. Used to encrypt the raw password.
		public var serverSalt:String;
		
		//Host server derived from the Indigo server, Flash shared object, or login form.
		public var host:String = "";
		
		//Host port derived from the Indigo server if present or set statically here.
		public var port:int = 1176;
		
		//Host password hash derived from the Indigo server if present.
		public var authHash:String = "";
		
		//Host raw password derived from Falsh shared object or login form.
		public var password:String = "";
		
		//Host username derived from the Indigo server, Falsh shared object, or login form.
		public var username:String = "";
		
        //Local cache of the Action Group list.
        private var _actionGroupList:ArrayCollection = new ArrayCollection();
        public var actionGroupDictionary:Dictionary;

		//Local cache of the Device list.
		private var _deviceList:ArrayCollection = new ArrayCollection();
        public var deviceDictionary:Dictionary;

        //Local cache of the Schedules list.
        public var scheduleDictionary:Dictionary;
        private var _scheduleList:ArrayCollection = new ArrayCollection();

        //Local cache of the Trigger list.
        private var _triggerList:ArrayCollection = new ArrayCollection();
        public var triggerDictionary:Dictionary;

        //Local cache of the Variable list.
        private var _variableList:ArrayCollection = new ArrayCollection();
        public var variableDictionary:Dictionary;

        //Local cache of the Update Time
        public var updateTimeInfo:String;

        //Local cache of the Log stream.
        public var logStream:String = "";

        //Local cache of the Packet stream.
        public var packetStream:String = "";

        //Local cache of the Registration info
        public var regInfo:IndigoRegInfo;
        public var regInfoCache:XML;


		[Bindable(event='deviceListChanged')]
		public function get deviceList():ArrayCollection
		{
			return this._deviceList;
		}
				
		public function set deviceList(value:ArrayCollection):void
		{
			if (_deviceList !=  value)
			{
				_deviceList = value;
				
				deviceDictionary = new Dictionary(true);
				
				var len:int = _deviceList?_deviceList.length:0;
				var tempDevice:IIndigoDevice;
				for (var i:int=0; i < len; i++)
				{
					tempDevice = _deviceList.getItemAt(i) as IIndigoDevice;
					if (tempDevice)
					{
						deviceDictionary[tempDevice.name] = tempDevice;
					}
				}	
			}
					
			dispatchEvent( new Event('deviceListChanged') );
		}
		
		public function getDevicesByType(type:String):ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			var len:int = this._deviceList?this._deviceList.length:0;
			var tempDevice:AbstractIndigoDevice;
			for (var i:int=0; i < len; i++)
			{
				tempDevice = this._deviceList.getItemAt(i) as AbstractIndigoDevice;
				if (tempDevice && tempDevice.description.indexOf(type) > -1)
				{
					result.addItem( tempDevice );
				}
			}
			
			return result;
		}
		
		[Bindable(event='actionGroupListChanged')]
		public function get actionGroupList():ArrayCollection
		{
			return this._actionGroupList;
		}
				
		public function set actionGroupList(value:ArrayCollection):void
		{
			if (_actionGroupList !=  value)
			{
				_actionGroupList = value;
				
				actionGroupDictionary = new Dictionary(true);
				
				var len:int = _actionGroupList?_actionGroupList.length:0;
				var tempActionGroup:IIndigoActionGroup;
				for (var i:int=0; i < len; i++)
				{
					tempActionGroup = _actionGroupList.getItemAt(i) as IIndigoActionGroup;
					if (tempActionGroup)
					{
						actionGroupDictionary[tempActionGroup.name] = tempActionGroup;
					}
				}	
			}
					
			dispatchEvent( new Event('actionGroupListChanged') );
		} 
		
        [Bindable(event='triggerListChanged')]
        public function get triggerList():ArrayCollection
        {
            return this._triggerList;
        }

        public function set triggerList(value:ArrayCollection):void
        {
            if (!this._triggerList)
                this._triggerList = new ArrayCollection();

            if (value)
            {
                this._triggerList.source = value.source;

                triggerDictionary = new Dictionary(true);

                var tempTrigger:IndigoTrigger;
                var len:int = value.length;
                for (var i:int=0; i < len; i++)
                {
                    tempTrigger = value.getItemAt(i) as IndigoTrigger;
                    triggerDictionary[tempTrigger.name] = tempTrigger;
                }

                this._triggerList.refresh();
            }
            else
                this._triggerList.source = null;


            dispatchEvent(new Event('triggerListChanged'));
        }
		
		[Bindable(event='variableListChanged')]
		public function get variableList():ArrayCollection
		{
			return this._variableList;
		}
		
		public function set variableList(value:ArrayCollection):void
		{
			if (!this._variableList)
				this._variableList = new ArrayCollection();
				
			if (value)	
			{	
				this._variableList.source = value.source;
				
				variableDictionary = new Dictionary(true);
				
				var tempVariable:IndigoVariable;
				var len:int = value.length;
				for (var i:int=0; i < len; i++)
				{
					tempVariable = value.getItemAt(i) as IndigoVariable;
					variableDictionary[tempVariable.name] = tempVariable.value;
				}	
				
				this._variableList.refresh();
			}
			else
				this._variableList.source = null;
				
			
			dispatchEvent(new Event('variableListChanged'));
		}

        [Bindable(event='scheduleListChanged')]
        public function get scheduleList():ArrayCollection
        {
            return this._scheduleList;
        }

        public function set scheduleList(value:ArrayCollection):void
        {
            if (!this._scheduleList)
                this._scheduleList = new ArrayCollection();

            if (value)
            {
                this._scheduleList.source = value.source;

                scheduleDictionary = new Dictionary(true);

                var tempSchedule:IndigoSchedule;
                var len:int = value.length;
                for (var i:int=0; i < len; i++)
                {
                    tempSchedule = value.getItemAt(i) as IndigoSchedule;
                    scheduleDictionary[tempSchedule.name] = tempSchedule;
                }

                this._scheduleList.refresh();
            }
            else
                this._scheduleList.source = null;


            dispatchEvent(new Event('scheduleListChanged'));
        }
	}
}