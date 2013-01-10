package com.thirdsense.utils
{
	import com.thirdsense.utils.getClassVariables;
	import com.thirdsense.utils.StringTools;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MediaEvent;
	import flash.media.CameraUI;
	import flash.media.MediaPromise;
	import flash.media.MediaType;
	
	/**
	 * Static class that makes use of the mobile device's native camera to take a photo.
	 * @author Ben Leffler
	 */
	
	public class DeviceCamera
	{
		private static var camera_ui:CameraUI;
		private static var imageLoader:Loader;
		private static var media:MediaPromise;
		
		private static var onComplete:Function;
		private static var onFailure:Function;
		
		public static const NOT_SUPPORTED:String = "notSupported";
		public static const USER_CANCELLED:String = "userCancelled";
		public static const CAMERA_ERROR:String = "cameraError";
		
		/**
		 * Calls upon the mobile device's native camera and returns the captured image as a Loader instance
		 * @param	onResult	The function to call upon a successful photo. It must accept a single argument which contains the resulting Loader instance
		 * @param	onFail	Function to call upon a failure. Must accept a String argument which indicates the nature of the failure (non support, camera error or user cancellation)
		 */
		
		public static function call(onResult:Function, onFail:Function = null):void
		{
			onComplete = onResult;
			onFailure = onFail;
			
			if (CameraUI.isSupported)
			{
				camera_ui = new CameraUI();
				camera_ui.addEventListener(MediaEvent.COMPLETE, imageCaptured);
				camera_ui.addEventListener(Event.CANCEL, captureCanceled);
				camera_ui.addEventListener(ErrorEvent.ERROR, cameraError);
				camera_ui.launch(MediaType.IMAGE);
			}
			else if (onFail != null)
			{
				onFail(NOT_SUPPORTED);
			}
		}
		
		private static function imageCaptured(evt:MediaEvent):void
		{
			var imagePromise:MediaPromise = media = evt.data;
			
			trace( StringTools.toString(media.file) );
			
			if (imagePromise.isAsync)
			{
				imageLoader = new Loader();
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, asyncImageLoaded);
				imageLoader.addEventListener(IOErrorEvent.IO_ERROR, cameraError);
				imageLoader.loadFilePromise(imagePromise);
			}
			else
			{
				imageLoader.loadFilePromise( imagePromise );
				onComplete( imageLoader );
				dispose();
			}
		}
		
		private static function asyncImageLoaded(evt:Event):void 
		{
			onComplete( imageLoader );
			
			dispose();
		}
		
		private static function captureCanceled( evt:Event ):void
		{
			onFailure( DeviceCamera.USER_CANCELLED );
			dispose();
		}
		
		private static function cameraError( evt:* ):void
		{
			onFailure( DeviceCamera.CAMERA_ERROR );
			dispose();
		}
		
		private static function dispose():void
		{
			if ( media ) media.file.moveToTrashAsync();
			imageLoader.contentLoaderInfo.removeEventListener( flash.events.Event.COMPLETE, asyncImageLoaded );
            imageLoader.removeEventListener( IOErrorEvent.IO_ERROR, cameraError );
			camera_ui.removeEventListener( MediaEvent.COMPLETE, imageCaptured );
			camera_ui.removeEventListener( flash.events.Event.CANCEL, captureCanceled );
			camera_ui.removeEventListener( ErrorEvent.ERROR, cameraError );
			imageLoader = null;
			camera_ui = null;
			media = null;
		}
	
	}

}