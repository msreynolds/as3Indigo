package com.perceptiveautomation.indigo.actiongroup
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Meta(event='runNow')]
	
	[Bindable]
	public class IndigoActionGroup extends EventDispatcher implements IIndigoActionGroup
	{		
		private var _name:String;
        private var _description:String;
        private var _folder:String;

		public function IndigoActionGroup(xmlNode:XML)
		{
			this._name = xmlNode.Name;
            this._description = xmlNode.Description;
            this._folder = xmlNode.FolderID;
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
		
        [Bindable(event="descriptionChanged")]
        public function get description():String {
            return _description;
        }

        public function set description(value:String):void {
            if (_description == value) return;
            _description = value;
            dispatchEvent(new Event("descriptionChanged"));
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

        public function runNow():void
        {
            dispatchEvent(new Event('runNow'));
        }
    }
}