package classes {
	
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.controllers.MobilityControl;
	import com.thirdsense.settings.Profiles;
	import com.thirdsense.ui.starling.LPsButton;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.ui.starling.menu.LPsBaseMenu;
	import com.thirdsense.ui.starling.menu.LPsMenu;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFieldAutoSize;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * Example Starling Menu.
	 */
	
	public class Menu1 extends LPsBaseMenu {
		
		public function Menu1() {
			
			// If the user has an Android device, we can handle a press of the device's back button as follows...
			if ( Profiles.isAndroid() )
			{
				var fn:Function = this.onBackButton;
			}
			
			super( this.onMenuTransition, fn );
			
			// It's usually good practise to create all this menu's assets and textures at this stage. At this point, the menu
			// hasn't been added to the stage yet, so we can afford a slight pause to perform these asynchronous tasks.
			this.create();
			
		}
		
		private function onBackButton():void
		{
			trace( "This Android user has hit the back button. What a jerk!" );
			
			// We can also release the Android user's device to handle the back button as the default "exit application" response...
			if ( Profiles.isAndroid() )	MobilityControl.killBackButton();
			
		}
		
		private function create():void
		{
			// create the matte background
			var quad:Quad = new Quad( this.stage_width, this.stage_height, 0x004400 );
			this.addChild( quad );
			
			// create the text in the center of the screen
			var tf:TextField = new TextField( 400, 100, "Tap background to load next menu" );
			tf.color = 0xFFFFFF;
			tf.hAlign = HAlign.CENTER;
			tf.vAlign = VAlign.CENTER;
			tf.x = this.stage_width - tf.width >> 1;
			tf.y = this.stage_height - tf.height >> 1;
			tf.touchable = false;
			this.addChild( tf );
			
			// Example of how to create a TexturePack for use with Starling...
			this.createExampleButton( "button 1" );
			this.createExampleButton( "button 2" );
			
			// Example of how to create a simple image heading
			this.createHeading();
		}
		
		private function createHeading():void
		{
			var mc:MovieClip = new example_heading();
			mc.label.text = "MENU 1 HEADING";
			mc.label.autoSize = TextFieldAutoSize.CENTER;
			TexturePack.createFromMovieClip( mc, this.section, "heading" );
		}
		
		private function createExampleButton( copy:String ):void
		{
			// Get the source movieclip
			var mc:MovieClip = new example_button();
			mc.label.text = copy;
			mc.filters = [ new DropShadowFilter(2, 45, 0, 1, 3, 3, 0.25, 3) ];
			
			// Convert to TexturePack and register it to the TexturePack library for use anywhere in the project
			TexturePack.createFromMovieClip( mc, this.section, copy );
		}
		
		private function onMenuTransition():void
		{
			trace( "Loaded " + this.section );
			
			// Create the gawdy coloured background quad
			var quad:Quad = this.getChildAt(0) as Quad;
			quad.addEventListener( TouchEvent.TOUCH, this.touchHandler );
			
			// Add the heading
			this.addHeading();
			
			// Add the LPsButton objects to the stage
			this.addButtons();
		}
		
		private function touchHandler( evt:TouchEvent ):void
		{
			var quad:Quad = this.getChildAt(0) as Quad;
			var touch:Touch = evt.getTouch( quad, TouchPhase.ENDED );
			if ( touch )
			{
				quad.removeEventListener( TouchEvent.TOUCH, this.touchHandler );
				
				LPsMenu.navigateTo( "Menu2", LPMenuTransition.RANDOM );
				
				// When this menu instance is removed from the stage, any TexturePack objects that were registered with the pool name "Menu1"
				// (or the value represented by calling 'this.section') are deleted for memory conservation.
				// It's not recommended, by you can override the onMenuRemove() function if you wish to prevent this from happening.
				
			}
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
		
		private function addButtons():void
		{
			// Example of how to use a TexturePack in the creation of an LPsButton object
			
			// Retrieve the relevant TexturePack object. This is also achievable by calling TexturePack.getTexturePack( this.section, "button 1" );
			var tp:TexturePack = this.getTexturePack( "button 1" );
			
			// Use the TexturePack in the creation of the Starling based button
			var button_1:LPsButton = new LPsButton( tp, this.onButtonClick );
			button_1.x = (this.stage_width/2) - button_1.source_width - 5;
			button_1.y = this.stage_height - button_1.source_height - 10;
			button_1.name = "button 1";
			this.addChild( button_1 );
			
			// Tween the button scale and rotation for a fancy transition between menus
			var tween:BTween = new BTween( button_1, 90, BTween.EASE_OUT_ELASTIC );
			tween.rotateFromTo( Trig.toRadians( -45), 0 );
			tween.scaleFromTo( 0, 1 );
			tween.start();
			
			// And create button 2 in much the same way, but add a 10 frame delay to the tween for added fanciness!
			tp = this.getTexturePack( "button 2" );
			var button_2:LPsButton = new LPsButton( tp, this.onButtonClick );
			button_2.x = (this.stage_width / 2) + 5;
			button_2.y = this.stage_height - button_2.source_height - 10;
			button_2.name = "button 2";
			this.addChild( button_2 );
			
			tween = new BTween( button_2, 90, BTween.EASE_OUT_ELASTIC, 10 );
			tween.rotateFromTo( Trig.toRadians( -45), 0 );
			tween.scaleFromTo( 0, 1 );
			tween.start();
		}
		
		// Handle the button clicks
		
		private function onButtonClick( touch:Touch ):void
		{
			switch ( touch.target.name )
			{
				case "button 1":
					trace( "User clicked button 1" );
					break;
					
				case "button 2":
					trace( "User clicked button 2" );
					break;
			}
		}
		
	}
	
}
