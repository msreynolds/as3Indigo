package com.perceptiveautomation.indigo.vo
{
	public class UpdateTimeInfo
	{
		private var updateTimeInfo:XML;
		
		public static function format(time:Number):String
		{
   			var includeSecs:Boolean;
   			var hours:Number;
   			var mins:int;
   			var pm:Boolean=false;
   			var returnStr:String;
   			var seconds:int
   			var timeCount:Number;
   			var timePortion:Number;
   			
   			timeCount = time;
   			timePortion = timeCount-(int(timeCount/(24*3600))*24*3600);
			hours = int(timePortion/3600);
			
			if (hours > 11)
			{	
				pm = true;
				if (hours > 12) 
					hours = hours - 12;
			}
			
			returnStr = hours + ":";
			
			if (pm && hours != 12)
				mins = int((timePortion-(hours+12)*3600)/60);
			else
				mins = int((timePortion-hours*3600)/60);
				
			
			if (mins<10) 
				returnStr += "0" + mins;
			else 
				returnStr += mins;
			
			if (includeSecs)
			{	
				if (pm && hours != 12)
					seconds = int(timePortion-(hours+12)*3600-mins*60);
				else			
					seconds = int(timePortion-hours*3600-mins*60);
				
				returnStr += ":";
				
				if (seconds<10) 
				{
					returnStr += "0" + seconds;
				} else {
					returnStr += seconds;
				}
			}
				
			if (pm)
				returnStr += " pm";
			else
				returnStr += " am";
			
			return returnStr;
		}
		
	}
}