package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	/**
	 * ...
	 * @author umhr
	 */
	public class Mixer 
	{
		[Embed(source = "number321.jpg", mimeType = "image/jpg")]
		private var EmbedClass:Class;
		private var _bitmap:Bitmap;
		public function Mixer() 
		{
			setBG();
		}
		
		private function setBG():void 
		{
			
			_bitmap = new EmbedClass() as Bitmap;
		}
		
		public function setBitmapData(target:Bitmap, bitmapData:BitmapData, alpha:Number):void {
			
			target.bitmapData = _bitmap.bitmapData.clone();
			
			var bitmap:Bitmap = new Bitmap(bitmapData);
			
			var a:int = alpha < 0?1:0;
			var matrix:Array = new Array();
			matrix = matrix.concat([1, 0, 0, 0, 0]); // red
			matrix = matrix.concat([0, 1, 0, 0, 0]); // green
			matrix = matrix.concat([0, 0, 1, 0, 0]); // blue
			matrix = matrix.concat([alpha, alpha, alpha, a, 0]); // alpha
			
			bitmap.filters = [new ColorMatrixFilter(matrix)];
			
			target.bitmapData.draw(bitmap);
		}
		
	}

}