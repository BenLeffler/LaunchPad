/*
 * Copyright (C) 2006 Claus Wahlers and Max Herkender
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

package com.thirdsense.data {
	
	import flash.events.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import deng.fzip.*;

	/**
	 * Dispatched when all pending files have been processed. 
	 *
	 * @eventType flash.events.Event.COMPLETE 
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * <p>FZipLibrary works with a FZip instance to load files as
	 * usable instances, like a DisplayObject or BitmapData. Each file
	 * from a loaded zip is processed based on their file extentions.
	 * More than one FZip instance can be supplied, and if it is
	 * currently loading files, then FZipLibrary will wait for incoming
	 * files before it completes.</p>
	 * 
	 * <p>Flash's built-in Loader class is used to convert formats, so the
	 * only formats currently supported are ones that Loader supports.
	 * As of this writing they are SWF, JPEG, GIF, and PNG.</p>
	 * 
	 * <p>The following example loads an external zip file, outputs the
	 * width and height of an image and then loads a sound from a SWF file.</p>
	 * 
	 * <listing>
	 * package {
	 * 	import flash.events.*;
	 * 	import flash.display.BitmapData;
	 * 	import deng.fzip.FZip;
	 * 	import deng.fzip.FZipLibrary;
	 * 	
	 * 	public class Example {
	 * 		private var lib:FZipLibrary;
	 * 		
	 * 		public function Example(url:String) {
	 * 			lib = new FZipLibrary();
	 * 			lib.formatAsBitmapData(".gif");
	 * 			lib.formatAsBitmapData(".jpg");
	 * 			lib.formatAsBitmapData(".png");
	 * 			lib.formatAsDisplayObject(".swf");
	 * 			lib.addEventListener(Event.COMPLETE,onLoad);
	 * 			
	 * 			var zip:FZip = new FZip();
	 * 			zip.load(url);
	 * 			lib.addZip(zip);
	 * 		}
	 * 		private function onLoad(evt:Event) {
	 * 			var image:BitmapData = lib.getBitmapData("test.png");
	 * 			trace("Size: " + image.width + "x" + image.height);
	 * 			
	 * 			var importedSound:Class = lib.getDefinition("data.swf", "SoundClass") as Class;
	 * 			var snd:Sound = new importedSound() as Sound;
	 * 		}
	 * 	}
	 * }</listing>
	 * 
	 * @see http://livedocs.macromedia.com/flex/201/langref/flash/display/Loader.html
	 */
	public class FZipExtra extends EventDispatcher {
		static private const FORMAT_BITMAPDATA:uint = (1 << 0);
		static private const FORMAT_DISPLAYOBJECT:uint = (1 << 1);

		private var pendingFiles:Array = [];
		private var pendingZips:Array = [];
		private var currentState:uint = 0;
		private var currentFilename:String;
		private var currentZip:FZip;
		private var currentLoader:Loader;

		private var bitmapDataFormat:RegExp = /[]/;
		private var displayObjectFormat:RegExp = /[]/;
		private var soundDataFormat:RegExp = /[]/;
		private var bitmapDataList:Object = {};
		private var displayObjectList:Object = { };
		private var soundDataList:Object = { };

		/**
		 * Constructor
		 */
		public function FZipExtra() {
		}
		/**
		 * Use this method to add an FZip instance to the processing queue.
		 * If the FZip instance specified is not active (currently receiving files)
		 * when it is processed than only the files already loaded will be processed.
		 * 
		 * @param zip An FZip instance to process
		 */
		public function addZip(zip:FZip):void {
			pendingZips.unshift(zip);
			processNext();
		}
		/**
		 * Used to indicate a file extension that triggers formatting to BitmapData.
		 * 
		 * @param ext A file extension (".jpg", ".png", etc)
		 */
		public function formatAsBitmapData(ext:String):void {
			bitmapDataFormat = addExtension(bitmapDataFormat,ext);
		}
		/**
		 * Used to indicate a file extension that triggers formatting to DisplayObject.
		 * 
		 * @param ext A file extension (".swf", ".png", etc)
		 */
		public function formatAsDisplayObject(ext:String):void {
			displayObjectFormat = addExtension(displayObjectFormat,ext);
		}
		
		/**
		 * Used to indicate a file extension that triggers formatting to Sound.
		 * 
		 * @param ext A file extension (".mp3", ".wav", etc)
		 */
		public function formatAsSoundData(ext:String):void
		{
			soundDataFormat = addExtension( soundDataFormat, ext );
			
		}
		
		/**
		 * Retrieves the names of all library items available in this zip library
		 * @return	An array of library linkage names. Sorted by type and then alphabetically.
		 */
		
		public function listLibraryItems():Array
		{
			var arr:Array = new Array();
			
			for ( var str:String in this.bitmapDataList )
			{
				arr.push( str );
			}
			arr.sort();
			
			var arr2:Array = new Array();
			for ( str in this.displayObjectList )
			{
				arr2.push( str );
			}
			arr2.sort();
			
			var arr3:Array = new Array();
			for ( str in this.soundDataList )
			{
				arr3.push( str );
			}
			arr3.sort();
			
			while ( arr2.length )
			{
				arr.push( arr2.shift() );
			}
			
			while ( arr3.length )
			{
				arr.push( arr3.shift() );
			}
			
			return arr;
		}
		
		/**
		 * @private
		 */
		private function addExtension(original:RegExp,ext:String):RegExp {
			return new RegExp(ext.replace(/[^A-Za-z0-9]/,"\\$&")+"$|"+original.source);
		}

		/**
		 * Request a file that has been formatted as BitmapData.
		 * A ReferenceError is thrown if the file does not exist as a
		 * BitmapData.
		 * 
		 * @param filename The filename of the BitmapData instance.
		 */
		
		public function getSoundData(filename:String):ByteArray {
			if (!soundDataList[filename] is ByteArray) {
				throw new Error("File \""+filename+"\" was not found as a ByteArray");
			}
			return soundDataList[filename] as ByteArray;
		}
		 
		public function getBitmapData(filename:String):BitmapData {
			if (!bitmapDataList[filename] is BitmapData) {
				throw new Error("File \""+filename+"\" was not found as a BitmapData");
			}
			return bitmapDataList[filename] as BitmapData;
		}
		/**
		 * Request a file that has been formatted as a DisplayObject.
		 * A ReferenceError is thrown if the file does not exist as a
		 * DisplayObject.
		 * 
		 * @param filename The filename of the DisplayObject instance.
		 */
		public function getDisplayObject(filename:String):DisplayObject {
			if (!displayObjectList.hasOwnProperty(filename)) {
				//throw new ReferenceError("File \""+filename+"\" was not found as a DisplayObject");
				return null;
			}
			return displayObjectList[filename] as DisplayObject;
		}
		/**
		 * Retrieve a definition (like a class) from a SWF file that has
		 * been formatted as a DisplayObject.
		 * A ReferenceError is thrown if the file does not exist as a
		 * DisplayObject, or the definition does not exist.
		 * 
		 * @param filename The filename of the DisplayObject instance.
		 */
		public function getDefinition(filename:String,definition:String):Object {
			if (!displayObjectList.hasOwnProperty(filename)) {
				throw new ReferenceError("File \""+filename+"\" was not found as a DisplayObject, ");
			}
			var disp:DisplayObject = displayObjectList[filename] as DisplayObject;
			try {
				return disp.loaderInfo.applicationDomain.getDefinition(definition);
			} catch (e:ReferenceError) {
				throw new ReferenceError("Definition \""+definition+"\" in file \""+filename+"\" could not be retrieved: "+e.message);
			}
			return null;
		}

		/**
		 * @private
		 */
		private function processNext(evt:Event = null):void {
			
			while (currentState === 0) {
				if (pendingFiles.length > 0) {
					var nextFile:FZipFile = pendingFiles.pop();
					if (bitmapDataFormat.test(nextFile.filename)) {
						currentState |= FORMAT_BITMAPDATA;
					}
					if (displayObjectFormat.test(nextFile.filename)) {
						currentState |= FORMAT_DISPLAYOBJECT;
					}
					if ((currentState & (FORMAT_BITMAPDATA | FORMAT_DISPLAYOBJECT)) !== 0) {
						currentFilename = nextFile.filename;
						currentLoader = new Loader();
						currentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
						currentLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderCompleteHandler);
						var content:ByteArray = nextFile.content;
						content.position = 0;
						currentLoader.loadBytes(content);
						break;
					}
					if ( nextFile.filename.indexOf(".mp3") ) {
						soundDataList[nextFile.filename] = nextFile.content as ByteArray;
						currentLoader = null;
						currentFilename = "";
						currentState &= ~(FORMAT_BITMAPDATA | FORMAT_DISPLAYOBJECT);
						processNext();
						break;						
					}
					
				} else if (currentZip == null) {
					if (pendingZips.length > 0) {
						currentZip = pendingZips.pop();
						var i:uint = currentZip.getFileCount();
						while (i > 0) {
							pendingFiles.push(currentZip.getFileAt(--i));
						}
						if (currentZip.active) {
							currentZip.addEventListener(Event.COMPLETE, zipCompleteHandler);
							currentZip.addEventListener(FZipEvent.FILE_LOADED, fileCompleteHandler);
							currentZip.addEventListener(FZipErrorEvent.PARSE_ERROR, zipCompleteHandler);
							break;
						} else {
							currentZip = null;
						}
					} else {
						dispatchEvent(new Event(Event.COMPLETE));
						break;
					}
				} else {
					break;
				}
			}
		}

		/**
		 * @private
		 */
		private function loaderCompleteHandler(evt:Event):void {
			if ((currentState & FORMAT_BITMAPDATA) === FORMAT_BITMAPDATA) {
				if (currentLoader.content is Bitmap && (currentLoader.content as Bitmap).bitmapData is BitmapData) {
					var bitmapData:BitmapData = (currentLoader.content as Bitmap).bitmapData
					bitmapDataList[currentFilename] = bitmapData.clone();
					//trace(currentFilename+" -> BitmapData ("+bitmapData.width+"x"+bitmapData.height+")");
				} else if (currentLoader.content is DisplayObject) {
					var width:uint = uint(currentLoader.content.width);
					var height:uint = uint(currentLoader.content.height);
					if (width && height) {
						var bitmapData2:BitmapData = new BitmapData(width,height,true,0x00000000);
						bitmapData2.draw(currentLoader);
						bitmapDataList[currentFilename] = bitmapData2;
						//trace(currentFilename+" -> BitmapData ("+bitmapData2.width+"x"+bitmapData2.height+")");
					} else {
						trace("File \""+currentFilename+"\" could not be converted to BitmapData");
					}
				} else {
					trace("File \""+currentFilename+"\" could not be converted to BitmapData");
				}
			}
			if ((currentState & FORMAT_DISPLAYOBJECT) === FORMAT_DISPLAYOBJECT) {
				if (currentLoader.content is DisplayObject) {
					//trace(currentFilename+" -> DisplayObject");
					displayObjectList[currentFilename] = currentLoader.content;
				} else {
					currentLoader.unload();
					trace("File \""+currentFilename+"\" could not be loaded as a DisplayObject");
				}
			} else {
				currentLoader.unload();
			}
			currentLoader = null;
			currentFilename = "";
			currentState &= ~(FORMAT_BITMAPDATA | FORMAT_DISPLAYOBJECT);
			processNext();
		}
		/**
		 * @private
		 */
		private function fileCompleteHandler(evt:FZipEvent):void {
			pendingFiles.unshift(evt.file);
			processNext();
		}
		/**
		 * @private
		 */
		private function zipCompleteHandler(evt:Event):void {
			currentZip.removeEventListener(Event.COMPLETE, zipCompleteHandler);
			currentZip.removeEventListener(FZipEvent.FILE_LOADED, fileCompleteHandler);
			currentZip.removeEventListener(FZipErrorEvent.PARSE_ERROR, zipCompleteHandler);
			currentZip = null;
			processNext();
		}
	}
}