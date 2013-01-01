package com.thirdsense.data 
{
	import com.thirdsense.settings.LPSettings;
	import com.thirdsense.utils.AccessorType;
	import com.thirdsense.utils.DuplicateDisplayObject;
	import com.thirdsense.utils.getClassVariables;
	import com.thirdsense.utils.JSONUtils;
	import com.thirdsense.utils.StringTools;
	import com.thirdsense.utils.XMLLoader;
	import deng.fzip.FZip;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class LPAsset 
	{
		private static var assets:Vector.<LPAsset>;
		
		public var url:String;
		public var label:String;
		public var id:String;
		public var data:Object;
		private var _type:String;
		public var postload:Boolean;
		
		private var loader:Loader;
		private var xmlloader:XMLLoader;
		private var onLoadComplete:Function;
		private var fzip:FZipExtra;
		
		public function LPAssets() 
		{
			
		}
		
		public function get type():String 
		{
			if ( !this._type )
			{
				this.determineType();
			}
			
			return this._type;
		}
		
		private function determineType():void
		{
			var arr:Array = getClassVariables(LPAssetType, AccessorType.NONE, true);
			
			for ( var i:uint = 0; i < arr.length; i++ )
			{
				if ( arr[i] == LPAssetType.UNKNOWN )	continue;
				
				var str:String = this.url.substr( this.url.length - arr[i].length );
				if ( str.toLowerCase() == arr[i].toLowerCase() )
				{
					this._type = arr[i];
					return void;
				}
			}
			
			this._type = LPAssetType.UNKNOWN;
		}
		
		public function toString():String
		{
			return StringTools.toString(this, AccessorType.READ_ONLY);
		}
		
		/**
		 * Loads the asset from the current url associated with this asset data object
		 */
		
		public function loadToAsset( onComplete:Function=null ):void
		{
			if ( onComplete != null )	this.onLoadComplete = onComplete;
			
			switch ( this.type )
			{
				case LPAssetType.SWF:
					this.loader = new Loader();
					this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loadHandler, false, 0, true);
					this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.loadHandler, false, 0, true);
					this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.loadHandler, false, 0, true);
					this.loader.load( new URLRequest(LPSettings.LIVE_EXTENSION + this.url) );
					break;
					
				case LPAssetType.XML:
					this.xmlloader = new XMLLoader();
					this.xmlloader.load( LPSettings.LIVE_EXTENSION + this.url, this.onXMLLoad );
					break;
					
				case LPAssetType.THIRD:
				case LPAssetType.ZIP:
					var fz:FZipExtra = this.fzip = new FZipExtra();
					fz.formatAsBitmapData( ".jpg" );
					fz.formatAsBitmapData( ".JPG" );
					fz.formatAsBitmapData( ".gif" );
					fz.formatAsBitmapData( ".GIF" );
					fz.formatAsBitmapData( ".png" );
					fz.formatAsBitmapData( ".PNG" );
					fz.formatAsDisplayObject( ".swf" );
					fz.formatAsDisplayObject( ".SWF" );
					fz.addEventListener(Event.COMPLETE, this.onZipLoad, false, 0, true);
					var zip:FZip = new FZip();
					zip.load( new URLRequest(LPSettings.LIVE_EXTENSION + this.url) );
					fz.addZip( zip );
					break;
					
				case LPAssetType.JSON:
					JSONUtils.loadRemoteJSON( LPSettings.LIVE_EXTENSION + this.url, this.onJSONLoad );
					break;
			}
		}
		
		private function onJSONLoad( success:Boolean, data:Object ):void
		{
			this.data = data;
			
			if ( success )
			{
				trace( "LaunchPad", LPAsset, "Asset " + this.id + " loaded successfully" );
			}
			else
			{
				trace( "LaunchPad", LPAsset, "Error loading asset " + this.id );
			}
			
			if ( this.onLoadComplete != null )
			{
				var fn:Function = this.onLoadComplete;
				this.onLoadComplete = null;
				fn( success );
			}
		}
		
		private function onZipLoad( evt:Event ):void
		{
			evt.currentTarget.removeEventListener(Event.COMPLETE, this.onZipLoad);
			
			this.data = new Object();
			trace( "LaunchPad", LPAsset, "Asset " + this.id + " loaded successfully" );
			
			if ( this.onLoadComplete != null )
			{
				var fn:Function = this.onLoadComplete;
				this.onLoadComplete = null;
				fn( true );
			}
		}
		
		private function onXMLLoad( data:XML ):void
		{
			this.xmlloader = null;
			
			if ( data != null )
			{
				trace( "LaunchPad", LPAsset, "Asset " + this.id + " loaded successfully" );
				this.data = data;
				var success:Boolean = true;
			}
			else
			{
				trace( "LaunchPad", LPAsset, "Error loading asset " + this.id );
				success = false;
			}
			
			if ( this.onLoadComplete != null )
			{
				var fn:Function = this.onLoadComplete;
				this.onLoadComplete = null;
				fn( success );
			}
		}
		
		private function loadHandler(evt:Event):void
		{
			switch( evt.type )
			{
				case Event.COMPLETE:
					trace( "LaunchPad", LPAsset, "Asset " + this.id + " loaded successfully" );
					this.data = this.loader.content;
					var success:Boolean = true;
					break;
					
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					trace( "LaunchPad", LPAsset, "Error loading asset " + this.id );
					success = false;
					break;
			}
			
			this.killListeners();
			
			if ( this.onLoadComplete != null )
			{
				var fn:Function = this.onLoadComplete;
				this.onLoadComplete = null;
				fn( success );
			}
		}
		
		private function killListeners():void
		{
			if ( this.loader )
			{
				this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.loadHandler);
				this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.loadHandler);
				this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.loadHandler);
				this.loader = null;
			}
		}
		
		/**
		 * Obtains the current progress of the asset load
		 * @return	A number value between 0 and 1
		 */
		
		public function getLoadProgress():Number
		{
			if ( this.type == LPAssetType.SWF )
			{
				if ( this.loader )
				{
					if ( !this.loader.contentLoaderInfo.bytesTotal )	return 0;
					return this.loader.contentLoaderInfo.bytesLoaded / this.loader.contentLoaderInfo.bytesTotal;
				}
			}
			else if ( this.type == LPAssetType.XML )
			{
				if ( this.xmlloader )
				{
					return this.xmlloader.progress;
				}
			}
			
			if ( this.data )
			{
				return 1
			}
			else
			{
				return 0;
			}
		}
		
		/**
		 * Adds an LPAsset object to the LaunchPad asset library
		 * @param	asset	The LPAsset object to add
		 */
		
		public static function addAsset( asset:LPAsset ):void
		{
			if ( !assets )
			{
				assets = new Vector.<LPAsset>;
			}
			
			assets.push( asset );
		}
		
		/**
		 * Retrieves an LPAsset object from the LaunchPad library
		 * @param	id	The identifier of the asset object
		 * @return	An LPAsset object. Null if the object isn't found or the library is empty.
		 */
		
		public static function getAssetRecord( id:String ):LPAsset
		{
			if ( !assets )
			{
				return null;
			}
			
			for ( var i:uint = 0; i < assets.length; i++ )
			{
				if ( assets[i].id == id )
				{
					return assets[i];
				}
			}
			
			return null;
		}
		
		/**
		 * Retrieves all current assets in the LaunchPad asset library
		 * @return	A vector of LPAssets. Alteration of the resulting vector WILL alter the structure within LaunchPad.
		 */
		
		public static function getAllAssets():Vector.<LPAsset>
		{
			return assets;
		}
		
		/**
		 * Gets the next unloaded asset in the library that is not marked for postload
		 * @return	An LPAsset object that has not yet had it's data loaded.
		 */
		
		public static function getNextUnloadedAsset():LPAsset
		{
			if ( !assets )
			{
				return null;
			}
			else
			{
				for ( var i:uint = 0; i < assets.length; i++ )
				{
					if ( !assets[i].data && !assets[i].postload )
					{
						return assets[i];
					}
				}
			}
			
			return null;
		}
		
		public static function getNumAssets( unloaded_only:Boolean = false ):int
		{
			if ( !assets )
			{
				return 0;
			}
			else if ( !unloaded_only )
			{
				return assets.length;
			}
			else
			{
				var counter:int = 0;
				for ( var i:uint = 0; i < assets.length; i++ )
				{
					if ( !assets[i].data )
					{
						counter++;
					}
				}
				
				return counter;
			}
		}
		
		public static function getAsset( id:String = "", linkage:String = "" ):*
		{
			if ( id.length )
			{
				var lpasset:LPAsset = LPAsset.getAssetRecord( id );
				
				if ( !lpasset )
				{
					trace( "LaunchPad", LPAsset, "Retrieval of asset '" + id + "' failed. Could not be found." );
					return null;
				}
				
				if ( !linkage.length )
				{
					if ( lpasset.type == LPAssetType.THIRD || lpasset.type == LPAssetType.ZIP )
					{
						return lpasset.fzip;
					}
					else
					{
						return lpasset.data;
					}
				}
				else if ( lpasset.type == LPAssetType.THIRD || lpasset.type == LPAssetType.ZIP )
				{
					var asset:* = lpasset.fzip.getBitmapData(linkage);
					
					if ( !asset )
					{
						asset = lpasset.fzip.getSoundData(linkage);
						if ( asset )
						{
							var snd:Sound = new Sound();
							snd.loadCompressedDataFromByteArray( asset as ByteArray, (asset as ByteArray).length );
							return snd;
						}
					}
					
					if ( !asset )
					{
						asset = lpasset.fzip.getDisplayObject(linkage);
					}
					
					return asset;
				}
				else
				{
					var class_name:String = getQualifiedClassName(lpasset.data)
					class_name = class_name.substr( class_name.lastIndexOf("::") + 2 );
					if ( class_name == "LPAssetClient" )
					{
						if ( lpasset.data.assets[linkage] )
						{
							return duplicateDisplayObject( lpasset.data.assets[linkage] );
						}
						else
						{
							trace( "LaunchPad", LPAsset, "Retrieval of asset '" + id + "', linkage '" + linkage +"' failed. Could not be found." );
							return null;
						}
					}
					else
					{
						trace( "LaunchPad", LPAsset, "Retrieval of asset '" + id + "', linkage '" + linkage +"' failed. Asset type is '"+ lpasset.type +"' and does not handle linkage values." );
						return null;
					}
				}
			}
			else
			{
				var assets:Vector.<LPAsset> = LPAsset.getAllAssets();
				for ( var i:uint = 0; i < assets.length; i++ )
				{
					if ( assets[i].type == LPAssetType.ZIP || assets[i].type == LPAssetType.THIRD )
					{
						asset = assets[i].fzip.getBitmapData(linkage);
					
						if ( !asset )
						{
							asset = assets[i].fzip.getSoundData(linkage);
							if ( asset )
							{
								var snd:Sound = new Sound();
								snd.loadCompressedDataFromByteArray( asset as ByteArray, (asset as ByteArray).length );
								return snd;
							}
						}
						
						if ( !asset )
						{
							asset = assets[i].fzip.getDisplayObject(linkage);
						}
						
						if ( asset ) return asset;
					}
					else
					{
						class_name = getQualifiedClassName(assets[i].data)
						class_name = class_name.substr( class_name.lastIndexOf("::") + 2 );
						if ( class_name == "LPAssetClient" && assets[i].data.assets[linkage] )
						{
							return duplicateDisplayObject( assets[i].data.assets[linkage] );
						}
					}
				}
			}
			
			trace( "LaunchPad", LPAsset, "Retrieval of linkage '" + linkage + "' failed. Could not be found." );
			
			return null;
		}
		
		private static function duplicateDisplayObject( asset:* ):*
		{
			var super_type:String = getQualifiedSuperclassName( asset );
			
			switch ( super_type )
			{
				case "flash.display::MovieClip":
				case "flash.display::Sprite":
				case "flash.display::DisplayObject":
					return DuplicateDisplayObject.duplicate(asset);
					break;
					
				default:
					return asset;
			}
		}
		
		
	}

}