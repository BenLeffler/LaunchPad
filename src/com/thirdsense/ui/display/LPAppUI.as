package com.thirdsense.ui.display 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.LaunchPad;
	import com.thirdsense.ui.GenericAlert;
	import com.thirdsense.ui.GenericPrompt;
	import com.thirdsense.utils.DuplicateDisplayObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	 * Static instance of the LaunchPad App UI providing access to Alert and Prompt UI elements
	 * @author Ben Leffler
	 */
	
	public class LPAppUI extends Sprite 
	{
		private static var instance:LPAppUI;
		private static var onComplete:Function;
		private static var onCancel:Function;
		private static var last_prompt:MovieClip;
		private static var last_alert:MovieClip;
		
		/**
		 * If a blurred background is required, a bitmapdata snapshot of the stage is taken and used instead of a darkened overlay
		 */
		public static var blur_background:Boolean = false;
		
		/**
		 * Applies a color matrix filter to the background if this is set before invoking a ui element
		 */
		public static var color_matrix_background:ColorMatrixFilter;
		
		/**
		 * Applies a color transform to the background if this is set before invoking a ui element
		 */
		public static var color_transform_background:ColorTransform;
		
		/**
		 * Constructor
		 */
		public function LPAppUI() 
		{
			
		}
		
		/**
		 * @private	Creates a shape based darkened background for the ui element
		 */
		private function createShapeOverlay():void
		{
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill( 0, 0.75 );
			spr.graphics.drawRect( 0, 0, LaunchPad.instance.nativeStage.stageWidth, LaunchPad.instance.nativeStage.stageHeight );
			spr.graphics.endFill();
			this.addChild( spr );
			spr.cacheAsBitmap = true;
			
			if ( color_matrix_background != null )
			{
				spr.filters = [ color_matrix_background ];
			}
			
			if ( color_transform_background != null )
			{
				spr.transform.colorTransform = color_transform_background;
			}
			
			var tween:BTween = new BTween( spr, Math.round(15 * (instance.stage.frameRate / 60)) );
			tween.fadeFromTo( 0, 1 );
			tween.start();
		}
		
		/**
		 * @private	Creates a snapshot of the stage, blurs it and uses it as the background for the ui element
		 */
		
		private function createBitmapOverlay():void
		{
			var spr:Sprite = new Sprite();
			var bmpdata:BitmapData = new BitmapData( LaunchPad.instance.nativeStage.stageWidth, LaunchPad.instance.nativeStage.stageHeight, false, 0 );
			bmpdata.draw( LaunchPad.instance.nativeStage, null, color_transform_background, null, null, true );
			bmpdata.applyFilter( bmpdata, bmpdata.rect, new Point(), new BlurFilter(4, 4, 3) );
			if ( color_matrix_background )
			{
				bmpdata.applyFilter( bmpdata, bmpdata.rect, new Point(), color_matrix_background );
			}
			spr.addChild( new Bitmap(bmpdata, "auto", true) );
			this.addChild( spr );
			spr.cacheAsBitmap = true;
			
			spr.addEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler, false, 0, true );
			
			var tween:BTween = new BTween( spr, Math.round(15 * (instance.stage.frameRate / 60)) );
			tween.fadeFromTo( 0, 1 );
			tween.start();
		}
		
		/**
		 * @private	Handles the disposal of the bitmapdata when a blurred background is being used
		 * @param	evt
		 */
		
		private function removeHandler( evt:Event ):void
		{
			var spr:Sprite = evt.currentTarget as Sprite;
			spr.removeEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			(spr.getChildAt(0) as Bitmap).bitmapData.dispose();
			(spr.getChildAt(0) as Bitmap).bitmapData = null;
		}
		
		/**
		 * @private	Checks if the container has been added to the stage, if not create one and ensure it's upper-most level
		 * @return
		 */
		
		private static function checkInstance():Boolean
		{
			if ( !instance )
			{
				instance = new LPAppUI();
				LaunchPad.instance.target.addChild( instance );
			}
			else if ( hasUI() )
			{
				return false;
			}
			
			if ( LaunchPad.instance.target.getChildIndex(instance) < LaunchPad.instance.target.numChildren - 1 )
			{
				LaunchPad.instance.target.setChildIndex(instance, LaunchPad.instance.target.numChildren - 1 );
			}
			
			return true;
		}
		
		/**
		 * @private	Populates the ui element with the required copy
		 * @param	element
		 * @param	heading
		 * @param	copy
		 */
		
		private static function configElement( element:MovieClip, heading:String, copy:String ):void
		{
			if ( element is GenericPrompt )
			{
				var prompt:GenericPrompt = element as GenericPrompt;
				prompt.create( heading, copy );
				
				var pt:Point = new Point( prompt.ok_button.x, prompt.ok_button.y );
				var but1:LPButton = new LPButton( prompt.ok_button, clickHandler );
				but1.name = "ok_button";
				but1.x = pt.x;
				but1.y = pt.y;
				prompt.addChild( but1 );
				
				pt = new Point( prompt.cancel_button.x, prompt.cancel_button.y );
				var but2:LPButton = new LPButton( prompt.cancel_button, clickHandler );
				but2.name = "cancel_button";
				but2.x = pt.x;
				but2.y = pt.y;
				prompt.addChild( but2 );
			}
			else if ( element is GenericAlert )
			{
				var alert:GenericAlert = element as GenericAlert;
				alert.create( heading, copy );
				
				pt = new Point( alert.ok_button.x, alert.ok_button.y );
				but1 = new LPButton( alert.ok_button, clickHandler );
				but1.name = "ok_button";
				but1.x = pt.x;
				but1.y = pt.y;
				alert.addChild( but1 );
			}
			else
			{
				if ( element.heading && element.heading is TextField ) element.heading.text = heading;
				if ( element.copy && element.copy is TextField ) element.copy.text = copy;
				if ( element.ok_button && element.ok_button is MovieClip )
				{
					pt = new Point( element.ok_button.x, element.ok_button.y );
					but1 = new LPButton( element.ok_button, clickHandler );
					but1.name = "ok_button";
					but1.x = pt.x;
					but1.y = pt.y;
					element.addChild( but1 );
				}
				if ( element.cancel_button && element.cancel_button is MovieClip )
				{
					pt = new Point( element.cancel_button.x, element.cancel_button.y );
					but2 = new LPButton( element.cancel_button, clickHandler );
					but2.name = "ok_button";
					but2.x = pt.x;
					but2.y = pt.y;
					element.addChild( but2 );
				}
			}
			
			var bounds:Rectangle = element.getBounds(new MovieClip());
			pt = new Point( (bounds.width / 2) - bounds.x, (bounds.height / 2) - bounds.y );
			
			element.x = instance.width - element.width >> 1;
			element.y = instance.height - element.height >> 1;
			instance.addChild( element );
			
			var tween:BTween = new BTween( element, Math.round(90 * (instance.stage.frameRate / 60)), BTween.EASE_OUT_ELASTIC );
			tween.moveFromTo( element.x + pt.x, element.y + pt.y, element.x, element.y );
			tween.scaleFromTo( 0, 1 );
			tween.start();
		}
		
		/**
		 * Adds a Prompt UI element to the stage. Only a single ui element instance may exist at any point
		 * @param	heading	Text to apply to the heading field
		 * @param	copy	Text to apply to the copy field
		 * @param	element	The MovieClip that will be used as the ui element scaffold
		 * @param	onComplete	The function to call when the user clicks the ok_button element
		 * @param	onCancel	The function to call when the user clicks the cancel_button element
		 * @return	Boolean value indicating if the ui element was added to the stage
		 * @see	com.thirdsense.ui.GenericPrompt
		 */
		
		public static function addPrompt( heading:String = "", copy:String = "", element:MovieClip = null, onComplete:Function = null, onCancel:Function = null ):Boolean
		{
			if ( !checkInstance() ) return false;
			
			blur_background ? instance.createBitmapOverlay() : instance.createShapeOverlay();
			
			if ( element )
			{
				if ( element is GenericPrompt )
				{
					last_prompt = null;
				}
				else
				{
					last_prompt = DuplicateDisplayObject.duplicate(element) as MovieClip;
				}
			}
			else if ( last_prompt )
			{
				element = DuplicateDisplayObject.duplicate(last_prompt) as MovieClip;
			}
			else
			{
				element = new GenericPrompt();
			}
			
			configElement( element, heading, copy );
			
			LPAppUI.onComplete = onComplete;
			LPAppUI.onCancel = onCancel;
			
			return true;			
		}
		
		/**
		 * Adds an Alert UI element to the stage. Only a single ui element instance may exist at any point
		 * @param	heading	Text to apply to the heading field
		 * @param	copy	Text to apply to the copy field
		 * @param	element	The MovieClip that will be used as the ui element scaffold
		 * @param	onComplete	The function to call when the user dismisses the alert
		 * @return	Boolean value indicating if the ui element was added to the stage
		 * @see	com.thirdsense.ui.GenericAlert
		 */
		
		public static function addAlert( heading:String = "", copy:String = "", element:MovieClip = null, onComplete:Function = null ):Boolean
		{
			if ( !checkInstance() ) return false;
			
			blur_background ? instance.createBitmapOverlay() : instance.createShapeOverlay();
			
			if ( element )
			{
				if ( element is GenericAlert )
				{
					last_alert = null;
				}
				else
				{
					last_alert = DuplicateDisplayObject.duplicate(element) as MovieClip;
				}
			}
			else if ( last_alert )
			{
				element = DuplicateDisplayObject.duplicate(last_alert) as MovieClip;
			}
			else
			{
				element = new GenericAlert();
			}
			
			configElement( element, heading, copy );
			
			LPAppUI.onComplete = onComplete;
			
			return true;
		}
		
		/**
		 * @private	Handles the user interaction
		 * @param	but
		 */
		
		private static function clickHandler( but:LPButton ):void
		{
			if ( but.name == "ok_button" )
			{
				var fn:Function = onComplete;
			}
			
			if ( but.name == "cancel_button" )
			{
				fn = onCancel;
			}
			
			onComplete = null;
			onCancel = null;
			killUI();
			
			if ( fn != null )
			{
				fn();
			}
		}
		
		/**
		 * Retrieves if a UI element currently exists on the stage
		 * @return
		 */
		
		public static function hasUI():Boolean
		{
			if ( instance && instance.numChildren > 0 )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Removes any UI elements that exist on the stage
		 */
		
		public static function killUI():void
		{
			if ( hasUI() )
			{
				instance.removeChildren();
				onComplete = null;
				onCancel = null;
			}
		}
	}

}