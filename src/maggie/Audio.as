package maggie {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Audio extends EventDispatcher {
		
		private var id:uint              = 0;
		private var data:Class           = null;
		private var sound:Sound          = null;
		private var channel:SoundChannel = null;
		private var loop:Boolean         = false;
		private var playing:Boolean      = false;
		
		public function Audio(sound:Class, loop:Boolean) {
			this.data = sound;
			this.loop = loop;
			
			this.id = Maggie.mySelf.nextAudioId();
			Maggie.mySelf.addAudio(this);
			
			play();
		}
		
		/**
		 * 	Devuelve el Id del audio
		 **/
		
		internal final function getId():uint {
			return this.id;
		}
		
		/**
		 * 	Reproduce el audio
		 **/
		
		public final function play():void {
			this.sound = new this.data as Sound;
			
			if (this.sound.length > 0) {
				this.channel = this.sound.play();
				this.playing = true;
				
				if (this.channel != null)
					this.channel.addEventListener(Event.SOUND_COMPLETE, soundFinish);
			}
		}
		
		/**
		 * 	Finaliza el audio
		 **/
		 
		public final function finish():void {
			stop();
			
			this.sound   = null;
			this.channel.removeEventListener(Event.SOUND_COMPLETE, soundFinish);
			this.channel = null;
			
			Maggie.mySelf.deleteAudio(this);
			
			dispatchEvent(new Signal(Signal.FINISH));
		}
		
		/**
		 * 	Devuelve true si el audio se esta reproduciendo
		 **/
		
		public final function isPlaying():Boolean {
			return this.playing;
		}
		
		/**
		 *	Fija el listener cuando el audio finaliza
		 **/
		
		public final function onFinish(func:Function):void {
			addEventListener(Signal.FINISH, func);
		}
		
		/**
		 * 	Detiene la reproduccion del audio
		 **/
		
		public final function stop():void {
			this.playing = false;
			
			if (this.channel != null)
				this.channel.stop();
		}
		
		/**
		 * 	Listener para cuando termina la reproduccion del audio
		 **/
		
		private function soundFinish(event:Event):void {
			if (this.loop)
				play();
			else
				finish();
		}
	}
}