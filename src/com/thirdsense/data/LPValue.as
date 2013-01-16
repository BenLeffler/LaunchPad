package com.thirdsense.data 
{
	import com.thirdsense.utils.AccessorType;
	import com.thirdsense.utils.StringTools;
	
	/**
	 * Retrieves a value as setup in the LaunchPad config.xml file
	 * @author Ben Leffler
	 */
	
	public class LPValue 
	{
		private static var values:Vector.<LPValue>
		
		/**
		 * The identifying name of the value
		 */
		public var name:String;
		
		/**
		 * The value of this object as a String. Numeric values will need to be parsed to a Number or Integer.
		 */
		public var value:String;
		
		public function LPValues():void
		{
			
		}
		
		public function toString():String
		{
			return StringTools.toString( this, AccessorType.NONE );
		}
		
		/**
		 * Adds a value object to the LaunchPad project. (Used mainly in the project initialization process when parsing out config.xml)
		 * @param	value	The LPValue object to add
		 */
		
		public static function addValue( value:LPValue ):void
		{
			if ( !values )
			{
				values = new Vector.<LPValue>;
			}
			
			values.push( value );
		}
		
		/**
		 * Retrieves a value that has previously been setup within the LaunchPad framework
		 * @param	name	The identifying name of the value to retrieve
		 * @return	The LPValue object associated with the passed name. If no object is found, null is returned.
		 */
		
		public static function getValue( name:String ):LPValue
		{
			if ( !values )
			{
				return null;
			}
			else
			{
				for ( var i:uint = 0; i < values.length; i++ )
				{
					if ( values[i].name == name )
					{
						return values[i];
					}
				}
			}
			
			return null;
		}
		
	}

}