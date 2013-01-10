package com.thirdsense.animation 
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A class that converts a classic display list MovieClip in to a sprite sequence (a vector of BitmapData snapshots) to be used with blitting or Starling texture packs
	 * @author Ben Leffler
	 */
	
	public class SpriteSequence 
	{
		/**
		 * The pool group name for this object
		 */
		public var pool:String;
		
		/**
		 * The sequence name for this object.
		 */
		public var sequence:String = "";
		
		/**
		 * The vector of BitmapData snapshots of each frame of the source MovieClip
		 */
		public var sprites:Vector.<BitmapData>;
		
		/**
		 * The cell width of the BitmapData instances that populate the <i>sprites</i> object
		 */
		public var cell_width:Number;
		
		/**
		 * The cell height of the BitmapData instances that populate the <i>sprites</i> object
		 */
		public var cell_height:Number;
		
		/**
		 * The offset to calculate the resulting sprite's pivot point
		 */
		public var cell_offset:Point;
		
		/**
		 * The total number of cells in the sprite sequence
		 */
		public var total_cells:int;
		
		/**
		 * The maximum number of cells in the width of a single spritesheet
		 */
		public var max_width:int;
		
		/**
		 * The source MovieClip's originally reported width value
		 */
		public var source_width:Number;
		
		/**
		 * The source MovieClip's originally reported height value
		 */
		public var source_height:Number;
		
		public function SpriteSequence() 
		{
			
		}
		
		/**
		 * Creates a sprite sequence object from a MovieClip by analysing and taking a bitmapdata snapshot of each frame, placing each in to a vector for use in blitting and texture packing in Starling
		 * @param	clip	The movieclip to capture frame-by-frame
		 * @param	timeline	If a sub-clip needs it's timeline to advance with the clip timeline, pass it through in this parameter
		 * @param	start_frame	The number of the first frame
		 * @param	end_frame	The number of the final frame. Leaving this as 0 will capture the every frame in the clip
		 * @param	crop	A rectangle object that will act as a clipping box for the resulting texture atlas
		 * @param	filter_pad	Allows a 'bleed' area around the movieclip bounds to account for any filters that may exceed the bounds area (like a glow filter or drop shadow for example)
		 * @param	onNewFrame	A function to call as the playhead advances through the clip timeline. If you have clip children that require calculations to be made on each frame, you can use this method.
		 * @param	onNewFrameArgs	An array of arguments to pass through to onNewFrame function.
		 * @return	The resulting spritesequence object
		 */
		
		public static function create( clip:MovieClip, timeline:MovieClip = null, start_frame:int = 0, end_frame:int = 0, crop:Rectangle = null, filter_pad:int = 5, onNewFrame:Function=null, onNewFrameArgs:Array=null ):SpriteSequence
		{
			if ( !timeline ) {
				timeline = clip;
			}
			
			if ( !end_frame ) {
				end_frame = timeline.totalFrames;
			}
			
			if ( !start_frame ) {
				start_frame = 1;
			}
			
			var rect:Rectangle = new Rectangle();
			var new_mc:MovieClip = new MovieClip();
			
			var totalframes:int = end_frame - start_frame + 1;
			var bmpdata_array:Array = new Array();
			var bmd:BitmapData;
			var matrix:Matrix;
			var rect2:Rectangle;
			
			for ( var i:uint = start_frame; i <= end_frame; i++ ) {
				timeline.gotoAndStop( i );
				
				if ( onNewFrame != null )
				{
					if ( onNewFrameArgs )
					{
						onNewFrame.apply(null, onNewFrameArgs);
					}
					else
					{
						onNewFrame();
					}
				}
				
				if ( !crop ) {
					rect2 = clip.getBounds( new_mc );
					rect = rect.union( rect2 );
					rect2.inflate( filter_pad, filter_pad );
				} else {
					rect2 = crop;
				}
				
				
				matrix = new Matrix();
				matrix.translate( -rect2.x, -rect2.y);
				
				bmd = new BitmapData( rect2.width, rect2.height, true, 0 );
				bmd.draw( clip, matrix, clip.transform.colorTransform, null, null, true );
				bmpdata_array.push( { bmd:bmd, rect:rect2 } );
				
			}
			
			if ( crop ) {
				rect = crop;
			}
			
			var twidth:Number = rect.width;
			var theight:Number = rect.height;
			
			rect.inflate( filter_pad, filter_pad );
			
			var sprite_sequence:SpriteSequence = new SpriteSequence();
			sprite_sequence.source_width = twidth;
			sprite_sequence.source_height = theight;
			sprite_sequence.sprites = new Vector.<BitmapData>;
			
			var counter:int = 0;
			for ( i = start_frame; i <= end_frame; i++ ) {
				rect2 = bmpdata_array[counter].rect;
				bmd = bmpdata_array[counter].bmd;
				var offset:Point = new Point(rect2.x - rect.x, rect2.y - rect.y);
				sprite_sequence.sprites[counter] = new BitmapData( rect.width, rect.height, true, 0 );
				sprite_sequence.sprites[counter].copyPixels( bmd, bmd.rect, new Point(offset.x, offset.y), null, null, true );
				counter++;
				bmd.dispose();
			}
			
			sprite_sequence.cell_width = rect.width;
			sprite_sequence.cell_height = rect.height;
			sprite_sequence.cell_offset = new Point( rect.x, rect.y );
			sprite_sequence.total_cells = totalframes;
			
			return sprite_sequence;
			
		}
		
		/**
		 * Compiles the vector of bitmapdata snapshots in to a single spritesheet
		 * @return	The bitmapdata grid of the spritesequence
		 */
		
		public function getSpriteSheet():BitmapData
		{
			if ( this.sprites ) {
				if ( this.sprites.length > 1 ) {
					
					var max_width:int = Math.min( this.sprites.length, Math.floor(2048 / this.cell_width), 8 );
					var bmpdata:BitmapData = new BitmapData( this.cell_width * Math.min(this.total_cells, max_width), this.cell_height * Math.ceil(this.total_cells / max_width), true, 0 );
					
					for ( var i:uint = 0; i < this.sprites.length; i++ ) {
						var row:int = Math.floor(i / max_width);
						var col:int = i - (row * max_width);
						bmpdata.copyPixels( this.sprites[i], this.sprites[i].rect, new Point(col * this.cell_width, row * this.cell_height), null, null, true );
					}
					
					return bmpdata;
					
				} else if ( this.sprites.length ) {
					
					bmpdata = new BitmapData( sprites[0].width, sprites[0].height, true, 0 );
					bmpdata.copyPixels( sprites[0], sprites[0].rect, new Point() );
					return bmpdata;
					
				}
			}
			
			return null;
		}
		
		/**
		 * Formats an XML object to Sparrow specifications for use with the Starling Framework
		 * @return	An Sparrow XML object
		 */
		
		public function getSparrowXML():XML
		{
			var str:String = "<TextureAtlas imagePath=''>";
			var max_width:int = Math.min( 8, Math.floor(2048 / this.cell_width) );
			
			for ( var i:uint = 0; i < this.total_cells; i++ ) {
				
				var num:String = String(i);
				while ( num.length < 4 ) {
					num = "0" + num;
				}
				
				var row:int = Math.floor( i / (max_width) );
				var col:int = i - ( row * (max_width) );
				
				var name:String;
				if ( this.sequence == "" ) {
					name = this.pool;
				} else {
					name = this.pool + "__" + this.sequence;
				}
				
				str += "<SubTexture name='" + name + num + "' x='" + (col * this.cell_width) +"' y='" + (row * this.cell_height) +"' width='"+ this.cell_width +"' height='"+this.cell_height+"'/>"
			}
			
			str += "</TextureAtlas>";
			
			return new XML( str );
			
		}
		
		/**
		 * Disposes the bitmapdata sprites from memory.
		 */
		
		public function dispose():void
		{
			if ( this.sprites ) {
				while( this.sprites.length ) {
					this.sprites[0].dispose();
					this.sprites[0] = null;
					this.sprites.shift();
				}
			}
		}
		
		
	}

}