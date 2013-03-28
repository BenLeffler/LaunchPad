package com.thirdsense.ui.starling 
{
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * A class that enables object drag and drop for Starling projects
	 * @author Ben Leffler
	 */
	
	public class DragControl 
	{
		private var target:DisplayObject;
		private var onTouch:Function;
		private var offset:Point;
		private var dx:Number;
		private var dy:Number;
		private var vx:Number;
		private var vy:Number;
		private var speed:Number;
		private var _disabled:Boolean;
		
		/**
		 * Constructor class for the DragControl
		 */
		
		public function DragControl() 
		{
			this._disabled = false;
		}
		
		/**
		 * Disables the drag functionality until enable is called
		 */
		
		public function disable():void
		{
			this._disabled = true;
		}
		
		/**
		 * Enables the drag functionality. A DragControl object is enabled by default
		 */
		
		public function enable():void
		{
			this._disabled = false;
		}
		
		/**
		 * Initialises the drag control object to start working with a desired Starling DisplayObject
		 * @param	target	The target DisplayObject to attach the DragControl object functionality to
		 * @param	speed	The speed of the drag. The higher this number, the slower the speed. For 1:1 dragging, pass this as 1.
		 * @param	onTouch	The function that is called whenever a TouchPhase.BEGAN, TouchPhase.MOVED, or TouchPhase.ENDED phase is detected on the object. The function must accept a Touch object as a param.
		 * @see	starling.events.TouchPhase
		 * @see	starling.events.Touch;
		 */
		
		public function init( target:DisplayObject, speed:Number = 5, onTouch:Function = null ):void
		{
			this.target = target;
			this.onTouch = onTouch;
			this.speed = Math.max(speed, 1);
			
			this.target.addEventListener(TouchEvent.TOUCH, this.touchHandler);
			this.target.addEventListener(Event.REMOVED_FROM_STAGE, this.removeHandler);
		}
		
		/**
		 * @private	When the target object is removed from stage, the DragControl removes associated listeners
		 */
		
		private function removeHandler(e:Event):void 
		{
			this.target.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
			this.target.removeEventListener(TouchEvent.TOUCH, this.touchHandler);
		}
		
		/**
		 * @private	Handler for TouchEvents on the target object
		 */
		
		private function touchHandler(evt:TouchEvent):void
		{
			if ( this._disabled ) return void;
			
			var touch:Touch = evt.getTouch(this.target);
			
			if ( touch )
			{
				switch ( touch.phase )
				{
					case TouchPhase.BEGAN:
						this.offset = touch.getLocation(this.target.parent);
						this.offset.x -= this.target.x;
						this.offset.y -= this.target.y;
						this.dx = this.target.x;
						this.dy = this.target.y;
						this.vx = 0;
						this.vy = 0;
						break;
						
					case TouchPhase.ENDED:
						this.offset = null;
						break;
						
					case TouchPhase.MOVED:
						this.dx = touch.getLocation(this.target.parent).x - this.offset.x;
						this.dy = touch.getLocation(this.target.parent).y - this.offset.y;
						this.vx = (this.dx - this.target.x) / this.speed;
						this.vy = (this.dy - this.target.y) / this.speed;
						this.target.x += this.vx;
						this.target.y += this.vy;
						break;
						
					default:
						return void;
				}
				
				if ( this.onTouch != null ) this.onTouch(touch);
			}
		}
		
	}

}