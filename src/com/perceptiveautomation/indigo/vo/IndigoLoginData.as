package com.perceptiveautomation.indigo.vo
{
	public class IndigoLoginData
	{
		public var host:String;
		public var port:String;
		
		public var username:String;
		public var password:String;
		
		public function IndigoLoginData(host:String,port:String='1176',user:String='',pass:String='')
		{
			this.host = host;
			this.port = port;
			this.username = user;
			this.password = pass;
		}
	}
}