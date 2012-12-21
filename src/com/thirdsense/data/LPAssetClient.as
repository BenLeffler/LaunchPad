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
	 * Client constructor class to be used with the Asset swf to allow access to the Launchpad Assets class
	 * @author Ben Leffler
	 */
	
	public dynamic class LPAssetClient extends MovieClip 
	{
		public var assets:Object = new Object();
		public var linkage:Array;
		
		public function LPAssetClient() 
		{
			if ( ExternalInterface.available ) {
				Security.allowDomain("*");
			}
			
			this.linkage = getDefinitionNames( super.loaderInfo );
			
			for (var i:uint=0; i<linkage.length; i++) {
				var str:String = String(linkage[i]);
				if (str != "Finder" && str != "SWFByteArray" && str.indexOf(":") < 0) {
					this.addAsset( String(linkage[i]) );
				}
			}
		}
		
		private function addAsset(linkage:String):void
		{
			var DynamicClass:Class = getDefinitionByName(linkage) as Class;
			var super_type:String = getQualifiedSuperclassName( DynamicClass );
			
			switch ( super_type ) {
				
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
		
	}

}