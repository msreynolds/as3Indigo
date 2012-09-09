/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/19/12
 * Time: 1:12 AM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.device
{
    import flash.events.Event;
    import flash.events.EventDispatcher;

    public class BaseIndigoDevice extends EventDispatcher implements IIndigoDevice
    {
        private var _id:String;
        private var _name:String;
        private var _description:String;

        public function BaseIndigoDevice(xmlNode:Object)
        {
            super();

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

            if (xmlNode.hasOwnProperty('Description'))
            {
                this._description = xmlNode.Description;
            }

            if (xmlNode.hasOwnProperty('description'))
            {
                this._description = xmlNode.description;
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

        [Bindable(event='descriptionChanged')]
        public function get description():String
        {
            return this._description;
        }

        public function set description(value:String):void
        {
            if (this._description != value)
            {
                this._description = value;
                dispatchEvent(new Event('descriptionChanged'));
            }
        }

        public function fill(value:IIndigoDevice):void
        {
            this.name = value.name;
            this.description = value.description;
        }

    }
}
