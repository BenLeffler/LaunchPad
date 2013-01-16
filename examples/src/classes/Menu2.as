package classes {
	
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.LaunchPad;
	import com.thirdsense.ui.starling.LPsCheckList;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.ui.starling.menu.LPsBaseMenu;
	import com.thirdsense.ui.starling.menu.LPsMenu;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
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
	 * Example Starling Menu
	 */
	
	public class Menu2 extends LPsBaseMenu {
		
		public function Menu2() {
			
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
			
			// Example of how to use the LaunchPad asset library in conjunction with Starling to create usable assets
			this.createBuildings();
		}
		
		private function createBuildings():void
		{
			// The names of the library assets located in a preloaded swf asset library
			var buildings:Array = [ "example_asset1", "example_asset2", "example_asset3" ];
			
			// Sometimes you will want to generate mipmaps for a texture. This makes scaled textures smooth and anti-aliased, but can be
			// quite memory intensive (especially if you are compiling for iPad 1). I'm going to turn it on just to create these building
			// textures, and then turn it off for the rest of the app at the end of this function.
			TexturePack.generate_mipmaps = true;
			
			for ( var i:uint = 0; i < buildings.length; i++ )
			{
				var mc:MovieClip = LaunchPad.getAsset( "", buildings[i] );
				TexturePack.createFromMovieClip( mc, this.section, "building_" + i );
			}
			
			// Turning off mipmaps to conserve memory.
			TexturePack.generate_mipmaps = false;
		}
		
		private function onMenuTransition():void
		{
			trace( "Loaded " + this.section );
			
			// Create the gawdy coloured background quad
			var quad:Quad = this.getChildAt(0) as Quad;
			quad.addEventListener( TouchEvent.TOUCH, this.touchHandler );
			
			// Add the heading element
			this.addHeading();
			
			// Add the first building on to the stage
			this.addBuilding( 1 );
			
			// Create the checklist ui element example
			this.addCheckList();
			
		}
		
		private function addBuilding( id:int ):void
		{
			// If a building image already exists on screen, remove it.
			
			var img:Image = this.getChildByName( "building" ) as Image;
			if ( img )
			{
				img.removeFromParent();
			}
			
			// Now retrieve the TexturePack of the building we wish to place on screen
			
			var tp:TexturePack = this.getTexturePack( "building_" + id )
			
			// Create a Starling Image object from the TexturePack, add it and position it.
			
			img = tp.getImage();
			img.scaleX = img.scaleY = 1.2;
			img.x = this.stage_width >> 1;
			img.y = (this.stage_height / 2) + tp.source_height + 50;
			img.name = "building";
			this.addChild( img );
			
			// And then Tween it in for effect.
			
			var tween:BTween = new BTween( img, 90, BTween.EASE_OUT_ELASTIC );
			tween.scaleFromTo( 0, 1.2 );
			tween.start();
		}
		
		private function addCheckList():void
		{
			// Example of using a check list ui asset
			
			// First create the TexturePacks to use with this asset:
			
			var labels:Array = [ "Option 0", "Option 1", "Option 2" ];
			
			var texture_packs:Array = new Array();
			for ( var i:uint = 0; i < labels.length; i++ )
			{
				var mc:MovieClip = new example_checklist();
				mc.label.text = labels[i];
				mc.label.autoSize = TextFieldAutoSize.LEFT;
				texture_packs.push( TexturePack.createFromMovieClip(mc, this.section, labels[i]) );
			}
			
			// Create the checklist element by passing through the array of TexturePack objects. In this instance, we want option id '1' selected
			// by default, and this will not be a multichoice ui element.
			
			var list:LPsCheckList = new LPsCheckList( texture_packs, [1], false, this.onCheckListToggle );
			list.x = this.stage_width - list.width >> 1;
			list.y = this.stage_height - list.height - 10;
			list.name = "list";
			this.addChild( list );
			
			// Add a fade in tween for effect
			
			var tween:BTween = new BTween( list, 30, BTween.LINEAR, 10 );
			tween.fadeFromTo( 0, 1 );
			tween.start();
		}
		
		private function onCheckListToggle():void
		{
			// When a user toggles between selections in the checklist, this function is fired off and we can update the content on the page accordingly
			var list:LPsCheckList = this.getChildByName( "list" ) as LPsCheckList;
			
			trace( "User selected OPTION " + list.values[0] );
			this.addBuilding( list.values[0] );
		}
		
		private function touchHandler( evt:TouchEvent ):void
		{
			var quad:Quad = this.getChildAt(0) as Quad;
			var touch:Touch = evt.getTouch( quad, TouchPhase.ENDED );
			if ( touch )
			{
				quad.removeEventListener( TouchEvent.TOUCH, this.touchHandler );
				
				LPsMenu.navigateTo( "Menu3", LPMenuTransition.RANDOM );
			}
		}
		
		private function createHeading():void
		{
			var mc:MovieClip = new example_heading();
			mc.label.text = "MENU 2 HEADING";
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
