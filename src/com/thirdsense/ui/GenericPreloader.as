package com.thirdsense.ui 
{
	import com.thirdsense.LaunchPad;
	import com.thirdsense.utils.AdjustColors;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	public class GenericPreloader extends MovieClip 
	{
		private var bg:Sprite;
		public var bar:Sprite;
		public var copy:TextField;
		public var label:TextField;
		
		public function GenericPreloader() 
		{
			this.create();
		}
		
		private function create():void
		{
			this.createBackground();
			this.createBar();
			this.createText();
			this.createLabel();
		}
		
		private function createBackground():void
		{
			this.bg = new Sprite();
			
			var spr:Sprite = new Sprite();
			spr.graphics.beginFill( 0xFFFFFF, 1 );
			spr.graphics.drawRect( 0, 0, 260, 35 );
			spr.graphics.endFill();
			this.bg.addChild( spr );
			
			var spr2:Sprite = new Sprite();
			spr2.graphics.beginFill( 0xB8CD00, 1 );
			spr2.graphics.drawRect( 0, 0, 245, 21 );
			spr2.graphics.endFill();
			spr2.filters = [ new DropShadowFilter(15, 270, 0xCEE600, 1, 0, 15, 1, 1, true), AdjustColors.HSB( 0, -100, 28, 0) ];
			spr2.x = ( spr.width - spr2.width ) / 2;
			spr2.y = ( spr.height - spr2.height ) / 2;
			this.bg.addChild( spr2 );
			
			this.bg.filters = [ new GlowFilter(0x000000, 1, 10, 10, 0.18, 3) ];
			this.bg.x = 0;
			this.bg.y = 35;
			this.addChild( this.bg );
			
		}
		
		private function createBar():void
		{
			this.bar = new Sprite();
			this.bar.graphics.beginFill( 0xB8CD00, 1 );
			this.bar.graphics.drawRect( 0, 0, 245, 21 );
			this.bar.graphics.endFill();
			this.bar.filters = [ new DropShadowFilter(10, 90, 0xD8F000, 1, 0, 10, 1, 1, true) ];
			this.bar.x = this.bg.x + ( this.bg.width - this.bar.width ) / 2;
			this.bar.y = this.bg.y + ( this.bg.height - this.bar.height ) / 2;
			this.bar.scaleX = 0.01;
			this.addChild( this.bar );
		}
		
		/**
		 * @private
		 */
		
		private function createText():void
		{
			if ( LaunchPad.instance.target.stage.color < 0xFF777777 )
			{
				var text_col:uint = 0xFFFFFF;
				var shadow_col:uint = 0x000000;
			}
			else
			{
				text_col = 0x333333;
				shadow_col = 0xFFFFFF;
			}
			
			//var cl:Class = getDefinitionByName( "ArialRounded" ) as Class;
			Font.registerFont( ArialRounded );
			var tf:TextFormat = new TextFormat( "Arial Rounded MT Bold", 22, text_col );
			
			this.copy = new TextField();
			this.copy.embedFonts = true;
			this.copy.defaultTextFormat = tf;
			this.copy.text = "   0%   ";
			this.copy.autoSize = TextFieldAutoSize.CENTER;
			this.copy.multiline = false;
			this.copy.x = ( this.bg.width - this.copy.width ) / 2;
			this.copy.y = this.bg.y + this.bg.height + 5;
			this.copy.filters = [ new BlurFilter(1.05, 1.05, 3), new DropShadowFilter( 2, 45, shadow_col, 1, 3, 3, 0.25, 3) ];
			this.addChild( this.copy );
		}
		
		private function createLabel():void
		{
			if ( LaunchPad.instance.target.stage.color < 0xFF777777 )
			{
				var text_col:uint = 0xFFFFFF;
				var shadow_col:uint = 0x000000;
			}
			else
			{
				text_col = 0x333333;
				shadow_col = 0xFFFFFF;
			}
			
			var tf:TextFormat = new TextFormat( "Arial Rounded MT Bold", 22, text_col, null, null, null, null, null, TextFormatAlign.CENTER );
			
			this.label = new TextField();
			this.label.embedFonts = true;
			this.label.defaultTextFormat = tf;
			this.label.text = "LOADING";
			this.label.multiline = false;
			this.label.width = this.bg.width;
			this.label.height = 35;
			this.label.x = this.bg.x;
			this.label.y = this.bg.y - this.label.height;
			this.label.filters = [ new BlurFilter(1.05, 1.05, 3), new DropShadowFilter( 2, 45, shadow_col, 1, 3, 3, 0.25, 3) ];
			this.addChild( this.label );
		}
		
	}

}