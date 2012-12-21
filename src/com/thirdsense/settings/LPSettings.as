package com.thirdsense.settings 
{
	/**
	 * ...
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
		 * 
		 */
		public static var FORCE_MOBILE_PROFILE:Boolean = false;
		
	}

}