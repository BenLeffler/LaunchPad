package com.thirdsense.utils 
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * Display Object duplicator
	 * @author Ben Leffler
	 */
	
	public class DuplicateDisplayObject
	{
		
		public static function duplicate( target:DisplayObject ):DisplayObject 
		{
			// create duplicate
			var targetClass:Class = Object(target).constructor;
			var dup:DisplayObject = new targetClass();
			
			// duplicate properties
			dup.transform = target.transform;
			dup.filters = target.filters;
			dup.cacheAsBitmap = target.cacheAsBitmap;
			dup.opaqueBackground = target.opaqueBackground;
			
			if ( target.scale9Grid ) {
				var rect:Rectangle = target.scale9Grid;
				// WAS Flash 9 bug where returned scale9Grid is 20x larger than assigned
				// rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				dup.scale9Grid = rect;
			}
			
			return dup;
		}
		
	}

}