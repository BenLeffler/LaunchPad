package com.thirdsense.utils 
{
	import com.thirdsense.utils.getClassVariables;
	
	/**
	 * A variety of tools to help with formatting of String data
	 * @author Ben Leffler
	 */
	
	public class StringTools 
	{
		/**
		 * Checks if a string is a valid email format
		 * @param	email	The email address to check
		 * @return	Boolean value that indicates if it is a valid email format
		 */
		
		public static function isValidEmailFormat( email:String ):Boolean
		{
			if ( email.indexOf("@") < 1 || email.length < 6 || email.indexOf(".") < 1 || email.lastIndexOf(".") == email.length-1 || email.indexOf("@.") >= 0 || email.indexOf(".@") >= 0 ) {
				return false;
			}
			
			return true;
		}
		
		/**
		 * Adds a string in to another string at a designated position
		 * @param	target_string	The target string to append to
		 * @param	pos	The position of where to place the insert_string value. (0 to n-1)
		 * @param	insert_string	The string to append to target_string
		 * @return	The resulting string
		 */
		
		public static function insertAt( target_string:String, pos:int, insert_string:String ):String
		{
			var str:String;
			var str1:String = target_string.substr(0, pos);
			var str3:String = target_string.substr(pos);
			str = str1 + insert_string + str3;
			
			return str;
		}
		
		/**
		 * Replaces instances of certain characters in a string with a desired character set
		 * @param	target_string	The target string to analyse and replace
		 * @param	searchFor	The character combination to search for
		 * @param	replaceWith	The character combination that will be replaced with
		 * @return	The resulting string
		 */
		
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
		
		/**
		 * Shortens a number with a suffix representation (K for thousands, M for millions and B for billions)
		 * @param	value	The value to shorten
		 * @param	digits	The minimum number of digits to allow before creating a suffix
		 * @return	The string representation of the number
		 */
		
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
		
		/**
		 * Converts an integer value in to a place (ie 1 converts to 1st, 2 converts to 2nd etc.)
		 * @param	value	The value to convert from
		 * @return	The string result
		 */
		
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
		
		/**
		 * Creates a string representation of a class or an instance of a class object.
		 * @param	cl	The class or object to analyse
		 * @param	accessorType	The type of accessor to include in the result
		 * @return	A string representation of the object 'cl'
		 * @see	com.thirdsense.utils.AccessorType
		 */
		
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
		
		/**
		 * Generates a Lorem Ipsum placeholder string for use with temporary textfield content
		 * @param	max_chars	The maximum number of characters the string is to return
		 * @return	A String representing the Lorem Ipsum text
		 */
		
		public static function generateLoremIpsum( max_chars:int = 100 ):String
		{
			var str:String = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Nam quis ipsum lacinia libero convallis semper. Ut vulputate sem id leo. In sollicitudin aliquet eros. Duis ornare sodales lorem. Duis ullamcorper. Donec ac magna. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum";
			
			if ( max_chars < 0 )
			{
				return str;
			}
			else
			{
				return str.substr( 0, max_chars - 1 );
			}
		}
	}

}