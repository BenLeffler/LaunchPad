package  
{
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.LPSettings;
	import com.thirdsense.social.FacebookInterface;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	public class Example extends MovieClip 
	{
		private var launchpad:LaunchPad;
		
		public function Example() 
		{
			this.launchpad = new LaunchPad();
			this.launchpad.init( this, this.onInit, null );
		}
		
		private function onInit():void
		{
			
		}
		
	}

}