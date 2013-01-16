package classes {
	
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.ui.starling.LPsCheckList;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.ui.starling.menu.LPsBaseMenu;
	import com.thirdsense.ui.starling.menu.LPsMenu;
	import com.thirdsense.ui.starling.ScrollControl;
	import com.thirdsense.ui.starling.ScrollType;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Example Starling Menu
	 */
	
	public class Menu3 extends LPsBaseMenu {
		
		private var scroll_control:ScrollControl;
		
		public function Menu3() {
			
			super( this.onMenuTransition );
			
			this.create();
			
		}
		
		private function create():void
		{
			var quad:Quad = new Quad( this.stage_width, this.stage_height, 0x004400 );
			this.addChild( quad );
			
			var tf:TextField = new TextField( 400, 100, "Tap background to load next menu" );
			tf.color = 0xFFFFFF;
			tf.hAlign = HAlign.CENTER;
			tf.vAlign = VAlign.CENTER;
			tf.x = this.stage_width - tf.width >> 1;
			tf.y = this.stage_height - tf.height >> 1;
			tf.touchable = false;
			this.addChild( tf );
			
			// Example of how to create a simple image heading
			this.createHeading();
		}
		
		private function onMenuTransition():void
		{
			trace( "Loaded " + this.section );
			
			// Create the gawdy coloured background quad
			var quad:Quad = this.getChildAt(0) as Quad;
			quad.addEventListener( TouchEvent.TOUCH, this.touchHandler );
			
			// Add the heading element
			this.addHeading();
			
			// Example of how to use the ScrollControl object
			this.createScrollElement();
			
		}
		
		private function createScrollElement():void
		{
			// Create the content to be scrolled, in this case a starling sprite containing 8 different coloured rectangles
			var spr:Sprite = new Sprite();
			spr.name = "Quad Container";
			this.addChild( spr );
			
			var colors:Array = [ 0xFF0000, 0xFFFF00, 0xFFFFFF, 0x00FFFF, 0x00FF00, 0xFF00FF, 0x0000FF, 0x000000 ];
			for ( var i:uint = 0; i < colors.length; i++ )
			{
				var quad:Quad = new Quad( 150, 150, colors[i] );
				quad.x = i * 155;
				quad.y = 0;
				spr.addChild( quad );
				
				quad.addEventListener(TouchEvent.TOUCH, this.quadTouchHandler);
			}
			
			spr.x = 50;
			// center the sprite on the bottom half of the stage
			spr.y = (this.stage_height / 2) + (((this.stage_height / 2) - 150) / 2);
			
			// Configure the viewport for the scrolling area
			var viewPort:Rectangle = new Rectangle(spr.x, spr.y, this.stage_width - (2*spr.x), spr.height);
			
			// Add the scroll control class
			this.scroll_control = new ScrollControl();
			this.scroll_control.init( spr, ScrollType.HORIZONTAL, viewPort );
			
			// And just for shits and giggles, add a tween for each quad to make a splashy entrance!
			for ( i = 0; i < spr.numChildren; i++ )
			{
				quad = spr.getChildAt(i) as Quad;
				
				var tween:BTween = new BTween( quad, 90, BTween.EASE_OUT_ELASTIC, (i * 5) + 5 );
				tween.rotateFromTo( Trig.toRadians( -45), 0 );
				tween.scaleFromTo( 0, 1 );
				tween.start();
			}
		}
		
		private function quadTouchHandler( evt:TouchEvent ):void
		{
			var quad:Quad = evt.currentTarget as Quad;
			var touch:Touch = evt.getTouch( quad, TouchPhase.ENDED );
			
			if ( touch && this.scroll_control.scrolling == false )
			{
				trace( "The user tapped on a box with the colour value of:", quad.color );
			}
		}
		
		private function touchHandler( evt:TouchEvent ):void
		{
			var quad:Quad = this.getChildAt(0) as Quad;
			var touch:Touch = evt.getTouch( quad, TouchPhase.ENDED );
			
			if ( touch && this.scroll_control.scrolling == false )
			{
				quad.removeEventListener( TouchEvent.TOUCH, this.touchHandler );
				
				var spr:Sprite = this.getChildByName( "Quad Container" ) as Sprite;
				for ( var i:uint = 0; i < spr.numChildren; i++ )
				{
					quad = spr.getChildAt(i) as Quad;
					quad.removeEventListeners( TouchEvent.TOUCH );
				}
				
				LPsMenu.navigateTo( "Menu1", LPMenuTransition.RANDOM );
			}
		}
		
		private function createHeading():void
		{
			var mc:MovieClip = new example_heading();
			mc.label.text = "MENU 3 HEADING";
			mc.label.autoSize = TextFieldAutoSize.CENTER;
			TexturePack.createFromMovieClip( mc, this.section, "heading" );
		}
		
		private function addHeading():void
		{
			// Get the texture pack we created in the createHeading function
			var tp:TexturePack = this.getTexturePack( "heading" );
			
			// Create an image object from the texture pack, center on the x stage and align to the top of the screen (with a 10 pixel pad)
			var img:Image = tp.getImage();
			img.x = this.stage_width >> 1;
			img.y = (tp.source_height / 2) + 10;
			img.touchable = false;
			this.addChild( img );
			
			// Tween another cool transition to make it pop
			var tween:BTween = new BTween( img, 90, BTween.EASE_OUT_ELASTIC );
			tween.scaleFromTo(0, 1);
			tween.rotateFromTo( Trig.toRadians( -45), 0 );
			tween.start();
		}
		
	}
	
}
