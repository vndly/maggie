package maggie {
	
	internal class Table {
		
		private var dictionary:Object = new Object();
		private var type:Class        = null;
		
	    public function Table(type:Class = null) {
	    	if (type == null)
	    		this.type = Object;
	    	else
	    		this.type = type;
	    }
	    
	    /**
		 * 	Agrega el valor al diccionario
		 **/
	    
	    internal final function add(clave:String, valor:*):void {
	        dictionary[clave] = type(valor);
	    }
	    
	    /**
		 * 	Elimina el valor del diccionario
		 **/
	    
	    internal final function remove(clave:String):void {
	        delete dictionary[clave];
	    }
	    
	    /**
		 * 	Devuelve el diccionario en forma de array
		 **/
	    
	    internal final function toArray():Array {
	        var result:Array = new Array();
	        
	        for (var key:String in dictionary)
	            result.push(type(dictionary[key]));
	
	        return result;
	    }
	}
}