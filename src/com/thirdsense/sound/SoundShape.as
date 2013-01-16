package com.thirdsense.sound 
{
	import com.thirdsense.animation.BTween;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * Applies a tween based sound effect to a SoundChannel object, such as fading and panning
	 * @author Ben Leffler
	 */
	
	public class SoundShape 
	{
		/**
		 * Fades the sound volume in from 0 to the current volume
		 */
		public static const FADE_IN:String = "fadeIn";
		
		/**
		 * Fades the sound volume out from the current volume to a value of 0
		 */
		public static const FADE_OUT:String = "fadeOut";
		
		/**
		 * Applies a sine curve fade in of volume from 0 to the current volume. Good for cross fading.
		 */
		public static const FADE_EASE_IN:String = "fadeEaseIn";
		
		/**
		 * Applies a sine curve fade out of volume from the current volume to 0. Good for cross fading.
		 */
		public static const FADE_EASE_OUT:String = "fadeEaseOut";
		
		/**
		 * Applies a linear pan from the current pan value to the far right channel
		 */
		public static const PAN_RIGHT:String = "panRight";
		
		/**
		 * Applies a linear pan from the current pan value to the far left channel
		 */
		public static const PAN_LEFT:String = "panLeft";
		
		/**
		 * Applies a linear pan from the far left channel to the far right channel
		 */
		public static const PAN_LEFT_TO_RIGHT:String = "panLeftToRight";
		
		/**
		 * Applies a linear pan from the far right channel to the far left channel
		 */
		public static const PAN_RIGHT_TO_LEFT:String = "panRightToLeft";
		
		/**
		 * Applies a tween based sound effect to a SoundChannel object
		 * @param	channel	The SoundChannel object to apply the transformation to
		 * @param	shape	The type of effect to apply. (eg. SoundShape.FADE_IN, SoundShape.PAN_RIGHT)
		 * @param	frames	The number of frames to apply this transformation over
		 * @param	onShapeComplete	The function that is called upon the transformation having been completed
		 */
		
		public static function apply( channel:SoundChannel, shape:String, frames:int = 60, onShapeComplete:Function = null ):void
		{
			switch ( shape )
			{
				case SoundShape.FADE_IN:
					shape = BTween.LINEAR;
					var target:Number = channel.soundTransform.volume;
					var st:SoundTransform = new SoundTransform(0);
					channel.soundTransform = st;
					var attribute:String = "volume";
					break;
					
				case SoundShape.FADE_EASE_IN:
					shape = BTween.EASE_IN;
					target = channel.soundTransform.volume;
					st = new SoundTransform(0);
					channel.soundTransform = st;
					attribute = "volume";
					break;
					
				case SoundShape.FADE_OUT:
					shape = BTween.LINEAR;
					target = 0;
					attribute = "volume"
					break;
					
				case SoundShape.FADE_EASE_OUT:
					shape = BTween.EASE_IN;
					target = 0;
					attribute = "volume"
					break;
					
				case SoundShape.PAN_LEFT:
					shape = BTween.LINEAR;
					target = -1;
					attribute = "pan";
					break;
					
				case SoundShape.PAN_RIGHT:
					shape = BTween.LINEAR;
					target = 1;
					attribute = "pan";
					break;
					
				case SoundShape.PAN_LEFT_TO_RIGHT:
					shape = BTween.EASE_IN_OUT;
					st = new SoundTransform( channel.soundTransform.volume, -1 );
					channel.soundTransform = st;
					target = 1;
					attribute = "pan";
					break;
					
				case SoundShape.PAN_RIGHT_TO_LEFT:
					shape = BTween.EASE_IN_OUT;
					st = new SoundTransform( channel.soundTransform.volume, 1 );
					channel.soundTransform = st;
					target = -1;
					attribute = "pan";
					break;
					
			}
			
			var obj:Object = {
				channel:channel,
				volume:channel.soundTransform.volume,
				pan:channel.soundTransform.pan
			}
			
			var tween:BTween = new BTween( obj, frames, shape );
			tween.animate( attribute, target );
			tween.onTween = shapeHandler;
			tween.onTweenArgs = [ tween.target ];
			if ( onShapeComplete != null )
			{
				tween.onComplete = onShapeComplete;
			}
			tween.start();
		}
		
		/**
		 * @private
		 */
		
		private static function shapeHandler( target:Object ):void
		{
			var st:SoundTransform = new SoundTransform( target.volume, target.pan );
			target.channel.soundTransform = st;
			
		}
	}

}