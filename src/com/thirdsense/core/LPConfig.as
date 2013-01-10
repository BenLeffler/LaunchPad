package com.thirdsense.core 
{
	import com.thirdsense.data.LPAsset;
	import com.thirdsense.data.LPValue;
	import com.thirdsense.net.Analytics;
	import com.thirdsense.settings.LPSettings;
	import com.thirdsense.social.FacebookInterface;
	import flash.external.ExternalInterface;
	import flash.system.Security;
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
			parseFacebook();
			parsePolicies();
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
			var value:LPValue;
			
			for ( var i:uint = 0; this.data.value[i]; i++ )
			{
				value = new LPValue();
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
		
		private function parseFacebook():void
		{
			if ( this.data.facebook && String(this.data.facebook.@appId).length )
			{
				LPSettings.FACEBOOK_APP_ID = String( this.data.facebook.@appId );
				LPSettings.FACEBOOK_REDIRECT_URL = String( this.data.facebook.@redirect_url );
				LPSettings.FACEBOOK_WALLPIC_URL = String( this.data.facebook.@wallpic_url );
				LPSettings.FACEBOOK_PERMISSIONS = new Array();
				for ( var i:uint = 0; this.data.facebook.permission[i]; i++ )
				{
					LPSettings.FACEBOOK_PERMISSIONS.push( this.data.facebook.permission[i] );
				}
				FacebookInterface.clearConstructors();
			}
		}
		
		private function parsePolicies():void
		{
			if ( ExternalInterface.available )
			{
				for ( var i:uint = 0; this.data.policy[i]; i++ )
				{
					trace( "LaunchPad", LPConfig, "Loading policy from " + this.data.policy[i].@url );
					Security.loadPolicyFile( this.data.policy[i].@url );
				}
			}
		}
		
		private function parseApplication():void
		{
			if ( this.data.application )
			{
				LPSettings.APP_NAME = String( this.data.application.@name );
				LPSettings.APP_VERSION = String( this.data.application.@version );
				LPSettings.FORCE_MOBILE_PROFILE = ( String(this.data.application.@force_mobile_profile) == "true" );
			}
		}
		
	}

}