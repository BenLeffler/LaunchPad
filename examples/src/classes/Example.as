package classes {
	
	import classes.AppData;
	import classes.sExample;
	import com.thirdsense.data.LPLocalData;
	import com.thirdsense.LaunchPad;
	import flash.display.MovieClip;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	public class Example extends MovieClip {
		
		/**
		 * LaunchPad will attempt to load the project config.xml file from the lib/xml folder, however you
		 * can pass through a custom embedded config if you wish to constrain your project to a single swf
		 * with no external files. The following embed shows how this is achieved...
		 */
		[Embed(source="../../bin/lib/xml/config.xml", mimeType="application/octet-stream")]
		private const config_xml:Class;
		
		private var launchpad:LaunchPad;
		
		public function Example() {
			
			// If you want to use your embedded config.xml file, you can initiate LaunchPad as follows:
			// var xml:XML = new XML( new config_xml() );
			// this.launchpad = new LaunchPad(xml);
			
			// But for this example, lets use the external config file so we don't have to recompile the project
			// every time we change something in it.
			
			this.launchpad = new LaunchPad();
			this.launchpad.init( this, this.onLaunchPadInit );
			
		}
		
		private function onLaunchPadInit():void
		{
			this.launchpad.startStarlingSession( sExample );
			
			this.startLocalDataExample();
			
		}
		
		private function startLocalDataExample():void
		{
			// Example of using the LaunchPad local data class (SharedObject handling)
			
			// First you need to register a class that extends the LPLocalData class. In this case, see classes.AppData for an example.
			var data:AppData = LPLocalData.registerClass( AppData );
			
			if ( !data.test1 )
			{
				// If data hasn't been saved previously, let's do that now. The next time you run this example, this data will be retrieved.
				LPLocalData.record( "test1", "I have just saved this string to a local shared object" );
				LPLocalData.record( "test2", 1234565789 );
				
				// We can also save batch data in a single call as follows:
				data.test1 = "I have just saved this string to a local shared object";
				data.test2 = 123456789;
				LPLocalData.recordAll();
			}
			else
			{
				// Locally stored data was found. Let's trace it out.
				trace( "LOCAL DATA EXAMPLE:", data.test1 );
				trace( "LOCAL DATA EXAMPLE:", data.test2 );
			}
			
			// You can also delete any locally stored data by calling LPLocalData.deleteData();
		}
		
	}
	
}
