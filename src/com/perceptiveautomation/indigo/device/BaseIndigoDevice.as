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
        private var _model:String;

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

            if (xmlNode.hasOwnProperty('Desc'))
            {
                this._description = xmlNode.Desc;
            }

            if (xmlNode.hasOwnProperty('desc'))
            {
                this._description = xmlNode.desc;
            }

            // Initialize the description to an empty string if it was null in the xmlNode
            if (!this._description)
            {
                this._description = "";
            }

            if (xmlNode.hasOwnProperty('TypeName'))
            {
                this._model = xmlNode.TypeName;
            }

            if (xmlNode.hasOwnProperty('type'))
            {
                this._model = xmlNode.type;
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

        [Bindable(event="modelChanged")]
        public function get model():String
        {
            return _model;
        }

        public function set model(value:String):void
        {
            if ( _model == value ) return;
            _model = value;
            dispatchEvent(new Event("modelChanged"));
        }

        public function fill(value:IIndigoDevice):void
        {
            this.name = value.name;
            this.description = value.description;
            this.model = value.model;
        }

    }
}
