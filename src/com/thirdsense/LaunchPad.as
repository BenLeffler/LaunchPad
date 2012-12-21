package com.thirdsense 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.core.Preload;
	import com.thirdsense.data.LPAsset;
	import com.thirdsense.data.LPAssetClient;
	import com.thirdsense.data.LPValue;
	import com.thirdsense.settings.LPSettings;
	import com.thirdsense.settings.Profiles;
	import com.thirdsense.utils.FlashVars;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.setTimeout;
	
	/**
	 * LaunchPad Contructor
	 * @author Ben Leffler
	 * @version 1.0.0
	 */
	
	public class LaunchPad extends Sprite
	{
		public static var instance:LaunchPad;
		
		private var _target:MovieClip;
		private var onCompleteInit:Function;
		
		public function LaunchPad() 
		{
			
		}
		
		/**
		 * Initializes and starts application load procedure.
		 * @param	root	The root class for the application. This can be accessed from calling LaunchPad.root
		 * @param	onComplete	The function to call once the application has completed initializing
		 * @param	preloader	The sprite to use for the preloading user interface. Pass as null to use the default generic loader.
		 * @param	profile	The profile of the device to use for this build.
		 * @see	com.thirdsense.profiles
		 */
		
		public function init( target:MovieClip, onComplete:Function, preloader:Sprite=null ):void
		{
			trace( "LaunchPad", LaunchPad, "Launching..." );
			
			instance = this;
			
			this._target = target;
			this._target.stop();
			
			this.onCompleteInit = onComplete;
			
			// Check for an alternate path to the lib folder through use of flashvars
			FlashVars.init( target );
			var live_extension:String = FlashVars.getVar( "lib_path" );
			if ( live_extension != null ) LPSettings.LIVE_EXTENSION = String(live_extension);
			
			// Call a start to the engine
			this.addEventListener(Event.ENTER_FRAME, this.processEngine, false, 0, true);
			
			// Call the preload on the next frame (because the stage size has to initialize first)
			BTween.callOnNextFrame( Preload.load, [preloader, this.onPreloadComplete] );
		}
		
		private function onPreloadComplete():void
		{
			Profiles.CURRENT_DEVICE = Profiles.DEVICE_DETECT;
			this.onCompleteInit();
		}
		
		/**
		 * The root movieclip that was passed through in the LaunchPad.init call
		 */
		
		public function get target():MovieClip 
		{
			return this._target;
		}
		
		private function processEngine(evt:Event):void
		{
			BTween.processCue();
		}
		
		/**
		 * Obtains a value as defined by the LaunchPad config.xml
		 * @param	name	The name of the value to retrieve
		 * @return	The value as a String
		 */
		
		public static function getValue( name:String ):String
		{
			return LPValue.getValue( name ).value;
		}
		
		/**
		 * Obtains an asset that has been loaded in to the LaunchPad framework during the preload stage.
		 * @param	id	(Optional) Designates which asset library to retrieve
		 * @param	linkage	(Optional) Designates the specific linkage name of an asset, if the asset library is of the LPAssetClient qualified class type
		 * @return	Null if item unfound. Otherwise it will return a variety of object types
		 */
		
		public static function getAsset( id:String = "", linkage:String = "" ):*
		{
			return LPAsset.getAsset( id, linkage );
		}
		
		/**
		 * Starts a post load procedure of LaunchPad library assets
		 * @param	id_array	An array of library id's to load one-by-one
		 * @param	onComplete	The callback function once the procedure has reached it's end
		 * @param	preloader	The preloader ui element to use. If left as null, the LaunchPad generic loader element is used. For no loader bar, pass this as an empty movieclip.
		 */
		
		public static function loadLibrary( id_array:Array, onComplete:Function=null, preloader:MovieClip=null ):void
		{
			Preload.postLoad( id_array, onComplete, preloader );
		}
		
	}

}