package com.thirdsense.animation.atf {

	/**
	 * @private
	 * @author Pierre Lepers
	 * away3d.tools.atf.ATFType
	 */
	public class AtfType {

		/**
		 * 2D texture
		 */
		public static const NORMAL : uint = 0;

		/**
		 * cubic texture
		 */
		public static const CUBE_MAP : uint = 1;

		/**
		 * return the human readable type information
		 */
		public static function getType( type : int ) : String {
			switch( type ) {
				case NORMAL : 	return "NORMAL";
				case CUBE_MAP :	return "CUBE_MAP";
				default:		return "UNKNOWN ATF TYPE";
			}
		}
	}
}
