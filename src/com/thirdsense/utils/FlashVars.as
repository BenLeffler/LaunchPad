package com.thirdsense.utils 
{
	import flash.display.DisplayObject;
	import flash.external.ExternalInterface;
	
	/**
	 * Retrieves and makes available flashvar parameters.
	 * @author Ben Leffler
	 */
	
	public class FlashVars 
	{
		private static var params:Object;
		
		/**
		 * Retrieves any available flashvars passed through to the swf and populates a local object with their values
		 * @param	target
		 */
		public static function init( target:DisplayObject ):void
		{
			if ( ExternalInterface.available ) {
				FlashVars.params = target.loaderInfo.parameters as Object;
			} else {
				FlashVars.params = { };
			}
		}
		
		/**
		 * Retrieves the desired flashvar
		 * @param	var_name	The name of the parameter to retrieve a value for
		 * @return	A String representation of the desired flashvar. Null will be returned if it doesn't exist
		 */
		public static function getVar( var_name:String ):String
		{
			if ( params[ var_name ] ) {
				trace( "LaunchPad", FlashVars, "Retrieved FlashVar '" + var_name + "' - returning " + String( params[ var_name ] ) );
				return String( params[ var_name ] );
			}
			
			trace( "LaunchPad", FlashVars, "Failure retrieving FlashVar '" + var_name + "' - returning null" );
			
			return null;
			
		}
		
	}

}