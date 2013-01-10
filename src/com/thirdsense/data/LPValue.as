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
		
		public var name:String;
		public var value:String;
		
		public function LPValues():void
		{
			
		}
		
		public function toString():String
		{
			return StringTools.toString( this, AccessorType.NONE );
		}
		
		public static function addValue( value:LPValue ):void
		{
			if ( !values )
			{
				values = new Vector.<LPValue>;
			}
			
			values.push( value );
		}
		
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