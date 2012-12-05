package com.perceptiveautomation.indigo.device
{
    import flash.events.Event;

    public class ThermostatDevice extends OnOffDevice
	{
		private var _make:String;
		private var _temperature:Number;
		private var _heatPoint:Number;
		private var _coolPoint:Number;
		
		public function ThermostatDevice(xmlNode:Object)
		{
			super(xmlNode);

            if (xmlNode.hasOwnProperty('DeviceDisplayLongState'))
            {
                this.temperature = xmlNode.DeviceDisplayLongState;
            }

            if (xmlNode.hasOwnProperty('displayLongState'))
            {
                this.temperature = xmlNode.displayLongState;
            }

            if (xmlNode.hasOwnProperty('ActiveSetpointHeat'))
            {
                this.heatPoint = xmlNode.ActiveSetpointHeat;
            }

            if (xmlNode.hasOwnProperty('setpointHeat'))
            {
                this.heatPoint = xmlNode.setpointHeat;
            }

            if (xmlNode.hasOwnProperty('ActiveSetpointCool'))
            {
                this.coolPoint = xmlNode.ActiveSetpointCool;
            }

            if (xmlNode.hasOwnProperty('setpointCool'))
            {
                this.coolPoint = xmlNode.setpointCool;
            }

            // TODO: make??
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
			if (value is IIndigoThermostatDevice)
			{
				this.temperature = IIndigoThermostatDevice(value).temperature;
				this.coolPoint = IIndigoThermostatDevice(value).coolPoint;
				this.heatPoint = IIndigoThermostatDevice(value).heatPoint;
				this.make = IIndigoThermostatDevice(value).make;
			}
		}
	}
}