package com.perceptiveautomation.indigo.vo
{
	import com.perceptiveautomation.indigo.device.IIndigoDevice;

	public class ThermostatDevice extends OnOffDevice
	{
		private var _make:String;
		private var _model:String;
		private var _temperature:Number;
		private var _heatSetpoint:Number;
		private var _coolSetpoint:Number;
		
		public function ThermostatDevice(xmlNode:Object)
		{
			super(xmlNode);
			
			if (xmlNode.Description.indexOf('Venstar') > -1)
				this._make = "Venstar";
			
			if (xmlNode.Description.indexOf('T1800') > -1 )
				this._model = "T1800";
			
			_temperature = Number(xmlNode.DeviceDisplayLongState);
			_heatSetpoint = Number(xmlNode.ActiveSetpointHeat);
			_coolSetpoint = Number(xmlNode.ActiveSetpointCool);
		}
		
		public function get make():String
		{
			return this._make
		}
		
		public function get model():String
		{
			return this._model;
		}	

		public function get heatSetpoint():Number
		{
			return _heatSetpoint;
		}

		public function set heatSetpoint(value:Number):void
		{
			_heatSetpoint = value;
		}

		public function get coolSetpoint():Number
		{
			return _coolSetpoint;
		}

		public function set coolSetpoint(value:Number):void
		{
			_coolSetpoint = value;
		}

		public function get temperature():Number
		{
			return _temperature;
		}

		public function set temperature(value:Number):void
		{
			_temperature = value;
		}

		override public function fill(value:IIndigoDevice):void
		{
			super.fill( value );
			if (value is ThermostatDevice)
			{
				this._temperature = ThermostatDevice(value).temperature;
				this._coolSetpoint = ThermostatDevice(value).coolSetpoint;
				this._heatSetpoint = ThermostatDevice(value).heatSetpoint;
				this._make = ThermostatDevice(value).make;
				this._model = ThermostatDevice(value).model;
			}
		}
	}
}