package com.perceptiveautomation.indigo.trigger
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class IndigoTrigger extends EventDispatcher implements IIndigoTrigger
	{
		private var _name:String;
        private var _type:String;
        private var _folder:String;
		
		public function IndigoTrigger(xmlNode:Object)
		{
			this._name = xmlNode.Name;
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