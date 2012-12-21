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
	 * ...
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
		
		private static function jsonTimeout():void
		{
			jsonLoadError(null);
		}
		
		public static function get timeout():Number
		{
			return _timeout;
		}
		
		public static function set timeout(value:Number)
		{
			_timeout = value;
		}
		
		public static function get retries():int 
		{
			return _retries;
		}
		
		public static function set retries(value:int):void 
		{
			_retries = value;
		}
		
		public static function inCall():Boolean
		{
			return ( url_loader != null )
		}
		
	}

}