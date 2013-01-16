package com.thirdsense.ui.starling 
{
	import com.thirdsense.LaunchPad;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * A simple class that controls tap drag scrolling for Starling display objects
	 * @author Ben Leffler
	 */
	
	public class ScrollControl 
	{
		private var target:DisplayObject
		private var type:String;
		private var viewPort:Rectangle;
		private var _scrolling:Boolean;
		private var x_padding:Number;
		
		private var offset:Point;
		private var dx:Number;
		private var dy:Number;
		private var vx:Number;
		private var vy:Number;
		
		private var _restrictTapArea:Boolean
		private var _tapArea:Rectangle;
		private var _scrollWheelEnabled:Boolean;
		private var _active:Boolean;
		
		/**
		 * This function is executed on each frame a scrolling movement takes place.
		 */
		public var onMove:Function;
		
		public function ScrollControl() 
		{
			this.restrictTapArea = true;
			this._scrollWheelEnabled = false;
			this._active = false;
		}
		
		/**
		 * Initializes a scroll control instance against a desired Starling display object. If the target is removed from the stage at any point, the scroll control instance self-terminates.
		 * @param	target	The Starling display object to register this controller against
		 * @param	type	The type of control to use
		 * @param	viewPort	The viewport of the scroll area. If passed as null, the entire stage is used as the viewport
		 * @see	com.thirdsense.ui.starling.ScrollType
		 */
		
		public function init( target:DisplayObject, type:String, viewPort:Rectangle=null ):void
		{
			if ( !target.stage ) 
			{
				trace( "ScrollControl.init :: target must be on the stage before calling init" );
				return void;
			}
			
			this.target = target;
			this.type = type;
			this.x_padding = x_padding;
			
			if ( viewPort ) {
				this.viewPort = viewPort;
			} else {
				this.viewPort = new Rectangle( 0, 0, this.target.stage.stageWidth, this.target.stage.stageHeight );
			}
			
			this.dx = target.x;
			this.dy = target.y;
			this.vx = 0;
			this.vy = 0;
			this._scrolling = false;
			
			this.target.stage.addEventListener( TouchEvent.TOUCH, this.touchHandler);
			this.target.addEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			this.target.addEventListener( EnterFrameEvent.ENTER_FRAME, this.timeline );
			
			this._active = true;
			
			if ( this._scrollWheelEnabled ) enableScrollWheel();
		}
		
		/**
		 * Enables the use of the mouse scroll wheel to interact with this scroll control target element.
		 */
		
		public function enableScrollWheel():void
		{
			if ( this.active && !Starling.current.nativeStage.hasEventListener(MouseEvent.MOUSE_WHEEL) )
			{
				Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelHandler);
				this._scrollWheelEnabled = true;
			}
		}
		
		/**
		 * @private
		 */
		
		private function mouseWheelHandler( evt:MouseEvent ):void
		{
			var pt:Point = new Point( LaunchPad.instance.target.mouseX, LaunchPad.instance.target.mouseY );
			if ( this.viewPort.containsPoint(pt) )
			{
			if ( this.type == ScrollType.VERTICAL )
				{
					this.vy += 5 * evt.delta;
				}
				else if ( this.type == ScrollType.HORIZONTAL )
				{
					this.vx += 5 * evt.delta;
				}
			}
		}
		
		/**
		 * @private
		 */
		
		private function removeHandler( evt:Event ):void
		{
			this.kill();
		}
		
		/**
		 * Removes this scroll controller from the target element and disposes associated listeners
		 */
		
		public function kill():void
		{
			this._active = false;
			
			this.target.removeEventListener(Event.REMOVED_FROM_STAGE, this.removeHandler);
			this.target.stage.removeEventListener(TouchEvent.TOUCH, this.touchHandler);
			this.target.removeEventListener( EnterFrameEvent.ENTER_FRAME, this.timeline );
			
			if ( this._scrollWheelEnabled )
			{
				Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelHandler);
			}
		}
		
		/**
		 * @private
		 */
		
		private function touchHandler( evt:TouchEvent ):void
		{
			var touch:Touch = evt.getTouch( this.target.stage );
			
			if ( !touch || (this.restrictTapArea && !this.tapArea.contains( touch.globalX, touch.globalY )) )
			{
				return void;
			}
			
			switch( touch.phase )
			{
				case TouchPhase.BEGAN:
					this.offset = touch.getLocation(this.target.parent);
					this.offset.x -= this.target.x;
					this.offset.y -= this.target.y;
					this.dx = target.x;
					this.dy = target.y;
					this.vx = 0;
					this.vy = 0;					
					break;
					
				case TouchPhase.ENDED:
					this.offset = null;
					this._scrolling = false;
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
		 * @private
		 */
		
		private function timeline(evt:EnterFrameEvent):void
		{
			if ( this.offset ) 
			{
				this.vx = (this.dx - this.target.x) / 8;
				this.vy = (this.dy - this.target.y) / 8;
				
				if ( Math.abs(this.vx) > 5 && this.type == ScrollType.HORIZONTAL )
				{
					this._scrolling = true;
				}
				if ( Math.abs(this.vy) > 5 && this.type == ScrollType.VERTICAL )
				{
					this._scrolling = true;
				}
			}
			else
			{
				if ( Math.abs(this.vx) < 1 ) 
				{
					this.vx = 0;
				}
				else
				{
					this.vx *= 0.95;
				}
				if ( Math.abs(this.vy) < 1 ) 
				{
					this.vy = 0;
				} 
				else 
				{
					this.vy *= 0.95;
				}
			}
			
			var rect:Rectangle = this.target.getBounds( this.target.parent );
			var moving:Boolean = false;
			
			if ( this.vx && rect.width > this.viewPort.width ) 
			{
				this.target.x += this.vx;
				moving = true;
			}
			
			if ( this.vy && rect.height > this.viewPort.height ) 
			{
				this.target.y += this.vy;
				moving = true;
			}
			
			rect = this.target.getBounds( this.target.parent );
			
			if ( rect.width > this.viewPort.width ) 
			{
				if ( rect.x > this.viewPort.x ) 
				{
					this.target.x += (this.viewPort.x-rect.x) ;
					this.vx = 0;
				}
				else if ( rect.x + rect.width < this.viewPort.x + this.viewPort.width )
				{
					this.target.x -= (rect.x + rect.width) - (this.viewPort.x + this.viewPort.width);
					this.vx = 0;
				}
			}
			
			if ( rect.height > this.viewPort.height ) 
			{
				if ( rect.y > this.viewPort.y ) 
				{
					this.target.y += (this.viewPort.y-rect.y) ;
					this.vy = 0;
				}
				else if ( rect.y + rect.height < this.viewPort.y + this.viewPort.height )
				{
					this.target.y -= (rect.y + rect.height) - (this.viewPort.y + this.viewPort.height);
					this.vy = 0;
				}
			}
			
			if ( moving && this.onMove != null )
			{
				this.onMove();
			}
			
		}
		
		/**
		 * Indicates if the scroll controller is in the act of a user scroll interation (use for bypassing button clicks within the target element)
		 */
		
		public function get scrolling():Boolean
		{
			return this._scrolling;
		}
		
		/**
		 * Set to true if you wish to restrict user tap scroll interaction to the designated viewport. Set to false if the entire stage can be tapped.
		 */
		
		public function get restrictTapArea():Boolean 
		{
			return _restrictTapArea;
		}
		
		public function set restrictTapArea(value:Boolean):void 
		{
			_restrictTapArea = value;
		}
		
		/**
		 * Retrieves the allowed tap area of this scroll control instance.
		 */
		
		public function get tapArea():Rectangle 
		{
			if ( !this._tapArea )
			{
				return this.viewPort;
			}
			
			return _tapArea;
		}
		
		public function set tapArea(value:Rectangle):void 
		{
			_tapArea = value;
		}
		
		/**
		 * Returns if this scroll control instance is currently active and enabled for use
		 */
		
		public function get active():Boolean 
		{
			return _active;
		}
		
		/**
		 * Retrieves the viewport of this scroll control instance
		 * @return	Rectangle representation of the viewport
		 */
		
		public function getViewPort():Rectangle
		{
			return this.viewPort;
		}
		
	}

}