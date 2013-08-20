package com.thirdsense.ui.starling 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Creates a button from a TexturePack object
	 * @author Ben Leffler
	 */
	
	public dynamic class LPsButton extends MovieClip 
	{
		private var _source_width:Number;
		private var _source_height:Number;
		private var onRelease:Function;
		private var disabled:Boolean;
		
		/**
		 * The local tween instance that can be used for transitions and animation of this button
		 */
		public var tween:BTween;
		
		/**
		 * This function is called (if not null) when this button has been disabled by the disable() function
		 */
		public var onDisable:Function;
		
		/**
		 * This function is called (if not null) when this button has been enabled by the enable() function
		 */
		public var onEnable:Function;
		
		/**
		 * The width of the source DisplayObject that was turned in to this button instance (not the width of the texture being used)
		 */
		public function get source_width():Number {	return this.scaleX * this._source_width	};
		
		/**
		 * The height of the source DisplayObject that was turned in to this button instance (not the height of the texture being used)
		 */
		public function get source_height():Number { return this.scaleY * this._source_height };
		
		/**
		 * Constructs a custom starling button from a TexturePack
		 * @param	tp	The TexturePack object to generate the button from
		 * @param	onRelease	If a click on the button is detected, call this function. Must accept a touch object as it's argument
		 * @param	helper_sequence	If a helper was used to create the texture pack, pass the desired sequence name here
		 * @see starling.events.Touch
		 */
		
		public function LPsButton( tp:TexturePack, onRelease:Function, helper_sequence:String="" ) 
		{
			this.onRelease = onRelease;
			
			super( tp.getTextures(helper_sequence) );
			
			
			if ( helper_sequence.length )
			{
				this.name = tp.pool + "_" + helper_sequence;
			}
			else
			{
				this.name = tp.pool + "_" + tp.sequence;
			}
			
			var pt:Point = tp.getOffset( helper_sequence );
			this.pivotX = -pt.x;
			this.pivotY = -pt.y;
			
			this.addListeners();
			this.currentFrame = 0;
			
			this._source_width = tp.source_width;
			this._source_height = tp.source_height;
			
			this.disabled = false;
			this.useHandCursor = true;
		}
		
		/**
		 * Disables the button.
		 * @param	fade_button	Multiplies the button's alpha value by 0.25 if passed as true
		 */
		
		public function disable( fade_button:Boolean=true ):void
		{
			if ( this.disabled ) return void;
			
			this.disabled = true;
			
			if ( fade_button )
			{
				this.alpha *= 0.25;
			}
			
			if ( this.onDisable != null )
			{
				this.onDisable();
			}
			
		}
		
		/**
		 * Returns the x,y co-ords of the button in a point format
		 * @return
		 */
		
		public function getPoint():Point
		{
			return new Point(this.x, this.y);
		}
		
		/**
		 * Enables a button if previously disabled and turns it fully visable or multiplies it's alpha by 4 (whatever is less in value)
		 */
		
		public function enable():void
		{
			if ( this.disabled ) {
				this.disabled = false;
				this.alpha = Math.min( 1, this.alpha * 4 );
				if ( this.onEnable != null )
				{
					this.onEnable();
				}
			}
			
		}
		
		/**
		 * @private	Adds the listeners necessary for this to become a button
		 */
		
		private function addListeners():void
		{
			this.addEventListener( TouchEvent.TOUCH, this.touchHandler );
			this.addEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			
		}
		
		/**
		 * @private	Handler for the TouchEvent listener
		 */
		
		private function touchHandler( evt:TouchEvent ):void
		{
			if ( this.disabled ) {
				return void;
			}
			
			var touches:Vector.<Touch> = evt.getTouches(this);
			
			for ( var i:uint = 0; i < touches.length; i++ ) {
				var touch:Touch = touches[i];
				if ( touch ) {
					
					switch ( touch.phase ) {
						
						case TouchPhase.BEGAN:
							if ( this.currentFrame != 1 && this.numFrames > 1 ) {
								this.currentFrame = 1;
							}
							break;
						
						case TouchPhase.ENDED:
							if ( this.currentFrame || this.numFrames <= 1 ) {
								this.currentFrame = 0;
								var bounds:Rectangle = this.getBounds(this.parent);
								var pt:Point = touch.getLocation(this.parent);
								if ( bounds.containsPoint(pt) && this.onRelease != null )
								{
									this.onRelease( touch );
								}
							}
							
							break;
							
						case TouchPhase.MOVED:
							pt = touch.getLocation(this.parent);
							if ( !this.getBounds(this.parent).containsPoint(pt) ) {
								if ( this.currentFrame ) {
									this.currentFrame = 0;
								}
							} else {
								if ( this.currentFrame != 1  && this.numFrames > 1 ) {
									this.currentFrame = 1;
								}
							}
							break;
							
					}
					
				}
			}
			
		}
		
		/**
		 * @private	Removes listeners from memory upon the removal of this button from the stage
		 */
		
		private function removeHandler( evt:Event ):void
		{
			if ( evt.type == Event.REMOVED_FROM_STAGE ) {
				this.removeEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
				this.removeEventListener( TouchEvent.TOUCH, this.touchHandler );
			}
			
		}
		
	}

}