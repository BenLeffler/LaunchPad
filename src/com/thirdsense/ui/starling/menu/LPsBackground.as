package com.thirdsense.ui.starling.menu 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.utils.DuplicateDisplayObject;
	import flash.display.MovieClip;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * Background image controller and container.
	 * @author Ben Leffler
	 */
	
	public class LPsBackground extends Sprite 
	{
		private static var source:MovieClip;		
		private static var instance:LPsBackground;
		private static var current_background:int = -1;
		private static var _hidden:Boolean;
		
		public function LPsBackground() 
		{
			
		}
		
		/**
		 * @private	Transitions a new background on to screen
		 * @param	id	The id of the new background to show
		 */
		
		private function transitionTo( id:int ):void
		{
			current_background = id;
			
			var mc:MovieClip = DuplicateDisplayObject.duplicate(LPsBackground.source) as MovieClip;
			mc.gotoAndStop( id + 1 );
			mc.width = Starling.current.stage.stageWidth;
			mc.height = Starling.current.stage.stageHeight;
			var cont:MovieClip = new MovieClip();
			cont.addChild( mc );
			
			var tp:TexturePack = TexturePack.createFromMovieClip( cont, "LPsBackground", String(id), null, 0, 0, null, 0 );
			var img:Image = tp.getImage();
			img.x = 0;
			img.y = 0;
			img.name = tp.sequence;
			this.addChild( img );
			
			var tween:BTween = new BTween( img, 20 );
			tween.fadeFromTo( 0, 1 );
			tween.onComplete = this.onTransitionComplete;
			tween.start();
		}
		
		/**
		 * @private	Called when a new background has concluded it's transition on screen
		 */
		
		private function onTransitionComplete():void
		{
			while ( this.numChildren > 1 )
			{
				var img:Image = this.getChildAt(0) as Image;
				TexturePack.deleteTexturePack( "LPsBackground", img.name );
				img.removeFromParent();
			}
		}
		
		/**
		 * Adds a designated background to the Starling project and sets the hidden value back to false (making it visible)
		 * @param	id	The id of the background to show
		 * @return	The singleton instance of the background. Use this to add this instance to the stage in your desired DisplayObjectContainer.
		 */
		
		public static function show( id:int = 0 ):LPsBackground
		{
			if ( !LPsBackground.source )
			{
				throw ( new Error("You must call LPsBackground.init before invoking LPsBackground.show") );
				return null;
			}
			
			if ( !instance )
			{
				instance = new LPsBackground();
			}
			
			if ( current_background != id )
			{
				instance.transitionTo(id);
			}
			
			instance.visible = true;
			_hidden = false;
			
			return instance;
		}
		
		/**
		 * Returns a random integer value to show a random background (range is 0 to source.totalFrames - 1)
		 */
		
		public static function get RANDOM():int
		{
			return Math.floor( Math.random() * LPsBackground.source.totalFrames );
		}
		
		/**
		 * Sets the background to invisible (doesn't remove, just sets visibility to false)
		 */
		
		public static function hide():void
		{
			if ( instance )
			{
				instance.visible = false;
				_hidden = true;
			}
		}
		
		/**
		 * Returns if the background is hidden or not
		 */
		
		static public function get hidden():Boolean 
		{
			return _hidden;
		}
		
		/**
		 * Sets a classic display list MovieClip object as the background source. Each frame in the source is given an id value of frame-1 (starts at 0) when calling LPsBackground.show
		 * @param	source	The MovieClip to use as the background source.
		 */
		
		public static function init( source:MovieClip ):void
		{
			LPsBackground.source = source;
		}
		
	}

}