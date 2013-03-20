package maggie {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	internal class DataRequest {
		
	    private static var connections:Queue = new Queue(Object);
	    private static var busy:Boolean      = false;
	    
	    /**
		 * 	Envia una peticion al servidor
		 **/
	    
	    internal static function send(url:String, complete:Function, fail:Function = null, parameters:Object = null, method:String = "post"):void {        
	        var loader:URLLoader = new URLLoader();
	        loader.addEventListener(Event.COMPLETE,        success);
	        loader.addEventListener(IOErrorEvent.IO_ERROR, error);
	        
	        var request:URLRequest = new URLRequest(url);
	        request.method = method;
	        
	        var variables:URLVariables = new URLVariables();
	        
	        if (parameters != null) {
		        for (var key:String in parameters)
		        	variables[key] = parameters[key];
		        	
	            request.data = variables;
         	}
	        
	        var connection:Object = new Object();
	        connection.loader     = loader;
	        connection.request    = request;
	        connection.complete   = complete;
	        connection.fail       = fail;
	        
	        DataRequest.connections.queue(connection);
	        DataRequest.nextConnection();
	    }
	    
	    /**
		 * 	Funcion que se llama cuando la peticion se realiza correctamente
		 **/
	    
	    private static function success(event:Event):void {
	    	var loader:URLLoader  = event.target as URLLoader;
	    	var parameters:Object = DataRequest.connections.first();
	    	var func:Function     = parameters.complete as Function;
	    	
	    	func(loader.data)
	    	finishConnection();
	    }
	    
	    /**
		 * 	Funcion que se llama cuando la peticion falla
		 **/
	    
	    private static function error(event:Event):void {
	    	var parameters:Object = DataRequest.connections.first();
	    	var func:Function     = parameters.fail as Function;
	    	
	    	if (func != null)
	    		func();
	    		
	    	finishConnection();
	    }
	    
	    /**
		 * 	Finaliza la conexion en curso
		 **/
	    
	    private static function finishConnection():void {
	    	DataRequest.connections.unqueue();
	    	DataRequest.busy = false;
	    	DataRequest.nextConnection();	    
	    }
	    
	    /**
		 * 	Envia la peticion al servidor
		 **/
	    
	    private static function executeConnection(connection:Object):void {
	    	var loader:URLLoader   = connection.loader  as URLLoader;
	    	var request:URLRequest = connection.request as URLRequest;
	    	
	    	loader.load(request);
	    	
			DataRequest.busy = true;			
	    }
	    
	    /**
		 * 	Pasa a ejecutar la siguiente peticion si la hay
		 **/
		
		private static function nextConnection():void {
			if (!DataRequest.busy && !DataRequest.connections.isEmpty())
				executeConnection(DataRequest.connections.first());
		}
	}
}