package com.thirdsense.sound 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.LPSettings;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	public class SoundStream 
	{
		private static var _sound_volume:Number = 1;
		private static var _music_volume:Number = 1;
		
		public function SoundStream() 
		{
			
		}
		
		public static function play( file:String, volume:Number = 1, loops:int = 0, label:String="sound" ):SoundChannel
		{
			var st:SoundTransform = new SoundTransform( volume * SoundStream[label + "_volume"] );
			
			var snd:Sound = LaunchPad.getAsset( "", file );
			if ( !snd )
			{
				snd = new Sound( new URLRequest(LPSettings.LIVE_EXTENSION + "lib/mp3/" + file) );
			}
			
			if ( snd )
			{
				return snd.play( 0, loops, st );
			}
			else
			{
				return null;
			}
		}
		
		static public function get sound_volume():Number 
		{
			return _sound_volume;
		}
		
		static public function set sound_volume(value:Number):void 
		{
			_sound_volume = value;
		}
		
		static public function get music_volume():Number 
		{
			return _music_volume;
		}
		
		static public function set music_volume(value:Number):void 
		{
			_music_volume = value;
		}
		
	}

}