package com.thirdsense.utils  
{
	import fl.motion.ColorMatrix;
	import fl.motion.AdjustColor;
	import flash.filters.ColorMatrixFilter;
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	
	
	/**
	 * Allows actionscript adjustment to Hue, Saturation and Brightness on par with the IDE filters.
	 * @author Ben Leffler
	 */
	
	public class AdjustColors
	{
		/**
		 * Creates a ColorMatrixFilter based on the Adjust Color Flash IDE filter set. All values are between -100 and 100.
		 * @param	hue	The hue value
		 * @param	saturation	The saturation value
		 * @param	brightness	The brightness value
		 * @param	contrast	The contrast value
		 * @return	A ColorMatrixFilter object that can be used as a classic filter
		 */
		
		public static function HSB( hue:int=0, saturation:int=0, brightness:int=0, contrast:int=0 ):ColorMatrixFilter
		{
			var colorFilter:AdjustColor = new AdjustColor();
			var mColorMatrix:ColorMatrixFilter;
			var mMatrix:Array = new Array();
			
			
			colorFilter.hue = hue;
			colorFilter.saturation = saturation;
			colorFilter.brightness = brightness;
			colorFilter.contrast = contrast;
			
			mMatrix = colorFilter.CalculateFinalFlatArray();
			mColorMatrix = new ColorMatrixFilter(mMatrix);
			
			return mColorMatrix;
		}
		
		/**
		 * Allows you to perform a tint on a classic display list object. eg. my_movieclip.transform.colorTransform = getColor( 0xFF0000, 1 );
		 * @param	tint	The color to tint as
		 * @param	alpha	The alpha of the tint to apply
		 * @return	A ColorTransform object
		 */
		
		public static function getColor( tint:uint, alpha:Number ):ColorTransform
		{
			var c:Color = new Color();
			c.setTint( tint, alpha );
			
			var ct:ColorTransform = c;
			
			return ct;
		}
		
	}

}