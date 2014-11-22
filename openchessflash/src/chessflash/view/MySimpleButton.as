package chessflash.view {
		import flash.display.Sprite;
		import flash.events.MouseEvent;

		public class  MySimpleButton extends Sprite
	{
		public var _enabled:Boolean = false;
		public var	upState:Sprite;
		public var	overState:Sprite;
		public var	downState:Sprite;
		public var	hitTestState:Sprite;
		
		public function MySimpleButton() {
			//cacheAsBitmap = true;
			//buttonMode = true;
			if (!LayoutManager.JANGAROO) { // interferes with touch on iPad and not needed there?
				addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			}
		}
		
		private function removeAllChildren():void {
			while (numChildren > 0) {
				removeChildAt(0);
			}
		}
		
		public function mouseOver(event:MouseEvent) : void {
			if (_enabled) {
				removeAllChildren();
				addChild(overState);
			} 
		}
		
		public function mouseOut(event:MouseEvent) : void {
			if (_enabled) {
				removeAllChildren();
				addChild(upState);
			} 
		}

		public function SetEnabled(value:Boolean):void {
			if (value != _enabled) {
				removeAllChildren();
			
				if (value) {
					addChild(upState);
				} else {
					addChild(downState);
				}
				_enabled = value;
			}
		}

		public function set enabled(value:Boolean):void {
			SetEnabled(value);
		}
		
		public function get enabled():Boolean {
			return _enabled
		}
	}
	
}