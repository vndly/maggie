package maggie {
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class TextLabel extends TextField {
		
		private var id:uint = 0;
		
		public function TextLabel(x:int = 0, y:int = 0, text:String = "", color:Object = "0x000000", font:String = "Verdana", size:uint = 10, bold:Boolean = false, center:Boolean = false) {
			super();
			
			this.id         = Maggie.mySelf.nextTextId();
			this.x          = x;
			this.y          = y;
			this.text       = text;
			this.selectable = false;
			this.autoSize   = TextFieldAutoSize.LEFT;
			this.embedFonts = Maggie.mySelf.existFont(font);
			
			this.addEventListener(Event.ADDED, centerText);
			
			var format:TextFormat = new TextFormat();
			format.color = color;
    		format.font  = font;
    		format.size  = size;
    		format.bold  = bold;
    		format.align = center ? TextFormatAlign.CENTER : TextFormatAlign.LEFT;
    		
    		setFormat(format);
		}
		
		/**
		 * 	Centra el texto en la pantalla
		 **/
		
		private function centerText(event:Event):void {
			if (this.defaultTextFormat.align == TextFormatAlign.CENTER) {
				this.x = (Maggie.mySelf.getScreenWidth() / 2) - (this.textWidth / 2);
				this.removeEventListener(Event.ADDED, centerText);
			}
		}
		
		/**
		 * 	Fija le formato del texto
		 **/
		
		private function setFormat(format:TextFormat):void {
			this.defaultTextFormat = format;
    		this.setTextFormat(format);
		}
		
		/**
		 * 	Devuelve el formato del texto
		 **/
		
		private function getFormat():TextFormat {
			var oldFormat:TextFormat = this.defaultTextFormat;
			
			var format:TextFormat = new TextFormat();
			format.color = oldFormat.color;
    		format.font  = oldFormat.font;
    		format.size  = oldFormat.size;
    		format.bold  = oldFormat.bold;
    		format.align = oldFormat.align;
    		
    		return format;
		}
		
		/**
		 * 	Devuelve el Id del texto
		 **/
		
		internal final function getId():uint {
			return this.id;
		}
		
		/**
		 * 	Fija la coordenada X del texto
		 **/
		
		public final function setX(value:int):void {
			this.x = value;
		}
		
		/**
		 * 	Fija la coordenada Y del texto
		 **/
		
		public final function setY(value:int):void {
			this.y = value;
		}
		
		/**
		 * 	Devuelve la coordenada X del texto
		 **/
		
		public final function getX():int {
			return this.x;
		}
		
		/**
		 * 	Devuelve la coordenada Y del texto
		 **/
		
		public final function getY():int {
			return this.y;
		}
		
		/**
		 * 	Mueve el texto hacia arriba
		 **/
		 
		public final function moveUp(value:int):void {
			this.y -= value;
		}
		
		/**
		 * 	Mueve el texto hacia abajo
		 **/
		
		public final function moveDown(value:int):void {
			this.y += value;
		}
		
		/**
		 * 	Mueve el texto hacia la izquierda
		 **/
		
		public final function moveLeft(value:int):void {
			this.x -= value;
		}
		
		/**
		 * 	Mueve el texto hacia la derecha
		 **/
		
		public final function moveRight(value:int):void {
			this.x += value;
		}
		
		/**
		 * 	Fija el valor del texto
		 **/
		
		public final function setText(value:String):void {
			this.text = value;
		}
		
		/**
		 *	Devuelve el valor actual del texto
		 **/
		
		public final function getText():String {
			return this.text;
		}
		
		/**
		 * 	Devuelve el ancho del texto
		 **/
		
		public final function getWidth():uint {
			return this.width;
		}
		
		/**
		 * 	Devuelve el alto del texto
		 **/
		
		public final function getHeight():uint {
			return this.height;
		}
		
		/**
		 * 	Fija el color de fondo del texto
		 **/
		
		public final function setBackgroundColor(color:uint):void {
			this.background      = true;
			this.backgroundColor = color;
		}
		
		/**
		 * 	Elimina el color de fondo del texto
		 **/
		
		public final function removeBackgroundColor():void {
			this.background = false;
		}
		
		/**
		 * 	Fija el color del borde del texto
		 **/
		
		public final function setBorderColor(color:uint):void {
			this.border = true;
			this.borderColor = color;
		}
		
		/**
		 * 	Elimina el color del borde del texto
		 **/
		
		public final function removeBorderColor():void {
			this.border = false;
		}
		
		/**
		 * 	Fija el color del texto
		 **/
		
		public final function setColor(value:String):void {
			var format:TextFormat = getFormat();
			format.color = value;
			setFormat(format);			
		}
		
		/**
		 * 	Devuelve el color del texto
		 **/
		
		public final function getColor():String {
			return this.defaultTextFormat.color.toString();
		}
		
		/**
		 * 	Fija la fuente del texto
		 **/
		
		public final function setFont(value:String):void {
			this.embedFonts = Maggie.mySelf.existFont(value);
			
			if (this.embedFonts) {
				var format:TextFormat = getFormat();
				format.font = value;
				setFormat(format);
			}	
		}
		
		/**
		 * 	Devuelve la fuente del texto
		 **/
		
		public final function getFont():String {
			return this.defaultTextFormat.font;
		}
		
		/**
		 * 	Fija el tamaño del texto
		 **/
		
		public final function setSize(value:uint):void {
			var format:TextFormat = getFormat();
			format.size = value;
			setFormat(format);	
		}
		
		/**
		 * 	Devuelve el tamaño del texto
		 **/
		
		public final function getSize():uint {
			return uint(this.defaultTextFormat.size);
		}
		
		/**
		 * 	Fija en negrita el texto
		 **/
		
		public final function setBold(bold:Boolean = true):void {
			var format:TextFormat = getFormat();
			format.bold = bold;
			setFormat(format);	
		}
		
		/**
		 * 	Devuelve true si el texto esta en negrita
		 **/
		
		public final function isBold():Boolean {
			return this.defaultTextFormat.bold;
		}
		
		/**
		 * 	Fija la alineacion del texto
		 **/
		
		public final function setCenter(center:Boolean):void {
			var format:TextFormat = getFormat();
			format.align = center ? TextFormatAlign.CENTER : TextFormatAlign.LEFT;
			setFormat(format);			
		}
		
		/**
		 * 	Devuelve true si el texto esta centrado
		 **/
		
		public final function isCenter():Boolean {
			return (this.defaultTextFormat.align == TextFormatAlign.CENTER);
		}
		
		/**
		 * 	Elimina el texto
		 **/
		
		public final function remove():void {
			Maggie.mySelf.deleteText(this);
		}
	}
}