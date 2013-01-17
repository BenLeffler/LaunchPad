package classes {
	
	import classes.sExample;
	import classes.AppData;
	import com.thirdsense.data.LPLocalData;
	import com.thirdsense.LaunchPad;
	import flash.display.MovieClip;
	
	
	public class Example extends MovieClip {
		
		var launchpad:LaunchPad;
		
		public function Example() {
			
			// Start the LaunchPad load handling a preload of assets from the lib folder
			
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
