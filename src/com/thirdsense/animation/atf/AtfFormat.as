package com.thirdsense.animation.atf {

	/**
	 * @private
	 * @author Pierre Lepers
	 * away3d.tools.atf.ATFFormat
	 */
	public class AtfFormat {
		
		/**
		 * 24bit RGB format
		 */
		public static const RGB888 : uint = 0;
		/**
		 * 32bit RGBA format
		 */
		public static const RGBA88888 : uint = 1;
		/**
		 * block based compression format (DXT1 + PVRTC + ETC1)
		 */
		public static const Compressed : uint = 2;
		
		
		/**
		 * return the human readable format information
		 */
		public static function getFormat( fmt : int ) : String {
			switch( fmt ) {
				case RGB888 : 		return "RGB888";
				case RGBA88888 :	return "RGBA88888";
				case Compressed :	return "Compressed";
				default:			return "UNKNOWN ATF FORMAT";
			}
		}
	}
}
