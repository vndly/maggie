package maggie {
	
	import flash.events.Event;
	
	public class Signal extends Event {
		
		internal static const FINISH:String  = "finish";
		internal static const SLEEP:String   = "sleep";
		internal static const WAKE_UP:String = "wakeUp";
		internal static const FREEZE:String  = "freeze";
		
		public function Signal(type:String) {
			super(type);
		}
		
		/**
		 * 	Devuelve la referencia del proceso que provocó la señal
		 **/
		
		public final function getProcess(type:Class = null):* {
			if (type == null)
				return target as Process;
			else
				return target as type;
		}
		
		/**
		 * 	Devuelve true si es una señal de finalización
		 **/
		
		public final function isFinish():Boolean {
			return (type == FINISH);
		}
		
		/**
		 * 	Devuelve true si es una señal de dormir
		 **/
		
		public final function isSleep():Boolean {
			return (type == SLEEP);
		}
		
		/**
		 * 	Devuelve true si es una señal de despertar
		 **/
		
		public final function isWakeUp():Boolean {
			return (type == WAKE_UP);
		}
		
		/**
		 * 	Devuelve true si es una señal de congelar
		 **/
		
		public final function isFreeze():Boolean {
			return (type == FREEZE);
		}
	}
}