package com.thirdsense.controllers 
{
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.Profiles;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.AudioPlaybackMode;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	public class MobilityControl 
	{
		private static var _has_focus:Boolean = true;
		private static var onActive:Function;
		private static var onDeactive:Function;
		private static var keep_awake:Boolean = false;
		private static var onBackButton:Function;
		private static var notification_manager:*;
		private static var onNotificationRegister:Function;
		public static var notification_ids:Array;
		private static var fps:int;
		
		public static function get has_focus():Boolean
		{
			return _has_focus;
		}
		
		public function MobilityControl() 
		{
			
		}
		
		public static function initAudioMode():void
		{
			SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
		}
		
		public static function exitIfInactive( enabled:Boolean=true ):void
		{
			if ( Capabilities.manufacturer.toLowerCase().indexOf("ios") < 0 ) {
				if ( enabled )
				{
					killActivationControl();
					NativeApplication.nativeApplication.autoExit = true;
					initActivationControl( null, exitApplication );
				}
				else
				{
					killActivationControl();
					NativeApplication.nativeApplication.autoExit = false;
					initActivationControl();
				}
			}
			
		}
		
		public static function killActivationControl():void
		{
			NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, MobilityControl.activationHandler);
			NativeApplication.nativeApplication.removeEventListener(Event.ACTIVATE, MobilityControl.activationHandler);
		}
		
		public static function initActivationControl( onActivate:Function=null, onDeactivate:Function=null ):void
		{
			if ( Capabilities.cpuArchitecture != "x86" ) {
				
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, MobilityControl.activationHandler, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, MobilityControl.activationHandler, false, 0, true);
				
				if ( onActivate != null ) {
					MobilityControl.fps = LaunchPad.instance.nativeStage.frameRate;
				}
				
				MobilityControl.onActive = onActivate;
				MobilityControl.onDeactive = onDeactivate;
				
			}
			
		}
		
		public static function preventFromSleep():void
		{
			if ( Profiles.mobile ) {
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
				keep_awake = true;
			}
			
		}
		
		public static function allowSleep( save_state:Boolean = true ):void
		{
			if ( Profiles.mobile ) {
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
				if ( save_state ) {
					keep_awake = false;
				}
			}
			
		}
		
		private static function activationHandler(evt:Event):void
		{
			if ( evt.type == Event.ACTIVATE ) {
				//LaunchPad.ROOT.stage.frameRate = MobilityControl.fps;
				
				_has_focus = true;
				
				if ( keep_awake ) {
					preventFromSleep();
				}
				
				SoundMixer.soundTransform = new SoundTransform(1);
				
				if ( onActive != null ) {
					onActive();
				}
				
			}
			
			if ( evt.type == Event.DEACTIVATE ) {
				//LaunchPad.ROOT.stage.frameRate = 4;
				
				_has_focus = false;
				
				allowSleep(false);
				
				SoundMixer.soundTransform = new SoundTransform(0);
				
				if ( onDeactive != null ) {
					onDeactive();
				}
			}
			
		}
		
		public static function exitApplication( evt:Event = null ):void
		{
			trace( "exitApplication" );
			
			if ( Capabilities.manufacturer.toLowerCase().indexOf("ios") >= 0 ) {
				trace( MobilityControl, "exitApplication call failed. Not compatible with iOS devices." );
			} else {
				NativeApplication.nativeApplication.exit();
			}
			
		}
		
		public static function initTimedGarbageCollect():void
		{
			setTimeout( garbageCollect, 5000 );
			
		}
		
		private static function garbageCollect():void
		{
			System.gc();
			System.gc();
			
			initTimedGarbageCollect();
		}
		
		/**
		 * Creates a listener tied to the back button press event (Android only)
		 * @param	onPress	The function to execute upon the event occuring.
		 */
		
		public static function initBackButton( onPress:Function ):void
		{
			MobilityControl.killBackButton();
			
			if ( Capabilities.manufacturer.toLowerCase().indexOf("ios") < 0 && Profiles.mobile ) {
				trace( MobilityControl, "Back Button is now handled." );
				onBackButton = onPress;
				LaunchPad.instance.nativeStage.stage.removeEventListener( KeyboardEvent.KEY_DOWN, backButtonHandler );
				LaunchPad.instance.nativeStage.stage.addEventListener( KeyboardEvent.KEY_DOWN, backButtonHandler, false, 0, true );
			} else {
				trace( MobilityControl, "Attempt to initBackButton failed - not compatible with this device type" );
			}
			
		}
		
		public static function killBackButton():void
		{
			LaunchPad.instance.nativeStage.stage.removeEventListener( KeyboardEvent.KEY_DOWN, backButtonHandler );
			onBackButton = null;
		}
		
		private static function backButtonHandler(evt:KeyboardEvent):void
		{
			if ( evt.keyCode == Keyboard.BACK ) {
				evt.preventDefault();
				if ( onBackButton != null )
				{
					onBackButton();
				}
			}
		}
		
		public static function getBackButtonHandler():Function
		{
			if ( onBackButton != null )
			{
				return onBackButton;
			}
			else
			{
				return null;
			}
		}
		
		
		
	}

}