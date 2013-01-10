package com.thirdsense.sound 
{
	import com.thirdsense.animation.BTween;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class SoundShape 
	{
		public static const FADE_IN:String = "fadeIn";
		public static const FADE_OUT:String = "fadeOut";
		public static const FADE_EASE_IN:String = "fadeEaseIn";
		public static const FADE_EASE_OUT:String = "fadeEaseOut";
		public static const PAN_RIGHT:String = "panRight";
		public static const PAN_LEFT:String = "panLeft";
		public static const PAN_LEFT_TO_RIGHT:String = "panLeftToRight";
		public static const PAN_RIGHT_TO_LEFT:String = "panRightToLeft";
		
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
		
		private static function shapeHandler( target:Object ):void
		{
			var st:SoundTransform = new SoundTransform( target.volume, target.pan );
			target.channel.soundTransform = st;
			
		}
	}

}