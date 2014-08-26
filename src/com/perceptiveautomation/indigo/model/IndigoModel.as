package com.perceptiveautomation.indigo.model
{
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.constants.IndigoSocketConstants;
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
		
		public var indigoState:String = IndigoSocketConstants.INDIGO_SOCKET_STATE_DISCONNECTED;
		
		//Hash salt retrieved during the authtication process. Used to encrypt the raw password.
		public var serverSalt:String;
		
		//Host server derived from the Indigo server, Flash shared object, or login form.
		public var host:String = "";
		
		//Host port derived from the Indigo server if present or set statically here.
		public var port:int = 8176;
		
		//Host password hash derived from the Indigo server if present.
		public var authHash:String = "";
		
		//Host raw password derived from Falsh shared object or login form.
		public var password:String = "";
		
		//Host username derived from the Indigo server, Falsh shared object, or login form.
		public var username:String = "";
		
        //Local cache of the Action Group list.
        private var _actionGroupList:ArrayCollection = new ArrayCollection();

		//Local cache of the Device list.
		private var _deviceList:ArrayCollection = new ArrayCollection();

        //Local cache of the Schedules list.
        private var _scheduleList:ArrayCollection = new ArrayCollection();

        //Local cache of the Trigger list.
        private var _triggerList:ArrayCollection = new ArrayCollection();

        //Local cache of the Variable list.
        private var _variableList:ArrayCollection = new ArrayCollection();

        //Local cache of the Update Time
        public var updateTimeInfo:String;

        //Local cache of the Log stream.
        public var logStream:String = "";

        //Local cache of the Packet stream.
        public var packetStreamIncoming:String = "";
        public var packetStreamOutgoing:String = "";

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
            if (!this._deviceList)
            {
                this._deviceList = new ArrayCollection();
            }

            if (value)
            {
                this._deviceList.source = value.source;
            }
            else
            {
                this._deviceList.source = null;
            }

            this._deviceList.refresh();
					
			dispatchEvent( new Event('deviceListChanged') );
		}
		
		public function getDevicesByType(type:String):ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			var len:int = this._deviceList?this._deviceList.length:0;
			var tempDevice:IIndigoDevice;
			for (var i:int=0; i < len; i++)
			{
				tempDevice = this._deviceList.getItemAt(i) as IIndigoDevice;
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
            if (!this._actionGroupList)
            {
                this._actionGroupList = new ArrayCollection();
            }

            if (value)
            {
                this._actionGroupList.source = value.source;
            }
            else
            {
                this._actionGroupList.source = null;
            }

            this._actionGroupList.refresh();

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
            {
                this._triggerList = new ArrayCollection();
            }

            if (value)
            {
                this._triggerList.source = value.source;
            }
            else
            {
                this._triggerList.source = null;
            }

            this._triggerList.refresh();

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
            {
				this._variableList = new ArrayCollection();
            }

			if (value)	
			{	
				this._variableList.source = value.source;
			}
			else
            {
				this._variableList.source = null;
            }

            this._variableList.refresh();

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
            {
                this._scheduleList = new ArrayCollection();
            }

            if (value)
            {
                this._scheduleList.source = value.source;
            }
            else
            {
                this._scheduleList.source = null;
            }

            this._scheduleList.refresh();

            dispatchEvent(new Event('scheduleListChanged'));
        }
	}
}