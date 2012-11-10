package com.perceptiveautomation.indigo.device
{
    import flash.events.Event;

    public class ThermostatDevice extends OnOffDevice
	{
		private var _make:String;
		private var _model:String;
		private var _temperature:Number;
		private var _heatPoint:Number;
		private var _coolPoint:Number;
		
		public function ThermostatDevice(xmlNode:Object)
		{
			super(xmlNode);
		}

        [Bindable(event="makeChanged")]
        public function get make():String
        {
            return _make;
        }

        public function set make(value:String):void
        {
            if (_make == value) return;
            _make = value;
            dispatchEvent(new Event("makeChanged"));
        }

        [Bindable(event="modelChanged")]
        public function get model():String
        {
            return _model;
        }

        public function set model(value:String):void
        {
            if (_model == value) return;
            _model = value;
            dispatchEvent(new Event("modelChanged"));
        }

        [Bindable(event="temperatureChanged")]
        public function get temperature():Number
        {
            return _temperature;
        }

        public function set temperature(value:Number):void
        {
            if (_temperature == value) return;
            _temperature = value;
            dispatchEvent(new Event("temperatureChanged"));
        }

        [Bindable(event="heatPointChanged")]
        public function get heatPoint():Number
        {
            return _heatPoint;
        }

        public function set heatPoint(value:Number):void
        {
            if (_heatPoint == value) return;
            _heatPoint = value;
            dispatchEvent(new Event("heatPointChanged"));
        }

        [Bindable(event="coolPointChanged")]
        public function get coolPoint():Number
        {
            return _coolPoint;
        }

        public function set coolPoint(value:Number):void
        {
            if (_coolPoint == value) return;
            _coolPoint = value;
            dispatchEvent(new Event("coolPointChanged"));
        }

        override public function fill(value:IIndigoDevice):void
		{
			super.fill( value );
			if (value is ThermostatDevice)
			{
				this._temperature = ThermostatDevice(value).temperature;
				this._coolPoint = ThermostatDevice(value).coolPoint;
				this._heatPoint = ThermostatDevice(value).heatPoint;
				this._make = ThermostatDevice(value).make;
				this._model = ThermostatDevice(value).model;
			}
		}
	}
}