package com.thirdsense.ui.starling.menu 
{
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.controllers.MobilityControl;
	import com.thirdsense.settings.Profiles;
	import flash.utils.getQualifiedClassName;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * Base class for use with the LaunchPad Starling based menu system
	 * @author Ben Leffler
	 */
	
	public class LPsBaseMenu extends Sprite 
	{
		private var _section:String;
		public var onTransition:Function;
		
		public function LPsBaseMenu( onTransitionIn:Function=null, onBackButton:Function=null ) 
		{
			var arr:Array = getQualifiedClassName(this).split("::");
			this._section = arr[arr.length - 1];
			
			this.onTransition = onTransitionIn;
			
			if ( Profiles.mobile ) MobilityControl.initBackButton( onBackButton );
			
			this.addEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
		}
		
		public function get section():String 
		{
			return _section;
		}
		
		public function removeHandler( evt:Event ):void
		{
			this.removeEventListener( Event.REMOVED_FROM_STAGE, this.removeHandler );
			TexturePack.deleteTexturePack( this.section );
		}
		
		public function get stage_width():Number
		{
			return Starling.current.stage.stageWidth;
		}
		
		public function get stage_height():Number
		{
			return Starling.current.stage.stageHeight;
		}
		
		public final function getTexturePack( sequence:String ):TexturePack
		{
			return TexturePack.getTexturePack( this.section, sequence );
		}
		
		public function navToPreviousMenu( transition:String = "R" ):void
		{
			LPsMenu.navigateTo( LPsMenu.last_menu, transition );
		}
		
	}

}