package com.thirdsense.core 
{
	import com.thirdsense.data.LPAsset;
	import com.thirdsense.data.LPValue;
	import com.thirdsense.net.Analytics;
	import com.thirdsense.settings.LPSettings;
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class LPConfig 
	{
		private var data:XML;
		
		public function LPConfig()
		{
			
		}
		
		public final function parse( data:XML ):void
		{
			this.data = data;
			parseApplication();
			parseAssets();
			parseValues();
			parseAnalytics();
		}
		
		private function parseAssets():void
		{
			for ( var i:uint = 0; this.data.asset[i]; i++ )
			{
				var asset:LPAsset = new LPAsset();
				asset.id = String( this.data.asset[i].@id );
				asset.label = String( this.data.asset[i].@label );
				asset.url = String( this.data.asset[i].@url );
				asset.postload = ( String(this.data.asset[i].@postload).toLowerCase() == "true" );
				LPAsset.addAsset( asset );
			}
			
		}
		
		private function parseValues():void
		{
			for ( var i:uint = 0; this.data.value[i]; i++ )
			{
				var value:LPValue = new LPValue();
				value.name = String( this.data.value[i].@name );
				value.value = String( this.data.value[i].@value );
				LPValue.addValue( value );
			}
		}
		
		private function parseAnalytics():void
		{
			if ( this.data.analytics && String(this.data.analytics.@tracking_id).length )
			{
				LPSettings.ANALYTICS_TRACKING_ID = String( this.data.analytics.@tracking_id );
				Analytics.init();
			}
		}
		
		private function parseApplication():void
		{
			if ( this.data.application )
			{
				LPSettings.APP_NAME = String( this.data.application.@name );
				LPSettings.APP_VERSION = String( this.data.application.@version );
				LPSettings.FORCE_MOBILE_PROFILE = Boolean( this.data.application.@force_mobile_profile );
			}
		}
		
	}

}