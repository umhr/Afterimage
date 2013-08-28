package  
{
	
	import fl.motion.ColorMatrix;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	/**
	 * ...
	 * @author umhr
	 */
	public class VideoManager extends Sprite 
	{
		private static var _instance:VideoManager;
		private var _video:Video;
		public function VideoManager(block:Block){init();};
		public static function getInstance():VideoManager{
			if ( _instance == null ) {_instance = new VideoManager(new Block());};
			return _instance;
		}
		
		
		private function init():void
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			var connection:NetConnection = new NetConnection();
			connection.connect(null);
			var netStream:NetStream = new NetStream(connection);

			var obj:Object = new Object();
			obj.onMetaData = function (param:Object):void{

				trace("総時間 : " + param.duration + "秒");
				trace("幅 : " + param.width);
				trace("高さ : " + param.height);
				trace("ビデオレート : " + param.videodatarate + "kb");
				trace("フレームレート : " + param.framerate + "fps");
				trace("コーデックＩＤ : " + param.videocodecid);

				var key:String;
				for (key in param){
					trace(key + ": " + param[key]);
				}
			};
			netStream.client = obj;
			netStream.play("movie.flv");
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStream_netStatus);
			
			_video = new Video();
			addChild(_video);
			_video.attachNetStream(netStream);
			
			var trans:SoundTransform = netStream.soundTransform;
			trans.volume = 0;
			netStream.soundTransform = trans;
		}
		
		private function netStream_netStatus(event:NetStatusEvent):void 
		{
			var netStream:NetStream = event.target as NetStream;
			trace(event.info.code);
			switch(event.info.code) {
				
				case "NetStream.Play.Stop":
				trace("再生の停止");
				netStream.play("movie.flv");
				break;
			}
		}
		
		public function getBitmapData(isMirror:Boolean, brightness:Number, contrast:Number, hue:Number, saturation:Number):BitmapData {
			var bitmapData:BitmapData = new BitmapData(320, 240, true, 0x0);
			
			if (_video) {
				if (isMirror) {
					var matrix:Matrix = new Matrix(-1,0,0,1);
					matrix.rotate(180 * 0.017453292519943295);
					matrix.translate(0, 240);
					bitmapData.draw(_video, matrix, null, null, new Rectangle(0, 120, 320, 120));
					bitmapData.draw(_video, null, null, null, new Rectangle(0, 0, 320, 120));
				}else {
					bitmapData.draw(_video);
					
				}
			}
			setColorMatrix(bitmapData, brightness, contrast, hue, saturation);
			return bitmapData;
		}
		
		private function setColorMatrix(bitmapData:BitmapData, brightness:Number, contrast:Number, hue:Number, saturation:Number):void 
		{
			var colorMatrix:ColorMatrix = new ColorMatrix();
			// 明度
			var brightnessColorMatrix:ColorMatrix = new ColorMatrix();
			brightnessColorMatrix.SetBrightnessMatrix(brightness);
			// コントラスト
			var contrastColorMatrix:ColorMatrix = new ColorMatrix();
			contrastColorMatrix.SetContrastMatrix(contrast);
			// 色相
			var hueColorMatrix:ColorMatrix = new ColorMatrix();
			hueColorMatrix.SetHueMatrix(hue);
			// 彩度
			var saturationColorMatrix:ColorMatrix = new ColorMatrix();
			saturationColorMatrix.SetSaturationMatrix(saturation);
			
			// 複数の処理をする場合は、行列の乗算をする。
			colorMatrix.Multiply(brightnessColorMatrix);
			colorMatrix.Multiply(contrastColorMatrix);
			colorMatrix.Multiply(hueColorMatrix);
			colorMatrix.Multiply(saturationColorMatrix);
			
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			var flatMatrix:Array = colorMatrix.GetFlatArray();
			colorMatrixFilter.matrix = flatMatrix;
			
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), colorMatrixFilter.clone());
		}
		
	}
	
}
class Block { };