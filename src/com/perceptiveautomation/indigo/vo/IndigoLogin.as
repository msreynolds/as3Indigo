package com.perceptiveautomation.indigo.vo
{
	public class IndigoLogin
	{
		public var host:String;
		public var port:String;
		
		public var username:String;
		public var password:String;
		
		public function IndigoLogin(host:String,user:String,pass:String)
		{
			this.host = host;
			this.port = '1176';
			this.username = user;
			this.password = pass;
		}
	}
}