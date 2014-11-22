package chessflash.view {

	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
  public class BtnBase extends MySimpleButton {
		protected var _width:uint;
		protected var _height:uint;
		
		protected var _foreground:uint;
		protected var _background:uint;
		protected var _lm:LayoutManager;
		protected var _alphaDisabled: Number = 0.10;
		protected var _alphaUp: Number = 0.50;
		protected var _alphaOver: Number = 1.0;
		protected var _lineStyleWidth: Number = 2.0;
		protected var _up:Boolean;
		protected var _name:String; // name of board for this, if applicable
		
/// Constructor
		
		public function BtnBase(width:uint, height:uint, lm:LayoutManager, 
				up:Boolean = true, name:String = LayoutManager.BV_MAIN){

			_lm = lm;
			_width = width;
			_height = height;
			_up = up;
			_name = name;
			_foreground = _lm.getDarkColor(_name);
			_background = _lm.getBorderColor(_name);
			_lineStyleWidth = _width / 15;
		}

		/// Override Protected Functions		
		override public function set enabled(value:Boolean):void {
			SetEnabled(value);
		}
		
		override public function SetEnabled(value:Boolean):void {
			if (value == super._enabled) {
				return;
			}
			if (upState == null) {
			  upState = createUpState();
			  overState =  createOverState(false);
			  downState =  createOverState(true);
			  hitTestState = upState;
			}
			if (!value) {
				overState.alpha = _alphaDisabled;
				upState.alpha = _alphaDisabled;
				downState.alpha = _alphaDisabled;
				super.SetEnabled(value);
			} else {
				upState.alpha = _alphaOver;
				overState.alpha = _alphaOver;
				downState.alpha = _alphaOver;
				super.SetEnabled(value);
			}
		}

/// Virtual Protected Functions	

		virtual protected function createUpState(): Sprite {
			return null;
		}
		
		virtual protected function createOverState(down:Boolean): Sprite {
			return null;
		}

		virtual protected function createBackground(): Shape {
			var border:int = 4; // border for focus highlight
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1, _background,0);
			rect.graphics.beginFill(_background, 0);
			rect.graphics.drawRect(0, 0, _width + border * 2, _height + border * 2);
			rect.graphics.endFill();
			rect.x = -border;
			rect.y = -border;
			return rect;
		}
	}
}