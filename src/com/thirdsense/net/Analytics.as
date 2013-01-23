package com.thirdsense.net 
{
	import com.thirdsense.LaunchPad;
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
				vp:String( LaunchPad.instance.nativeStage.stageWidth + "x" + LaunchPad.instance.nativeStage.stageHeight ),
				sr:String( LaunchPad.instance.nativeStage.fullScreenWidth + "x" + LaunchPad.instance.nativeStage.fullScreenHeight ),
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				cd:screen_name,
				t:"appview"
			}
			
			var success:Boolean = sendPayload( obj );
			
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
		 * Reports a caught exception to Google Analytics
		 * @param	error	The error thrown by your app that needs reporting
		 * @return	A boolean value that indicates if the call was made successfully
		 */
		
		public static function trackException( error:Error ):Boolean
		{
			if ( !uuid || !uuid.length )
			{
				trace( "LaunchPad", Analytics, "Call to trackException failed as a tracking id has not been correctly defined in LaunchPad's config.xml" )
				return false;
			}
			
			var obj:Object = {
				v:1,
				tid:LPSettings.ANALYTICS_TRACKING_ID,
				cid:uuid,
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				t:"exception",
				exd:error.name + "(" + error.errorID + ")",
				exf:1
			}
			
			var success:Boolean = sendPayload( obj );
			
			if ( success )
			{
				trace( "LaunchPad", Analytics, "Analytics exception tracked: '" + error.name + "'" );
			}
			else
			{
				trace( "LaunchPad", Analytics, "Analytics exception tracking failed: '" + error.name + "'" );
			}
			
			return success;
		}
		
		/**
		 * Reports to Google Analytics that a social media interaction has been initiated from your app
		 * @param	network	The name of the social media service (eg. "facebook", "twitter", "linkedin" etc)
		 * @param	action	The type of social media interaction that occured. (eg. "postToWall", "like", "invite")
		 * @param	target	(Optional) The target url or target specific information contained within the interaction
		 * @return	A boolean value that indicates if the call was made successfully
		 */
		
		public static function trackSocialMedia( network:String = "facebook", action:String = "postToWall", target:String = "/home" ):Boolean
		{
			if ( !uuid || !uuid.length )
			{
				trace( "LaunchPad", Analytics, "Call to trackSocialMedia failed as a tracking id has not been correctly defined in LaunchPad's config.xml" )
				return false;
			}
			
			var obj:Object = {
				v:1,
				tid:LPSettings.ANALYTICS_TRACKING_ID,
				cid:uuid,
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				t:"social",
				sn:network,
				sa:action,
				st:target
			}
			
			
			var success:Boolean = sendPayload( obj );
			
			if ( success )
			{
				trace( "LaunchPad", Analytics, "Analytics social media interaction tracked: '" + network + "'" );
			}
			else
			{
				trace( "LaunchPad", Analytics, "Analytics social media interaction tracking failed: '" + network + "'" );
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
			
			var success:Boolean = sendPayload( obj );
			
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
		 * Sends a message to Google Analytics that the user's session has ended. This call is not necessary, as GA makes a calculated guess as to when a user session
		 * ends based on inactivity. But for more accurate tracking, this can be called when the app has been terminated or a user has logged off within the app.
		 */
		
		public static function trackEndSession():void
		{
			if ( !uuid || !uuid.length )
			{
				trace( "LaunchPad", Analytics, "Call to trackEvent failed as a tracking id has not been correctly defined in LaunchPad's config.xml" )
				return void;
			}
			
			var obj:Object = {
				v:1,
				tid:LPSettings.ANALYTICS_TRACKING_ID,
				cid:uuid,
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				t:"timing",
				ni:1,
				sc:"end"
			}
			
			sendPayload( obj );
		}
		
		/**
		 * Initializes the Analytics tracking for the app. This is called during the LaunchPad.init process at the load of an app. This call also sends a payload
		 * to GA to flag a session start.
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
			
			var obj:Object = {
				v:1,
				tid:LPSettings.ANALYTICS_TRACKING_ID,
				cid:uuid,
				an:LPSettings.APP_NAME,
				av:LPSettings.APP_VERSION,
				t:"timing",
				ni:1,
				sc:"start"
			}
			
			sendPayload( obj );
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
		
		/**
		 * @private	Sends an object to Google Analytics for tracking
		 * @param	obj	The object payload to send
		 * @return	True is successful. False otherwise.
		 */
		
		private static function sendPayload( obj:Object ):Boolean
		{
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
			
			return success;
		}
		
	}

}