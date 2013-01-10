package com.thirdsense.ui.starling 
{
	import com.thirdsense.animation.TexturePack;
	import flash.geom.Point;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class LPsRadioButton extends MovieClip 
	{
		private var _source_width:Number;
		private var _source_height:Number;
		private var _disabled:Boolean;
		private var _value:Boolean;
		private var onToggle:Function;
		
		/**
		 * Creates a new Radio Button based on a (minimum) 2-frame texture pack
		 * @param	tp	The texture pack to use as a Radio Button
		 * @param	default_value	The default value of the radio button. If false, frame 0 of the texture pack is shown. If true, frame 1 of the texture pack is shown
		 * @param	onToggle	(Optional) Function that is called upon a user interaction with this element
		 */
		
		public function LPsRadioButton( tp:TexturePack, default_value:Boolean = false, onToggle:Function = null ) 
		{
			if ( onToggle != null )	this.onToggle = onToggle;
			
			this.name = tp.pool + "_" + tp.sequence;
			
			super( tp.getTextures() );
			
			this.pivotX = -tp.offset.x;
			this.pivotY = -tp.offset.y;
			
			this.addListeners();
			
			this._source_width = tp.source_width;
			this._source_height = tp.source_height;
			
			this._disabled = false;
			this.useHandCursor = true;
			this._value = default_value;
			
			!this._value ? this.currentFrame = 0 : this.currentFrame = 1;
		}
		
		/**
		 * The source width of the classic MovieClip that was used to make the texture pack this radio button is based on
		 */
		
		public function get source_width():Number 
		{
			return _source_width;
		}
		
		/**
		 * The source height of the classic MovieClip that was used to make the texture pack this radio button is based on
		 */
		
		public function get source_height():Number 
		{
			return _source_height;
		}
		
		/**
		 * The current value of the radio button element
		 */
		
		public function get value():Boolean 
		{
			return _value;
		}
		
		/**
		 * Indicates if this radio button has been disabled
		 */
		
		public function get disabled():Boolean 
		{
			return _disabled;
		}
		
		/**
		 * Returns the x,y co-ordinates of this element as a Point object
		 * @return	The Point object populated with this object's x,y co-ords.
		 */
		
		public function getPoint():Point
		{
			return new Point( this.x, this.y );
		}
		
		/**
		 * Disables this radio button element
		 */
		public function disable():void
		{
			if ( this._disabled )	return void;
			this._disabled = true;
		}
		
		/**
		 * Enables this radio button element
		 */
		public function enable():void
		{
			if ( !this._disabled ) return void;
			this._disabled = false;
			
		}
		
		private function addListeners():void
		{
			this.addEventListener(TouchEvent.TOUCH, this.touchHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.removeHandler);
		}
		
		private function removeHandler(evt:Event):void
		{
			this.kill();
		}
		
		public function kill():void
		{
			this.removeEventListener(TouchEvent.TOUCH, this.touchHandler);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, this.removeHandler);
		}
		
		private function touchHandler( evt:TouchEvent ):void
		{
			var touch:Touch = evt.getTouch(this, TouchPhase.ENDED);
			if ( touch && !this._disabled )
			{
				this._value ? this._value = false : this._value = true;
				!this._value ? this.currentFrame = 0 : this.currentFrame = 1;
				if ( this.onToggle != null ) this.onToggle();
			}
		}
		
	}

}