package classes {
	
	import classes.sExample;
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
			
			var data:AppData = LPLocalData.registerClass( LaunchPad );
		}
		
	}
	
}
