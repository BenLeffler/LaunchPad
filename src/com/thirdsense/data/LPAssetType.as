package com.thirdsense.data 
{
	/**
	 * A list of the type of assets the LaunchPad framework can import in to it's asset library
	 * @author Ben Leffler
	 */
	
	public class LPAssetType 
	{
		/**
		 * An asset type associated with a swf or swf library containing linkage items
		 */
		public static const SWF:String = "swf";
		
		/**
		 * An asset type associated with an XML data construct
		 */
		public static const XML:String = "xml";
		
		/**
		 * An asset type associated with a compressed zip library
		 */
		public static const ZIP:String = "zip";
		
		/**
		 * An asset type associated with a compressed zip library that has had it's extension changed to '3rd'
		 */
		public static const THIRD:String = "3rd";
		
		/**
		 * An asset type associated with a JSON data construct
		 */
		public static const JSON:String = "json";
		
		/**
		 * An unknown asset type
		 */
		public static const UNKNOWN:String = "?";
		
	}

}