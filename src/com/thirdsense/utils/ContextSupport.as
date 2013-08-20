package com.thirdsense.utils 
{
	import com.thirdsense.LaunchPad;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import flash.display3D.Context3DProfile;
	
	/**
	 * Altered class from Jeff (Jamikada) which determines what Context3DProfile to use at runtime for the device your project is running on. This class only support Air 3.8 and above
	 * @author Ben Leffler
	 */
	public class ContextSupport 
	{
		// simple easy shared access to callback and current attempted profile
		private static var supportsCallback:Function;
		private static var checkingProfile:String;
		private static var phase:int = 0;
		static private var onResult:Function;
		
		/**
		 * Obtains the correct Context3DProfile to use for your device. If no Stage3D support is available, an exception is thrown.
		 * @param	onResult	Callback function to return the profile type to. The function must accept a String as it's parameter.
		 */
		
		public static function getSupportedProfile( onResult:Function ):void
		{
			if ( onResult != null ) ContextSupport.onResult = onResult;
			
			switch ( phase )
			{
				case 0:
					supportsProfile( LaunchPad.instance.nativeStage, Context3DProfile.BASELINE_EXTENDED, supportHandler );
					phase++;
					break;
					
				case 1:
					setTimeout( supportsProfile, 100, LaunchPad.instance.nativeStage, Context3DProfile.BASELINE, supportHandler );
					phase++;
					break;
					
				case 2:
					setTimeout( supportsProfile, 100, LaunchPad.instance.nativeStage, Context3DProfile.BASELINE_CONSTRAINED, supportHandler );
					phase++;
					break;
					
				case 3:
					throw new ArgumentError( "Failed to create a Context3D profile - Starling may not be supported on this device" );
					break;
			}
			
		}
		
		/**
		 * @private
		 * @param	profile
		 * @param	success
		 */
		
		private static function supportHandler( profile:String, success:Boolean ):void
		{
			if ( success )
			{
				var fn:Function = onResult;
				onResult = null;
				fn( profile );
			}
			else
			{
				getSupportedProfile( null );
			}
		}
		
		/**
		 * Checks the device for compatibility with a specific Context3DProfile type
		 * @param	nativeStage	The native display list stage
		 * @param	profile	The profile to check against
		 * @param	callback	Function to call back to. It must accept a String and Boolean value indicating the profile and success as params.
		 */
		
		public static function supportsProfile( nativeStage:Stage, profile:String, callback:Function ):void
		{
			supportsCallback = callback;
			checkingProfile = profile;
			
			if ( nativeStage.stage3Ds.length > 0 ) 
			{
				var stage3D:Stage3D = nativeStage.stage3Ds[ 0 ];    
				stage3D.addEventListener( Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener, false, 10, true );
				stage3D.addEventListener( ErrorEvent.ERROR, supportsProfileContextErroredListener, false, 10, true );
				
				try
				{
					stage3D.requestContext3D( "auto", profile ); 
				}
				catch ( e:Error )
				{
					stage3D.removeEventListener( Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener ); 
					stage3D.removeEventListener( ErrorEvent.ERROR, supportsProfileContextErroredListener ); 
					
					if ( supportsCallback != null )
					{
						supportsCallback( checkingProfile, false );
					}
				}
				
			}
			else
			{
				// no Stage3D instances
				if ( supportsCallback != null )
				{
					supportsCallback( checkingProfile, false );
				}
			}
		}
		
		/**
		 * @private
		 * @param	event
		 */
		
		private static function supportsProfileContextErroredListener( event:ErrorEvent ):void 
		{
			var targetStage3D:Stage3D = event.target as Stage3D;
			
			if ( targetStage3D )
			{
				targetStage3D.removeEventListener( flash.events.Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener ); 
				targetStage3D.removeEventListener( ErrorEvent.ERROR, supportsProfileContextErroredListener ); 
			}
			
			if ( supportsCallback != null )
			{
				supportsCallback( checkingProfile, false );
			}
		}
		
		/**
		 * @private
		 * @param	event
		 */
		private static function supportsProfileContextCreatedListener( event:Event ):void 
		{
			var targetStage3D:Stage3D = event.target as Stage3D;
			
			if ( targetStage3D )
			{
				targetStage3D.removeEventListener( Event.CONTEXT3D_CREATE, supportsProfileContextCreatedListener ); 
				targetStage3D.removeEventListener( ErrorEvent.ERROR, supportsProfileContextErroredListener ); 
				
				if ( targetStage3D.context3D )
				{
					// the context is recreated as long as there are listeners on it, but there shouldn't be here.
					// Beginning with AIR 3.6, we can guarantee that with an additional parameter of false.
					var disposeContext3D:Function = targetStage3D.context3D.dispose;
					
					if ( disposeContext3D.length == 1 )
					{
						disposeContext3D( false );
					}
					else
					{
						disposeContext3D();
					}
					
					if ( supportsCallback != null )
					{
						supportsCallback( checkingProfile, true );
					}
				}
			}
		}
		
	}

}