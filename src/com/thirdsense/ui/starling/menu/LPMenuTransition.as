package com.thirdsense.ui.starling.menu 
{
	import flash.geom.Point;
	
	/**
	 * Transition types for the LaunchPad menu system
	 * @author Ben Leffler
	 */
	
	public class LPMenuTransition 
	{
		public static const TO_LEFT:String = "L";
		public static const TO_RIGHT:String = "R";
		public static const FROM_LEFT:String = "R";
		public static const FROM_RIGHT:String = "L";
		public static const NONE:String = "";
		public static const UP:String = "T";
		public static const DOWN:String = "B";
		
		public function LPMenuTransition() 
		{
			
		}
		
		public static function get RANDOM():String
		{
			var arr:Array = [ "L", "R", "T", "B" ];
			return arr[ Math.floor(Math.random() * arr.length) ];
		}
		
		public static function translate( transition:String ):Point
		{
			var pt:Point = new Point();
			
			switch ( transition )
			{
				case TO_LEFT:
				case FROM_RIGHT:
					pt.x = -1;
					pt.y = 0;
					break;
					
				case TO_RIGHT:
				case FROM_LEFT:
					pt.x = 1;
					pt.y = 0;
					break;
					
				case NONE:
					pt.x = 0;
					pt.y = 0;
					break;
					
				case UP:
					pt.x = 0;
					pt.y = -1;
					break;
					
				case DOWN:
					pt.x = 0;
					pt.y = 1;
					break;
				
			}
			
			return pt;
		}
		
	}

}