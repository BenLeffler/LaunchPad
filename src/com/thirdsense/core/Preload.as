package com.thirdsense.core 
{
	import com.thirdsense.animation.BTween;
	import com.thirdsense.data.LPAsset;
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.LPSettings;
	import com.thirdsense.ui.GenericPreloader;
	import com.thirdsense.utils.XMLLoader;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * @private	Preloading of project and assets for the LaunchPad framework
	 * @author Ben Leffler
	 */
	
	public class Preload 
	{
		private static var loader_mc:*;
		private static var xml_loader:XMLLoader;
		private static var onLoadComplete:Function;
		private static var focus_asset:LPAsset;
		private static var postload_cue:Vector.<LPAsset>;
		private static var custom_config:XML;
		
		/**
		 * Commences a preload activity
		 * @param	preloader	The preloader to use. If null, the generic preloader is used. If an empty movieclip, none is used
		 * @param	onComplete	The function to call upon preload completion
		 * @param	custom_config	If an embedded config.xml file is to be used (instead of a remote one), pass through the XML here
		 */
		
		public static function load( preloader:MovieClip = null, onComplete:Function=null, custom_config:XML = null ):void
		{
			if ( onComplete != null )	onLoadComplete = onComplete;
			if ( custom_config != null )	Preload.custom_config = custom_config;
			
			if ( !preloader )
			{
				loader_mc = new GenericPreloader();
			}
			else
			{
				loader_mc = preloader;
			}
			
			if ( !loader_mc.stage )
			{
				var target:MovieClip = LaunchPad.instance.target;
				
				loader_mc.x = ( target.stage.stageWidth - loader_mc.width ) / 2;
				loader_mc.y = ( target.stage.stageHeight - loader_mc.height ) / 2;
				target.addChild( loader_mc );
			}
			
			startPreload();
		}
		
		/**
		 * @private
		 */
		
		private static function startPreload():void
		{
			var target:MovieClip = LaunchPad.instance.target;
			target.addEventListener(Event.ENTER_FRAME, mainLoadHandler, false, 0, true);
		}
		
		/**
		 * @private
		 */
		
		private static function mainLoadHandler(evt:Event):void
		{
			if ( !focus_asset )
			{
				var target:MovieClip = evt.currentTarget as MovieClip;
				var perc:Number = target.loaderInfo.bytesLoaded / target.loaderInfo.bytesTotal;
				if ( perc >= 1 )
				{
					target.removeEventListener(Event.ENTER_FRAME, mainLoadHandler);
					importConfigXML();
				}
			}
			else
			{
				perc = focus_asset.getLoadProgress();
			}
			
			if ( loader_mc )
			{
				if ( loader_mc.bar )
				{
					loader_mc.bar.scaleX = perc;
				}
				
				if ( loader_mc.copy )
				{
					loader_mc.copy.text = Math.floor( perc * 100 ) + "%";
				}
				
				if ( loader_mc.label )
				{
					if ( focus_asset ) 
					{
						loader_mc.label.text = focus_asset.label.toUpperCase();
					}
				}
			}
		}
		
		/**
		 * @private	Imports the project configuration xml file
		 */
		
		private static function importConfigXML():void
		{
			if ( Preload.custom_config )
			{
				Preload.onConfigXML( Preload.custom_config );
			}
			else
			{
				xml_loader = new XMLLoader();
				xml_loader.load( LPSettings.LIVE_EXTENSION + "lib/xml/config.xml", onConfigXML );
			}
			
		}
		
		/**
		 * @private	Gets called on the load complete of config.xml. Parses the config, sets up the project bones and then loads project assets
		 */
		
		private static function onConfigXML( data:XML ):void
		{
			var lpconfig:LPConfig = new LPConfig();
			lpconfig.parse( data );
			
			var asset:LPAsset = LPAsset.getNextUnloadedAsset();
			if ( asset )
			{
				focus_asset = asset;
				asset.loadToAsset( onAssetLoad );
				startPreload();
			}
			else
			{
				allLoadsComplete();
			}
		}
		
		/**
		 * @private	Gets called on an asset having been loaded. Checks for and starts the next asset load, if none remaining - concludes set up of project.
		 */
		
		private static function onAssetLoad( success:Boolean ):void
		{
			if ( success )
			{
				var asset:LPAsset = LPAsset.getNextUnloadedAsset();
				if ( asset )
				{
					focus_asset = asset;
					asset.loadToAsset( onAssetLoad );
				}
				else
				{
					focus_asset = null;
					LaunchPad.instance.target.removeEventListener(Event.ENTER_FRAME, mainLoadHandler);
					allLoadsComplete();
				}
			}
			else
			{
				// throw error
				trace( "LaunchPad", Preload, "Error loading asset." );
			}
		}
		
		/**
		 * Calls a completion to the LaunchPad init phase and calls back to the client's init function
		 */
		
		private static function allLoadsComplete():void
		{
			LaunchPad.instance.target.removeChild( loader_mc );
			loader_mc = null;
			var fn:Function = onLoadComplete;
			onLoadComplete = null;
			fn();
		}
		
		/**
		 * Starts a post load procedure of LaunchPad library assets
		 * @param	ids	An array of library id's to load one-by-one
		 * @param	onComplete	The callback function once the procedure has reached it's end
		 * @param	preloader	The preloader ui element to use. If left as null, the LaunchPad generic loader element is used. For no loader bar, pass this as an empty movieclip.
		 */
		
		public static function postLoad( ids:Array, onComplete:Function=null, preloader:MovieClip=null ):void
		{
			if ( !postload_cue )
			{
				postload_cue = new Vector.<LPAsset>;
			}
			
			onLoadComplete = onComplete;
			
			for ( var i:uint = 0; i < ids.length; i++ )
			{
				var asset:LPAsset = LPAsset.getAssetRecord( ids[i] );
				if ( !asset )
				{
					trace( "LaunchPad", Preload, "Postload of asset id '" + ids[i] + "' failed as it was not found in LaunchPad config.xml" );
					continue;
				}
				else
				{
					postload_cue.push( asset );
				}
			}
			
			if ( postload_cue.length )
			{
				if ( !preloader )
				{
					loader_mc = new GenericPreloader();
					loader_mc.x = ( LaunchPad.instance.target.stage.stageWidth - loader_mc.width ) / 2;
					loader_mc.y = ( LaunchPad.instance.target.stage.stageHeight - loader_mc.height ) / 2;
					LaunchPad.instance.target.addChild( loader_mc );
				}
				else
				{
					loader_mc = preloader;
				}
				
				startPostLoadCue();				
				startPreload();
			}
			else if ( onComplete != null )
			{
				var fn:Function = onLoadComplete;
				onLoadComplete = null;
				fn();
			}
			
		}
		
		/**
		 * @private
		 */
		
		private static function startPostLoadCue():void
		{
			var asset:LPAsset = postload_cue.shift();
			focus_asset = asset;
			asset.loadToAsset( onPostLoadAsset );			
		}
		
		/**
		 * @private
		 */
		
		private static function onPostLoadAsset( success:Boolean ):void
		{
			if ( postload_cue.length )
			{
				startPostLoadCue();
			}
			else
			{
				if ( loader_mc && loader_mc.parent )
				{
					LaunchPad.instance.target.removeChild( loader_mc );
					loader_mc = null;
				}
				
				focus_asset = null;
				LaunchPad.instance.target.removeEventListener(Event.ENTER_FRAME, mainLoadHandler);
				
				if ( onLoadComplete != null )
				{
					var fn:Function = onLoadComplete;
					onLoadComplete = null;
					fn();
				}
			}
		}
	}

}