package  
{
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.Profiles;
	import com.thirdsense.sound.SoundShape;
	import com.thirdsense.sound.SoundStream;
	import com.thirdsense.utils.AdjustColors;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	import flash.media.SoundChannel;
	
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