package com.perceptiveautomation.indigo.device
{
	import com.perceptiveautomation.indigo.device.IIndigoDevice;

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
			
			if (xmlNode.TypeName.indexOf('Venstar') > -1)
				this._make = "Venstar";
			
			if (xmlNode.TypeName.indexOf('T1800') > -1 )
				this._model = "T1800";
			
			_temperature = Number(xmlNode.DeviceDisplayLongState);
			_heatPoint = Number(xmlNode.ActiveSetpointHeat);
			_coolPoint = Number(xmlNode.ActiveSetpointCool);
		}
		
		public function get make():String
		{
			return this._make
		}
		
		public function get model():String
		{
			return this._model;
		}	

		public function get heatPoint():Number
		{
			return _heatPoint;
		}

		public function set heatPoint(value:Number):void
		{
			_heatPoint = value;
		}

		public function get coolPoint():Number
		{
			return _coolPoint;
		}

		public function set coolPoint(value:Number):void
		{
			_coolPoint = value;
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
				this._coolPoint = ThermostatDevice(value).coolPoint;
				this._heatPoint = ThermostatDevice(value).heatPoint;
				this._make = ThermostatDevice(value).make;
				this._model = ThermostatDevice(value).model;
			}
		}
	}
}