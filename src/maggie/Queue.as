package maggie {
	
	internal class Queue {
		
		private var data:Array = new Array();
		private var type:Class = null;
		
		public function Queue(type:Class = null) {
	    	if (type == null)
	    		this.type = Object;
	    	else
	    		this.type = type;
	    }
	    
	    /**
		 * 	Obtiene el primer elemento de la cola
		 **/
		
		public function first():* {
			if (data.length > 0)
				return type(data[0]);
			else
				return null;
		}
		
		/**
		 * 	Desencola el primer objeto de la cola
		 **/
		
		public function unqueue():void {
			data.shift();
		}
		
		/**
		 * 	Encola un objeto en la cola
		 **/
		
		public function queue(valor:*):void {
			data.push(type(valor));
		}
		
		/**
		 * 	Devuelve true si la cola esta vacia
		 **/
	    
	    public function isEmpty():Boolean {
			return (data.length == 0);
		}
	}
}