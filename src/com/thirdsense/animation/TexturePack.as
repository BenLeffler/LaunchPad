package com.thirdsense.animation
{
	import com.thirdsense.animation.SpriteSequence;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * The TexturePack class enables you to convert during runtime a MovieClip to a texture packed object primarily for use with the Starling Framework. This class also
	 * acts as a psuedo-asset management sytem for textures, texture atlases, source bitmapdata and render textures.
	 * @author Ben Leffler
	 */
	
	public class TexturePack 
	{
		private var _spritesheet:BitmapData;
		private var _sparrow_xml:XML;
		
		/**
		 * The pool name of the TexturePack object
		 */
		public var pool:String = "";
		
		/**
		 * The sequence name of the TexturePack object
		 */
		public var sequence:String = "";
		
		/**
		 * The texture object representation of the source sprite sheet
		 */
		public var texture:Texture;
		
		/**
		 * The dynamic render texture object if the TexturePack object has been slated to use it
		 */
		public var render_texture:RenderTexture;
		
		/**
		 * The texture atlas to be used by the Starling framework
		 */
		public var atlas:TextureAtlas;
		
		/**
		 * The x/y co-ordinate offset of the source sprite. Use the to correctly calculate the pivot point
		 */
		public var offset:Point;
		
		/**
		 * The original MovieClip's source width
		 */
		public var source_width:Number;
		
		/**
		 * The original MovieClip's source height
		 */
		public var source_height:Number;
		
		/**
		 * Dynamic metadata that can be configured to carry any kind of data to be attached with this specific TexturePack object
		 */
		public var metadata:Object;
		
		private static var texture_packs:Vector.<TexturePack>;
		
		/**
		 * Indicates if mipmaps are to be generated when converting from a MovieClip/SpriteSequence to a TexturePack object
		 */
		public static var generate_mipmaps:Boolean = false;
		
		/**
		 * Constructor class for a Texture Pack
		 * @param	sprite_sequence	The SpriteSequence object that the Texture Pack is to be generated from.
		 * @param	disposeOnImport	Dispose the spritesheet bitmapData from the Texture Pack upon import.
		 */
		
		public function TexturePack( sprite_sequence:SpriteSequence=null, disposeOnImport:Boolean = true )
		{
			if ( sprite_sequence ) {
				this.spritesheet = sprite_sequence.getSpriteSheet();
				this.sparrow_xml = sprite_sequence.getSparrowXML();
				this.pool = sprite_sequence.pool;
				this.sequence = sprite_sequence.sequence;
				this.offset = new Point( sprite_sequence.cell_offset.x, sprite_sequence.cell_offset.y );
				this.source_width = sprite_sequence.source_width;
				this.source_height = sprite_sequence.source_height;
			} else {
				this.offset = new Point(0, 0);
			}
			
			if ( disposeOnImport && sprite_sequence ) {
				this.kill(true);
			}
			
		}
		
		/**
		 * Creates a new Texture from a bitmapdata object
		 * @param	bmpdata	The bitmapdata object to convert from
		 * @param	asRenderTexture	Creates a texture as a render texture for runtime alteration
		 * @param	retainBitmapData	Retains the bitmapdata object in the TexturePack object for collision detection etc.
		 */
		
		public function fromBitmapData(bmpdata:BitmapData, asRenderTexture:Boolean = false, retainBitmapData:Boolean = false ):void
		{
			if ( !Starling.context )
			{
				trace( "LaunchPad", TexturePack, "Unable to convert to a Texture. You must establish a Stage3D context first by starting a Starling session." );
				throw ( new Error("Unable to convert to a Texture. You must establish a Stage3D context first by starting a Starling session.") );
				return void;
			}
			
			this.texture = Texture.fromBitmapData(bmpdata, generate_mipmaps, asRenderTexture);
			
			if ( asRenderTexture ) {
				this.render_texture = new RenderTexture(bmpdata.width, bmpdata.height);
				this.render_texture.draw( new Image(this.texture) );
			}
			
			if ( retainBitmapData ) {
				this._spritesheet = bmpdata;
			}
			
		}
		
		/**
		 * The bitmapdata spritesheet used in the texture. The can be kept in resident memory for use in collision detection and render texture writing.
		 */
		
		public function get spritesheet():BitmapData	{	return this._spritesheet	};
		public function set spritesheet( bmpdata:BitmapData ):void
		{
			if ( !Starling.context )
			{
				trace( "LaunchPad", TexturePack, "Unable to convert to a Texture. You must establish a Stage3D context first by starting a Starling session." );
				throw ( new Error("Unable to convert to a Texture. You must establish a Stage3D context first by starting a Starling session.") );
				return void;
			}
			
			this._spritesheet = bmpdata;
			
			if ( this.texture ) {
				this.texture.dispose();
			}
			
			this.texture = Texture.fromBitmapData(bmpdata, generate_mipmaps);
			
		}
		
		/**
		 * Retrieves a sparrow formatted XML object representation of the spritesheet for use in converting to a texture atlas
		 */
		
		public function get sparrow_xml():XML	{	return this._sparrow_xml	};
		public function set sparrow_xml(xml:XML):void
		{
			this._sparrow_xml = xml;
			
			if ( this.atlas ) {
				this.atlas.dispose();
			}
			
			this.atlas = new TextureAtlas( this.texture, xml );
		}
		
		/**
		 * Gets the Texture Atlas of the Texture Pack
		 * @return	Texture Atlas for use with a Starling Display Object.
		 */
		public function getTextures():Vector.<Texture>
		{
			return this.atlas.getTextures();
			
		}
		
		/**
		 * Creates a movieclip based on the texture pack.
		 * @param	fps	The frames per second this clip will run at
		 * @return	A Starling MovieClip object
		 */
		public function getMovieClip( fps:int = 30):MovieClip
		{
			var mc:MovieClip = new MovieClip( this.getTextures(), fps );
			mc.pivotX = -this.offset.x;
			mc.pivotY = -this.offset.y;
			return mc;
			
		}
		
		/**
		 * Retrieves an Image object from the texture pack
		 * @param	asRenderTexture	The image is retrieved as a render texture object (dynamic and can be written to)
		 * @param	frame	If the source is a multiframe texture atlas (eg. MovieClip), you can designate which frame to output as an Image. Default is 0.
		 * @return	The Image object for use in the Starling Framework
		 */
		public function getImage( asRenderTexture:Boolean=false, frame:int=0 ):Image
		{
			var img:Image;
			
			if ( !this.atlas ) {
				if ( asRenderTexture ) {
					img = new Image( this.render_texture );
				} else {
					img = new Image( this.texture );
				}
			} else {
				img = new Image( this.atlas.getTextures()[frame] );
			}
			
			if ( this.offset ) {
				img.pivotX = -this.offset.x;
				img.pivotY = -this.offset.y;
			}
			
			img.name = this.pool + "_" + this.sequence;
			
			return img;
		}
		
		/**
		 * Gets a random image from a multiframe texture
		 * @return	An Image object generated from the multiframe texture atlas
		 */
		
		public function getRandomImage():Image
		{
			if ( !this.atlas ) {
				img = new Image( this.texture );
				
			} else {
			
				var choice:int = Math.floor( Math.random() * this.atlas.getTextures().length );
				var img:Image = new Image( this.atlas.getTextures()[choice] );
				
			}
			
			if ( this.offset ) {
				img.pivotX = -this.offset.x;
				img.pivotY = -this.offset.y;
			}
			
			return img;
		}
		
		/**
		 * Removes the Texture Pack and spritesheets from memory
		 * @param	spritesheet_only	True if you want to only destroy the spritesheet - not the texture or atlas.
		 */
		public function kill( spritesheet_only:Boolean = false ):void
		{
			if ( this._spritesheet ) {
				this._spritesheet.dispose();
				this._spritesheet = null;
				if ( spritesheet_only ) {
					return void;
				}
			}
			
			if ( this.texture ) {
				this.texture.dispose();
				this.texture = null;
			}
			
			if ( this.render_texture ) {
				this.render_texture.dispose();
				this.render_texture = null;
			}
			
			if ( this.atlas ) {
				this.atlas.dispose();
				this.atlas = null;
			}
			
		}
		
		/**
		 * Converts a traditional display list MovieClip to a texture pack.
		 * @param	clip	The movieclip to capture frame-by-frame
		 * @param	pool	The pool name of the resulting texture pack
		 * @param	sequence	The sequence name of the resulting texture pack
		 * @param	timeline	If a sub-clip needs it's timeline to advance with the clip timeline, pass it through in this parameter
		 * @param	start_frame	The number of the first frame
		 * @param	end_frame	The number of the final frame. Leaving this as 0 will capture the every frame in the clip
		 * @param	crop	A rectangle object that will act as a clipping box for the resulting texture atlas
		 * @param	filter_pad	Allows a 'bleed' area around the movieclip bounds to account for any filters that may exceed the bounds area (like a glow filter or drop shadow for example)
		 * @param	onNewFrame	A function to call as the playhead advances through the clip timeline. If you have clip children that require calculations to be made on each frame, you can use this method.
		 * @param	onNewFrameArgs	An array of arguments to pass through to onNewFrame function.
		 * @return	A texture pack of the clip to be used within the Starling Framework.
		 */
		
		public static function createFromMovieClip( clip:flash.display.MovieClip, pool:String, sequence:String = "", timeline:flash.display.MovieClip = null, start_frame:int = 0, end_frame:int = 0, crop:Rectangle = null, filter_pad:int = 5, onNewFrame:Function = null, onNewFrameArgs:Array = null):TexturePack
		{
			var sq:SpriteSequence = SpriteSequence.create( clip, timeline, start_frame, end_frame, crop, filter_pad, onNewFrame, onNewFrameArgs );
			sq.pool = pool;
			sq.sequence = sequence;
			var tp:TexturePack = new TexturePack( sq );
			TexturePack.addTexturePack( tp );
			sq.dispose();
			
			return tp;			
		}
		
		/**
		 * Adds a texture pack to memory for use in the application.
		 * @param	tp	The texture pack object to add to the library
		 */
		
		public static function addTexturePack( tp:TexturePack ):void
		{
			if ( !texture_packs ) {
				texture_packs = new Vector.<TexturePack>;
			}
			
			if ( !getTexturePack(tp.pool, tp.sequence) ) {
				texture_packs.push( tp );
			}
			
		}
		
		/**
		 * Deletes and disposes of an individual or group of texture packs from the application library.
		 * @param	pool	The pool name of the texture pack to target
		 * @param	sequence	The sequence name of the texture pack to target. Leaving this as an empty string will delete all instances of texture packs using the pool name.
		 */
		
		public static function deleteTexturePack( pool:String, sequence:String="" ):void
		{
			if ( texture_packs ) {
				for ( var i:uint = 0; i < texture_packs.length; i++ ) {
					var tp:TexturePack = texture_packs[i] as TexturePack;
					if ( (tp.pool == pool && sequence == "") || (tp.pool == pool && tp.sequence == sequence) ) {
						tp.kill();
						texture_packs.splice(i, 1);
						i--;
					}
				}
			}
			
		}
		
		/**
		 * Deletes and disposes of all texture packs from the application library.
		 */
		
		public static function deleteAllTexturePacks():void
		{
			while ( texture_packs && texture_packs.length ) {
				var tp:TexturePack = texture_packs[0];
				tp.kill();
				texture_packs.shift();
			}
			
		}
		
		/**
		 * Retrieves a designated texture pack from the application library for use with the Starling Framework
		 * @param	pool	The pool name of the texture pack
		 * @param	sequence	The sequence name of the texture pack. If passed as an empty string, the first texture pack with the passed pool name will be returned
		 * @return	The designated texture pack. If no match was found in the application library, null will be returned.
		 */
		
		public static function getTexturePack( pool:String, sequence:String="" ):TexturePack
		{
			if ( !texture_packs ) {
				return null;
			}
			
			var match:String = "";
			
			for ( var i:uint = 0; i < texture_packs.length; i++ ) {
				var tp:TexturePack = texture_packs[i] as TexturePack;
				if ( tp.pool == pool && tp.sequence == sequence ) {
					return tp;
				}
				if ( tp.pool == pool && sequence == "" && match == "" ) {
					match = tp.sequence;
				}
			}
			
			if ( match != "" ) {
				return getTexturePack( pool, match );
			}
			
			return null;
			
		}
		
		/**
		 * Traces out the list of texture pack objects that currently exist in the application library.
		 * @param	pool	If you wish to limit the traced results to a specific pool, pass through the pool name
		 */
		
		public static function traceAllTexturePacks( pool:String = "" ):int
		{
			var counter:int = 0;
			for ( var i:uint = 0; i < texture_packs.length; i++ )
			{
				var tp:TexturePack = texture_packs[i];
				if ( pool == "" || tp.pool == pool )
				{
					trace( "TEXTURE PACK - POOL:", tp.pool, ", SEQ:", tp.sequence );
					counter++;
				}
			}
			
			return counter;
		}
		
	}

}