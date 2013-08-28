package  
{
	import fl.motion.ColorMatrix;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	/**
	 * ...
	 * @author umhr
	 */
	public class CameraManager extends Sprite 
	{
		private static var _instance:CameraManager;
		private var _video:Video;
		private var _bitmapData:BitmapData = new BitmapData(320, 240, false, 0x0);
		public function CameraManager(block:Block){init();};
		public static function getInstance():CameraManager{
			if ( _instance == null ) {_instance = new CameraManager(new Block());};
			return _instance;
		}
		
		
		private function init():void
		{
			
			var camera:Camera = Camera.getCamera();
			//カメラの存在を確認
			if (camera) {
				camera.setMode(320, 240, 30);
				_video = new Video();
				_video.attachCamera(camera);
				this.addChild(_video);
				_bitmapData = new BitmapData(camera.width, camera.height, false, 0x0);
			} else {
				trace("カメラが見つかりませんでした。");
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
		
		public function get video():Video {
			return _video;
		}
		
		
	}
	
}
class Block { };