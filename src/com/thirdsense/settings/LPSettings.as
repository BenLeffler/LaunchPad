package com.thirdsense.settings 
{
	/**
	 * Global LaunchPad project settings. Most of the elements within this class are predetermined in the parsing process of the config.xml file
	 * @author Ben Leffler
	 */
	
	public class LPSettings 
	{
		/**
		 * Web extension relative to the swf delivery location of where config.xml is located
		 */
		public static var LIVE_EXTENSION:String = "";
		
		/**
		 * Google Analytics tracking id (passed through from config.xml)
		 */
		public static var ANALYTICS_TRACKING_ID:String = "";
		
		/**
		 * Application name (passed through from config.xml)
		 */
		public static var APP_NAME:String = "";
		
		/**
		 * Application version (passed through from config.xml)
		 */
		public static var APP_VERSION:String = "";
		
		/**
		 * Application is forcing mobile profile (passed through from config.xml)
		 */
		public static var FORCE_MOBILE_PROFILE:Boolean = false;
		
		/**
		 * Facebook application ID (passed through from config.xml)
		 */
		public static var FACEBOOK_APP_ID:String = "";
		
		/**
		 * Facebook redirection URL as defined in the Facebook Developer portal (passed through from config.xml)
		 */
		public static var FACEBOOK_REDIRECT_URL:String = "";
		
		/**
		 * The location of the Facebook wall picture to be used in stream posts (passed through from config.xml). This must exist within a domain that is listed in the FB Dev portal record for the app.
		 */
		public static var FACEBOOK_WALLPIC_URL:String = "";
		
		/**
		 * An array of requested permissions the app will request upon a user's first connection to Facebook through the app. (passed through from config.xml)
		 */
		public static var FACEBOOK_PERMISSIONS:Array;
		
	}

}