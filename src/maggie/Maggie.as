package maggie {
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLRequestMethod;
	import flash.system.System;
	import flash.text.Font;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	public class Maggie extends Sprite {
		
		public const GET:String  = URLRequestMethod.GET;
		public const POST:String = URLRequestMethod.POST;
		
		private  static var processId:uint     = 1;
		private  static var textId:uint        = 1;
		private  static var audioId:uint       = 1;
		private  static var music:Audio        = null;
		internal static var mySelf:Maggie      = null;
		private  static var centralClock:Timer = null;
		private  static var keys:Array         = new Array();
		private  static var fontList:Table     = new Table(Font);
		private  static var audioList:Table    = new Table(Audio);
		private  static var processList:Table  = new Table(Process);
		private  static var textList:Table     = new Table(TextLabel);
		
		/**
		 * 
		 * Constructor: 
		 * 	-	Inicializa las variables del motor.
		 * 	-	Inicializa los listeneres del teclado.
		 * 	-	Borra la imagen de fondo.
		 * 	-	Inicializa la musica.
		 * 
		 **/
		
		public function Maggie(frequency:uint = 0) {
			Maggie.mySelf = this;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP,   keyReleased);
			
            stage.align     = StageAlign.TOP_LEFT;
            stage.quality   = StageQuality.BEST;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            setFps(30);
            deleteBackGroundImage();
            playMusic(Sound);
            
            if (frequency > 0) {
            	Maggie.centralClock = new Timer(frequency);
            	Maggie.centralClock.addEventListener(TimerEvent.TIMER, cycle);
				Maggie.centralClock.start();
            }
		}
		
		/**
		 * 	Ejecuta el metodo run de cada proceso despierto si este lo tiene implementado
		 **/
		
		private function cycle(event:TimerEvent):void {
			var list:Array = processList.toArray();
			
			for each (var process:Process in list) {
				if (process.isAwake())
					process.run();
			}
		}
		
		/**
		 *  Devvuelve true si esta fijado el reloj central
		 **/
		
		internal final function isCentralClock():Boolean {
			return Maggie.centralClock != null;
		}
		
		/** 
		 * Incrementador de Id de procesos
		 **/
		
		internal final function nextProcessId():uint {
			return (processId++);
		}
		
		/** 
		 * Incrementador de Id de textos
		 **/
		
		internal final function nextTextId():uint {
			return (textId++);
		}
		/** 
		 * Incrementador de Id de audios
		 **/
		
		internal final function nextAudioId():uint {
			return (audioId++);
		}
		
		/**
		 *	Detecta una si hay colision entre dos procesos 
		 **/
		
		internal final function collisionWith(process1: Process, process2: Process):Boolean {
			if (!process1.isVisible() || !process2.isVisible())
				return false;
			
			var firstObj:DisplayObject  = process1.getImage(); 
			var secondObj:DisplayObject = process2.getImage();
			
			var x1:int = process1.getX();
			var y1:int = process1.getY();
			
			var x2:int = process2.getX();
			var y2:int = process2.getY();
			
			if ((firstObj == null) || (secondObj == null))
				return false;
			
			var bounds1:Rectangle = firstObj.getBounds(firstObj.root);
			var bounds2:Rectangle = secondObj.getBounds(secondObj.root);
			
			bounds1.x = process1.getX();
			bounds1.y = process1.getY();

			bounds2.x = process2.getX();
			bounds2.y = process2.getY();
			
			if (((bounds1.right < bounds2.left) || (bounds2.right < bounds1.left)) || ((bounds1.bottom < bounds2.top) || (bounds2.bottom < bounds1.top)))
				return false;
			
			var bounds:Object = {};
			bounds.left   = Math.max(bounds1.left,bounds2.left);
			bounds.right  = Math.min(bounds1.right,bounds2.right);
			bounds.top    = Math.max(bounds1.top,bounds2.top);
			bounds.bottom = Math.min(bounds1.bottom,bounds2.bottom);
			
			var w:Number = bounds.right  - bounds.left;
			var h:Number = bounds.bottom - bounds.top;
			
			if (w < 1 || h < 1)
				return false;
			
			var bitmapData:BitmapData = new BitmapData(w, h, false);
			
			var matrix:Matrix = firstObj.transform.concatenatedMatrix;
			matrix.tx -= bounds.left;
			matrix.ty -= bounds.top;
			bitmapData.draw(firstObj,matrix,new ColorTransform(1,1,1,1,255,-255,-255,255));
			
			matrix = secondObj.transform.concatenatedMatrix;
			matrix.tx -= bounds.left;
			matrix.ty -= bounds.top;
			bitmapData.draw(secondObj,matrix,new ColorTransform(1,1,1,1,255,255,255,255),BlendMode.DIFFERENCE);
			
			var intersection:Rectangle = bitmapData.getColorBoundsRect(0xFFFFFFFF,0xFF00FFFF);
			
			if (intersection.width == 0)
				return false;
			
			return (intersection != null);
		}
		
		/**
		 * 	Detecta si hay colision entre un proceso con cualquiera de la lista
		 **/
		
		internal final function collision(proc:Process, type:Class = null):Process {
			var process:Process = null;
			var list:Array = processList.toArray();
			
			for each (var element:Process in list) {
				if (((type == null) || ((type != null) && (element is type))) && (collisionWith(element, proc))) {
					process = element;
					break;
				}
			}
			
			return process;
		}
		
		/**
		 * 	Mata a todos los procesos excepto al que invoca a esta funcion
		 **/
		
		internal final function letMeAlone(process:Process):void {
			var list:Array = processList.toArray();
			
			for each (var element:Process in list) {
				if (element !== process)
					element.finish(false);
			}
		}
		
		/**
		 * 	Devuelve el color del pixel de la imagen en las coordenadas (x,y)
		 **/
		
		public final function getPixel(graph:Class, x:int, y:int, width:uint = 0, height:uint = 0):uint {
			var image:DisplayObject = new graph();
			
			if ((width > 0) && (height > 0)) {
				image.width  = width;
				image.height = height;
			}
			
			var bitMapData:BitmapData = new BitmapData(image.width, image.height)
			bitMapData.draw(image) 
			
			return bitMapData.getPixel(x, y);
		}
		
		/**
		 * 	Devuelve true si el proceso existe
		 **/ 
		
		public final function existsProcess(process:Process):Boolean {
			var list:Array    = processList.toArray();
			var exist:Boolean = false;
			
			for each (var element:Process in list) {
				if (element === process) {
					exist = true;
					break;
				}
			}
			
			return exist;
		}
		
		/**
		 * 	Devuelve true si existe un proceso de esa clase
		 **/
		
		public final function existsType(type:Class):Boolean {
			var list:Array    = processList.toArray();
			var exist:Boolean = false;
			
			for each (var element:Process in list) {
				if (element is type) {
					exist = true;
					break;
				}
			}
			
			return exist;
		}
		
		/**
		 * 	Carga la fuente
		 **/
		
		public final function loadFont(font:Class):void {
			var instance:Font = new font();
			fontList.add(instance.fontName, instance);
		}
		
		/**
		 * 	Devuelve true si la fuente ha sido cargada
		 **/
		
		public final function existFont(name:String):Boolean {
			var list:Array    = fontList.toArray();
			var exist:Boolean = false;
			
			for each (var font:Font in list) {
				if (font.fontName == name) {
					exist = true;
					break;
				}
			}
			
			return exist;
		}
		
		/**
		 * 	Muestra el ratón
		 **/
		
		public final function mouseEnable():void {
			Mouse.show();
		}
		
		/**
		 * 	Oculta el ratón
		 **/
		
		public final function mouseDisable():void {
			Mouse.hide();
		}
		
		/**
		 *	Agrega un proceso a la lista de procesos
		 **/
		
		internal final function addProcess(process:Process):void {
			processList.add(String(process.getId()), process);
		}
		
		/**
		 *	Elimina un proceso de la lista de procesos
		 **/
		
		internal final function deleteProcess(process:Process):void {
			processList.remove(String(process.getId()));
		}
		
		/**
		 *	Agrega un sonido a la lista de sonidos
		 **/
		
		internal final function addAudio(audio:Audio):void {
			audioList.add(String(audio.getId()), audio);
		}
		
		/**
		 *	Elimina un sonido de la lista de sonidos
		 **/
		
		internal final function deleteAudio(audio:Audio):void {
			audioList.remove(String(audio.getId()));
		}
		
		/**
		 *	Agrega un texto a la lista de textos
		 **/
		
		public final function addText(x:int = 0, y:int = 0, text:String = "", color:Object = "0x000000", font:String = "Verdana", size:uint = 10, bold:Boolean = false, center:Boolean = false):TextLabel {
			var label:TextLabel = new TextLabel(x, y, text, color, font, size, bold, center);
			
			textList.add(String(label.getId()), label);
			mySelf.stage.addChild(label);
			
			return label;
		}
		
		/**
		 *	Elimina un texto de la lista de textos
		 **/
		
		internal final function deleteText(label:TextLabel):void {
			textList.remove(String(label.getId()));
			
			if (mySelf.stage.contains(label))
				mySelf.stage.removeChild(label);
		}
		
		/**
		 *	Elimina todos los textos de la lista de textos
		 **/
		
		public final function deleteAllText():void {
			var list:Array = textList.toArray();
			
			for each (var label:TextLabel in list)
				deleteText(label)
		}
		
		/**
		 * 	Reproduce un sonido
		 **/
		
		public final function playAudio(sound:Class, loop:Boolean = false):Audio {
            var audio:Audio = new Audio(sound, loop);
            
            return audio;
		}
		
		/**
		 * 	Detiene todos los sonidos que se estan reproduciendo
		 **/
		
		public final function stopAllAudio():void {
			var list:Array = audioList.toArray();
			
			for each (var audio:Audio in list)
				audio.stop();
		}
		
		/**
		 * 	Reproduce la musica
		 **/
		
		public final function playMusic(sound:Class):void {
			music = new Audio(sound, true);
		}
		
		/**
		 * 	Detiene la musica
		 **/
		
		public final function stopMusic():void {
			music.stop();
		}
		
		/**
		 * 	Reinicia la musica
		 **/
		
		public final function restartMusic():void {
			music.stop();
			music.play();
		}
		
		/**
		 * 	Devuelve true si la musica se esta reproduciendo
		 **/
		
		public final function isPlayingMusic():Boolean {
			return music.isPlaying();
		}
		
		/**
		 * 	Marca como presionada la tecla
		 **/
		
		private function keyPressed(event:KeyboardEvent):void {
			keys[event.keyCode] = true;
		}
		
		/**
		 * 	Desmarca como presionada la tecla
		 **/
		
		private function keyReleased(event:KeyboardEvent):void {
			keys[event.keyCode] = false;
		}
		
		/**
		 * 	Devuelve true si la tecla ha sido presionada
		 **/
		
		internal final function isKeyPressed(code:uint):Boolean {
			return keys[code];
		}
		
		/**
		 * 	Fija la imagen de fondo
		 **/
		
		public final function setBackGroundImage(image:Class):void {
			var picture:DisplayObject = new image();
			
			if (!(picture is Sprite)) {
				picture.width  = getScreenWidth();
				picture.height = getScreenHeight();
			}
			
			mySelf.stage.addChildAt(picture, 0);
		}
		
		/**
		 * 	Elimina la imagen de fondo
		 **/
		
		public final function deleteBackGroundImage():void {
			setBackGroundImage(Sprite);
		}
		
		/**
		 * 	Construye una nueva funcion con nuevos argumentos
		 **/
		
		private final function totalEvent(func:Function, ... args):Function {
            return function(newArgs:*):* {
               return func.apply(null, args.concat(newArgs));
            }
        }
        
        /**
		 * 	Construye una nueva funcion con los mismos argumentos
		 **/
        
        internal final function partialEvent(func:Function, ... args):Function {
            return function(newArgs:*):* {
               return func.apply(null, args);
            }
        }
		
		/**
		 * 	Programa una funcion que se llamará pasado el tiempo indicado
		 **/
		
		public final function alarm(func:Function, time:uint):void {
			var timer:Timer = new Timer(time, 1);
			timer.addEventListener(TimerEvent.TIMER, totalEvent(alarmRing, timer, func));
			timer.start();
		}
		
		/**
		 * 	Llama a la funcion qeu se habia programado
		 **/
		
		private function alarmRing(timer:Timer, func:Function, evento:TimerEvent):void {
			timer.stop();
			func();
		}
		
		/**
		 * 	Devuelve el ancho de la pantalla
		 **/
		 
		public final function getScreenWidth():uint {
			return mySelf.stage.stageWidth;
		}
		
		/**
		 * 	Devuelve el alto de la pantalla
		 **/
		
		public final function getScreenHeight():uint {
			return mySelf.stage.stageHeight;
		}
		
		/**
		 * 	Devuelve la coordenada X del raton
		 **/
		
		public final function getMouseX():int {
			return mySelf.stage.mouseX;
		}
		
		/**
		 * 	Devuelve la coordenada Y del raton
		 **/
		
		public final function getMouseY():int {
			return mySelf.stage.mouseY;
		}
		
		/**
		 * 	Fija los frames por segundo
		 **/
		
		public final function setFps(fps:uint):void {
			mySelf.stage.frameRate = fps;
		}
		
		/**
		 * 	Envia una peticion al servidor
		 **/
		
		public final function dataRequest(url:String, complete:Function, fail:Function = null, parameters:Object = null, method:String = "post"):void {
			DataRequest.send(url, complete, fail, parameters, method);
		}
		
		/**
		 * 	Devuelve un numero aleatorio entre min y max
		 **/
		
		public final function random(min:int, max:int):int {
			return int(Math.floor(Math.random() * (max - min + 1)) + min);
		}
		
		/**
		 * 	Muestra la memoria utilizada
		 **/
		
		public final function showMemory():void {
			System.gc();
			trace(System.totalMemory/1000 + " KB")
		}
	}
}