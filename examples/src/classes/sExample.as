package classes
{
	import classes.Menu1;
	import classes.Menu2;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.display.Logo;
	import com.thirdsense.display.LogoType;
	import com.thirdsense.sound.SoundLabel;
	import com.thirdsense.sound.SoundShape;
	import com.thirdsense.sound.SoundStream;
	import com.thirdsense.ui.starling.LPsButton;
	import com.thirdsense.ui.starling.LPsSelectList;
	import com.thirdsense.ui.starling.LPsWebBrowser;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.ui.starling.menu.LPsMenu;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.filters.BlurFilter;
	
	
	/**
	 * Example Starling root container class
	 * @author Ben Leffler
	 */
	
	public class sExample extends Sprite 
	{
		private var buttons:Sprite;
		
		public function sExample() 
		{
			this.init();
		}
		
		public function init():void
		{
			// Create our button container
			this.buttons = new Sprite();
			this.addChild( this.buttons );
			
			// Create our buttons
			this.createButton( "Web Browser (Air only)" );
			this.createButton( "Menu System" );
			this.createButton( "Select List" );
			this.createButton( "SoundStream (Fade in)" );
			this.createButton( "SoundStream (Fade out)" );
			
			// Center the button container on the stage
			this.buttons.x = Starling.current.stage.stageWidth - this.buttons.width >> 1;
			this.buttons.y = Starling.current.stage.stageHeight - this.buttons.height >> 1;
			
			// Add the funky LaunchPad logo, because why the hell not?
			this.addLogo();
			
		}
		
		private function createButton( copy:String ):void
		{
			// Create a simple button in the classic display list
			var mc:MovieClip = new MovieClip();
			mc.graphics.beginFill( 0x999999, 1 );
			mc.graphics.drawRect( 0, 0, 300, 40 );
			mc.graphics.endFill();
			
			// Create the text for the button. (LaunchPad.swc already has Arial Rounded MT Bold font embedded)
			var tf:TextFormat = new TextFormat( "Arial Rounded MT Bold", 22, 0x000000 );
			var field:TextField = new TextField();
			field.embedFonts = true;
			field.defaultTextFormat = tf;
			field.text = copy;
			field.autoSize = TextFieldAutoSize.CENTER;
			field.multiline = false;
			field.x = 300 - field.width >> 1;
			field.y = 40 - field.height >> 1;
			mc.addChild( field );
			
			// Convert the movieclip in to a runtime TexturePack object
			var tp:TexturePack = TexturePack.createFromMovieClip( mc, "buttons", copy );
			
			// Create a LaunchPad Starling button based on the texture pack
			var button:LPsButton = new LPsButton( tp, this.buttonHandler );
			button.x = 0;
			button.y = this.buttons.height;
			button.name = copy;
			this.buttons.addChild( button );
			
		}
		
		private function buttonHandler( touch:Touch ):void
		{
			switch ( touch.target.name )
			{
				case "Web Browser (Air only)":
					LPsWebBrowser.create( "http://www.3rdsense.com" );
					break;
					
				case "Menu System":
					this.startMenu();
					break;
					
				case "Select List":
					this.addSelectList();
					break;
					
				case "SoundStream (Fade in)":
					this.soundStreamFadeIn();
					break;
					
				case "SoundStream (Fade out)":
					this.soundStreamFadeOut();
					break;
			}
		}
		
		/**
		 * And example of how to call a LaunchPad logo and display it in Starling as an image
		 */
		
		private function addLogo():void
		{
			// Create a new logo
			var logo:Logo = new Logo();
			logo.create( LogoType.LAUNCHPAD_DARK );
			logo.scaleX = 2;
			logo.scaleY = 2;
			
			// Because we have resized the display object, we will need to place it in to a container before converting to a TexturePack object
			var mc:MovieClip = new MovieClip();
			mc.addChild( logo );
			
			// Convert to TexturePack
			var tp:TexturePack = TexturePack.createFromMovieClip( mc, "logo" );
			
			// Create the image based on the TexturePack object, position it and add it to this Starling display list
			var img:Image = tp.getImage();
			img.x = Starling.current.stage.stageWidth - tp.source_width >> 1;
			img.y = Starling.current.stage.stageHeight - tp.source_height - 10;
			img.touchable = false;
			this.addChild( img );
			
			// And we can use Starling filters to make it pop a little
			img.filter = BlurFilter.createDropShadow( 2, Trig.toRadians(45), 0, 0.25, 1, 1 );
			img.filter.cache();
		}
		
		// *************************************************************************************************
		// Starling Menu framework example (see Menu1.as, Menu2.as and Menu3.as for implementation of
		// individual menu's extending the LPsBaseMenu class
		// *************************************************************************************************
		
		private function startMenu():void
		{
			this.removeChildren();
			
			// Register the menu classes (these classes should extend com.thirdsense.ui.starling.menu.LPsBaseMenu)
			LPsMenu.registerMenu( Menu1 );
			LPsMenu.registerMenu( Menu2 );
			LPsMenu.registerMenu( Menu3 );
			
			// Create instance
			var menu:LPsMenu = new LPsMenu();
			this.addChild( menu );
			
			// Let's also enable a nice transition effect in FADING
			LPsMenu.fading = true;
			
			// Navigate to the first menu class with a random transition
			LPsMenu.navigateTo( "Menu1", LPMenuTransition.RANDOM );
		}
		
		// *************************************************************************************************
		// Select list ui example
		// *************************************************************************************************
		
		private function addSelectList():void
		{
			// Set up the list of options for the user to choose from
			var choices:Array = [ "Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12" ];
			
			// Various static values can be defined for the UI such as the following
			LPsSelectList.box_width = 400;
			LPsSelectList.font_size = 16;
			LPsSelectList.unselect_text_color = 0x888888;
			
			// Create the ui element (overlays on the base Starling container). Choices 0, 1 and 3 are on by default in this multichoice element.
			LPsSelectList.create( choices, this.onSelectListComplete, [0, 1, 3], true );
			
		}
		
		private function onSelectListComplete( result:Array ):void
		{
			if ( result == null )
			{
				trace( "User cancelled from within the select list ui element" );
			}
			else if ( !result.length )
			{
				trace( "User has not selected any available option" );
			}
			else
			{
				trace( "User selected the following option(s):", result );
			}
		}
		
		// *************************************************************************************************
		// Sound examples
		// *************************************************************************************************
		
		private function soundStreamFadeIn():void
		{
			// Start the sound playing and then apply a SoundShape object to it over 160 frames
			var channel:SoundChannel = SoundStream.play( "music_out2.mp3", 1, 0, SoundLabel.SOUND );
			SoundShape.apply( channel, SoundShape.FADE_IN, 160, this.onSoundShapeComplete );
		}
		
		private function soundStreamFadeOut():void
		{
			// Start the sound playing and then apply a SoundShape object to it over 160 frames
			var channel:SoundChannel = SoundStream.play( "music_out2.mp3", 1, 0, SoundLabel.SOUND );
			SoundShape.apply( channel, SoundShape.FADE_OUT, 160, this.onSoundShapeComplete );
		}
		
		private function onSoundShapeComplete():void
		{
			trace( "The SoundShape object has completed it's transition" );
		}
		
	}

}