package  
{
	
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.HSlider;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.RadioButton;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author umhr
	 */
	public class CanvasUI extends Sprite 
	{
		protected var blendModeDelay:ComboBox;
		protected var blendModeTop:ComboBox;
		protected var rotationHSlider:NumericStepper;
		protected var scaleHSlider:NumericStepper;
		protected var alphaNS:NumericStepper;
		protected var stepNS:NumericStepper;
		
		public function CanvasUI() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}
		
		protected var uiCanvas:Sprite = new Sprite();
		/**
		 * 明度のスライダーです。
		 */
		protected var brightnessHSlider:HSlider;
		/**
		 * コントラストのスライダーです。
		 */
		protected var contrastHSlider:HSlider;
		/**
		 * 色相のスライダーです。
		 */
		protected var hueHSlider:HSlider;
		/**
		 * 彩度のスライダーです。
		 */
		protected var saturationHSlider:HSlider;
		protected var brightnessLabel:Label;
		protected var contrastLabel:Label;
		protected var hueLabel:Label;
		protected var saturationLabel:Label;
		
		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			addUI();
			
		}
		private function addUI():void 
		{
			uiCanvas.x = 5;
			uiCanvas.y = 240;
			addChild(uiCanvas);
			
			// 明度
			brightnessHSlider = new HSlider(uiCanvas, 0, 5, onBrightness);
			brightnessHSlider.maximum = 255;
			brightnessHSlider.minimum = -256;
			brightnessHSlider.value = 0;
			brightnessLabel = new Label(uiCanvas, 102, 5 - 4);
			
			// コントラスト
			contrastHSlider = new HSlider(uiCanvas, 0, 25, onBrightness);
			contrastHSlider.maximum = 255;
			contrastHSlider.minimum = -256;
			contrastHSlider.value = 127;
			contrastLabel = new Label(uiCanvas, 102, 25 - 4);
			
			// 色相
			hueHSlider = new HSlider(uiCanvas, 0, 45, onBrightness);
			hueHSlider.maximum = 3.14;
			hueHSlider.minimum = -3.14;
			hueHSlider.value = 0;
			hueLabel = new Label(uiCanvas, 102, 45 - 4);
			
			// 彩度
			saturationHSlider = new HSlider(uiCanvas, 0, 65, onBrightness);
			saturationHSlider.maximum = 2;
			saturationHSlider.minimum = -1;
			saturationHSlider.value = 1;
			saturationLabel = new Label(uiCanvas, 102, 65 - 4);
			
			onBrightness(null);
			
			new CheckBox(uiCanvas, 200, 5, "Mirror", onMirror);
			
			// ===============================
			var mixRB0:RadioButton = new RadioButton(uiCanvas, 0, 85, "Normal", false, onMix);
			var mixRB1:RadioButton = new RadioButton(uiCanvas, 50, 85, "BGMix", false, onMix);
			var mixRB2:RadioButton = new RadioButton(uiCanvas, 100, 85, "AlphaMix", false, onMix);
			var mixRB3:RadioButton = new RadioButton(uiCanvas, 200, 85, "BlendMix", true, onMix);
			mixRB0.groupName = mixRB1.groupName = mixRB2.groupName = mixRB3.groupName = "mix";
			mixRB2.selected = true;
			
			new Label(uiCanvas, 100, 95, "Alpha");
			alphaNS = new NumericStepper(uiCanvas, 100, 110, onAlpha);
			alphaNS.value = 0.5;
			alphaNS.minimum = -10;
			alphaNS.step = 0.1;
			alphaNS.maximum = 10;
			alphaNS.width = 80;
			
			var itemList:Array/*String*/ = [];
			itemList.push(BlendMode.ADD, BlendMode.DARKEN, BlendMode.DIFFERENCE, BlendMode.ERASE);
			itemList.push(BlendMode.HARDLIGHT, BlendMode.INVERT, BlendMode.LIGHTEN, BlendMode.MULTIPLY);
			itemList.push(BlendMode.NORMAL, BlendMode.OVERLAY, BlendMode.SCREEN, BlendMode.SHADER);
			itemList.push(BlendMode.SUBTRACT);
			
			new Label(uiCanvas, 200, 95, "Top");
			blendModeTop = new ComboBox(uiCanvas, 200, 110, "", itemList);
			blendModeTop.addEventListener(Event.SELECT, onBlendModeTop);
			blendModeTop.selectedIndex = 6;
			blendModeTop.defaultLabel = itemList[blendModeTop.selectedIndex];
			
			new Label(uiCanvas, 200, 130, "Delay");
			blendModeDelay = new ComboBox(uiCanvas, 200, 145, "", itemList);
			blendModeDelay.addEventListener(Event.SELECT, onBlendModeDelay);
			blendModeDelay.selectedIndex = 6;
			blendModeDelay.defaultLabel = itemList[blendModeDelay.selectedIndex];
			// ===============================
			
			new Label(uiCanvas, 0, 165, "DelaySteps");
			stepNS = new NumericStepper(uiCanvas, 0, 180, onStep);
			stepNS.value = 4;
			stepNS.minimum = 0;
			stepNS.maximum = 10;
			
			new CheckBox(uiCanvas, 100, 180, "DelayRandum", onDelayRandum);
			
			// ===============================
			new Label(uiCanvas, 0, 200, "Scale");
			scaleHSlider = new NumericStepper(uiCanvas, 0, 215, onScale);
			scaleHSlider.minimum = 0;
			scaleHSlider.maximum = 3;
			scaleHSlider.step = 0.1;
			scaleHSlider.value = 1;
			
			new Label(uiCanvas, 100, 200, "Rotation");
			rotationHSlider = new NumericStepper(uiCanvas, 100, 215, onRotation);
			rotationHSlider.minimum = -30;
			rotationHSlider.maximum = 30;
			rotationHSlider.value = 0;
			
		}
		protected function onBrightness(event:Event):void { };
		protected function onMirror(event:Event):void { };
		protected function onMix(event:Event):void { };
		protected function onAlpha(event:Event):void { };
		protected function onBlendModeTop(event:Event):void { };
		protected function onBlendModeDelay(event:Event):void { };
		protected function onStep(event:Event):void { };
		protected function onDelayRandum(event:Event):void { };
		protected function onScale(event:Event):void { };
		protected function onRotation(event:Event):void { };
	}
	
}