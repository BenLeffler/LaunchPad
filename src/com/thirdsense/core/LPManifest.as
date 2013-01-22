package com.thirdsense.core 
{
	import com.thirdsense.animation.SpriteSequence;
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.data.LPLocalData;
	import com.thirdsense.display.Logo;
	import com.thirdsense.LaunchPad;
	import com.thirdsense.settings.IOSDevices;
	import com.thirdsense.social.facebook.FacebookFriendField;
	import com.thirdsense.sound.SoundLabel;
	import com.thirdsense.sound.SoundShape;
	import com.thirdsense.sound.SoundStream;
	import com.thirdsense.ui.menu.LPBaseMenu;
	import com.thirdsense.ui.menu.LPMenu;
	import com.thirdsense.ui.starling.LPsButton;
	import com.thirdsense.ui.starling.LPsCheckList;
	import com.thirdsense.ui.starling.LPsRadioButton;
	import com.thirdsense.ui.starling.LPsSelectList;
	import com.thirdsense.ui.starling.LPsWebBrowser;
	import com.thirdsense.ui.starling.menu.LPMenuTransition;
	import com.thirdsense.ui.starling.menu.LPsBaseMenu;
	import com.thirdsense.ui.starling.menu.LPsMenu;
	import com.thirdsense.ui.starling.ScrollControl;
	import com.thirdsense.utils.DeviceCamera;
	import com.thirdsense.utils.getDefinitionNames;
	import com.thirdsense.utils.IsoTools;
	import com.thirdsense.utils.Landscape;
	import com.thirdsense.utils.StringTools;
	import com.thirdsense.utils.Trig;
	
	/**
	 * @private
	 */
	
	public class LPManifest 
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
		
		public function LPManifest() 
		{
			getDefinitionNames(null);
			
		}
		
	}

}