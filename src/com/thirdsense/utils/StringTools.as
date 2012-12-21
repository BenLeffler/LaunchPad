package com.thirdsense.utils 
{
	import com.thirdsense.utils.getClassVariables;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class StringTools 
	{
		
		public static function isValidEmailFormat( email:String ):Boolean
		{
			if ( email.indexOf("@") < 1 || email.length < 6 || email.indexOf(".") < 1 || email.lastIndexOf(".") == email.length-1 || email.indexOf("@.") >= 0 || email.indexOf(".@") >= 0 ) {
				return false;
			}
			
			return true;
		}
		
		public static function insertAt( target_string:String, pos:int, insert_string:String ):String
		{
			var str:String;
			var str1:String = target_string.substr(0, pos);
			var str3:String = target_string.substr(pos);
			str = str1 + insert_string + str3;
			
			return str;
		}
		
		public static function replaceAll( target_string:String, searchFor:String, replaceWith:String ):String
		{
			if ( searchFor == replaceWith ) {
				trace( "Illegal replace call - searchFor and replaceWith params can not be the same" );
				return "";
			}
			
			var index:int = 0;
			
			while ( target_string.indexOf(searchFor, index) >= 0 ) {
				
				var pos:int = target_string.indexOf(searchFor, index);
				
				var s1:String = target_string.substr( 0, pos );
				var s3:String = target_string.substr( pos + searchFor.length );
				target_string = s1 + replaceWith + s3;
				
				index = pos + 1;
			}
			
			return target_string;
			
		}
		
		public static function shortenNumber( value:Number, digits:int=5 ):String
		{
			var str:String = "1";
			for ( var i:uint = 1; i < digits; i++ ) {
				str += "0";
			}
			var max:Number = Number(str);
			
			if ( value < max ) {
				return String(value);
			}
			
			if ( value > 1000000000 ) {
				value /= 1000000000;
				value = Math.round( value * 100 );
				value /= 100;
				return value + "B";
			}
			
			if ( value > 1000000 ) {
				value /= 1000000;
				value = Math.round( value * 100 );
				value /= 100;
				return value + "M";
			}
			
			if ( value > 1000 ) {
				value /= 1000;
				value = Math.round( value );
				return value + "K";
			}
			
			return String(value);
		}
		
		public static function convertToPlace( value:int ):String
		{
			if ( value < 1 ) {
				return String(value);
			}
			
			if ( value > 3 && value < 21 ) {
				return value + "th";
			}
			
			var str:String = String(value);
			
			if ( str.length > 1 && str.charAt(str.length - 2) != "1" ) {
				
				if ( str.charAt(str.length - 1) == "1" ) {
					return value + "st";
				}
				
				if ( str.charAt(str.length - 1) == "2" ) {
					return value + "nd";
				}
				
				if ( str.charAt(str.length - 1) == "3" ) {
					return value + "rd";
				}
				
			} else {
			
				if ( str.charAt(str.length - 1) == "1" ) {
					return value + "st";
				}
				
				if ( str.charAt(str.length - 1) == "2" ) {
					return value + "nd";
				}
				
				if ( str.charAt(str.length - 1) == "3" ) {
					return value + "rd";
				}
				
			}
			
			return value + "th";
		}
		
		public static function toString( cl:*, accessorType:String="" ):String
		{
			var arr:Array = getClassVariables(cl, accessorType);
			var str:String = "{";
			
			for ( var i:uint = 0; i < arr.length; i++ ) {
				if ( i ) {
					str += ", ";
				}
				str += arr[i] + ":" + cl[arr[i]];
			}
			
			str += "}";
			
			return str;
			
		}
	}

}