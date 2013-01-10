package com.thirdsense.utils 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class XMLLoader 
	{
		private var url:String;
		private var onComplete:Function;
		private var loader:URLLoader;
		private var _progress:Number;
		
		public function XMLLoader() 
		{
			this._progress = 0;
		}
		
		/**
		 * Loads an XML file located at a URL.
		 * @param	url	The location of the XML file to import
		 * @param	onComplete	The callback function upon load. It should accept an xml object parameter
		 */
		
		public function load( url:String, onComplete:Function ):void
		{
			this.url = url;
			this.onComplete = onComplete;
			
			this.loader = new URLLoader();
			this.loader.dataFormat = URLLoaderDataFormat.TEXT;
			this.loader.addEventListener( Event.COMPLETE, this.loaderHandler, false, 0, true );
			this.loader.addEventListener( IOErrorEvent.IO_ERROR, this.loaderHandler, false, 0, true );
			this.loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, this.loaderHandler, false, 0, true );
			this.loader.addEventListener( ProgressEvent.PROGRESS, this.loaderHandler, false, 0, true );
			this.loader.load( new URLRequest(url) );
			
		}
		
		private function loaderHandler(evt:Event):void
		{
			switch ( evt.type )
			{
				case Event.COMPLETE:
					this.killListeners();
					var fn:Function = this.onComplete;
					this.onComplete = null;
					fn( new XML(this.loader.data) );
					break;
					
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					this.killListeners();
					fn = this.onComplete;
					this.onComplete = null;
					fn(null);
					break;
					
				case ProgressEvent.PROGRESS:
					this._progress = (evt as ProgressEvent).bytesLoaded / (evt as ProgressEvent).bytesTotal;
					break;
			}
		}
		
		private function killListeners():void
		{
			this.loader.removeEventListener( Event.COMPLETE, this.loaderHandler );
			this.loader.removeEventListener( IOErrorEvent.IO_ERROR, this.loaderHandler );
			this.loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, this.loaderHandler);
			this.loader.removeEventListener( ProgressEvent.PROGRESS, this.loaderHandler );
		}
		
		/**
		 * The progress of the current xml load call
		 */
		
		public function get progress():Number 
		{
			return _progress;
		}
	}

}