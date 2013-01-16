package com.thirdsense.settings
{
	import com.thirdsense.LaunchPad;
	import com.thirdsense.utils.getClassVariables;
	
	/**
	 * Tools for identifying type of IOS device
	 * @author Ben Leffler
	 */
	
	public class IOSDevices
	{
		public static const IPOD_TOUCH_4:String = "iPod4,1";
		public static const IPOD_TOUCH_5:String = "iPod5,1";
		public static const IPHONE_3GS:String = "iPhone2,1";
		public static const IPHONE_4:String = "iPhone3,1";
		public static const IPHONE_4CDMA:String = "iPhone3,2";
		public static const IPHONE_4S:String = "iPhone4,1";
		public static const IPHONE_5:String = "iPhone5,1";
		public static const IPAD_1:String = "iPad1,1";
		public static const IPAD_2WIFI:String = "iPad2,1";
		public static const IPAD_2GSM:String = "iPad2,2";
		public static const IPAD_2CDMAV:String = "iPad2,3";
		public static const IPAD_2CDMAS:String = "iPad2,4";
		public static const IPAD_MINI:String = "iPad2,5";
		public static const IPAD_3WIFI:String = "iPad3,1";
		public static const IPAD_3:String = "iPad3,2";
		public static const IPAD_3CDMA:String = "iPad3,2";
		public static const IPAD_3GSM:String = "iPad3,3";
		public static const IPAD_4WIFI:String = "iPad3,4";
		
		public static const FAMILY_IPAD:String = "IPAD";
		public static const FAMILY_IPHONE:String = "IPHONE";
		public static const FAMILY_IPOD:String = "IPOD";
		
		public static const MODEL_1:String = "1";
		public static const MODEL_2:String = "2";
		public static const MODEL_3:String = "3";
		public static const MODEL_4:String = "4";
		public static const MODEL_MINI:String = "MINI";
		
		/**
		 * Checks if a passed device type is of a specified family (and model - optional)
		 * @param	device	The device string to check
		 * @param	family	The family to check against
		 * @param	model	The model to check against (optional)
		 * @return	True if the device is part of the designated family/model.
		 */
		
		public static function isDeviceType(device:String, family:String, model:String = ""):Boolean
		{
			var arr:Array = getClassVariables(IOSDevices);
			
			if (!model.length)
			{
				for (var i:uint = 0; i < arr.length; i++)
				{
					if (device == IOSDevices[arr[i]] && !arr[i].indexOf(family))
					{
						return true;
					}
				}
			}
			else
			{
				for (i = 0; i < arr.length; i++)
				{
					if (device == IOSDevices[arr[i]] && !arr[i].indexOf(family + "_" + model))
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		/**
		 * Checks if the device utilises Ipad retina display
		 * @return	Boolean value response
		 */
		
		public static function checkIpadRetina():Boolean
		{
			if ( Profiles.isIOS() )
			{
				var device:String = Profiles.getIOSDeviceType();
				if ( IOSDevices.isDeviceType(device, IOSDevices.FAMILY_IPAD) && LaunchPad.instance.nativeStage.stageWidth > 1024 )
				{
					return true;
				}
			}
			
			return false;
		}
	}

}