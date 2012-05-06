package com.perceptiveautomation.indigo.control
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	/**********************************/
	/*
		The scope of this class handles all received XML 'packets' from the Indigo Server.
		The scope of this class is responsible for dispatching appropriate change events for the possible packet types sent by indigo.
		Event listeners should be added to to this instance from other objects if those objects need to know about indigo data sent in XML 'packets' from the server.	
	*/
	/**********************************/
	public class IndigoComBroker extends EventDispatcher
	{
		private static var _instance:IndigoComBroker;
		private static var _canInit:Boolean;
		
		public function IndigoComBroker() 
		{
			if (!_canInit || _instance)
				throw new IllegalOperationError("IndigoComBroker can only be instantiated using IndigoComBroker.getInstance()");
				
			return;	
		}
		
		public static function getInstance():IndigoComBroker
		{
			_canInit = true;
			
			if (!_instance)
				_instance = new IndigoComBroker();
				
			return _instance;
		}
	}
}

//{} class Singleton