/**
 * 
    ChessFlash is a Flash based chess game (pgn file) viewer.
    Copyright 2008, 2009 Glenn Wilson.
    
    This file is part of ChessFlash.
 
    ChessFlash is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ChessFlash is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ChessFlash.  If not, see <http://www.gnu.org/licenses/>.
 * 
 */
package chessflash.view {
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.display.SimpleButton;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;

	public class BtnText extends BtnBase {
		private var _text:String;
		protected var _backgroundNotSelected:uint;
		protected var _index:int;
		protected var _upTF:TextField;
		protected var _upTFSel:TextField;
		protected var _upFormat:TextFormat;
		protected var _upFormatSel:TextFormat;
		protected var _overTF:TextField;
		protected var _overFormat:TextFormat;
		protected var _downTF:TextField;
		protected var _downFormat:TextFormat;
		protected var _selected:Boolean;
		protected var _upStateSelected:Sprite;
		
/// Constructor
		
		public function BtnText(text:String, index:int, lm:LayoutManager) {
			super(lm._varBtnWidth, lm._varBtnHeight, lm);
			_text = text;
			_foreground = lm.getVarBtnColorForeground();
			_background = lm.getVarBtnColorBackground();
			_index = index;
			_selected = false;
			_lineStyleWidth = _width / 15;
			_backgroundNotSelected = 0xC0C0C0;
			
			_upStateSelected = createUpStateSelected();
		}
		
		override public function mouseOver(event:MouseEvent) : void {
			
		}
		
		override public function mouseOut(event:MouseEvent) : void {
			
		}

		
/// Public Functions		
		
		public function setSelected(value:Boolean):void {
			if (value == _selected) return;
			_selected = value;
			if (!_selected) {
				_upTF.setTextFormat(_upFormat);
			} else {
				_upTF.setTextFormat(_overFormat);
			}
		}
		
		public function getIndex():int {
			return _index;
		}
		
/// Protected Functions		
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			_upFormat = createTextFormat(false);
			_upTF = createTextField(false, _upFormat);
			sprite.addChild(background);
			sprite.addChild(_upTF);
			return sprite;
		}
		
		protected function createUpStateSelected(): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			_upFormatSel = createTextFormat(true);
			_upTFSel = createTextField(false, _upFormatSel);
			sprite.addChild(background);
			sprite.addChild(_upTFSel);
			return sprite;
		}
		
		override protected function createOverState(value:Boolean): Sprite {
			if (value == false) {
				return createDownState();
			}
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			_overFormat = createTextFormat(true);
			_overTF = createTextField(false, _overFormat);
			sprite.addChild(background);
			sprite.addChild(_overTF);
			return sprite;
		}

		protected function createDownState(): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			_downFormat = createTextFormat(true);
			_downTF = createTextField(true, _downFormat);
			sprite.addChild(background);
			sprite.addChild(_downTF);
			return sprite;
		}

		override protected function createBackground(): Shape {
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1, _background);
			rect.graphics.beginFill(_background, 1);
			rect.graphics.drawRoundRect(0, 0, _width, _height, 10, 20);
			rect.graphics.endFill();
			return rect;
		}
		
/// Private Functions		
		
		private function createTextFormat(highlight:Boolean):TextFormat {
			var format:TextFormat = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.color = _foreground;
			format.bold = highlight;
			format.italic = highlight;
			format.font = "arial";
			format.size = .6 * _height;
			format.kerning = true;
			return format;	
		}
		
		private function createTextField(downState:Boolean, format:TextFormat):TextField {
			var textField:TextField = new TextField();
			textField.text = _text;
			textField.width = _width;
			textField.height = _height;
			
			textField.setTextFormat(format);
			
			textField.y = (_height - textField.textHeight) ;
			textField.y -= _height * .2; 
			
			if (downState) {
				textField.x += 1;
			}
			
			return textField;	
		}
	}
}