package com.thirdsense.ui 
{
	import com.thirdsense.LaunchPad;
	import com.thirdsense.ui.display.LPButton;
	import com.thirdsense.utils.AdjustColors;
	import com.thirdsense.utils.Trig;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	
	/**
	 * <p>A LaunchPad generic ui prompt which can be customized to your application colour palette and appearance. </p>
	 * <p>This object can be called for use with either the LPAppUI class or the LPsAppUI Starling class as follows:</p>
	 * <listing>
	 * LPAppUI.addPrompt( "My Prompt Heading", "This is the body of the prompt which will convey important information", null, this.onPromptComplete );
	 * 
	 * function onPromptComplete():void
	 * {
	 * 	trace( "The user tapped the button" );
	 * }</listing>
	 * <p>As I have passed null in the above call, an unaltered generic prompt ui element is displayed. But if you want to customize the element to better
	 * suit the design of your project, you can alter the prompt element and call it as follows:</p>
	 * <listing>
	 * // create a custom prompt with 'yes' and 'no' as my button labels
	 * var prompt:GenericPrompt = new GenericPrompt();
	 * prompt.setButtonLabels( ["Yes", "No"] );
	 * 
	 * // define my alterations to the look of the element to better match my project
	 * GenericPrompt.heading_font_size = 18;
	 * GenericPrompt.heading_font_color = 0xDDDDDD;
	 * GenericPrompt.button_hue = 120;
	 * GenericPrompt.button_saturation = -50;
	 * 
	 * // call my custom prompt from anywhere in my project.
	 * LPAppUI.addPrompt( "My Prompt Heading", "This is the body of the prompt which will convey important information", prompt, this.onPromptComplete );</listing>
	 * <p>You can also pass through your own MovieClip as a custom prompt, as long as it contains two textfields named 'heading' and 'copy' and it contains
	 * two MovieClips to serve as the element buttons, named 'ok_button' and 'cancel_button'</p>
	 * <listing>
	 * LPAppUI.addPrompt( "My Prompt Heading", "This is the body of the prompt which will convey important information", new myMovieClip(), this.onPromptComplete );</listing>
	 * @author Ben Leffler
	 */
	
	public class GenericPrompt extends MovieClip 
	{
		/**
		 * The font family to use for the heading
		 */
		public static var heading_font:String = "Arial Rounded MT Bold";
		
		/**
		 * The font size of the heading
		 */
		public static var heading_font_size:int = 22;
		
		/**
		 * The font color of the heading
		 */
		public static var heading_font_color:uint = 0xFFFFFF;
		
		/**
		 * The color of the drop shadow that will be used on the heading textfield
		 */
		public static var heading_shadow_color:uint = 0x000000;
		
		/**
		 * The gradient (top-to-bottom linear) colors to be used for the heading background band
		 */
		public static var heading_background_gradient:Array = [ 0xBBBBBB, 0xAAAAAA ];
		
		/**
		 * The gradient (top-to-bottom linear) colors to be used for the main background box
		 */
		public static var background_gradient:Array = [ 0xFFFFFF, 0xE5E5E5 ];
		
		/**
		 * The color of the stroke to be used on the main background box (will be 1 pixel wide)
		 */
		public static var background_stroke_color:uint = 0xFFFFFF;
		
		/**
		 * The font family to use for the element copy
		 */
		public static var copy_font:String = "Arial Rounded MT Bold";
		
		/**
		 * The font size to use for the element copy
		 */
		public static var copy_font_size:int = 18;
		
		/**
		 * The font color to use for the element copy
		 */
		public static var copy_font_color:uint = 0x999999;
		
		/**
		 * The button hue value to apply to the element's button ColorMatrixFilter
		 */
		public static var button_hue:int = 0;
		
		/**
		 * The button saturation value to apply to the element's button ColorMatrixFilter
		 */
		public static var button_saturation:int = 0;
		
		/**
		 * The heading textfield object
		 */
		public var heading:TextField;
		
		/**
		 * The main copy textfield object
		 */
		public var copy:TextField;
		
		/**
		 * The MovieClip that will serve as the OK Button
		 */
		public var ok_button:MovieClip;
		
		/**
		 * The MovieClip that will serve as the CANCEL Button
		 */
		public var cancel_button:MovieClip;
		
		private var element_width:int = 360;
		private var labels:Array;
		
		/**
		 * Constructor
		 */
		
		public function GenericPrompt() 
		{
			
		}
		
		/**
		 * Sets the copy that appears on the buttons
		 * @param	labels	An array of strings that will appear on the buttons from left to right. The array passed will only use the data in index 0 and 1.
		 */
		
		public function setButtonLabels( labels:Array ):void
		{
			this.labels = labels;
		}
		
		/**
		 * Creates the prompt element
		 * @param	heading	The text that will appear in the heading field
		 * @param	copy	The text that will appear in the copy field
		 */
		
		public function create( heading:String, copy:String ):void
		{
			if ( this.element_width > LaunchPad.instance.nativeStage.stageWidth - 20 )
			{
				this.element_width = LaunchPad.instance.nativeStage.stageWidth - 20;
			}
			
			this.createBG();
			this.createHeadingBG();
			this.createHeadingText( heading );
			this.createCopyText( copy );
			this.createButtons();
		}
		
		/**
		 * @private
		 */
		
		private function createBG():void
		{
			var spr:Sprite = new Sprite();
			var mat:Matrix = new Matrix();
			mat.createGradientBox( this.element_width, 320, Trig.toRadians(90) );
			spr.graphics.beginGradientFill( GradientType.LINEAR, background_gradient, [1, 1], [80, 255], mat );
			spr.graphics.lineStyle( 1, background_stroke_color, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER );
			spr.graphics.drawRect( 0, 0, this.element_width, 320 );
			spr.graphics.endFill();
			spr.name = "BG";
			spr.filters = [ new DropShadowFilter(2, 45, 0, 1, 3, 3, 0.25, 3) ];
			this.addChild( spr );
		}
		
		/**
		 * @private
		 */
		
		private function createHeadingBG():void
		{
			var spr:Sprite = new Sprite();
			var mat:Matrix = new Matrix();
			mat.createGradientBox( this.element_width - 10, 50, Trig.toRadians(90) );
			spr.graphics.beginGradientFill( GradientType.LINEAR, heading_background_gradient, [1, 1], [50, 255], mat );
			spr.graphics.drawRect( 0, 0, this.element_width - 10, 50 );
			spr.graphics.endFill();
			spr.x = 5;
			spr.y = 5;
			spr.name = "HeadingBG";
			this.addChild( spr );
		}
		
		/**
		 * @private
		 */
		
		private function createHeadingText( text:String ):void
		{
			var tf:TextFormat = new TextFormat( heading_font, heading_font_size, heading_font_color, null, null, null, null, null, TextFormatAlign.CENTER );
			var spr:Sprite = this.getChildByName( "HeadingBG" ) as Sprite;
			
			this.heading = new TextField();
			this.heading.embedFonts = true;
			this.heading.defaultTextFormat = tf;
			this.heading.text = text;
			this.heading.multiline = false;
			this.heading.autoSize = TextFieldAutoSize.CENTER;
			this.heading.filters = [ new BlurFilter(1.05, 1.05, 3), new DropShadowFilter( 2, 45, heading_shadow_color, 1, 3, 3, 0.25, 3) ];
			this.heading.x = spr.x + (spr.width - this.heading.width) / 2;
			this.heading.y = spr.y + (spr.height - this.heading.height) / 2;
			this.addChild( this.heading );
		}
		
		/**
		 * @private
		 */
		
		private function createCopyText( text:String ):void
		{
			var tf:TextFormat = new TextFormat( copy_font, copy_font_size, copy_font_color, null, null, null, null, null, TextFormatAlign.CENTER );
			var spr:Sprite = this.getChildByName( "HeadingBG" ) as Sprite;
			
			this.copy = new TextField();
			this.copy.embedFonts = true;
			this.copy.defaultTextFormat = tf;
			this.copy.multiline = true;
			this.copy.wordWrap = true;
			this.copy.width = this.element_width - 20;
			this.copy.text = text;
			this.copy.autoSize = TextFieldAutoSize.CENTER;
			this.copy.x = 10;
			this.copy.y = spr.y + spr.height + 10;
			this.copy.filters = [ new BlurFilter(1.05, 1.05, 3) ];
			this.addChild( this.copy );
			
			spr = this.getChildByName( "BG" ) as Sprite;
			spr.height = this.copy.y + this.copy.height + 70;
		}
		
		/**
		 * @private
		 */
		
		private function createButtons():void
		{
			var spr:Sprite = this.getChildByName( "HeadingBG" ) as Sprite;
			var w:Number = (spr.width - 5) / 2;
			
			var cl:Class = getDefinitionByName( "lp_button1" ) as Class;
			var mc:MovieClip = new cl();
			
			this.labels && this.labels.length ? mc.label_txt.text = this.labels[0] : mc.label_txt.text = "OK";
			mc.label_txt.scaleX = mc.bg.width / w;
			mc.label_txt.autoSize = TextFieldAutoSize.CENTER;
			mc.label_txt.x = mc.bg.width - mc.label_txt.width >> 1;
			mc.width = w;
			mc.x = spr.x;
			mc.y = this.getChildByName( "BG" ).height - 5 - mc.height;
			this.addChild( mc );
			this.ok_button = mc;
			
			mc = new cl();
			this.labels && this.labels.length > 1 ? mc.label_txt.text = this.labels[1] : mc.label_txt.text = "CANCEL";
			mc.label_txt.scaleX = mc.bg.width / w;
			mc.label_txt.autoSize = TextFieldAutoSize.CENTER;
			mc.label_txt.x = mc.bg.width - mc.label_txt.width >> 1;
			mc.width = w;
			mc.x = this.ok_button.x + this.ok_button.width + 5;
			mc.y = this.getChildByName( "BG" ).height - 5 - mc.height;
			this.addChild( mc );
			this.cancel_button = mc;
			
			this.ok_button.filters = [ AdjustColors.HSB(button_hue, button_saturation) ];
			this.cancel_button.filters = [ AdjustColors.HSB(button_hue, button_saturation) ];
			
			this.ok_button.gotoAndStop(1);
			this.cancel_button.gotoAndStop(1);
		}
		
	}

}