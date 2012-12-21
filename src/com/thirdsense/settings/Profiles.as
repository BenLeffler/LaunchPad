package com.thirdsense.settings 
{
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class Profiles 
	{
		public static const DEVICE_ANDROID_PHONE:String = "deviceAndroidPhone";
		public static const DEVICE_ANDROID_TABLET:String = "deviceAndroidTablet";
		public static const DEVICE_ANDROID_ALL:String = "deviceAndroidAll";
		
		public static const DEVICE_IOS_PHONE:String = "deviceIOSPhone";
		public static const DEVICE_IOS_TABLET:String = "deviceIOSTablet";
		public static const DEVICE_IOS_ALL:String = "deviceIOSAll";
		public static const DEVICE_MOBILE_ALL:String = "deviceMobileAll"
		
		public static const DEVICE_APP_MAC:String = "deviceAppMac";
		public static const DEVICE_APP_PC:String = "deviceAppPC";
		public static const DEVICE_WEB:String = "deviceWeb";
		
		public static const DEVICE_DETECT:String = "deviceDetect";
		
		private static var _CURRENT_DEVICE:String = "";
		
		public static function get CURRENT_DEVICE():String	{	return _CURRENT_DEVICE	};
		public static function set CURRENT_DEVICE( val:String )
		{
			if ( val == DEVICE_DETECT ) {
				
				var manu:String = Capabilities.manufacturer.toLowerCase();
				
				if ( LocalConnection.isSupported ) {
					var lc:LocalConnection = new LocalConnection();
					if ( !lc.domain.indexOf("app#") ) {
						
						if ( manu.indexOf("windows") >= 0 || manu.indexOf("linux") >= 0 ) {
							_CURRENT_DEVICE = DEVICE_APP_PC;
						} else if ( manu.indexOf("macintosh") >= 0 ) {
							_CURRENT_DEVICE = DEVICE_APP_MAC;
						}
						
					} else {
						if ( manu.indexOf("windows") >= 0 || manu.indexOf("macintosh") || manu.indexOf("linux") ) {
							_CURRENT_DEVICE = DEVICE_WEB;
						}
					}
				} else {
					if ( manu.indexOf("windows") >= 0 || manu.indexOf("macintosh") || manu.indexOf("linux") ) {
						_CURRENT_DEVICE = DEVICE_WEB;
					}
				}
				
				if ( manu.indexOf("android") >= 0 ) {
					var pixels:Number = Capabilities.screenResolutionX * Capabilities.screenResolutionY;
					if ( pixels > 400000 ) {
						_CURRENT_DEVICE = DEVICE_ANDROID_TABLET;
					} else {
						_CURRENT_DEVICE = DEVICE_ANDROID_PHONE;
					}
				}
				
				if ( manu.indexOf("ios") >= 0 ) {
					pixels = Capabilities.screenResolutionX * Capabilities.screenResolutionY;
					if ( pixels > 780000 ) {
						_CURRENT_DEVICE = DEVICE_IOS_TABLET;
					} else {
						_CURRENT_DEVICE = DEVICE_IOS_PHONE;
					}
				}
				
				trace( Profiles, "Device type detected and set to: " + _CURRENT_DEVICE );
				
			} else {
				_CURRENT_DEVICE = val;				
				trace( Profiles, "Device type set to: " + _CURRENT_DEVICE );
			}
			
			
		}
		
		public static function get mobile():Boolean
		{
			if ( LPSettings.FORCE_MOBILE_PROFILE ) {
				return true;
			}
			
			switch( CURRENT_DEVICE ) {
				
				case DEVICE_ANDROID_PHONE:
				case DEVICE_ANDROID_TABLET:
				case DEVICE_ANDROID_ALL:
				case DEVICE_IOS_PHONE:
				case DEVICE_IOS_TABLET:
				case DEVICE_IOS_ALL:
				case DEVICE_MOBILE_ALL:
					return true;
				
				default:
					break;
			}
			
			return false;
			
		}
		
		public static function get desktop():Boolean
		{
			if ( LPSettings.FORCE_MOBILE_PROFILE ) {
				return false;
			}
			
			if ( CURRENT_DEVICE == DEVICE_APP_MAC || CURRENT_DEVICE == DEVICE_APP_PC ) {
				return true;
			}
			
			return false;
			
		}
		
		public static function get web():Boolean
		{
			if ( ExternalInterface.available || (!mobile && !desktop) ) {
				return true;
			}
			
			return false;
			
		}
		
		public static function isIOS():Boolean
		{
			if ( !mobile ) {
				return false;
			} else {
			
				var manu:String = Capabilities.manufacturer.toLowerCase();
				
				if ( manu.indexOf("ios") >= 0 || CURRENT_DEVICE.indexOf("IOS")>=0 ) {
					return true;
				}
				
			}
			
			return false;
			
		}
		
		public static function isAndroid():Boolean
		{
			if ( !mobile ) {
				return false;
			} else {
			
				var manu:String = Capabilities.manufacturer.toLowerCase();
				
				if ( manu.indexOf("android") >= 0 || CURRENT_DEVICE.indexOf("Android")>=0 ) {
					return true;
				}
				
			}
			
			return false;
			
		}
		
		public static function getIOSDeviceType():String
		{
			if ( isIOS() )
			{
				var devStr:String = Capabilities.os;
				var devStrArr:Array = devStr.split(" ");
				devStr = devStrArr.pop();
				return devStr;
			}
			else
			{
				return "";
			}
		}
		
		
	}

}