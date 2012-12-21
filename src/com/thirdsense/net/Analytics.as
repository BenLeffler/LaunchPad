package com.thirdsense.net 
{
	import com.thirdsense.settings.LPSettings;
	import flash.events.EventDispatcher;
	import flash.net.sendToURL;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	public class Analytics extends EventDispatcher
	{
		private static var uuid:String;
		
		public static function trackScreen( screen:String ):Boolean
		{
			if ( !uuid || !uuid.length )
			{
				trace( "LaunchPad", Analytics, "Call to trackScreen failed as a tracking id has not been correctly defined in LaunchPad's config.xml" )
				return false;
			}
			
			var obj:Object = {
				v:1,
				tid:LPSettings.ANALYTICS_TRACKING_ID,
				cid:uuid,
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				cd:screen,
				t:"appview"
			}
			
			var vars:URLVariables = new URLVariables();
			for ( var str:String in obj )
			{
				vars[str] = obj[str];
			}
			
			var url_request:URLRequest = new URLRequest();
			url_request.method = URLRequestMethod.POST;
			url_request.data = vars;
			url_request.url = "http://www.google-analytics.com/collect";
			
			try
			{
				sendToURL(url_request);
			}
			catch (e:*)
			{
				// return false;
			}
			
			trace( "Analytics screen tracked: " + screen );
			return true;
		}
		
		public static function trackEvent( category:String, action:String, label:String = "", value:Number = 0 ):Boolean
		{
			if ( !uuid || !uuid.length )
			{
				trace( "LaunchPad", Analytics, "Call to trackEvent failed as a tracking id has not been correctly defined in LaunchPad's config.xml" )
				return false;
			}
			
			var obj:Object = {
				v:1,
				tid:LPSettings.ANALYTICS_TRACKING_ID,
				cid:uuid,
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				ec:category,
				ea:action,
				t:"event"
			}
			
			if ( label.length )
			{
				obj.el = label;
				obj.ev = value;
			}
			
			var vars:URLVariables = new URLVariables();
			for ( var str:String in obj )
			{
				vars[str] = obj[str];
			}
			
			var url_request:URLRequest = new URLRequest();
			url_request.method = URLRequestMethod.POST;
			url_request.data = vars;
			url_request.url = "http://www.google-analytics.com/collect";
			
			try
			{
				sendToURL(url_request);
			}
			catch (e:*)
			{
				// return false;
			}
			
			return true;
			
		}
		
		public static function init():void
		{
			trace( "LaunchPad", Analytics, "Initializing Google Analytics with AppId:", LPSettings.ANALYTICS_TRACKING_ID );
			uuid = assignUUID();
		}
		
		public static function assignUUID():String
		{
			var hex:Array = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ];
			var str:String = "";
			for ( var i:uint = 0; i < 32; i++ )
			{
				str += hex[ Math.floor(Math.random() * hex.length) ];
				switch ( i )
				{
					case 8:
					case 12:
					case 16:
					case 20:
						str += "-";
						break;
				}
			}
			
			return str;
		}
		
	}

}