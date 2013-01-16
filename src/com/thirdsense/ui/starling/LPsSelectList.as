package com.thirdsense.ui.starling 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * A Select List UI Element to be used in starling projects. Can be defined as a single option, or multi option element. Scrolling is enabled on this ui element if the options extend past the edge of the stage.
	 * @author Ben Leffler
	 */
	
	public class LPsSelectList extends Sprite 
	{
		/**
		 * The gradient to use on the background of an option that is selected
		 */
		public static var select_gradient:Array = [ 0xB8CD00, 0x81A100 ];
		
		/**
		 * The gradient to use on the outline of the background of a selected option
		 */
		public static var select_border:Array = [ 0xB8CD00, 0xB8CD00 ];
		
		/**
		 * The color of the text to use on a selected option
		 */
		public static var select_text_color:uint = 0xFFFFFF;
		
		/**
		 * The gradient to use on the background of an unselected option
		 */
		public static var unselect_gradient:Array = [ 0xFFFFFF, 0xF5F5F5 ];
		
		/**
		 * The gradient to use on the outline of the background of an unselected option
		 */
		public static var unselect_border:Array = [ 0xFFFFFF, 0xFFFFFF ];
		
		/**
		 * The color of the text to use on an unselected option
		 */
		public static var unselect_text_color:uint = 0x999999;
		
		/**
		 * The name of the font family to use in this ui element. (Must be embedded in the project - the default font is already embedded by the LaunchPad framework)
		 */
		public static var font_type:String = "Arial Rounded MT Bold";
		
		/**
		 * The size of the font to use in this ui element
		 */
		public static var font_size:int = 22;
		
		/**
		 * Does the font use a bold type
		 */
		public static var font_bold:Boolean = true;
		
		/**
		 * The desired width in pixels of the ui element
		 */
		public static var box_width:int = 400;
		
		/**
		 * The color of the quad that gets overlayed behind this ui element (will be set to 0.75 alpha)
		 */
		public static var background_color:uint = 0x000000;
		
		private static var instance:LPsSelectList;
		
		private var _values:Array;
		private var _multiline:Boolean;
		private var canvas:Sprite;
		private var options:Array;
		private var sControl:ScrollControl;
		private var viewPort:Rectangle;
		private var buttons:Sprite;
		private var onComplete:Function;
		private var filters:Array;
		
		/**
		 * Constructor of the LPsSelectList element
		 * @param	options	An array of options for the user to select between
		 * @param	onComplete	The function to call upon the element becoming closed by the user. This must accept an array as a parameter that indicates what options the user selected. Will pass <i>null</i> if the user tapped 'CANCEL'
		 * @param	default_values	An array of index values to determine what options are selected by default
		 * @param	multiline	Pass as true if this element will allow multiple (or none) selectable options
		 */
		
		public function LPsSelectList( options:Array, onComplete:Function, default_values:Array = null, multiline:Boolean = false ) 
		{
			if ( !default_values )
			{
				this._values = [];
			}
			else
			{
				this._values = Trig.copyArray( default_values );
			}
			
			this._multiline = multiline;
			this.options = Trig.copyArray(options);
			this.onComplete = onComplete;
			this.viewPort = new Rectangle(0, 50, Starling.current.stage.stageWidth, Starling.current.stage.stageHeight - 107);
			
			this.addEventListener(Event.ADDED_TO_STAGE, this.addedHandler);
			
		}
		
		/**
		 * @private
		 */
		
		private function addedHandler(evt:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, this.addedHandler);
			
			this.createBackground();
			this.createList( options );
		}
		
		/**
		 * @private
		 */
		
		private function createBackground():void
		{
			var quad:Quad = new Quad( Starling.current.stage.stageWidth, Starling.current.stage.stageHeight, background_color );
			quad.x = 0;
			quad.y = 0;
			this.addChild( quad );
			
			var tween:BTween = new BTween(quad, 30 );
			tween.fadeFromTo(0, 0.75, true);
			tween.start();
		}
		
		/**
		 * @private
		 */
		
		private function createList( options:Array ):void
		{
			this.canvas = new Sprite();
			this.canvas.x = 0;
			this.canvas.y = 50;
			this.canvas.useHandCursor = true;
			this.addChild( this.canvas );
			
			var i:uint;
			var length:int = options.length;
			var spr:Sprite;
			var tween:BTween;
			
			for ( i = 0; i < length; i++ )
			{
				spr = this.createLine( options[i], this.checkIfOn(i) );
				spr.x = Starling.current.stage.stageWidth - spr.width >> 1;
				spr.y = (i * (spr.height + 5));
				spr.name = String(i);
				this.canvas.addChild( spr );
				
				spr.addEventListener(TouchEvent.TOUCH, this.touchHandler);
				
				tween = new BTween( spr, 10, BTween.EASE_IN, i*2 );
				tween.fadeFromTo(0, spr.alpha);
				tween.moveFromTo( spr.x, spr.y + 25, spr.x, spr.y );
				tween.start();
			}
			
			this.addEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			
			this.addScrollControl();
			this.addButtons();
		}
		
		/**
		 * @private
		 */
		
		private function checkIfOn( id:int ):Boolean
		{
			var children:int = this._values.length;
			
			for ( var i:uint = 0; i < children; i++ )
			{
				if ( this._values[i] == id )	return true;
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		
		private function getSingleSelection():int
		{
			if ( !this._multiline && this._values.length )
			{
				return this._values[0];
			}
			else
			{
				return -1;
			}
		}
		
		/**
		 * @private
		 */
		
		private function createLine( copy:String, is_on:Boolean ):Sprite
		{
			var spr:Sprite = new Sprite();
			
			var quad:Quad = new Quad( 20, 50 );
			quad.setVertexColor( 0, select_border[0] );
			quad.setVertexColor( 1, select_border[0] );
			quad.setVertexColor( 2, select_border[select_border.length - 1] );
			quad.setVertexColor( 3, select_border[select_border.length - 1] );
			spr.addChild( quad );
			
			quad = new Quad( 16, 46 );
			quad.x = 2;
			quad.y = 2;
			quad.setVertexColor( 0, select_gradient[0] );
			quad.setVertexColor( 1, select_gradient[0] );
			quad.setVertexColor( 2, select_gradient[select_gradient.length - 1] );
			quad.setVertexColor( 3, select_gradient[select_gradient.length - 1] );
			spr.addChild( quad );
			
			quad = new Quad( box_width, 50 );
			quad.x = 25;
			quad.y = 0;
			spr.addChild( quad );
			
			if ( is_on )
			{
				quad.setVertexColor( 0, select_border[0] );
				quad.setVertexColor( 1, select_border[0] );
				quad.setVertexColor( 2, select_border[select_border.length - 1] );
				quad.setVertexColor( 3, select_border[select_border.length - 1] );
			}
			else
			{
				quad.setVertexColor( 0, unselect_border[0] );
				quad.setVertexColor( 1, unselect_border[0] );
				quad.setVertexColor( 2, unselect_border[unselect_border.length - 1] );
				quad.setVertexColor( 3, unselect_border[unselect_border.length - 1] );
			}
			
			
			quad = new Quad( box_width - 4, 46 );
			quad.x = 27;
			quad.y = 2;
			spr.addChild( quad );
			
			if ( is_on )
			{
				quad.setVertexColor( 0, select_gradient[0] );
				quad.setVertexColor( 1, select_gradient[0] );
				quad.setVertexColor( 2, select_gradient[select_gradient.length - 1] );
				quad.setVertexColor( 3, select_gradient[select_gradient.length - 1] );
			}
			else
			{
				quad.setVertexColor( 0, unselect_gradient[0] );
				quad.setVertexColor( 1, unselect_gradient[0] );
				quad.setVertexColor( 2, unselect_gradient[unselect_gradient.length - 1] );
				quad.setVertexColor( 3, unselect_gradient[unselect_gradient.length - 1] );
			}
			
			if ( is_on )
			{
				var tf:TextField = new TextField( box_width - 14, 46, copy, font_type, font_size, select_text_color, font_bold );
			}
			else
			{
				tf = new TextField( box_width - 14, 46, copy, font_type, font_size, unselect_text_color, font_bold );
			}
			
			tf.hAlign = HAlign.LEFT;
			tf.vAlign = VAlign.CENTER;
			tf.x = quad.x + 2;
			tf.y = quad.y;
			spr.addChild( tf );
			
			this.adjustText( tf );
			
			spr.flatten();
			
			return spr;
		}
		
		/**
		 * @private
		 */
		
		private function adjustText( tf:TextField ):void
		{
			var copy:String = tf.text;
			
			while ( tf.textBounds.height > 30 )
			{
				copy = copy.substr( 0, copy.length - 1 );
				tf.text = copy + "...";
			}
		}
		
		/**
		 * @private
		 */
		
		private function touchHandler( evt:TouchEvent ):void
		{
			var spr:Sprite = evt.currentTarget as Sprite;
			var spr2:Sprite;
			var spr3:Sprite;
			var spr4:Sprite;
			var touch:Touch = evt.getTouch( spr, TouchPhase.ENDED );
			
			if ( this.sControl && this.sControl.scrolling )	return void;
			
			if ( touch )
			{
				var rect:Rectangle = new Rectangle(0, 0, spr.width, spr.height);
				
				if ( rect.containsPoint(touch.getLocation(spr)) )
				{
					if ( !this._multiline )
					{
						this.switchOff( this.canvas.getChildByName( String(this.getSingleSelection()) ) as Sprite );
						this.switchOn( spr );
					}
					else if ( this.checkIfOn(Number(spr.name)) )
					{
						this.switchOff( spr );
					}
					else
					{
						this.switchOn( spr );
					}
					
				}
			}
		}
		
		/**
		 * @private
		 */
		
		private function switchOn( target:Sprite ):void
		{
			target.removeEventListeners( TouchEvent.TOUCH );
			var spr2:Sprite = this.createLine( this.options[Number(target.name)], true );
			spr2.x = target.x;
			spr2.y = target.y;
			spr2.name = target.name;
			this.canvas.addChildAt( spr2, Number(target.name) + 1 );
			spr2.addEventListener(TouchEvent.TOUCH, this.touchHandler);
					
			var tween:BTween = new BTween( spr2, 10 );
			tween.fadeFromTo(0, 1);
			tween.onComplete = this.canvas.removeChild;
			tween.onCompleteArgs = [target];
			tween.start();
			
			if ( this._values.indexOf(Number(target.name)) < 0 )
			{
				this._values.push( Number(target.name) );
			}
			
		}
		
		/**
		 * @private
		 */
		
		private function switchOff( target:Sprite ):void
		{
			target.removeEventListeners( TouchEvent.TOUCH );
			this.canvas.removeChild(target);
			
			var spr2:Sprite = this.canvas.getChildByName( target.name ) as Sprite;
			if ( spr2 )
			{
				spr2.removeEventListeners( TouchEvent.TOUCH );
				this.canvas.removeChild( spr2 );
			}
			
			spr2 = this.createLine( this.options[Number(target.name)], false );
			spr2.x = target.x;
			spr2.y = target.y;
			spr2.name = target.name;
			spr2.addEventListener(TouchEvent.TOUCH, this.touchHandler);
			this.canvas.addChildAt( spr2, Number(spr2.name) );
			
			var index:int = this._values.indexOf( Number(target.name) );
			if ( index >= 0 )
			{
				this._values.splice( index, 1 );
			}
			
		}
		
		/**
		 * @private
		 */
		
		private function removeHandler( evt:Event ):void
		{
			for ( var i:uint = 0; i < this.canvas.numChildren; i++ )
			{
				var spr:Sprite = this.canvas.getChildAt(i) as Sprite;
				spr.removeEventListeners( TouchEvent.TOUCH );
			}
			
			this.removeEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			TexturePack.deleteTexturePack( "LPsSelectList" );
		}
		
		/**
		 * An array of values that indicates what options in this ui element are currently selected (ranging from 0 to n-1)
		 */
		
		public function get values():Array 
		{
			return _values;
		}
		
		/**
		 * Indicates if this ui element is multiline enabled
		 */
		
		public function get multiline():Boolean 
		{
			return _multiline;
		}
		
		/**
		 * @private
		 */
		
		private function addScrollControl():void
		{
			var bounds:Rectangle = this.canvas.getBounds( this );
			
			if ( bounds.y + bounds.height > Starling.current.stage.stageHeight - 50 )
			{
				this.sControl = new ScrollControl();
				this.sControl.init( this.canvas, ScrollType.VERTICAL, this.viewPort );
				this.sControl.restrictTapArea = false;
				this.sControl.enableScrollWheel();
			}
		}
		
		/**
		 * @private
		 */
		
		private function addButtons():void
		{
			var button_width:Number = (box_width + 17) / 2;
			var button_height:Number = 48;
			
			var cl:Class = getDefinitionByName( "lp_button1" ) as Class;
			
			var mc:MovieClip = new cl();
			mc.label_txt.text = "OK";
			mc.bg.width = button_width;
			mc.bg.height = button_height;
			mc.label_txt.x = button_width - mc.label_txt.width >> 1;
			TexturePack.createFromMovieClip( mc, "LPsSelectList", "ok_button", null, 1, 2, null, 2 );
			
			mc = new cl();
			mc.label_txt.text = "CANCEL";
			mc.bg.width = button_width;
			mc.bg.height = button_height;
			mc.label_txt.x = button_width - mc.label_txt.width >> 1;
			TexturePack.createFromMovieClip( mc, "LPsSelectList", "cancel_button", null, 1, 2, null, 2 );
			
			this.buttons = new Sprite();
			this.addChild( this.buttons );
			
			var quad:Quad = new Quad( box_width + 25, 52 );
			quad.setVertexColor(0, unselect_border[0]);
			quad.setVertexColor(1, unselect_border[0]);
			quad.setVertexColor(2, unselect_border[1]);
			quad.setVertexColor(3, unselect_border[1]);
			this.buttons.addChild(quad);
			this.filters = [ BlurFilter.createGlow( 0x000000, 0.5, 3 ) ];
			quad.filter = this.filters[0];
			this.filters[0].cache();
			
			var cancel:LPsButton = new LPsButton( TexturePack.getTexturePack("LPsSelectList", "cancel_button"), this.buttonHandler );
			cancel.x = 2;
			cancel.y = 2;
			cancel.name = "cancel";
			this.buttons.addChild( cancel );
			
			var ok:LPsButton = new LPsButton( TexturePack.getTexturePack("LPsSelectList", "ok_button"), this.buttonHandler );
			ok.x = button_width + 5;
			ok.y = 2;
			ok.name = "ok";
			this.buttons.addChild( ok );
			
			this.buttons.x = Starling.current.stage.stageWidth - quad.width >> 1;
			
			if ( this.sControl != null )
			{
				this.buttons.y = this.viewPort.y + this.viewPort.height + 5;
			}
			else
			{
				this.canvas.y = Starling.current.stage.stageHeight - (this.canvas.height + this.buttons.height) >> 1;
				this.buttons.y = this.canvas.y + this.canvas.height + 5;
			}
		}
		
		/**
		 * @private
		 */
		
		private function buttonHandler( touch:Touch ):void
		{
			(this.filters[0] as BlurFilter).clearCache();
			this.removeFromParent();
			instance = null;
			
			switch ( touch.target.name )
			{
				case "cancel":
					this.onComplete(null);
					break;
					
				case "ok":
					this.onComplete( this._values.sort(Array.NUMERIC) );
					break;
			}
		}
		
		/**
		 * Creates a single static instance of the LPsSelectList element and adds it to the root Starling container
		 * @param	options	An array of options for the user to select between
		 * @param	onComplete	The function to call upon the element becoming closed by the user. This must accept an array as a parameter that indicates what options the user selected. Will pass <i>null</i> if the user tapped 'CANCEL'
		 * @param	default_values	An array of index values to determine what options are selected by default
		 * @param	multiline	Pass as true if this element will allow multiple (or none) selectable options
		 */
		
		public static function create( options:Array, onComplete:Function, default_values:Array = null, multiline:Boolean = false ):void
		{
			instance = new LPsSelectList( options, onComplete, default_values, multiline );
			(Starling.current.root as Sprite).addChild( instance );
		}
		
		/**
		 * Obtains the currently showing instance of the LPsSelectList element. If there is no current instance, null is returned
		 * @return	The LPsSelectList singleton instance
		 */
		
		public static function getInstance():LPsSelectList
		{
			if ( instance ) return instance;
			return null;
		}
		
	}

}