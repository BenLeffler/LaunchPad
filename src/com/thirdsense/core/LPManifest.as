package com.thirdsense.core 
{
	import com.thirdsense.animation.GlideConstruct;
	import com.thirdsense.animation.GlideExaminer;
	import com.thirdsense.animation.SpriteSequence;
	import com.thirdsense.animation.SpriteSheetHelper;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.data.LPLocalData;
	import com.thirdsense.display.Logo;
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.IOSDevices;
	import com.thirdsense.social.facebook.FacebookFriendField;
	import com.thirdsense.sound.SoundLabel;
	import com.thirdsense.sound.SoundShape;
	import com.thirdsense.sound.SoundStream;
	import com.thirdsense.starfx.DisplaceWave;
	import com.thirdsense.ui.display.LPAppUI;
	import com.thirdsense.ui.display.LPButton;
	import com.thirdsense.ui.display.menu.LPBaseMenu;
	import com.thirdsense.ui.display.menu.LPMenu;
	import com.thirdsense.ui.GenericAlert;
	import com.thirdsense.ui.GenericPrompt;
	import com.thirdsense.ui.starling.DragControl;
	import com.thirdsense.ui.starling.LPsAppUI;
	import com.thirdsense.ui.starling.LPsButton;
	import com.thirdsense.ui.starling.LPsCheckList;
	import com.thirdsense.ui.starling.LPsRadioButton;
	import com.thirdsense.ui.starling.LPsSelectList;
	import com.thirdsense.ui.starling.LPsWebBrowser;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.ui.starling.menu.LPsBackground;
	import com.thirdsense.ui.starling.menu.LPsBaseMenu;
	import com.thirdsense.ui.starling.menu.LPsMenu;
	import com.thirdsense.ui.starling.ScrollControl;
	import com.thirdsense.ui.starling.SwipeControl;
	import com.thirdsense.utils.ContextSupport;
	import com.thirdsense.utils.DeviceCamera;
	import com.thirdsense.utils.getDefinitionNames;
	import com.thirdsense.utils.IsoTools;
	import com.thirdsense.utils.Landscape;
	import com.thirdsense.utils.StringTools;
	import com.thirdsense.utils.Trig;
	import flash.display.MovieClip;
	
	/**
	 * @private
	 */
	
	public class LPManifest extends MovieClip
	{
		private var launchpad:LaunchPad;
		private var sprite_sequence:SpriteSequence;
		private var texture_pack:TexturePack;
		private var ios_devices:IOSDevices;
		private var sound_stream:SoundStream;
		private var sound_shape:SoundShape;
		private var sound_label:SoundLabel;
		private var trig:Trig;
		private var facebook_friend_field:FacebookFriendField;
		private var lps_menu:LPsMenu;
		private var lp_menu:LPMenu;
		private var lp_menu_transition:LPMenuTransition
		private var iso_tools:IsoTools;
		private var landscape:Landscape;
		private var lps_base_menu:LPsBaseMenu;
		private var lp_base_menu:LPBaseMenu;
		private var lps_button:LPsButton;
		private var scroll_control:ScrollControl;
		private var device_camera:DeviceCamera;
		private var lps_web_browser:LPsWebBrowser;
		private var lps_check_list:LPsCheckList;
		private var lps_select_list:LPsSelectList;
		private var lps_radio_button:LPsRadioButton;
		private var string_tools:StringTools;
		private var logos:Logo;
		private var lp_local_data:LPLocalData;
		private var lp_button:LPButton;
		private var lps_backgrounds:LPsBackground;
		private var glide_construct:GlideConstruct;
		private var glide_examiner:GlideExaminer;
		private var lp_app_ui:LPAppUI;
		private var drag_control:DragControl;
		private var lps_app_ui:LPsAppUI;
		private var swipe_control:SwipeControl;
		private var generic_alert:GenericAlert;
		private var generic_prompt:GenericPrompt;
		private var displace_wave:DisplaceWave;
		private var context_support:ContextSupport;
		private var sprite_sheet_helper:SpriteSheetHelper;
		
		public function LPManifest() 
		{
			getDefinitionNames(null);
			
		}
		
	}

}