package  
{
	
	import com.bit101.components.RadioButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author umhr
	 */
	public class Canvas extends CanvasUI 
	{
		private var _bitmap:Bitmap = new Bitmap(new BitmapData(320, 240, false));
		private var _cameraManager:CameraManager;
		private var _step:int;
		private var _effectRotation:Number = 0;
		private var _bitmapDataList:Vector.<BitmapData> = new Vector.<BitmapData>();
		private var _blendMode:String;
		private var _blendModeTop:String;
		private var _effectCenter:Point = new Point(160, 120);
		private var _isMirror:Boolean;
		private var _isDelayRandum:Boolean;
		private var _scale:Number;
		private var _alpha:Number;
		private var _mix:String = "AlphaMix";
		private var _mixer:Mixer = new Mixer();
		
		private var _saturation:Number;
		private var _brightness:Number;
		private var _contrast:Number;
		private var _hue:Number;
		
		public function Canvas() 
		{
			init();
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
			
			_cameraManager = CameraManager.getInstance();
			_cameraManager.y = 240;
			//addChild(_cameraManager);
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x0);
			sprite.graphics.drawRect(0, 0, 320, 240);
			sprite.graphics.endFill();
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, sprite_mouseDown);
			
			addChild(sprite);
			addChild(_bitmap);
			
			uiInit();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		private function uiInit():void 
		{
			onAlpha(null);
			onStep(null);
			onRotation(null);
			onScale(null);
			onBrightness(null);
			onBlendModeTop(null);
			onBlendModeDelay(null);
			var n:int = 10 * stepNS.maximum + 1;
			for (var i:int = 0; i < n; i++) 
			{
				_bitmapDataList[i] = new BitmapData(320, 240, false, 0x0);
			}
		}
		
		override protected function onBrightness(event:Event):void 
		{
			_brightness = brightnessHSlider.value;
			brightnessLabel.text = "Brightness:" + brightnessHSlider.value;
			
			_contrast = contrastHSlider.value;
			contrastLabel.text = "Contrast:" + contrastHSlider.value;
			
			_hue = hueHSlider.value;
			hueLabel.text = "Hue:" + hueHSlider.value;
			
			_saturation = saturationHSlider.value;
			saturationLabel.text = "Saturation:" + saturationHSlider.value;
			
		}
		
		override protected function onMix(event:Event):void 
		{
			var radioButton:RadioButton = event.currentTarget as RadioButton;
			_mix = radioButton.label;
		}
		
		override protected function onAlpha(event:Event):void 
		{
			_alpha = alphaNS.value;
		}
		
		override protected function onDelayRandum(event:Event):void 
		{
			_isDelayRandum = !_isDelayRandum;
		}
		
		override protected function onMirror(event:Event):void 
		{
			_isMirror = !_isMirror;
		}
		
		override protected function onScale(event:Event):void 
		{
			_scale = scaleHSlider.value;
		}
		
		override protected function onStep(event:Event):void 
		{
			_step = stepNS.value;
		}
		
		private function sprite_mouseDown(event:MouseEvent):void 
		{
			_effectCenter.x = Math.max(0, Math.min(320, mouseX));
			_effectCenter.y = Math.max(0, Math.min(240, mouseY));
		}
		
		override protected function onRotation(event:Event):void 
		{
			_effectRotation = rotationHSlider.value * Math.PI / 180;
		}
		
		override protected function onBlendModeDelay(event:Event):void 
		{
			_blendMode = String(blendModeDelay.selectedItem);
		}
		
		override protected function onBlendModeTop(event:Event):void 
		{
			_blendModeTop = String(blendModeTop.selectedItem);
		}
		
		private function enterFrame(e:Event):void 
		{
			_bitmapDataList.unshift(_cameraManager.getBitmapData(_isMirror, _brightness, _contrast, _hue, _saturation));
			_bitmapDataList.length = 41;
			
			if (_mix == "Normal") {
				normalMix();
			}else if (_mix == "BGMix") {
				_mixer.setBitmapData(_bitmap, _bitmapDataList[0].clone(), _alpha);
			}else if (_mix == "AlphaMix") {
				alphaMix();
			}else if (_mix == "BlendMix") {
				blendMix();
			}
		}
		
		private function normalMix():void 
		{
			_bitmap.bitmapData = _bitmapDataList[0].clone();
		}
		
		private function alphaMix():void 
		{
			var step:int;
			step = (_isDelayRandum?_step * Math.random():_step) * 4;
			var matrix:Matrix;
			_bitmap.bitmapData = new BitmapData(320, 240, false, 0x000000);
			
			var a:int = _alpha < 0?1:0;
			
			var matrixList:Array = new Array();
			matrixList = matrixList.concat([1, 0, 0, 0, 0]); // red
			matrixList = matrixList.concat([0, 1, 0, 0, 0]); // green
			matrixList = matrixList.concat([0, 0, 1, 0, 0]); // blue
			matrixList = matrixList.concat([_alpha, _alpha, _alpha, a, 0]); // alpha
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter(matrixList);
			
			_bitmapDataList[0].applyFilter(_bitmapDataList[0], _bitmapDataList[0].rect, new Point(), colorMatrixFilter.clone());
			
			var bitmap:Bitmap;
			
			matrix = setMatrix(_scale*4);
			step = (_isDelayRandum?_step * Math.random():_step) * 4;
			bitmap = new Bitmap(_bitmapDataList[step]);
			_bitmap.bitmapData.draw(bitmap, matrix);
			
			matrix = setMatrix(_scale*3);
			step = (_isDelayRandum?_step * Math.random():_step) * 3;
			bitmap = new Bitmap(_bitmapDataList[step]);
			_bitmap.bitmapData.draw(bitmap, matrix);
			
			matrix = setMatrix(_scale*2);
			step = (_isDelayRandum?_step * Math.random():_step) * 2;
			bitmap = new Bitmap(_bitmapDataList[step]);
			_bitmap.bitmapData.draw(bitmap, matrix);
			
			matrix = setMatrix(_scale*1);
			step = (_isDelayRandum?_step * Math.random():_step) * 1;
			bitmap = new Bitmap(_bitmapDataList[step]);
			_bitmap.bitmapData.draw(bitmap, matrix);
			
			bitmap = new Bitmap(_bitmapDataList[0]);
			_bitmap.bitmapData.draw(bitmap);
		}
		
		private function blendMix():void 
		{
			var step:int;
			step = (_isDelayRandum?_step * Math.random():_step) * 4;
			var matrix:Matrix = setMatrix(_scale*4);
			_bitmap.bitmapData = new BitmapData(320, 240, false,0x000000);
			_bitmap.bitmapData.draw(new Bitmap(_bitmapDataList[step]), matrix, null, _blendMode);
			matrix = setMatrix(_scale*3);
			step = (_isDelayRandum?_step * Math.random():_step) * 3;
			_bitmap.bitmapData.draw(new Bitmap(_bitmapDataList[step]), matrix, null, _blendMode);
			matrix = setMatrix(_scale*2);
			step = (_isDelayRandum?_step * Math.random():_step) * 2;
			_bitmap.bitmapData.draw(new Bitmap(_bitmapDataList[step]), matrix, null, _blendMode);
			matrix = setMatrix(_scale*1);
			step = (_isDelayRandum?_step * Math.random():_step) * 1;
			_bitmap.bitmapData.draw(new Bitmap(_bitmapDataList[step]), matrix, null, _blendMode);
			
			_bitmap.bitmapData.draw(new Bitmap(_bitmapDataList[0]), null, null, _blendModeTop);
		}
		
		
		private function setMatrix(scale:Number):Matrix {
			var matrix:Matrix = new Matrix();
			matrix.translate( -160, -120);
			matrix.rotate(_effectRotation * scale);
			matrix.translate( 160, 120);
			matrix.scale(1 + scale * 0.1, 1 + scale * 0.1);
			matrix.translate( -_effectCenter.x * scale * 0.1, -_effectCenter.y * scale * 0.1);
			return matrix;
		}
	}
	
}