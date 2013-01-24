package classes {
	
	import com.thirdsense.LaunchPad;
	import com.thirdsense.ui.display.menu.LPMenu;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import flash.display.MovieClip;
	
	/**
	 * The following is an example of how to use an embedded configuration xml file and how to call a classic display list menu system.
	 */
	
	public class ClassicExample extends MovieClip {
		
		/**
		 * LaunchPad will attempt to load the project config.xml file from the lib/xml folder, however you
		 * can pass through a custom embedded config if you wish to constrain your project to a single swf
		 * with no external files. The following embed shows how this is achieved...
		 */
		[Embed(source="../../bin/lib/xml/config.xml", mimeType="application/octet-stream")]
		private const config_xml:Class;
		
		private var launchpad:LaunchPad;
		
		public function ClassicExample() {
			
			// If you want to use your embedded config.xml file, you can initiate LaunchPad as follows:
			
			var xml:XML = new XML( new config_xml() );			
			this.launchpad = new LaunchPad(xml);
			
			// In this example, we will use a custom preloader
			this.launchpad.init( this, this.onLaunchPadInit, new custom_preloader() );
			
		}
		
		private function onLaunchPadInit():void
		{
			this.createMenu();
		}
		
		private function createMenu():void
		{
			// Register the classes which extend com.thirdsense.ui.menu.LPBaseMenu
			LPMenu.registerMenu( ClassicMenu1 );
			LPMenu.registerMenu( ClassicMenu2 );
			
			// Create the menu instance
			var menu:LPMenu = new LPMenu()
			this.addChild( menu );
			
			// Turn on the stitching effect. This allows menu bounds to be stitched together during transitions (compare against the starling example for a non-stitched menu)
			LPMenu.stitch = true;
			
			// Navigate to one of the menus with a random transition type
			LPMenu.navigateTo( "ClassicMenu1", LPMenuTransition.RANDOM );
		}
		
	}
	
}
