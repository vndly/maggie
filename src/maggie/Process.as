package maggie {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequestMethod;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	public class Process extends EventDispatcher {
		
		public const GET:String  = URLRequestMethod.GET;
		public const POST:String = URLRequestMethod.POST;
		
		private var id:uint             = 0;
		private var x:int               = 0;
		private var y:int               = 0;
		private var width:uint          = 0;
		private var height:uint         = 0;
		private var angle:uint          = 0;
		private var frequency:uint      = 0;
		private var alpha:Number        = 1;
		private var timer:Timer         = null;
		private var image:DisplayObject = null;
		private var hasRun:Boolean      = true;
		private var isWakeUp:Boolean    = true;
		private var isFreeze:Boolean    = false;
		private var isSleep:Boolean     = false;
		private var isFinish:Boolean    = false;
		
		public function Process(frequency:uint = 25, x:int = 0, y:int = 0, graph:Class = null, angle:uint = 0) {			
			this.frequency = frequency;
			
			setImage(graph);
			setX(x);
			setY(y);	
			setAngle(angle);
			
			this.id = Maggie.mySelf.nextProcessId();
			Maggie.mySelf.addProcess(this);
			
			if (!Maggie.mySelf.isCentralClock()) {
				this.timer = new Timer(this.frequency);
				this.timer.addEventListener(TimerEvent.TIMER, cycle);
				this.timer.start();
			}
		}
		
		/**
		 * 	Fija un listener para cuando el proceso se congela
		 **/
		
		public final function onFreeze(func:Function):void {
			addEventListener(Signal.FREEZE, func);
		}
		
		/**
		 * 	Fija un listener para cuando el proceso se duerme
		 **/
		
		public final function onSleep(func:Function):void {
			addEventListener(Signal.FREEZE, func);
		}
		
		/**
		 * 	Fija un listener para cuando el proceso se despierta
		 **/
		
		public final function onWakeUp(func:Function):void {
			addEventListener(Signal.WAKE_UP, func);
		}
		
		/**
		 * 	Fija un listener para cuando el proceso finaliza
		 **/
		
		public final function onFinish(func:Function):void {
			addEventListener(Signal.FINISH, func);
		}
		
		/**
		 * 	Devuelve el angulo actual del proceso
		 **/
		
		public final function getAngle():uint {
			return this.angle;
		}
		
		/**
		 * 	Suma una cantidad al angulo actual del proceso
		 **/
		
		public final function addAngle(value:int):void {
			setAngle(this.angle + value);
		}
		
		/**
		 * 	Fija el angulo del proceso
		 **/
		
		public final function setAngle(newAngle:int):void {
			var oldAngle:uint = this.angle;
			
			if (newAngle < 0)
				this.angle = uint((newAngle % 360)) + 360;
			else
				this.angle = newAngle % 360;
			
			rotate(this.angle - oldAngle);
		}	
		
		/**
		 * 	Avanza el proceso en el angulo correspondiente
		 **/	
		
		public final function advance(value:int):void {
			var valueX:int = int(cos(this.angle) * value);
			var valueY:int = int(sin(this.angle) * value);
			
			this.x       += valueX;
			this.y       -= valueY;
			this.image.x += valueX;
			this.image.y -= valueY;
		}
		
		/**
		 * 	Programa una funcion que se llamará pasado el tiempo indicado
		 **/
		 
		public final function alarm(func:Function, time:uint):void {
			Maggie.mySelf.alarm(func, time);
		}
		
		/**
		 * 	Mata a todos los procesos excepto al que invoca a esta funcion
		 **/
		
		public final function letMeAlone():void {
			Maggie.mySelf.letMeAlone(this);
		}
		
		/**
		 * 	Devuelve true si el proceso existe
		 **/ 
		
		public final function existsProcess(process:Process):Boolean {
			return Maggie.mySelf.existsProcess(process);
		}
		
		/**
		 * 	Devuelve true si existe un proceso de esa clase
		 **/
		
		public final function existsType(type:Class):Boolean {
			return Maggie.mySelf.existsType(type);
		}
		
		/**
		 * 	Devuelve la imagen del proceso
		 **/
		
		internal final function getImage():DisplayObject {
			return this.image;
		}
		
		/**
		 * 	Devuelve el color del pixel de la imagen en las coordenadas (x,y)
		 **/
		
		public final function getPixel(graph:Class, x:int, y:int, width:uint = 0, height:uint = 0):uint {
			return Maggie.mySelf.getPixel(graph, x, y, width, height);
		}
		
		/**
		 *	Agrega un texto a la lista de textos
		 **/
		
		public final function addText(x:int = 0, y:int = 0, text:String = "", color:Object = "0x000000", font:String = "Verdana", size:uint = 10, bold:Boolean = false, center:Boolean = false):TextLabel {
			return Maggie.mySelf.addText(x, y, text, color, font, size, bold, center);
		}
		
		/**
		 *	Fija la imagen del proceso
		 **/
		
		public final function setImage(graph:Class = null):void {
			if (this.image == null) {
				
				if (graph == null)
					this.image = new Sprite();
				else
					this.image = new graph();
					
				this.width       = this.image.width;
				this.height      = this.image.height;
				this.image.alpha = this.alpha;
				Maggie.mySelf.stage.addChild(this.image);
				
			} else {
				
				if (graph != null) { 
				
					if (!(this.image is graph)) {
						
						Maggie.mySelf.stage.removeChild(this.image);
						
						this.image       = new graph();
						this.image.alpha = this.alpha;
						this.image.x     = this.x;
						this.image.y     = this.y;
						this.width       = this.image.width;
						this.height      = this.image.height;
						
						Maggie.mySelf.stage.addChild(this.image);
					}
					
				} else {
					
					Maggie.mySelf.stage.removeChild(this.image);
					
					this.image       = new Sprite();
					this.width       = this.image.width;
					this.height      = this.image.height;
					this.image.alpha = this.alpha;
					
					Maggie.mySelf.stage.addChild(this.image);
				}
			}
		}
		
		/**
		 *	Devuelve true si la imagen es visible
		 **/
		
		internal final function isVisible():Boolean {
			return (this.image != null) && (this.image.visible);
		}
		
		/**
		 *	Fija la transparencia de la imagen del proceso
		 **/
		
		public final function setAlpha(value:Number):void {
			this.alpha = value;
			
			if (this.image != null)
				this.image.alpha = value;
		}
		
		/**
		 * 	Devuelve la coordenada X del raton
		 **/
		
		public final function getMouseX():int {
			return Maggie.mySelf.getMouseX();
		}
		
		/**
		 * 	Devuelve la coordenada Y del raton
		 **/
		
		public final function getMouseY():int {
			return Maggie.mySelf.getMouseY();
		}
		
		/**
		 * 	Devuelve true si el proceso esta dormido
		 **/
		
		public final function isSleeping():Boolean {
        	return this.isSleep;
        }
        
        /**
		 * 	Devuelve true si el proceso esta congelado
		 **/
        
        public final function isFrozen():Boolean {
        	return this.isFreeze;
        }
        
        /**
		 * 	Devuelve true si el proceso esta despierto
		 **/
        
        public final function isAwake():Boolean {
        	return this.isWakeUp;
        }
        
        /**
		 * 	Detiene el reloj
		 **/
        
        private function stopClock():void {
        	if (this.timer != null)
        		this.timer.stop();
        }
        
        /**
		 * 	Inicia el reloj
		 **/
        
        private function startClock():void {
        	if (this.timer != null)
        		this.timer.start();
        }
        
        /**
		 * 	Inicia el reloj
		 **/
        
        private function clockRunning():Boolean {
        	return ((this.timer != null) && (this.timer.running));
        }
        
        /**
		 * 	Duerme al proceso
		 **/
        
        public final function sleep():void {
        	this.image.visible = false;
        	this.isSleep  = true;
        	this.isFreeze = false;
        	this.isWakeUp = false;
        	stopClock();
        	dispatchEvent(new Signal(Signal.SLEEP));
        }
        
        /**
		 * 	Congela al proceso
		 **/
        
        public final function freeze():void {
        	this.image.visible = true;
        	this.isFreeze = true;
        	this.isSleep  = false;
        	this.isWakeUp = false;
        	stopClock();
        	dispatchEvent(new Signal(Signal.FREEZE));
        }
        
        /**
		 * 	Despierta al proceso
		 **/
        
        public final function wakeUp():void {
        	this.image.visible = true;
        	this.isFreeze = false;
        	this.isSleep  = false;
        	this.isWakeUp = true;
        	startClock();
        	dispatchEvent(new Signal(Signal.WAKE_UP));	
        }
        
        /**
		 * 	Finaliza el proceso
		 **/
        
        public final function finish(sendSignal:Boolean = true):void {
        	this.isFinish = true;
        	this.isWakeUp = false;
        	
			if (sendSignal)
				dispatchEvent(new Signal(Signal.FINISH));
			
			Maggie.mySelf.deleteProcess(this);
			
			if (this.image != null) {
				Maggie.mySelf.stage.removeChild(this.image);
				this.image = null;
			}
			
			if (this.timer != null) {
				this.timer.stop();
				this.timer = null;
			}
		}
		
		/**
		 * 	Devuelve el ancho de la pantalla
		 **/
        
        public final function getScreenWidth():uint {
			return Maggie.mySelf.getScreenWidth();
		}
		
		/**
		 * 	Devuelve el alto de la pantalla
		 **/
		
		public final function getScreenHeight():uint {
			return Maggie.mySelf.getScreenHeight();
		}
		
		/**
		 * 	Devuelve el Id del proceso
		 **/
		
		internal final function getId():uint {
			return this.id;
		}
		
		/**
		 * 	Devuelve el ancho de la imagen
		 **/
		
		public final function getWidth():uint {
			return uint(this.image.width);
		}
		
		/**
		 * 	Devuelve el alto de la imagen
		 **/
		
		public final function getHeight():uint {
			return uint(this.image.height);
		}
		
		/**
		 * 	Fija la escala de la imagen
		 **/
		
		public final function setScale(value:Number):void {
			setScaleX(value);
			setScaleY(value);
		}
		
		/**
		 * 	Fija la escala en X
		 */
		
		public final function setScaleX(value:Number):void {
			var oldWidth:uint = this.image.width;
			this.image.width  = uint(this.width * value);
			
			if (oldWidth != this.image.width)
				setX(getX() + ((oldWidth - this.image.width)/2));
		}
		
		/**
		 * 	Fija la escala en Y
		 */
		
		public final function setScaleY(value:Number):void {
			var oldHeight:uint = this.image.height;
			this.image.height  = uint(this.height * value);
			
			if (oldHeight != this.image.height)
				setY(getY() + ((oldHeight - this.image.height)/2));
		}
		
		/**
		 * 	Devuelve la referencia de un proceso si éste colisiona con él
		 **/
		
		public final function collision(type:Class = null):Process {			
			return Maggie.mySelf.collision(this, type);
		}
		
		/**
		 *	Debvuelve true una si hay colision con el proceso indicado
		 **/
		
		public final function collisionWith(process: Process):Boolean {
			return Maggie.mySelf.collisionWith(this, process);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla indicada
		 **/
		
		public final function key(code:uint):Boolean {
			return Maggie.mySelf.isKeyPressed(code);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla UP
		 **/
		
		public final function keyUp():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.UP);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla DOWN
		 **/
		
		public final function keyDown():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.DOWN);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla LEFT
		 **/
		
		public final function keyLeft():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.LEFT);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla RIGHT
		 **/
		
		public final function keyRight():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.RIGHT);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla SPACE
		 **/
		
		public final function keySpace():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.SPACE);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla ESCAPE
		 **/
		
		public final function keyEscape():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.ESCAPE);
		}
		
		/**
		 *	Devuelve true si se ha presionado la tecla ENTER
		 **/
		
		public final function keyEnter():Boolean {
			return Maggie.mySelf.isKeyPressed(Keyboard.ENTER);
		}
		
		/**
		 *	Mueve la imagen hacia abajo
		 **/
		
		public final function moveDown(value:int):void {
			this.image.y += value;
			this.y = this.image.y;
		}
		
		/**
		 *	Mueve la imagen hacia arriba
		 **/
		
		public final function moveUp(value:int):void {
			this.image.y -= value;
			this.y = this.image.y;
		}
		
		/**
		 *	Mueve la imagen hacia la izquierda
		 **/
		
		public final function moveLeft(value:int):void {
			this.image.x -= value;
			this.x = this.image.x;
		}
		
		/**
		 *	Mueve la imagen hacia la derecha
		 **/
		
		public final function moveRight(value:int):void {
			this.image.x += value;
			this.x = this.image.x;
		}
		
		/**
		 *	Devuelve la coordenada X del proceso
		 **/
		
		public final function getX():int {
			return this.x;
		}
		
		/**
		 *	Devuelve la coordenada Y del proceso
		 **/
		
		public final function getY():int {
			return this.y;
		}
		
		/**
		 *	Fija la coordenada X del proceso
		 **/
		
		public final function setX(value:int):void {
			this.image.x = value;
			this.x = this.image.x;
		}
		
		/**
		 *	Fija la coordenada Y del proceso
		 **/
		
		public final function setY(value:int):void {
			this.image.y = value;
			this.y = this.image.y;
		}
		
		/**
		 *	Metodo principal del proceso
		 **/
		
		public function run():void {
			this.hasRun = false;
		}
		
		/**
		 * 	Devuelve un numero aleatorio entre min y max
		 **/
		
		public final function random(min:int, max:int):int {
			return Maggie.mySelf.random(min, max);
		}
		
		/**
		 * 	Reproduce un sonido
		 **/
		
		public final function playAudio(sound:Class, loop:Boolean = false):Audio {
            return Maggie.mySelf.playAudio(sound, loop);
		}
		
		/**
		 * 	Detiene todos los sonidos que se estan reproduciendo
		 **/
		
		public final function stopAllAudio():void {
			Maggie.mySelf.stopAllAudio();
		}
		
		/**
		 * 	Reproduce la musica
		 **/
		
		public final function playMusic(sound:Class):void {
			Maggie.mySelf.playMusic(sound);
		}
		
		/**
		 * 	Detiene la musica
		 **/
		
		public final function stopMusic():void {
			Maggie.mySelf.stopMusic();
		}
		
		/**
		 * 	Reinicia la musica
		 **/
		
		public final function restartMusic():void {
			Maggie.mySelf.restartMusic();
		}
		
		/**
		 * 	Devuelve true si la musica se esta reproduciendo
		 **/
		
		public final function isPlayingMusic():Boolean {
			return Maggie.mySelf.isPlayingMusic();
		}
		
		/**
		 * 	Devuelve el angulo entre el proceso y el indicado
		 **/
				
		public final function getAngleWith(process:Process):uint {
			return -((Math.atan2(process.getY() - getY(), process.getX() - getX())) * 180.0) / Math.PI;
		}
		
		/**
		 * 	Devuelve la distancia entre el proceso y el indicado
		 **/
		
		public final function getDistance(process:Process):uint {
			return Math.sqrt(Math.pow(getX() - process.getX(), 2) + Math.pow(getY() - process.getY(), 2));
		}
		
		/**
		 * 	Devuelve la distancia sobre el eje X entre el proceso y el indicado
		 **/
		
		public final function getDistanceX(process:Process):uint {
			return Math.abs(getX() - process.getX());
		}
		
		/**
		 * 	Devuelve la distancia sobre el eje Y entre el proceso y el indicado
		 **/
		
		public final function getDistanceY(process:Process):uint {
			return Math.abs(getY() - process.getY());
		}
		
		/**
		 * 	Ejecuta el metodo run si el proceso lo tiene implementado
		 **/
		
		private function cycle(event:TimerEvent):void {
			if (this.hasRun) {
				if (clockRunning())
					run();
			} else
				stopClock();
		}
		
		/**
		 * 	Convierte los angulos a radianes
		 **/
		
		private function toRadian(angle:int):Number {
			return (angle * Math.PI) / 180.0;
		}
		
		/**
		 * 	Calcula el coseno de un angulo
		 **/
		
		private function cos(angle:uint):Number {
			return Math.cos(toRadian(angle));
		}
		
		/**
		 * 	Calcula el seno de un angulo
		 **/
		
		private function sin(angle:uint):Number {
			return Math.sin(toRadian(angle));
		}
		
		/**
		 * 	Rota la imagen del proceso
		 **/
		
		private function rotate(angle:int):void {
			var center:Point  = new Point(getX() + (this.width/2), getY() + (this.height/2));
			var matrix:Matrix = this.image.transform.matrix;
			matrix.tx -= center.x;
			matrix.ty -= center.y;
			matrix.rotate(-toRadian(angle));
			matrix.tx += center.x;
			matrix.ty += center.y;
			this.image.transform.matrix = matrix;
		}
		
		/**
		 * 	Ejecuta el fade in
		 **/
        
        public final function fadeIn(from:Number, until:Number, step:Number, frequency:uint, onFinish:Function = null):void {
			if (from < until) {
        		this.image.alpha = from;
        		alarm(Maggie.mySelf.partialEvent(fadeIn, from + step, until, step, frequency, onFinish), frequency);
     		} else if (onFinish != null)
     			onFinish();
		}
		
		/**
		 * 	Ejecuta el fade out
		 **/
		
		public final function fadeOut(from:Number, until:Number, step:Number, frequency:uint, onFinish:Function = null):void {
			if (from > until) {
        		this.image.alpha = from;
        		alarm(Maggie.mySelf.partialEvent(fadeOut, from - step, until, step, frequency, onFinish), frequency);
     		} else if (onFinish != null)
     			onFinish();
		}
		
		/**
		 * 	Carga la fuente
		 **/
		
		public final function loadFont(font:Class):void {
			Maggie.mySelf.loadFont(font);
		}
		
		/**
		 * 	Devuelve true si la fuente ha sido cargada
		 **/
		
		public final function existFont(name:String):Boolean {
			return Maggie.mySelf.existFont(name);
		}
		
		/**
		 * 	Muestra el ratón
		 **/
		
		public final function mouseEnable():void {
			Maggie.mySelf.mouseEnable();
		}
		
		/**
		 * 	Oculta el ratón
		 **/
		
		public final function mouseDisable():void {
			Maggie.mySelf.mouseDisable();
		}
		
		/**
		 *	Elimina todos los textos de la lista de textos
		 **/
		
		public final function deleteAllText():void {
			Maggie.mySelf.deleteAllText();
		}
		
		/**
		 * 	Fija la imagen de fondo
		 **/
		
		public final function setBackGroundImage(image:Class):void {
			Maggie.mySelf.setBackGroundImage(image);
		}
		
		/**
		 * 	Elimina la imagen de fondo
		 **/
		
		public final function deleteBackGroundImage():void {
			Maggie.mySelf.deleteBackGroundImage();
		}
		
		/**
		 * 	Envia una peticion al servidor
		 **/
		
		public final function dataRequest(url:String, complete:Function, fail:Function = null, parameters:Object = null, method:String = "post"):void {
			Maggie.mySelf.dataRequest(url, complete, fail, parameters, method);
		}
		
		/**
		 * 	Fija los frames por segundo
		 **/
		
		public final function setFps(fps:uint):void {
			Maggie.mySelf.setFps(fps);
		}
	}
}