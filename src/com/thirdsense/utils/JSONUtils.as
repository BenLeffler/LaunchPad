package com.thirdsense.utils 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * Loads remote JSON files and parses the out for use
	 * @author Ben Leffler
	 */
	
	public class JSONUtils 
	{
		private static var url:String;
		private static var onResponse:Function;
		private static var url_loader:URLLoader;
		private static var _timeout:Number = 30000;
		private static var _retries:int = 3;
		private static var retry_counter:int;
		private static var timer:uint;
		
		/**
		 * Initiates a remote load of a JSON object
		 * @param	url	The url location of the JSON object to load (either from cloud or local)
		 * @param	onResponse	The function to call upon a result. This must accept a boolean param (indicates success) and an object param (the parsed response)
		 * @return	A boolean value of the call to load's success. If a load is already happening when this is called, false will be returned
		 */
		
		public static function loadRemoteJSON( url:String, onResponse:Function ):Boolean
		{
			if ( url_loader )	return false;
			
			JSONUtils.url = url;
			JSONUtils.onResponse = onResponse;
			JSONUtils.retry_counter = retries;
			
			url_loader = new URLLoader();
			url_loader.addEventListener(Event.COMPLETE, jsonLoaded, false, 0, true);
			url_loader.addEventListener(IOErrorEvent.IO_ERROR, jsonLoadError, false, 0, true);
			
			var url_request:URLRequest = new URLRequest(url);
			url_request.method = URLRequestMethod.GET;
			url_loader.dataFormat = URLLoaderDataFormat.TEXT;
			url_loader.load( url_request );
			
			timer = setTimeout( jsonTimeout, timeout );
			
			return true;
		}
		
		/**
		 * @private
		 */
		
		private static function jsonLoaded( evt:Event ):void
		{
			clearTimeout(timer);
			url_loader.removeEventListener(Event.COMPLETE, jsonLoaded);
			url_loader.removeEventListener(IOErrorEvent.IO_ERROR, jsonLoadError);
			url = "";
			
			var data:Object = JSON.parse( url_loader.data as String );
			url_loader = null;
			
			var fn:Function = onResponse;
			onResponse = null;
			fn( true, data );
		}
		
		/**
		 * @private
		 */
		
		private static function jsonLoadError( evt:IOErrorEvent ):void
		{
			clearTimeout(timer);
			url_loader.removeEventListener(Event.COMPLETE, jsonLoaded);
			url_loader.removeEventListener(IOErrorEvent.IO_ERROR, jsonLoadError);
			url_loader = null;
			
			retry_counter--;
			if ( !retry_counter )
			{
				var fn:Function = onResponse;
				onResponse = null;
				fn( false, null );
			}
			else
			{
				loadRemoteJSON( url, onResponse );
			}
		}
		
		/**
		 * @private
		 */
		
		private static function jsonTimeout():void
		{
			jsonLoadError(null);
		}
		
		/**
		 * The number of milliseconds to wait before declaring a local timeout on a remote retrieval
		 */
		
		public static function get timeout():Number
		{
			return _timeout;
		}
		
		public static function set timeout(value:Number):void
		{
			_timeout = value;
		}
		
		/**
		 * Returns and sets the number of retries to attempt before declaring a failed remote retrieval
		 */
		public static function get retries():int 
		{
			return _retries;
		}
		
		public static function set retries(value:int):void 
		{
			_retries = value;
		}
		
		/**
		 * Checks if the utility is currently in a call
		 * @return
		 */
		
		public static function inCall():Boolean
		{
			return ( url_loader != null )
		}
		
	}

}