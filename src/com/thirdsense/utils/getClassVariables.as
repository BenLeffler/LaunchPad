package com.thirdsense.utils 
{
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author Ben Leffler
	 */
	
	/**
	 * Retrieves all variables, constants and accessors (if requested) of the passed object.
	 * @param	cl	The object to examine
	 * @param	includeAccessors	Pass as true if you want to include accessors (getter/setter)
	 * @param	asValues	If the array to be returned is to be populated with the var/const values
	 * @return	An array of vars or var values
	 */
	 
	public function getClassVariables( cl:*, accessorType:String="", asValues:Boolean=false ):Array
	{
		var arr:Array = new Array();
		var xml:XML = describeType( cl );
		
		for ( var i:uint = 0; xml.variable[i] != undefined; i++ ) {
			arr.push( xml.variable[i].@name );
		}
		for ( i = 0; xml.constant[i] != undefined; i++ ) {
			arr.push( xml.constant[i].@name );
		}
		for ( i = 0; xml.accessor[i] != undefined; i++ ) {
			if ( xml.accessor[i].@access == accessorType || accessorType == AccessorType.ALL ) {
				arr.push( xml.accessor[i].@name );
			}
		}
		
		if ( !arr.length ) {
			return null;
		}
		
		if ( asValues )
		{
			for ( i = 0; i < arr.length; i++ )
			{
				arr[i] = cl[arr[i]];
			}
		}
		
		return arr;
		
	}
	
}