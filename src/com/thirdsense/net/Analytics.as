package com.thirdsense.net 
{
	import com.thirdsense.settings.LPSettings;
	import flash.events.EventDispatcher;
	import flash.net.sendToURL;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * Enables Google Analytics tracking of a LaunchPad project, if the tracking id has been set up in the project config.xml and with the Google service.
	 * @author Ben Leffler
	 */
	
	public class Analytics extends EventDispatcher
	{
		private static var uuid:String;
		
		/**
		 * Reports to Google Analytics that a user has viewed a specific screen
		 * @param	screen_name	The name of the screen to report back to GA
		 * @return	A boolean value to indicate if the call was successfully made
		 */
		
		public static function trackScreen( screen_name:String ):Boolean
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
				cd:screen_name,
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
			
			var success:Boolean = true;
			
			try
			{
				sendToURL(url_request);
			}
			catch (e:*)
			{
				success = false;
			}
			
			if ( success )
			{
				trace( "LaunchPad", Analytics, "Analytics screen tracked: '" + screen_name + "'" );
			}
			else
			{
				trace( "LaunchPad", Analytics, "Analytics screen tracking failed: '" + screen_name + "'" );
			}
			
			return success;
		}
		
		/**
		 * Reports to Google Analytics that an event has occured. Handy for tracking in-app stats.
		 * @param	category	The category of the event. Best used to pass through the platform (eg. "AppIOS", "AppAndroid", "AppWeb" etc.)
		 * @param	action	The name of the event that has occured (eg. "GameLoaded", "ScoreSubmitted" etc.)
		 * @param	label	If a value is to be associated, this is the label to use for it (eg. "QuizQuestionAnsweredCorrect" )
		 * @param	value	The value of the label. (eg 1). GA increments source values by this value amount
		 * @return	A boolean value that indicates if the call was made successfully
		 */
		
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
			
			var success:Boolean = true;
			
			try
			{
				sendToURL(url_request);
			}
			catch (e:*)
			{
				success = false;
			}
			
			if ( success )
			{
				trace( "LaunchPad", Analytics, "Analytics event tracked: '" + action + "'" );
			}
			else
			{
				trace( "LaunchPad", Analytics, "Analytics event tracking failed: '" + action + "'" );
			}
			
			return success;
			
		}
		
		/**
		 * Initializes the Analytics tracking for the app. This is called during the LaunchPad.init process at the load of an app.
		 */
		
		public static function init():void
		{
			trace( "LaunchPad", Analytics, "Initializing Google Analytics with AppId:", LPSettings.ANALYTICS_TRACKING_ID );
			
			var so:SharedObject = SharedObject.getLocal( escape(LPSettings.APP_NAME) + "_GA" );
			if ( so.data.uuid )
			{
				uuid = so.data.uuid;
			}
			else
			{
				uuid = assignUUID();
				so.data.uuid = uuid;
				so.flush();
			}
		}
		
		/**
		 * Assigns a UUID value to the session.
		 * @return	String representation of the generated unique identifier
		 */
		
		private static function assignUUID():String
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