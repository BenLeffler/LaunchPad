package com.thirdsense.data 
{
	import com.thirdsense.utils.getDefinitionNames;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.net.LocalConnection;
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedSuperclassName;
	
	/**
	 * <p>Client class to be used with an asset swf to allow the LaunchPad framework access to it's library linkaged MovieClips, Sprites and Sounds. </p>
	 * <p>Simply create a new LPAssetClient instance on the main timeline of your swf library, compile and reference the swf location in the core LaunchPad project's config.xml</p>
	 * <listing>
	 * import com.thirdsense.data.LPAssetClient;
	 * 
	 * var client:LPAssetClient = new LPAssetClient( this );
	 * </listing>
	 * @author Ben Leffler
	 */
	
	public dynamic class LPAssetClient extends MovieClip 
	{
		private var assets:Object;
		private var linkage:Array;
		
		/**
		 * Initializes the calling swf as a LaunchPad asset client
		 * @param	target	The root of the swf to prepare as a client
		 * @param	asset_names	For IOS devices, you will need to provide the manifest of linkage names. Pass this through as an array of strings in this param
		 */
		
		public function LPAssetClient( target:MovieClip = null, asset_names:Array = null ) 
		{
			if ( ExternalInterface.available ) {
				Security.allowDomain("*");
			}
			
			if ( !target ) target = this;
			
			if ( !target )
			{
				this.linkage = getDefinitionNames( super.loaderInfo );
			}
			else
			{
				this.linkage = getDefinitionNames( target.loaderInfo );
			}
			
			this.assets = new Object();
			
			if ( asset_names != null )
			{
				while ( asset_names.length ) this.addAsset( asset_names.shift() );
			}
			else
			{
				for (var i:uint=0; i<linkage.length; i++) {
					var str:String = String(linkage[i]);
					if (str != "Finder" && str != "SWFByteArray" && str.indexOf(":") < 0) {
						this.addAsset( String(linkage[i]) );
					}
				}
			}
			
			if ( target ) 
			{
				target.assets = this.assets;
				target.listLibraryItems = this.listLibraryItems;
			}
		}
		
		/**
		 * @private
		 */
		
		private function addAsset(linkage:String):void
		{
			var DynamicClass:Class = getDefinitionByName(linkage) as Class;
			var super_type:String = getQualifiedSuperclassName( DynamicClass );
			
			switch ( super_type ) 
			{
				case "flash.display::MovieClip":
					var mc:MovieClip = new DynamicClass();
					this.assets[linkage] = mc;
					break;
					
				case "flash.display::Sprite":
					var spr:Sprite = new DynamicClass();
					this.assets[linkage] = spr;
					break;
					
				case "flash.display::DisplayObject":
					var dispObj:DisplayObject = new DynamicClass();
					this.assets[linkage] = dispObj;
					break;
					
				case "flash.media::Sound":
					var snd:Sound = new DynamicClass();
					this.assets[linkage] = snd;
					break;
				
			}
			
		}
		
		/**
		 * Returns an item from the assets package
		 * @param	linkage	The name of the item to retrieve (A call to listLibraryItems() will give you a list of what's available)
		 * @return	The requested item. If no item exists with the passed name, returns null
		 */
		
		public function getItem( linkage:String ):Object
		{
			if ( assets[linkage] )
			{
				return assets[linkage];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Lists the available library item names in the asset client
		 * @param	omit_trace	Pass as true if you don't want to trace out the result
		 * @return	An array of library item names available through the LaunchPad getAsset() call
		 */
		
		public function listLibraryItems( omit_trace:Boolean = false ):Array
		{
			var arr:Array = new Array();
			for (var i:uint = 0; i < this.linkage.length; i++) {
				var str:String = String( this.linkage[i] );
				if (str != "Finder" && str != "SWFByteArray" && str.indexOf(":") < 0) {
					arr.push( str );
				}
			}
			
			arr.sort();
			
			if ( !omit_trace ) {
				str = arr.join("\n");
				trace( str );
			}
			
			return arr;
		}
		
	}

}