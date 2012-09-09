package com.perceptiveautomation.indigo.trigger
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class IndigoTrigger extends EventDispatcher implements IIndigoTrigger
	{
		private var _id:String;
        private var _name:String;
        private var _type:String;
        private var _folder:String;

		public function IndigoTrigger(xmlNode:Object)
		{
            if (xmlNode.hasOwnProperty('ID'))
            {
                this._id = xmlNode.ID;
            }

            if (xmlNode.hasOwnProperty('id'))
            {
                this._id = xmlNode.id;
            }

            if (xmlNode.hasOwnProperty('Name'))
            {
                this._name = xmlNode.Name;
            }

            if (xmlNode.hasOwnProperty('name'))
            {
                this._name = xmlNode.name;
            }

		}

        [Bindable(event="idChanged")]
        public function get id():String
        {
            return _id;
        }

        public function set id(value:String):void
        {
            if (_id == value) return;
            _id = value;
            dispatchEvent(new Event("idChanged"));
        }

		[Bindable(event='nameChanged')]
		public function get name():String
		{
			return this._name;
		}
		
		public function set name(value:String):void
		{
			if (this._name != value)
			{
				this._name = value;
				dispatchEvent(new Event('nameChanged'));
			}
		}

        [Bindable(event="typeChanged")]
        public function get type():String {
            return _type;
        }

        public function set type(value:String):void {
            if (_type == value) return;
            _type = value;
            dispatchEvent(new Event("typeChanged"));
        }

        [Bindable(event="folderChanged")]
        public function get folder():String {
            return _folder;
        }

        public function set folder(value:String):void {
            if (_folder == value) return;
            _folder = value;
            dispatchEvent(new Event("folderChanged"));
        }
    }
}