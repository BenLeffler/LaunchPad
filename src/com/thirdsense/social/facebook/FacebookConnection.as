package com.thirdsense.social.facebook 
{
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.Facebook;
	import com.thirdsense.settings.LPSettings;
	import com.thirdsense.utils.SmoothImageLoad;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	public class FacebookConnection 
	{
		private static var onComplete:Function;
		private static var onLogoutComplete:Function;
		private static var force_new:Boolean;
		private static var auto_only:Boolean;
		private static var appId:String;
		private static var connected:Boolean;
		private static var phase:int;
		private static var onAvatarLoad:Function;
		private static var onWallPost:Function;
		private static var container:MovieClip;
		private static var ping:uint;
		private static var ping_counter:int;
		
		public static function init( onComplete:Function=null, force_new_login:Boolean=false, auto_login_only:Boolean=false ):void
		{
			if ( ExternalInterface.available )
			{
				trace( "FacebookConnection.init" );
				
				FacebookConnection.appId = LPSettings.FACEBOOK_APP_ID;
				
				FacebookConnection.force_new = force_new_login;
				FacebookConnection.auto_only = auto_login_only;
				
				if ( onComplete != null )	FacebookConnection.onComplete = onComplete;
				
				Facebook.init( FacebookConnection.appId, FacebookConnection.onFacebookInit );
				
				phase = 0;
			}
			else
			{
				trace( "Call to Facebook.init failed as there is no external interface available" );
				onComplete(false);
			}
		}
		
		private static function onFacebookInit( success:Object, fail:Object ):void
		{
			trace( "FacebookConnection.onFacebookInit", success, fail );
			
			if ( success && success.uid == null )
			{
				success = null;
			}
			
			phase = 1;
			
			if ( success == null && !FacebookConnection.auto_only )
			{
				trace( "FacebookConnection.onFacebookInit - calling for login" );
				
				Facebook.login( FacebookConnection.onFacebookLogin, { scope:'email,publish_stream' } );
			}
			else if ( FacebookConnection.force_new && !FacebookConnection.auto_only )
			{
				trace( "FacebookConnection.onFacebookInit - calling for logout" );
				FacebookConnection.logout( FacebookConnection.init );
			}
			else
			{
				FacebookConnection.onFacebookLogin( success, null );
			}
		}
		
		public static function logout( onComplete:Function ):void
		{
			if ( onComplete != null )	FacebookConnection.onLogoutComplete = onComplete;
			
			Facebook.logout( FacebookConnection.onFacebookLogout );
		}
		
		private static function onFacebookLogin( success:Object, fail:Object ):void
		{
			trace( "FacebookConnection.onFacebookLogin", success, fail );
			
			if ( success && success.uid == null )
			{
				success = null;
			}
			
			FacebookConnection.connected = (success != null);
			
			if ( FacebookConnection.connected )
			{
				var session:FacebookSession = FacebookConnection.getUserSession();
				if ( session && session.user )
				{
					trace( "Connected to Facebook as user: " + session.user.name );
				}
				else if ( session )
				{
					trace( "Connected to Facebook as user id: " + session.uid );
				}
				else
				{
					trace( "Connect to Facebook, but user details unavailable for some reason" );
				}
			}
			else
			{
				trace( "Connection to Facebook failed. No existing session data" );
			}
			
			if ( !success && !fail && !auto_only )
			{
				trace( "Starting session ping" );
				ping = setTimeout( pingSession, 3000 );
				ping_counter = 30;
			}
			else if ( FacebookConnection.onComplete != null && FacebookConnection.phase > 0 )
			{
				if ( !FacebookConnection.connected )
				{
					var fn:Function = FacebookConnection.onComplete;
					FacebookConnection.onComplete = null;
					fn( FacebookConnection.connected );
				}
				else
				{
					FacebookConnection.getUser( FacebookConnection.onComplete );
				}
			}
		}
		
		private static function pingSession():void
		{
			var session:FacebookSession = getUserSession();
			if ( !session.uid )
			{
				ping_counter--;
				if ( ping_counter ) 
				{
					trace( "Session pinged. No connection yet" );
					ping = setTimeout( pingSession, 3000 );
					return void;
				}
				else
				{
					trace( "Session pinged. No connection and timed out. Login failed." );
					FacebookConnection.connected = false;
					
					var fn:Function = FacebookConnection.onComplete;
					FacebookConnection.onComplete = null;
					fn( FacebookConnection.connected );
				}
			}
			else
			{
				trace( "Session pinged. Connection found!" );
				FacebookConnection.connected = true;
				
				FacebookConnection.getUser( FacebookConnection.onComplete );
			}
			
		}
		
		public static function getUserSession():FacebookSession
		{
			if ( FacebookConnection.connected || Facebook.getAuthResponse() )
			{
				var session:FacebookSession = new FacebookSession();
				var auth:FacebookAuthResponse = Facebook.getAuthResponse();
				session.accessToken = auth.accessToken;
				session.uid = auth.uid;
				return session;
			} 
			else
			{
				return null;
			}
		}
		
		private static function onFacebookLogout():void
		{
			FacebookFriend.clear();
			
			if ( FacebookConnection.onLogoutComplete != null )
			{
				var fn:Function = FacebookConnection.onLogoutComplete;
				FacebookConnection.onLogoutComplete = null;
				fn();
			}
			
		}
		
		public static function isConnected():Boolean
		{
			return ( FacebookConnection.connected == true );
			
		}
		
		public static function getFriends( onComplete:Function, fields:Array = null ):void
		{
			FacebookConnection.onComplete = onComplete;
			
			if ( fields )
			{
				var field_str:String = fields.join(",");
			}
			else
			{
				field_str = "installed,name"
			}
			
			Facebook.api( "/me/friends", onGetFriends, { fields:field_str } );
			
			var session:FacebookSession = FacebookConnection.getUserSession();
			
			if ( session.user && !FacebookFriend.getMe() )
			{
				var user:Object = session.user;
				var friend:FacebookFriend = new FacebookFriend();
				friend.id = user.id;
				friend.name = user.name;
				friend.installed = true;
				for ( var str:String in user )
				{
					if ( !friend[str] )
					{
						friend[str] = user[str];
					}
				}
				FacebookFriend.addMe( friend );
			}
			
		}
		
		private static function onGetFriends( success:Object, fail:Object ):void
		{
			var fn:Function = FacebookConnection.onComplete;
			FacebookConnection.onComplete = null;
			
			if ( success != null )
			{
				FacebookFriend.processFromArray( success as Array );
			}
			
			fn( (success != null) );
			
		}
		
		public static function getUser( onComplete:Function ):void
		{
			FacebookConnection.onComplete = onComplete;
			Facebook.api( "me", onGetUser );
			
		}
		
		private static function onGetUser( success:Object, fail:Object ):void
		{
			var fn:Function = FacebookConnection.onComplete;
			FacebookConnection.onComplete = null;
			
			if ( success != null )
			{
				var friend:FacebookFriend = new FacebookFriend();
				friend.installed = true;
				
				for ( var str:String in success )
				{
					//ignore any unexpected fields
					try
					{
						friend[str] = success[str];
					}
					catch (e:*)
					{
						
					}
				}				
				FacebookFriend.addMe( friend );
			}
			
			fn( (success != null) );
		}
		
		public static function getUserAvatar( onComplete:Function, fbUserId:String="" ):Boolean
		{
			var session:FacebookSession = FacebookConnection.getUserSession();
			if ( session || fbUserId.length )
			{
				FacebookConnection.onAvatarLoad = onComplete;
				
				if ( !fbUserId.length )
				{
					fbUserId = session.uid;
				}
				
				container = new MovieClip();
				container.addEventListener(Event.COMPLETE, FacebookConnection.fbUserAvatarLoaded, false, 0, true);
				container.addEventListener(SmoothImageLoad.CANCEL_LOAD, FacebookConnection.cancelFbUserAvatarLoad, false, 0, true);
				SmoothImageLoad.imageLoad( "https://graph.facebook.com/" + fbUserId + "/picture?type=square", container, 50, 50, SmoothImageLoad.EXACT, true, true );
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private static function cancelFbUserAvatarLoad( evt:Event ):void
		{
			var container:MovieClip = evt.currentTarget as MovieClip;
			container.removeEventListener(Event.COMPLETE, FacebookConnection.fbUserAvatarLoaded);
			container.removeEventListener(SmoothImageLoad.CANCEL_LOAD, FacebookConnection.cancelFbUserAvatarLoad);
			
			var fn:Function = FacebookConnection.onAvatarLoad;
			FacebookConnection.onAvatarLoad = null;
			fn( null );
			
		}
		
		private static function fbUserAvatarLoaded( evt:Event ):void
		{
			var container:MovieClip = evt.currentTarget as MovieClip;
			container.removeEventListener(Event.COMPLETE, FacebookConnection.fbUserAvatarLoaded);
			container.removeEventListener(SmoothImageLoad.CANCEL_LOAD, FacebookConnection.cancelFbUserAvatarLoad);
			
			var bmp:Bitmap = new Bitmap( (container.getChildAt(0) as Bitmap).bitmapData.clone(), "auto", true );
			(container.getChildAt(0) as Bitmap).bitmapData.dispose();
			(container.getChildAt(0) as Bitmap).bitmapData = null
			container = null;
			
			var fn:Function = FacebookConnection.onAvatarLoad;
			FacebookConnection.onAvatarLoad = null;
			fn( bmp );
		}
		/**
		* Post to the FB wall
		 * 
		 * @param	picture		An image to attach to the post
		 * @param	postName	The name of the post
		 * @param	link		The link that will open when users click on the post name
		 * @param	caption		The text that sits right afer the post name
		 * @param	description	The text that sits right afer the post caption
		 * @param	message		An optional field that was be used to add a message typed by the user
		 * @param	onComplete	The function to return the result of the post to. Function must include a parameter that accepts a boolean value - true if successful, false otherwise
		 * 
		 * @return
		 */
		
		public static function postToWall(picture:String, postName:String, link:String, caption:String, description:String, message:String = null, onComplete:Function=null):Boolean
		{
			if ( !FacebookConnection.getUserSession() ) return false;
			
			var post:Object = { name:postName, picture:picture, link:link, caption:caption, description:description };
			FacebookConnection.onWallPost = onComplete;
			
			if ( message ) post.message = message;
			
			Facebook.api("/me/feed", FacebookConnection.onFacebookPost, post, "POST");
			
			return true;
		}
		
		private static function onFacebookPost(result:Object, fail:Object):void
		{
			if ( FacebookConnection.onWallPost != null ) {
				
				var fn:Function = FacebookConnection.onWallPost;
				FacebookConnection.onWallPost = null;
				
				if ( result != null ) {
					fn( true );
				} else {
					fn( false );
				}
				
			}
		}
		
	}

}