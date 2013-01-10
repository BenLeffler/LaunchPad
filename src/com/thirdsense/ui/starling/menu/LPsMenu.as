package com.thirdsense.ui.starling.menu 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.net.Analytics;
	import com.thirdsense.settings.LPSettings;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.core.Starling;
	import starling.display.Sprite;
	
	/**
	 * The LaunchPad Starling based menu scaffold class
	 * @author Ben Leffler
	 */
	
	public class LPsMenu extends Sprite 
	{
		private static var instance:LPsMenu;
		private static var _last_menu:String;
		private static var _current_menu:String;
		private static var _menus_class_path:String;
		private static var registered_menus:Array;
		
		private var onComplete:Function;
		private var content:Sprite;
		
		public function LPsMenu() 
		{
			instance = this;
			_last_menu = "";
			_current_menu = "";
			
		}
		
		private function addMenu( menu_name:String = "", transition:String = "", onComplete:Function=null ):void
		{
			if ( menu_name != _current_menu )
			{
				_last_menu = _current_menu;
				_current_menu = menu_name;
			}
			else
			{
				return void;
			}
			
			if ( onComplete != null )
			{
				this.onComplete = onComplete;
			}
			
			if ( this.content && transition != "" )
			{
				var pt:Point = LPMenuTransition.translate(transition);
				var tween:BTween = new BTween( this.content, 20, BTween.EASE_IN_OUT );
				tween.moveTo( pt.x * Starling.current.stage.stageWidth, pt.y * Starling.current.stage.stageHeight );
				tween.onComplete = this.onMenuTransition;
				tween.onCompleteArgs = [ transition ]
				tween.start();
			}
			else
			{
				this.onMenuTransition( transition );
			}			
		}
		
		private function onMenuTransition( transition:String ):void
		{
			if ( this.content )
			{
				this.content.removeChildren( 0, -1 );
			}
			else
			{
				this.content = new Sprite();
				this.addChild( this.content );
			}
			
			if ( _current_menu != "" )
			{
				var pt:Point = LPMenuTransition.translate(transition);
				this.content.x = pt.x * -Starling.current.stage.stageWidth;
				this.content.y = pt.y * -Starling.current.stage.stageHeight;
				
				var menu_class:String = this.getMenuPath( _current_menu );
				
				var cl:Class = getDefinitionByName( menu_class ) as Class;
				var menu:* = new cl();
				menu.x = 0;
				menu.y = 0;
				this.content.addChild( menu );
			}
			
			this.initMenu();
		}
		
		private function getMenuPath( name:String ):String
		{
			if ( !registered_menus )	return null;
			
			for ( var i:uint = 0; i < registered_menus.length; i++ )
			{
				if ( registered_menus[i].name == name )
				{
					return registered_menus[i].path + registered_menus[i].name;
				}
			}
			
			return null;
		}
		
		private function initMenu():void
		{
			if ( this.content )
			{
				if ( this.content.numChildren )
				{
					var mm:* = this.content.getChildAt(0);
					if ( mm.onTransition != null )	mm.onTransition();
					
				}
				
				if ( this.content.x != 0 || this.content.y != 0 )
				{
					var tween:BTween = new BTween( this.content, 30, BTween.EASE_OUT );
					tween.moveTo(0, 0);
					if ( this.onComplete != null )
					{
						tween.onComplete = this.onComplete;
						this.onComplete = null;
					}
					tween.start();
				}
				else
				{
					if ( this.onComplete != null )
					{
						var fn:Function = this.onComplete;
						this.onComplete = null;
						fn();
					}
				}
			}
			
			if ( current_menu != "" )
			{
				if ( LPSettings.ANALYTICS_TRACKING_ID.length > 0 )
				{
					Analytics.trackScreen( current_menu );
				}
			}
		}
		
		/**
		 * Obtains the name of the last menu that was visited
		 */
		
		public static function get last_menu():String 
		{
			return _last_menu;
		}
		
		
		/**
		 * Obtains the name of the currently showing menu
		 */
		public static function get current_menu():String 
		{
			return _current_menu;
		}
		
		/**
		 * Navigates the menu system to the designated screen
		 * @param	menu_name	The name of the menu class to invoke
		 * @param	transition_type	The menu transition type
		 * @param	onComplete	The callback function that is invoked upon the new menu completing it's transition in to position
		 */
		
		public static function navigateTo( menu_name:String, transition:String = "", onComplete:Function=null ):void
		{
			if ( !instance.getMenuPath(menu_name) )
			{
				trace( "LaunchPad", LPsMenu, "Error retrieving '" + menu_name + "' as it needs to be registered with LPsMenu.registerMenu first" );
			}
			else
			{
				instance.addMenu( menu_name, transition, onComplete );
			}
		}
		
		/**
		 * Returns the scaleX value of the menu container.
		 */
		
		public static function get scale():Number
		{
			return instance.scaleX;
		}
		
		/**
		 * Registers a menu class for use with the LaunchPad Starling Menu system
		 * @param	menu	The menu class to be called upon via the LPsMenu.navigateTo function
		 */
		
		public static function registerMenu( menu:Class ):void
		{
			if ( !registered_menus )
			{
				registered_menus = new Array();
			}
			
			var arr:Array = getQualifiedClassName(menu).split( "::" );
			
			for ( var i:uint = 0; i < registered_menus.length; i++ )
			{
				if ( registered_menus[i].name == arr[arr.length-1] )
				{
					trace( "LaunchPad", LPsMenu, "Error registering '" + arr[arr.length-1] + "' as this menu type already registered" );
					return void;
				}
			}
			
			if ( arr.length > 1 )
			{
				registered_menus.push( { path:arr[0] + ".", name:arr[1] } );
			}
			else
			{
				registered_menus.push( { path:"", name:arr[0] } );
			}
			
			trace( "LaunchPad", LPsMenu, arr[arr.length-1] + " successfully registered as a menu" );
		}
		
		
	}

}