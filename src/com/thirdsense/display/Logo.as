package com.thirdsense.display 
{
	import com.thirdsense.utils.Trig;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Creates a logo from the LaunchPad framework
	 * @author Ben Leffler
	 */
	
	public class Logo extends Sprite 
	{
		/**
		 * Constructor for the logo
		 */
		
		public function Logo() 
		{
			this.cacheAsBitmap = true;
		}
		
		/**
		 * Populates the Logo with the appropriate graphic (result is either vector or bitmap depending on the chosen logo)
		 * @param	type	The type of logo to use
		 * @see	com.thirdsense.animation.LogoType
		 */
		
		public final function create( type:String ):void
		{
			switch ( type )
			{
				case LogoType.THIRD_SENSE:
					this.create3rdSenseLogo();
					break;
					
				case LogoType.STARLING_LIGHT:
					this.createStarlingLogo( true );
					break;
					
				case LogoType.STARLING_DARK:
					this.createStarlingLogo( false );
					break;
					
				case LogoType.LAUNCHPAD_LIGHT:
					this.createLaunchPadLogo( true );
					break;
					
				case LogoType.LAUNCHPAD_DARK:
					this.createLaunchPadLogo( false );
					break;
			}
			
			if ( !this.numChildren )
			{
				trace( "LaunchPad", Logo, "Create call failed. Logo type '" + type + "' not recognised" );
			}
		}
		
		/**
		 * @private
		 */
		
		private function create3rdSenseLogo():void
		{
			var w:Number = 11;	// width of each line
			var d:Number = 5;	// x distance between each shape
			var l:Number;
			var pt:Point;
			var p:Array;
			
			p = new Array();
			p.push( new Point(0, 25) );
			p.push( new Point(p[0].x + 25, p[0].y - 25) );			
			l = Trig.findDistance( p[0], p[1] );			
			pt = Trig.findPoint( 135, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -135, l - w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( 135, l - w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -135, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			p.push( p[0] );			
			this.processArray( p, 0x06A2C7 );
			
			pt = p[3];
			p = new Array();
			p.push( new Point(d + pt.x, pt.y) );
			p.push( new Point(p[0].x + 25, p[0].y - 25) );			
			l = Trig.findDistance( p[0], p[1] );			
			pt = Trig.findPoint( 135, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -135, l - w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( 135, l - w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -135, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			p.push( p[0] );			
			this.processArray( p, 0xEF0982 );
			
			pt = p[3];
			p = new Array();
			p.push( new Point(d + pt.x, pt.y) );
			pt = Trig.findPoint( 45, w * 2 );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( 135, w * 2 );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -135, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -45, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			pt = Trig.findPoint( -135, w );
			p.push( new Point(p[p.length - 1].x + pt.x, p[p.length - 1].y + pt.y) );
			p.push( p[0] );			
			this.processArray( p, 0xFFD700 );
		}
		
		/**
		 * @private
		 */
		
		private function processArray( p:Array, color:uint ):void
		{
			var g:Graphics = this.graphics;
			g.beginFill( color, 1 );
			g.moveTo( p[0].x, p[0].y );
			for ( var i:uint = 1; i < p.length; i++ )
			{
				g.lineTo( p[i].x, p[i].y );
			}			
			g.endFill();
		}
		
		/**
		 * @private
		 */
		
		private function createStarlingLogo( light_version:Boolean ):void
		{
			if ( light_version )
			{
				var cl:Class = getDefinitionByName( "lp_starlinglight" ) as Class;
			}
			else
			{
				cl = getDefinitionByName( "lp_starlingdark" ) as Class;
			}
			
			var bitmap:Bitmap = new Bitmap( new cl(), "auto", true );
			this.addChild( bitmap );
		}
		
		/**
		 * @private
		 */
		
		private function createLaunchPadLogo( light_version:Boolean ):void
		{
			if ( light_version )
			{
				var cl:Class = getDefinitionByName( "lp_launchpadlight" ) as Class;
			}
			else
			{
				cl = getDefinitionByName( "lp_launchpaddark" ) as Class;
			}
			
			var spr:Sprite = new cl();
			spr.x = 0;
			spr.y = 0;
			this.addChild( spr );
		}
		
	}

}