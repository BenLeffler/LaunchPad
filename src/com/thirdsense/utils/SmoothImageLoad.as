package com.thirdsense.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class SmoothImageLoad {
		
		public var urlrequest:URLRequest;
		public var target:DisplayObjectContainer;
		public var maxwidth:Number;
		public var maxheight:Number;
		public var requiresPolicyFile:Boolean;
		public var scaletype:String;
		public var bmpdata:BitmapData;
		public var cache:Boolean;
		
		public static const CONSTRAIN:String = "constrain";
		public static const CROP_TO_CENTER:String = "cropToCenter";
		public static const CROP_TO_TOP_LEFT:String = "cropToTopLeft";
		public static const STRETCH:String = "stretch";
		public static const EXACT:String = "exact";
		
		public static const CANCEL_LOAD:String = "cancelLoad";
		
		private static var myLoader:Loader;
		private static var myURLRequest:URLRequest;
		private static var queue:Vector.<SmoothImageLoad>;
		private static var cache:Array;
		public static var progress:Number = 0;
		private static var timeout:uint;
		
		
		public function SmoothImageLoad():void
		{
			
		}
		
		/**
		 * Loads an image from a specified url
		 * @param	myURL	The url to load the image from
		 * @param	target	The target container to place a bitmap copy of the loaded image
		 * @param	maxwidth	The maximum width of the image. Leave as 0 for the native size to be used
		 * @param	maxheight	The maximum height of the image. Leave as 0 for the native size to be used
		 * @param	scale_type	Determines the scale type to be used. Defaults to SmoothImageLoad.CONSTRAIN.
		 * @param	requiresPolicyFile	If a crossdomain load is required, pass this as true and ensure you have loaded the appropriate context security policy first.
		 * @param	cacheImage	If the image should be cached for later use in the session, pass this as true. Defaults to false.
		 */
		
		public static function imageLoad(myURL:String, target:DisplayObjectContainer, maxwidth:Number=0, maxheight:Number=0, scale_type:String="constrain", requiresPolicyFile:Boolean=false, cacheImage:Boolean=false ):void {
			
			myURLRequest = new URLRequest(myURL);
			
			if ( !queue )
			{
				queue = new Vector.<SmoothImageLoad>;
			}
			
			var sml:SmoothImageLoad = new SmoothImageLoad();
			sml.urlrequest = myURLRequest;
			sml.target = target;
			sml.maxwidth = maxwidth;
			sml.maxheight = maxheight;
			sml.requiresPolicyFile = requiresPolicyFile;
			sml.scaletype = scale_type;
			sml.bmpdata = null;
			sml.cache = cacheImage;
			
			queue.push(sml);
			
			if ( cacheImage )
			{
				if ( !cache )
				{
					cache = new Array();
				}
				
			}
			
			target.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler, false, 0, true);
			
			if ( queue.length == 1 ) {
				timeout = setTimeout( loadNextSlot, 100 );
			}
			
		}
		
		/**
		 * Reports on if a specified url is currently sitting in the load cue (waiting to be loaded)
		 * @param	url	The source url of the image
		 * @return	boolean value
		 */
		
		public static function urlExistsInCue( url:String ):Boolean
		{
			if ( queue )
			{
				for ( var i:uint = 0; i < queue.length; i++ )
				{
					if ( queue[i].urlrequest.url == url )
					{
						return true;
					}
				}
			}
			
			return false;
		}
		
		/**
		 * Clears the session cache of images
		 */
		
		public static function killCache():void
		{
			if ( cache )
			{
				while ( cache.length )
				{
					cache[0].bmpdata.dispose();
					cache[0].bmpdata = null;
					cache.shift();
				}
			}
			
			cache = null;
		}
		
		/**
		 * Kills the current cue of images waiting to be loaded.
		 */
		
		public static function killCue():void
		{
			trace( SmoothImageLoad, "Called killCue()" );
			
			clearTimeout( timeout );
			
			if ( myLoader && myLoader.contentLoaderInfo ) {
				
				try
				{
					if ( myLoader.contentLoaderInfo.bytesLoaded < myLoader.contentLoaderInfo.bytesTotal ) {
						myLoader.close();
					}
				}
				catch (e:*)
				{
					//
				}
				
				myLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, doneLoad );
				myLoader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
				myLoader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );
				myLoader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityHandler );
				
				myLoader = null;
			}
			
			if ( queue && queue.length ) {
				for ( var i:uint = 0; i < queue.length; i++ ) {
					(queue[i].target as DisplayObjectContainer).dispatchEvent( new Event(SmoothImageLoad.CANCEL_LOAD) );
				}
			}
			queue = null;
			
		}
		
		/**
		 * Retrieves if the SmoothImageLoad class has files waiting in the load cue
		 * @return	True if the queue is populated. False otherwise.
		 */
		
		public static function hasCue():Boolean
		{
			if ( queue && queue.length ) {
				return true;
			}
			
			return false;
		}
		
		private static function removeHandler(evt:Event):void
		{
			evt.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			
			for ( var i:uint = 0; i < queue.length; i++ ) {
				if ( queue[i].target == evt.currentTarget as MovieClip ) {
					queue.splice(i, 1);
					return void;
				}
			}
		}
		
		/**
		 * Retrieves a bitmapdata object from the session stored cache
		 * @param	url	The url of the source image
		 * @return	A bitmapdata instance of the cached object. If the object does not exist in the session cache, returns null.
		 */
		
		public static function getFromCache( url:String ):BitmapData
		{
			if ( cache )
			{
				for ( var i:uint = 0; i < cache.length; i++ )
				{
					if ( cache[i].url == url )
					{
						return cache[i].bmpdata.clone();
					}
				}
			}
			
			return null;
		}
		
		private static function loadNextSlot():void
		{
			myLoader = new Loader();
			
			if ( !queue[0] )
			{
				return void;
			}
			
			queue[0].target.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			
			if ( queue[0].bmpdata || getFromCache(queue[0].urlrequest.url) )
			{
				timeout = setTimeout( doneLoad, 100 );
				return void;
			}
			
			if ( queue[0].requiresPolicyFile ) {
				var context:LoaderContext = new LoaderContext();
				context.checkPolicyFile = true;
				
				if ( LocalConnection.isSupported ) {
					var lc:LocalConnection = new LocalConnection();
					if ( lc.domain.toLowerCase().indexOf("app") ) {
						Security.allowDomain( (queue[0].urlrequest as URLRequest).url );
					}
				}
				myLoader.load( queue[0].urlrequest, context );
			} else {
				myLoader.load( queue[0].urlrequest );
			}
			
			myLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, doneLoad, false, 0, true );
			myLoader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progressHandler, false, 0, true );
			myLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, errorHandler, false, 0, true );
			myLoader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityHandler, false, 0, true );
			
		}
		
		private static function securityHandler( evt:SecurityErrorEvent ):void
		{
			trace( SmoothImageLoad, "Security Error loading image:", evt );
			
			myLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, doneLoad );
			myLoader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
			myLoader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			myLoader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityHandler );
			
			queue[0].target.dispatchEvent( evt );
			
			if ( queue.length > 1 ) {
				queue.shift();
				loadNextSlot();
			} else {
				queue = null;
			}
			
		}
		
		private static function errorHandler( evt:IOErrorEvent ):void
		{
			trace( SmoothImageLoad, "Error loading image:", evt );
			
			myLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, doneLoad );
			myLoader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
			myLoader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			myLoader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityHandler );
			
			queue[0].target.dispatchEvent( evt );
			
			if ( queue.length > 1 ) {
				queue.shift();
				loadNextSlot();
			} else {
				queue = null;
			}
			
		}
		
		private static function progressHandler( evt:ProgressEvent ):void
		{
			queue[0].target.dispatchEvent( evt );
			progress = evt.bytesLoaded / evt.bytesTotal;
			
		}
		
		private static function doneLoad(evt:Event=null):void {
			
			if ( evt )
			{
				var BMPdata:BitmapData = new BitmapData(myLoader.width, myLoader.height, true, 0x00000000);
				var BMP:Bitmap = new Bitmap(BMPdata, "auto", true );
				
				try {
					BMPdata.draw(myLoader, null, null, null, null, true);
				} catch (e:Error) {
					
					trace( SmoothImageLoad, "ERROR", e );
					
					queue[0].target.dispatchEvent( new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR) );
					
					myLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, doneLoad );
					myLoader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
					myLoader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );
					myLoader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityHandler );
					
					if ( queue.length > 1 ) {
						queue.shift();
						loadNextSlot();
					} else {
						queue = null;
						myLoader = null;
					}
					
					return void;
				}
			}
			else if ( !queue )
			{
				return void;
			}
			else
			{
				BMPdata = getFromCache( queue[0].urlrequest.url );
				if ( !BMPdata )
				{
					BMPdata = queue[0].bmpdata;
				}
				BMP = new Bitmap( BMPdata, "auto", true );
			}
			
			var scaletype:String = queue[0].scaletype;
			
			if ( queue[0].maxwidth || queue[0].maxheight) {
				
				if ( scaletype == SmoothImageLoad.CONSTRAIN ) 
				{
					while ( BMP.height > queue[0].maxheight || BMP.width > queue[0].maxwidth ) {
						BMP.scaleX -= 0.005;
						BMP.scaleY -= 0.005;
					}
				}
				
				if ( scaletype == SmoothImageLoad.STRETCH ) 
				{
					if ( BMP.height > queue[0].maxheight ) {
						BMP.height = queue[0].maxheight;
					}
					if ( BMP.width > queue[0].maxwidth ) {
						BMP.width = queue[0].maxwidth;
					}					
				}
				
				if ( scaletype == SmoothImageLoad.CROP_TO_CENTER || scaletype == SmoothImageLoad.CROP_TO_TOP_LEFT ) 
				{					
					BMP.height = 1;
					BMP.width = 1;
					while ( BMP.height < queue[0].maxheight || BMP.width < queue[0].maxwidth ) {
						BMP.scaleX += 0.005;
						BMP.scaleY += 0.005;
					}
					
					if ( scaletype == SmoothImageLoad.CROP_TO_CENTER ) {
						BMP.x = (queue[0].maxwidth - BMP.width) / 2;
						BMP.y = (queue[0].maxheight - BMP.height) / 2;
					}
					if ( scaletype == SmoothImageLoad.CROP_TO_TOP_LEFT ) {
						BMP.x = 0;
						BMP.y = 0;
					}
					
					var bmpdata:BitmapData = new BitmapData( queue[0].maxwidth, queue[0].maxheight, true, 0 );
					var matrix:Matrix = BMP.transform.matrix;
					bmpdata.draw( BMP, matrix, null, null, null, true );
					BMP = new Bitmap( bmpdata, "auto", true );
					
				}
				
				if ( scaletype == SmoothImageLoad.EXACT ) {
					BMP.width = queue[0].maxwidth;
					BMP.height = queue[0].maxheight;
				}
				
				
			}
			
			queue[0].target.addChild(BMP);
			
			if ( evt )
			{
				var url:String = (queue[0].urlrequest as URLRequest).url;
				for ( var i:uint = 1; i < queue.length; i++ )
				{
					if ( queue[i].urlrequest.url == url )
					{
						queue[i].bmpdata = BMP.bitmapData;
					}
				}
				
				if ( queue[0].cache && !getFromCache(queue[0].urlrequest.url) )
				{
					var obj:Object = {
						url:queue[0].urlrequest.url,
						bmpdata:BMP.bitmapData.clone()
					}
					cache.push( obj );
				}
			}
			
			myLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, doneLoad );
			myLoader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressHandler );
			myLoader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			myLoader.contentLoaderInfo.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityHandler );
			
			obj = queue[0];
			
			if ( queue.length > 1 ) {
				queue.shift();
				loadNextSlot();
			} else {
				queue = null;
			}
			
			obj.target.dispatchEvent( new Event(Event.COMPLETE, false) );
			
		}
		
	}
}