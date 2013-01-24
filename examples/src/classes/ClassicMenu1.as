package classes
{
	import com.thirdsense.ui.display.menu.LPBaseMenu;
	import com.thirdsense.ui.display.menu.LPMenu;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.utils.SmoothImageLoad;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	public class ClassicMenu1 extends LPBaseMenu
	{
		public function ClassicMenu1():void
		{
			super( this.onMenuTransition );
			
			// This places a bitmap in this menu:
			SmoothImageLoad.imageLoad( "lib/img/surfboard.jpg", this, 0, 0, "contrain", false, true );
		}
		
		/**
		 * This function has been set up (with the super() call above) to be called once a menu transition has concluded
		 */
		
		private function onMenuTransition():void
		{
			// Add a listener to the stage for a mouse click to begin transition to the next menu screen.
			this.addEventListener(MouseEvent.CLICK, this.clickHandler);
		}
		
		private function clickHandler(evt:MouseEvent):void
		{
			// Removes the listener and navs to the next menu in a random transition
			this.removeEventListener(MouseEvent.CLICK, this.clickHandler);
			LPMenu.navigateTo( "ClassicMenu2", LPMenuTransition.RANDOM );
		}
		
		/**
		 * This function is called when this menu screen is removed from the stage
		 */
		
		public override function onMenuRemove():void
		{
			// It's good practise to dispose of bitmapdata once you no longer need it, or you may encounter memory leaks
			if ( this.numChildren )
			{
				var bmp:Bitmap = this.getChildAt(0) as Bitmap;
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
			}
		}
		
	}
	
}