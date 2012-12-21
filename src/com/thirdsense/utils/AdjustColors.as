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
		
		public static function getColor( tint:uint, alpha:Number ):ColorTransform
		{
			var c:Color = new Color();
			c.setTint( tint, alpha );
			
			var ct:ColorTransform = c;
			
			return ct;
		}
		
	}

}