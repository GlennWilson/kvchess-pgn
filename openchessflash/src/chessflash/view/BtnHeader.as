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
	
	public class BtnHeader extends BtnBase {
		
		private var _format:TextFormat;
		private var _text:String;
		
/// Constructor
		
		public function BtnHeader(width:uint, height:uint, lm:LayoutManager, format:TextFormat, text:String) {
			_format = format;
			_text = text;
			super(width, height, lm, false);
		
		}
		
/// Override Protected Functions			
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var textField: TextField = createTextField(false, _lm._moveTextForegroundColor, false);
			sprite.addChild(textField);
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			var textField: TextField = createTextField(down, _lm._moveTextForegroundColor, true);
			sprite.addChild(background);
			sprite.addChild(textField);
			return sprite;
		}

/// Private Functions		
		
		private function createTextField(downState:Boolean, foreground:uint, italic:Boolean):TextField {
			var textField:TextField = new TextField();
			textField.text = _text;
			textField.width = _width;
			textField.height = _height;
			
			_format.italic = italic;
			textField.setTextFormat(_format);
			
			if (downState) {
				textField.x += 1;
			}
			
			return textField;	
		}
	}
}