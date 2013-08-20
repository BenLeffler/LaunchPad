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
	import starling.filters.BlurFilter;
	
	/**
	 * The LaunchPad Starling based menu scaffold.
	 * @author Ben Leffler
	 */
	
	public class LPsMenu extends Sprite 
	{
		private static var instance:LPsMenu;
		private static var _last_menu:String;
		private static var _current_menu:String;
		private static var _menus_class_path:String;
		private static var registered_menus:Array;
		private static var _fading:Boolean;
		private static var _blurring:Boolean;
		private static var _stitch:Boolean;
		private static var onTransitionStart:Function;
		private static var _transitioning:Boolean;
		
		private var onComplete:Function;
		private var content:Sprite;
		
		/**
		 * Constructor of the LaunchPad Starling based menu framework
		 */
		
		public function LPsMenu() 
		{
			instance = this;
			_last_menu = "";
			_current_menu = "";
			_transitioning = false;
		}
		
		/**
		 * @private
		 */
		
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
			
			this.onComplete = onComplete;
			_transitioning = true;
			
			if ( this.content && transition != "" )
			{
				this.content.flatten();
				var pt:Point = LPMenuTransition.translate(transition);
				
				if ( _stitch )
				{
					var tween_speed:int = 30;
				}
				else
				{
					tween_speed = 15;
				}
				
				var tween:BTween = new BTween( this.content, tween_speed, BTween.EASE_IN_OUT, 1 );
				tween.moveTo( pt.x * Starling.current.stage.stageWidth, pt.y * Starling.current.stage.stageHeight );
				if ( _blurring )
				{
					tween.onTween = this.blurTransitionEffect;
					tween.onTweenArgs = [ tween, pt ];
				}
				if ( _fading ) tween.fadeTo(0);
				if ( _stitch )
				{
					this.onMenuTransition( transition );
					tween.onComplete = this.onStitchedMenuTransitionComplete;
					tween.onCompleteArgs = [ tween ];
				}
				else
				{
					tween.onComplete = this.onMenuTransition;
					tween.onCompleteArgs = [ transition ];
				}
				tween.start();
			}
			else
			{
				this.onMenuTransition( transition );
			}
			
			if ( onTransitionStart != null )
			{
				onTransitionStart();
			}
		}
		
		/**
		 * @private	Handles the removal of the last menu in a stitched instance
		 */
		
		private function onStitchedMenuTransitionComplete( tween:BTween ):void
		{
			if ( tween.target.parent ) tween.target.parent.removeChild( tween.target );
		}
		
		/**
		 * @private	Provides a blur effect on the content container when transitioning a menu off screen
		 */
		
		private function blurTransitionEffect( tween:BTween, transition:Point ):void
		{
			var progress:Number = tween.progress;
			var blur:int = 15;
			if ( _fading ) blur *= 2;
			if ( _stitch ) blur /= 4;
			var filter:BlurFilter = new BlurFilter( progress * blur * Math.abs(transition.x), progress * blur * Math.abs(transition.y), 0.25 );
			tween.target.filter = filter;			
		}
		
		/**
		 * @private
		 */
		
		private function onMenuTransition( transition:String ):void
		{
			if ( this.content && (!_stitch || transition == "") )
			{
				this.content.unflatten();
				this.content.filter = null;
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
		
		/**
		 * @private
		 */
		
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
		
		/**
		 * @private
		 */
		
		private function initMenu():void
		{
			if ( this.content )
			{
				if ( this.content.x != 0 || this.content.y != 0 )
				{
					var tween_type:String = BTween.EASE_OUT;
					if ( _stitch ) tween_type = BTween.EASE_IN_OUT;
					var tween:BTween = new BTween( this.content, 30, tween_type, 1 );
					tween.moveTo(0, 0);
					if ( _fading ) tween.fadeFromTo(0, 1);
					tween.onComplete = this.onTransitionComplete;
					tween.start();
				}
				else
				{
					this.onTransitionComplete();
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
		 * @private
		 */
		
		private function onTransitionComplete():void
		{
			_transitioning = false;
			
			if ( this.content.numChildren )
			{
				var mm:* = this.content.getChildAt(0);
				if ( mm.onTransition != null )	mm.onTransition();
			}
			
			if ( this.onComplete != null )
			{
				var fn:Function = this.onComplete;
				this.onComplete = null;
				fn();
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
		 * Enables or disables fading of each menu as it transitions (Your app may take a performance hit on mobile devices if it is enabled and your menus are quite busy)
		 */
		
		public static function get fading():Boolean 
		{
			return _fading;
		}
		
		/**
		 * @private
		 */
		
		public static function set fading(value:Boolean):void 
		{
			_fading = value;
		}
		
		/**
		 * Enables or disables a motion blur effect on menu transitions (There may be a performance hit on some mobile devices if enabled)
		 */
		
		public static function get blurring():Boolean 
		{
			return _blurring;
		}
		
		/**
		 * @private
		 */
		
		public static function set blurring(value:Boolean):void 
		{
			_blurring = value;
		}
		
		/**
		 * Enables or disables menu stitching for transitioning
		 */
		
		public static function get stitch():Boolean 
		{
			return _stitch;
		}
		
		/**
		 * @private
		 */
		
		public static function set stitch(value:Boolean):void 
		{
			_stitch = value;
		}
		
		/**
		 * Registers a menu class for use with the LaunchPad Starling Menu system
		 * @param	menu	The menu class to be called upon via the LPsMenu.navigateTo function where the menu_name parameter is the class name as a String.
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
		
		/**
		 * Retrieves an array of menu names that have been registered with the LPsMenu.registerMenu function
		 * @return	Array of menu names
		 */
		
		public static function getRegisteredMenuNames():Array
		{
			if ( registered_menus == null )
			{
				return null;
			}
			
			var arr:Array = new Array();			
			for ( var i:uint = 0; i < registered_menus.length; i++ )
			{
				arr.push( registered_menus[i].name );
			}
			
			return arr;
		}
		
		/**
		 * Sets a call back function when a menu transition is detected
		 * @param	fn	The function to call when a menu transitions
		 */
		
		public static function set callOnTransitionStart( fn:Function ):void
		{
			onTransitionStart = fn;
		}
		
		/**
		 * Retrieves if the menu system is currently in the act of transitioning
		 */
		
		static public function get transitioning():Boolean 
		{
			return _transitioning;
		}
	}

}