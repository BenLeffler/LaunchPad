package com.thirdsense.data 
{
	import com.thirdsense.utils.getDefinitionNames;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	
	/**
	 * <p>Client class to be used with an asset swf to allow the LaunchPad framework access to it's library linkaged MovieClips, Sprites and Sounds. </p>
	 * <p>Simply call to LPAssetClient.start root timeline of your swf library, compile and reference the swf location in the core LaunchPad project's config.xml</p>
	 * <listing>
	 * import com.thirdsense.data.LPAssetClient;
	 * 
	 * LPAssetClient.start( this );</listing>
	 * <p>For IOS devices, you will need to pass through the linkage names of library assets as an array because the Loader class is not able to auto-detect lib items.</p>
	 * <listing>
	 * LPAssetClient.start( this, ["linkage_one", "linkage_two", "linkage_three"] );</listing>
	 * @author Ben Leffler
	 */
	
	public dynamic class LPAssetClient extends MovieClip 
	{
		private var assets:Object;
		private var linkage:Array;
		
		/**
		 * @private Initializes the calling swf as a LaunchPad asset client. For general use, it's better to use the static start() function.
		 * @param	target	The root of the swf to prepare as a client
		 * @param	asset_names	For IOS devices, you will need to provide the manifest of linkage names. Pass this through as an array of strings in this param
		 */
		
		public function LPAssetClient( target:MovieClip = null, asset_names:Array = null ) 
		{
			if ( ExternalInterface.available ) {
				Security.allowDomain("*");
			}
			
			this.assets = new Object();
			
			if ( asset_names != null )
			{
				while ( asset_names.length ) this.addAsset( asset_names.shift() );
			}
			else
			{
				if ( !target )
				{
					target = this;
					this.linkage = getDefinitionNames( super.loaderInfo );
				}
				else
				{
					this.linkage = getDefinitionNames( target.loaderInfo );
				}
				
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
			this.assets[linkage] = DynamicClass;
		}
		
		/**
		 * @private	Returns an item from the assets package
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
		 * @private	Lists the available library item names in the asset client
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
		
		/**
		 * Initializes the LPAssetClient library for use with the LaunchPad framework. Once the swf that this is called from is loaded by LaunchPad, the client will auto-populate with library assets
		 * @param	root	The root timeline of the external swf
		 * @param	asset_names	For IOS devices, you will need to pass through an array of the asset linkage names as limitations to the Loader class prevent auto-detection of library linkage items.
		 */
		
		public static function start( root:MovieClip, asset_names:Array = null ):void
		{
			root.arr = asset_names;
			root.loaderInfo.addEventListener( Event.COMPLETE, completeHandler, false, 0, true );
			
		}
		
		/**
		 * @private
		 */
		
		private static function completeHandler( evt:Event ):void
		{
			evt.currentTarget.removeEventListener( Event.COMPLETE, completeHandler );
			
			var loaderInfo:LoaderInfo = evt.currentTarget as LoaderInfo;
			var target:MovieClip = loaderInfo.content as MovieClip;
			target.client = new LPAssetClient( target, target.arr );
		}
		
	}

}