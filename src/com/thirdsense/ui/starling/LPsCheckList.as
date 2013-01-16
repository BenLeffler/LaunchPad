package com.thirdsense.ui.starling 
{
	import com.thirdsense.animation.TexturePack;
	import com.thirdsense.ui.starling.LPsRadioButton;
	import com.thirdsense.utils.Trig;
	import flash.geom.Point;
	import starling.display.Sprite;
	
	/**
	 * Creates a Starling based checklist element based on an array of texture packs and values. This can be a multichoice or singlechoice element.
	 * @author Ben Leffler
	 */
	
	public class LPsCheckList extends Sprite 
	{
		private var _multichoice:Boolean;
		private var _values:Array;
		private var _disabled:Boolean;
		
		/**
		 * The function that gets called (if not null) upon a user interacting with this ui element
		 */
		public var onToggle:Function;
		
		/**
		 * Creates a new CheckList element
		 * @param	texture_packs	An array of texture_packs to use with this checklist. Each element is assigned an integer id (starting with 0)
		 * @param	defaults	An array of integer id's that are to start as marked as 'selected on'. If the multichoice param is 'false', the first id in this array (or id:0 if this is passed as null) will be selected
		 * @param	multichoice	Set as true if the user is allowed to have multiple (or none) selections within this element
		 * @param	onToggle	A function that can be called when a user changes a selection
		 */
		
		public function LPsCheckList( texture_packs:Array, defaults:Array = null, multichoice:Boolean=false, onToggle:Function=null ):void
		{
			this._multichoice = multichoice;
			this.onToggle = onToggle;
			this._disabled = false;
			
			if ( defaults )
			{
				for ( var i:uint = 0; i < defaults.length; i++ )
				{
					if ( defaults[i] < 0 || defaults[i] >= texture_packs.length )
					{
						defaults.splice(i, 1);
						i--;
					}
				}
				
				if ( multichoice )
				{
					this._values = Trig.copyArray(defaults);
				}
				else
				{
					this._values = [ defaults.shift() ];
				}
			}
			else
			{
				this._values = [0];
			}
			
			this.create( texture_packs );
		}
		
		/**
		 * @private	creates the interface
		 */
		
		private function create( tp_arr:Array ):void
		{
			var i:uint;
			var j:uint;
			var tChildren:int = tp_arr.length;
			var dChildren:int = this._values.length;
			var rb:LPsRadioButton;
			var dValue:Boolean;
			var running_height:Number = 0;
			
			for ( i = 0; i < tChildren; i++ )
			{
				dValue = false;
				for ( j = 0; j < dChildren; j++ )
				{
					if ( this._values[j] == i ) dValue = true;					
				}
				
				rb = new LPsRadioButton( tp_arr[i], dValue, this.onLocalToggle );
				rb.x = 0;
				rb.y = running_height;
				this.addChild( rb );
				running_height += tp_arr[i].source_height;
			}
		}
		
		/**
		 * @private	user interaction handling for single choice and multi choice instances
		 */
		
		private function onLocalToggle():void
		{
			if ( multichoice )
			{
				var arr:Array = new Array();
				for ( var i:uint = 0; i < this.numChildren; i++ )
				{
					var rb:LPsRadioButton = this.getChildAt(i) as LPsRadioButton;
					if ( rb.value == true ) arr.push(i);
				}
				this._values = arr;
				
				if ( this.onToggle != null )
				{
					this.onToggle();
				}
				
			}
			else
			{
				if ( this._values.length )
				{
					var old:int = this._values[0];
				}
				else
				{
					old = -1;
				}
				
				arr = new Array();
				var arr2:Array = new Array();
				for ( i = 0; i < this.numChildren; i++ )
				{
					rb = this.getChildAt(i) as LPsRadioButton;
					arr[i] = rb.value;
					this._values.indexOf(i) >= 0 ? arr2[i] = true : arr2[i] = false;
				}
				
				for ( i = 0; i < arr.length; i++ )
				{
					rb = this.getChildAt(i) as LPsRadioButton;
					if ( arr[i] == arr2[i] )
					{
						rb.value = false;
					}
					else
					{
						rb.value = true;
						this._values = [i];
					}
				}
				
				if ( old != this._values[0] && this.onToggle != null )
				{
					this.onToggle();
				}				
			}
			
		}
		
		/**
		 * Returns an array populated with the choice indexes that are currently selected
		 */
		
		public function get values():Array 
		{
			return _values;
		}
		
		/**
		 * Indicates if this element is has multichoice enabled
		 */
		
		public function get multichoice():Boolean 
		{
			return _multichoice;
		}
		
		/**
		 * Indicates if this element is in a state of disable
		 */
		
		public function get disabled():Boolean 
		{
			return _disabled;
		}
		
		/**
		 * Returns the x,y co-ordinates of this element as a Point object
		 * @return	The Point object populated with this object's x,y co-ords.
		 */
		
		public function getPoint():Point
		{
			return new Point( this.x, this.y );
		}
		
		/**
		 * Disables this ui element from interaction
		 */
		
		public function disable():void
		{
			if ( !this._disabled )
			{
				var rb:LPsRadioButton;
				
				this._disabled = true;
				
				for ( var i:uint = 0; i < this.numChildren; i++ )
				{
					rb = this.getChildAt(i) as LPsRadioButton;
					rb.disable();
				}
			}
		}
		
		/**
		 * Enables this ui element for interaction
		 */
		
		public function enable():void
		{
			if ( this._disabled )
			{
				var rb:LPsRadioButton;
				
				this._disabled = false;
				
				for ( var i:uint = 0; i < this.numChildren; i++ )
				{
					rb = this.getChildAt(i) as LPsRadioButton;
					rb.enable();
				}
			}
		}
		
	}

}