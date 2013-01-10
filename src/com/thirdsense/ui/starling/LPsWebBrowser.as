package com.thirdsense.ui.starling 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.utils.getDefinitionByName;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Touch;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class LPsWebBrowser extends Sprite 
	{
		private var border:Sprite;
		private var loading_icon:Image;
		private var loading_icon_tween:BTween;
		private var filter1:BlurFilter;
		private var close_button:LPsButton;
		private var address_text:TextField;
		private var url:String;
		private var swv:StageWebView;
		private var viewport:Rectangle;
		private var redirect_url:String;
		
		/**
		 * If the user hits the close button, this function gets called.
		 */
		public var onCloseButton:Function;
		
		/**
		 * This function is called when the browser has been invoked.
		 */
		public var onInvoke:Function;
		
		/**
		 * This function is called when the browser has been removed from the stage (separate to onCloseButton which gets called when a removal is by the user)
		 */
		public var onRemove:Function;
		
		private static var instance:LPsWebBrowser;
		
		/**
		 * Base function for the LPsWebBrowser class.
		 * @param	url	The url to navigate to. Leave as an empty string if you aren't invoking the browser yet
		 * @param	redirect_url	A url that the browser will redirect to if a location other than the one passed in the <b>url</b> argument is detected
		 */
		
		public function LPsWebBrowser( url:String="", redirect_url:String = "" ) 
		{
			this.url = url;
			this.redirect_url = redirect_url;
			
			this.createScaffold();
			
			if ( url.length )
			{
				if ( !Starling.current.root )
				{
					trace( "LaunchPad", LPsWebBrowser, "Can not add browser to the Starling root just yet. The Starling instance must complete initialization before it can be used" );
					return void;
				}
				(Starling.current.root as Sprite).addChild(this);
				this.addToStage( url );
			}
			
			instance = this;			
		}
		
		/**
		 * Creates the background quad and browser interface
		 */
		
		private function createScaffold():void
		{
			this.createBackground();
			this.createBorder();
		}
		
		private function createBackground():void
		{
			var quad:Quad = new Quad( Starling.current.stage.stageWidth, Starling.current.stage.stageHeight, 0x000000 );
			quad.x = 0;
			quad.y = 0;
			this.addChild( quad );
			
			var tween:BTween = new BTween(quad, 30 );
			tween.fadeFromTo(0, 0.75, true);
			tween.start();
		}
		
		private function createBorder():void
		{
			this.border = new Sprite();
			this.addChild( this.border );
			
			var stage_width:Number = Starling.current.stage.stageWidth;
			var stage_height:Number = Starling.current.stage.stageHeight;
			var padding:int = 30;
			if ( stage_width <= 480 ) padding = 10;
			
			var quad:Quad = new Quad( stage_width - (padding*2), stage_height - (padding*2), 0xFFFFFF );
			quad.x = padding;
			quad.y = padding;
			quad.alpha = 1;
			this.border.addChild( quad );
			
			quad = new Quad( stage_width - (padding*2) - 4, stage_height - (padding*2) - 4 );
			quad.x = padding + 2;
			quad.y = padding + 2;
			quad.alpha = 1;
			quad.setVertexColor( 0, 0xFFFFFF );
			quad.setVertexColor( 1, 0xFFFFFF );
			quad.setVertexColor( 2, 0xF5F5F5 );
			quad.setVertexColor( 3, 0xF5F5F5 );
			this.border.addChild( quad );
			
			quad = new Quad( stage_width - (padding*2) - 24, stage_height - (padding*2) - 80, 0xF0F0F0 );
			quad.x = padding + 12;
			quad.y = padding + 12;
			quad.alpha = 1;
			this.filter1 = BlurFilter.createDropShadow( 2, Trig.toRadians(90), 0, 0.25, 2 );
			this.filter1.cache()
			quad.filter = filter1;
			this.border.addChild( quad );
			
			quad = new Quad( stage_width - (padding*2) - 28, stage_height - (padding*2) - 84 );
			quad.x = padding + 14;
			quad.y = padding + 14;
			quad.alpha = 1;
			quad.setVertexColor( 0, 0xF5F5F5 );
			quad.setVertexColor( 1, 0xF5F5F5 );
			quad.setVertexColor( 2, 0xFFFFFF );
			quad.setVertexColor( 3, 0xFFFFFF );
			this.border.addChild( quad );
			
			this.viewport = new Rectangle( quad.x, quad.y, quad.width, quad.height );
			
			var tp:TexturePack = TexturePack.createFromMovieClip( new lp_loadingicon(), "LPsWebBrowser", "loading_icon", null, 0, 0, null, 2 );
			this.loading_icon = tp.getImage();
			this.loading_icon.x = padding + 12 + (tp.source_width / 2);
			this.loading_icon.y = stage_height - padding - 10 - (tp.source_height / 2);
			this.border.addChild( this.loading_icon );
			
			quad = new Quad( stage_width - (padding*2) - 190, 36, 0xDEDEDE );
			quad.x = this.loading_icon.x + (this.loading_icon.width / 2) + 10;
			quad.y = this.loading_icon.y - 18;
			this.border.addChild( quad );
			
			quad = new Quad( stage_width - (padding*2) - 194, 32, 0xF5F5F5 );
			quad.x = this.loading_icon.x + (this.loading_icon.width / 2) + 12;
			quad.y = this.loading_icon.y - 16;
			this.border.addChild( quad );
			
			this.address_text = new TextField( quad.width - 10, quad.height, "Loading...", "Arial Rounded MT Bold", 18, 0xBCBCBC, true );
			this.address_text.x = quad.x + 5;
			this.address_text.y = quad.y + 1;
			this.address_text.hAlign = HAlign.LEFT;
			this.address_text.vAlign = VAlign.CENTER;
			this.border.addChild( this.address_text );
			
			var mc:MovieClip = new lp_button1();
			mc.label_txt.text = "CLOSE";
			tp = TexturePack.createFromMovieClip( mc, "LPsWebBrowser", "close_button", null, 0, 0, null, 1 );
			this.close_button = new LPsButton( tp, this.closeHandler );
			this.close_button.x = quad.x + quad.width + 15;
			this.close_button.y = this.loading_icon.y - (this.close_button.source_height / 2);
			this.border.addChild( this.close_button );
			
			var tween:BTween = new BTween( this.border, 30 );
			tween.fadeFromTo( 0, 1 );
			tween.start();
			
			this.loading_icon_tween = new BTween( this.loading_icon, 30 );
			this.loading_icon_tween.rotateFromTo( 0, Trig.toRadians(359) );
			this.loading_icon_tween.loops = BTween.LOOPS_FOREVER;
			this.loading_icon_tween.start();
			
		}
		
		/**
		 * Called when the user clicks the "close" button
		 * @param	touch
		 */
		
		private function closeHandler(touch:Touch):void
		{
			if ( this.swv )
			{
				this.swv.stop();
			}
			
			this.kill();
			
			if ( this.onCloseButton != null )
			{
				var fn:Function = this.onCloseButton;
				this.onCloseButton = null;
				fn();
			}
		}
		
		/**
		 * The public function that is called to invoke the browser. This will mainly be used by classes such as FacebookInterface to create login dialogues
		 * @return	The StageWebView instance of the new browser session
		 */
		
		public function invoke():StageWebView
		{
			if ( !this.parent )
			{
				if ( !Starling.current.root )
				{
					trace( "LaunchPad", LPsWebBrowser, "Can not add browser to the Starling root just yet. The Starling instance must complete initialization before it can be used" );
					return null;
				}
				(Starling.current.root as Sprite).addChild( this );
			}
			
			if ( !this.swv )
			{
				this.createStageWebView();
			}
			
			if ( this.onInvoke != null )
			{
				this.onInvoke();
			}
			
			return this.swv;
		}
		
		/**
		 * Redirects the current browser session to the designated url
		 * @param	url	The url to navigate to. Must be prefaced with a "http://", "https://" etc. or an error is thrown
		 */
		
		public function navToURL( url:String ):void
		{
			this.addToStage( url );
		}
		
		/**
		 * Kills the current browser session and disposes of all listeners, textures, tweens and static singleton
		 */
		
		private function kill():void
		{
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, this.timeline);
			
			if ( this.swv )
			{
				this.swv.removeEventListener( Event.COMPLETE, this.loadComplete );
				this.swv.removeEventListener( LocationChangeEvent.LOCATION_CHANGING, this.locationChangingHandler );
				this.swv.removeEventListener( LocationChangeEvent.LOCATION_CHANGE, this.locationChangingHandler );
				
				try {
					this.swv.stage = null;
					this.swv.dispose();
				}
				catch (e:*)
				{
					//
				}
			}
			
			this.swv = null;
			instance = null;
			
			if ( this.parent ) this.removeFromParent();
			
			while ( this.border && this.border.numChildren )
			{
				this.border.removeChildAt(0, true);
			}
			
			TexturePack.deleteTexturePack( "LPsWebBrowser" );
			BTween.removeFromCue( this.loading_icon_tween );
			
			if ( this.onRemove != null )
			{
				this.onRemove();
			}
		}
		
		private function addToStage( url:String ):void
		{
			if ( !this.swv )
			{
				this.createStageWebView();
			}
			
			this.swv.loadURL( url );
		}
		
		private function createStageWebView():void
		{
			this.swv = new StageWebView();
			this.swv.viewPort = this.viewport;
			this.swv.stage = Starling.current.nativeStage;
			this.swv.assignFocus();
			this.swv.addEventListener( Event.COMPLETE, this.loadComplete, false, 0, true );
			this.swv.addEventListener( LocationChangeEvent.LOCATION_CHANGING, this.locationChangingHandler, false, 0, true );
			this.swv.addEventListener( LocationChangeEvent.LOCATION_CHANGE, this.locationChangingHandler, false, 0, true );
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, this.timeline);
		}
		
		/**
		 * Called when the browser session requests a new location and when the browser starts loading the new location content
		 * @param	evt	The event dispatched by the location listeners
		 */
		
		private function locationChangingHandler( evt:LocationChangeEvent ):void
		{
			this.loading_icon.visible = true;
			
			this.updateAddressText( evt.location );
			
			if ( this.redirect_url.length && evt.type == LocationChangeEvent.LOCATION_CHANGE && evt.location != this.url )
			{
				this.swv.loadURL( this.redirect_url );
				this.url = this.redirect_url;
				this.redirect_url = "";
			}
		}
		
		/**
		 * Called when the load of a new location has completed
		 * @param	evt	The event dispatched by the StageWebView instance
		 */
		
		private function loadComplete( evt:Event ):void
		{
			this.updateAddressText( this.swv.location );
			
			this.loading_icon.visible = false;
		}
		
		private function updateAddressText( copy:String = "" ):void
		{
			this.address_text.text = copy;
			
			while ( this.address_text.textBounds.height > 30 )
			{
				copy = copy.substr( 0, copy.length - 1 );
				this.address_text.text = copy + "...";
			}
		}
		
		/**
		 * An enter frame event that polls the StageWebView instance for it's stage. If a stage is no longer detected, it signals a kill of the LPsWebBrowser instance
		 * @param	evt	The enter frame event dispatched to the function
		 */
		
		private function timeline( evt:EnterFrameEvent ):void
		{
			if ( this.swv )
			{
				try {
					this.swv.stage;
				}
				catch (e:*)
				{
					this.kill();
				}
			}
		}
		
		/**
		 * Creates a new instance of the LPsWebBrowser. If a url is passed through, a browser session is automatically added to the root Starling container. If url is left
		 * as a blank string, the static singleton is only created and allows you to customize callback functions prior to invoking the browser.
		 * @param	url	The url to immediately load with a new browser session
		 * @param	redirect_url	If the browser session detects a location other than the one passed in the <b>url</b> parameter, the browser will redirect to this location
		 * @return	The LPsWebBrowser singleton instance
		 */
		
		public static function create( url:String = "", redirect_url:String = "" ):*
		{
			instance = new LPsWebBrowser( url, redirect_url );
			
			return instance;
		}
		
		/**
		 * Returns the current LPsWebBrowser instance.
		 * @return	A LPsWebBroswer singleton instance. <i>null</i> is returned if a singleton does not exist in memory.
		 */
		
		public static function getInstance():*
		{
			return instance;
		}
		
		/**
		 * Kills and disposes of the current LPsWebBrowser session and/or singleton
		 */
		
		public static function dispose():void
		{
			if ( instance )	instance.kill();
		}
		
		/**
		 * Invokes an LPsWebBrowser session. If a singleton doesn't exist prior to calling <i>invoke</i> a new instance is created. This method is mainly used for classes such as
		 * FacebookInterface which can invoke a browser session to prompt the user for an oAuth login.
		 * @return	The StageWebView instance which is summarily created as part of the browser session invoke.
		 */
		
		public static function invoke():*
		{
			if ( !instance )
			{
				create();
			}
			
			return instance.invoke();
		}
		
	}

}