package com.thirdsense.ui.starling 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Gesture swipe controller
	 * @author Ben Leffler
	 */
	
	public class SwipeControl 
	{
		private var target:DisplayObject;
		private var type:String;
		private var viewPort:Rectangle;
		private var onSwipe:Function;
		private var offset:Point;
		private var dx:Number;
		private var dy:Number;
		private var vx:Number;
		private var vy:Number;
		private var mx:Number;
		private var my:Number;
		private var tr:Number;
		private var _scrolling:Boolean;
		private var speed:int;
		private var origin:Point;
		private var _disabled:Boolean;
		private var called_out:Boolean;
		
		/**
		 * Function that can be called upon the target display object moving through interaction
		 */
		public var onMovement:Function;
		
		/**
		 * Function that can be called upon interaction with the target display object ending
		 */
		public var onRelease:Function;
		
		/**
		 * Constructor
		 */
		
		public function SwipeControl() 
		{
			
		}
		
		/**
		 * Initialises the a display object with a SwipeControl interaction
		 * @param	target	The Starling DisplayObject to target through this class
		 * @param	type	The type of swipe to use. Use the ScrollType class for available interactions
		 * @param	viewPort	The viewport rectangle of the content being displayed. This will determine the area of interaction and the bounds of the content when calling to onSwipe
		 * @param	onSwipe	The function to call when swiped content has left the viewport area upon a successful swipe. The function must accept an integer param. -1 is passed on a left swipe, 1 is passed on a right swipe.
		 */
		
		public function init( target:DisplayObject, type:String, viewPort:Rectangle, onSwipe:Function ):void
		{
			if ( !target || !target.stage ) 
			{
				trace( "SwipeControl :: Can not initialize as target is either null or has not been added to the stage yet" );
				return void;
			}
			
			this.target = target;
			this.type = type;
			this.viewPort = viewPort;
			this.onSwipe = onSwipe;
			
			// destination
			this.dx = target.x;
			this.dy = target.y;
			
			// velocity
			this.vx = 0;
			this.vy = 0;
			
			// momentum
			this.mx = 0;
			this.my = 0;
			
			// transition
			this.tr = 0;
			
			this._scrolling = false;
			this._disabled = false;
			
			this.speed = 8;
			this.origin = new Point( target.x, target.y );
			this.called_out = false;
			
			this.target.stage.addEventListener( TouchEvent.TOUCH, this.touchHandler);
			this.target.addEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			this.target.addEventListener( EnterFrameEvent.ENTER_FRAME, this.timeline );
		}
		
		/**
		 * @private	Touch handler for the swipe class
		 */
		
		private function touchHandler(evt:TouchEvent):void
		{
			var touch:Touch = evt.getTouch( this.target.stage );
			
			if ( this._disabled || !touch || this.tr ) return void;
			
			switch ( touch.phase )
			{
				case TouchPhase.BEGAN:
					this.offset = touch.getLocation(this.target.parent);
					if ( this.viewPort.containsPoint(this.offset) )
					{
						this.offset.x -= this.target.x;
						this.offset.y -= this.target.y;
						this.dx = this.target.x;
						this.dy = this.target.y;
						this.vx = 0;
						this.vy = 0;
						this.mx = 0;
						this.my = 0;
						this.speed = 8;
						this.called_out = false;
					}
					else
					{
						this.offset = null;
					}					
					break;
					
				case TouchPhase.ENDED:
					this.offset = null;
					this.speed = 4;
					this.dx = this.origin.x;
					this.dy = this.origin.y;
					this.mx = this.vx * 6;
					this.my = this.vy * 6;
					this._scrolling = false;
					if ( this.onRelease != null )
					{
						this.onRelease();
					}
					break;
					
				case TouchPhase.MOVED:
					if ( this.offset )
					{
						if ( this.type == ScrollType.HORIZONTAL )
						{
							this.dx = touch.getLocation(this.target.parent).x - this.offset.x;
						}
						
						if ( this.type == ScrollType.VERTICAL ) 
						{
							this.dy = touch.getLocation(this.target.parent).y - this.offset.y;
						}
					}
					break;
			}
		}
		
		/**
		 * @private	When the target has been removed from the stage, all SwipeControl listeners are also removed with it
		 */
		
		private function removeHandler(evt:Event):void
		{
			this.target.stage.removeEventListener( TouchEvent.TOUCH, this.touchHandler);
			this.target.removeEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			this.target.removeEventListener( EnterFrameEvent.ENTER_FRAME, this.timeline );
		}
		
		/**
		 * @private	The EnterFrame handler for this class
		 */
		
		private function timeline(evt:EnterFrameEvent):void
		{
			if ( this._disabled ) return void;
			
			this.vx = (this.dx - this.target.x) / this.speed;
			this.vy = (this.dy - this.target.y) / this.speed;
			
			if ( offset )
			{
				if ( Math.abs(this.vx) > 5 && this.type == ScrollType.HORIZONTAL )
				{
					if ( !this._scrolling )
					{
						this._scrolling = true;
						if ( this.onMovement != null ) this.onMovement();
					}
				}
				if ( Math.abs(this.vy) > 5 && this.type == ScrollType.VERTICAL )
				{
					if ( !this._scrolling )
					{
						this._scrolling = true;
						if ( this.onMovement != null ) this.onMovement();
					}
				}
			}
			else
			{
				Math.abs(this.mx) > 0.25 ? this.mx *= 0.90 : this.mx = 0;
				Math.abs(this.my) > 0.25 ? this.my *= 0.90 : this.my = 0;
			}
			
			if ( !this.tr )
			{
				if ( this._scrolling || !this.offset )
				{
					this.target.x += this.vx + this.mx;
					this.target.y += this.vy + this.my;
				}
			}
			
			this.checkCallOut();
		}
		
		/**
		 * @private	Checks the content location and determines if content has been successfully swiped. If so, a call to the onSwipe function is made passing the direction of the swipe as a param.
		 */
		
		private function checkCallOut():void
		{
			if ( this.tr )
			{
				if ( this.type == ScrollType.HORIZONTAL )
				{
					this.target.x -= this.tr;
					if ( this.target.x < this.viewPort.x - this.viewPort.width * 1.25 )
					{
						this.mx = 0;
						this.my = 0;
						this.onSwipe( -1);
						this.tr = 0;
						this.called_out = true;
					}
					else if ( this.target.x > this.viewPort.x + this.viewPort.width * 1.25 )
					{
						this.mx = 0;
						this.my = 0;
						this.onSwipe(1);
						this.tr = 0;
						this.called_out = true;
					}
				}
				else if ( this.type == ScrollType.VERTICAL )
				{
					this.target.y -= this.tr;
					if ( this.target.y < this.viewPort.y - this.viewPort.height * 1.25 )
					{
						this.mx = 0;
						this.my = 0;
						this.onSwipe( -1);
						this.tr = 0;
						this.called_out = true;
					}
					else if ( this.target.y > this.viewPort.y + this.viewPort.height * 1.25 )
					{
						this.mx = 0;
						this.my = 0;
						this.onSwipe( 1 );
						this.tr = 0;
						this.called_out = true;
					}
				}
			}
			else if ( !this.called_out && !this.offset )
			{
				if ( this.type == ScrollType.HORIZONTAL )
				{
					if ( this.mx < this.viewPort.width / -10 )
					{
						this.tr = -this.mx;
					}
					else if ( this.mx > this.viewPort.width / 10 )
					{
						this.tr = -this.mx;
					}
				}
				else if ( this.type == ScrollType.VERTICAL )
				{
					if ( this.my < this.viewPort.height / -10 )
					{
						this.tr = -this.mx;
					}
					else if ( this.my > this.viewPort.height / 10 )
					{
						this.tr = -this.mx;
					}
				}
				
			}
		}
		
		/**
		 * Disables the SwipeControl object and prevents interaction until enable() is called
		 */
		
		public function disable():void
		{
			this._disabled = true;
		}
		
		/**
		 * Enables the SwipeControl object. This object is enabled by default once a call to init is made
		 */
		
		public function enable():void
		{
			this._disabled = false;
		}
		
		/**
		 * Kills the swipe control object. Can be reinstated by a call to init.
		 */
		
		public function kill():void
		{
			this.removeHandler(null);
		}
		
		/**
		 * Returns if the target object is currently being interacted with in a Swipe context. (If a movement of more than 5 pixels is made, swiping is set to true until the user releases the target from the swipe)
		 */
		
		public function get swiping():Boolean 
		{
			return _scrolling;
		}
	}

}