package com.thirdsense.utils 
{
	import flash.display.BitmapData;
	
	/**
	 * Class to assist with the generation of random landscape
	 * @author Ben Leffler
	 */
	
	public class Landscape 
	{
		/**
		 * Generates a 3-Dimensional array filled with height data (values between 0 and 1)
		 * @param	columns	Number of columns in the resulting array
		 * @param	rows	Number of rows in the resulting array
		 * @param	min_limit	Values are capped on the low-end at this variable
		 * @param	max_limit	Values are capped on the high-end at this variable
		 * @return	A 3 dimensional array
		 */
		
		public static function generateHeightMap( columns:int=200, rows:int=200, min_limit:Number=0, max_limit:Number=1, seed:int=-1 ):Array
		{
			if ( seed < 0 ) {
				seed = Math.round(Math.random() * 100);
			}
			
			var bmpdata:BitmapData = new BitmapData( columns, rows, true, 0 );
			bmpdata.perlinNoise( columns / 2, rows / 2, 28, seed, false, true, 7, true );
			
			return Landscape.autoLevel( bmpdata, min_limit, max_limit );
			
		}
		
		private static function autoLevel( bmd:BitmapData, min:Number, max:Number ):Array
		{
			var pixels:Array = new Array();
			var brightest_pixel:Number = 0;
			var darkest_pixel:Number = 1;
			
			for ( var i:uint = 0; i < bmd.width; i++ ) {
				pixels[i] = new Array();
				for ( var j:uint = 0; j < bmd.height; j++ ) {
					pixels[i][j] = bmd.getPixel(i,j) / 0xFFFFFF;
					if ( pixels[i][j] > brightest_pixel ) {
						brightest_pixel = pixels[i][j];
					}
					if ( pixels[i][j] < darkest_pixel ) {
						darkest_pixel = pixels[i][j];
					}
				}
			}
			
			brightest_pixel -= darkest_pixel;
			
			for ( i=0; i<pixels.length; i++ ) {
				for (j=0; j<pixels[i].length;j++) {
					pixels[i][j] -= darkest_pixel;
					pixels[i][j] /= brightest_pixel;
					pixels[i][j] = Trig.lim( pixels[i][j], min, max );
				}
			}
			
			return pixels;
			
		}
		
	}

}