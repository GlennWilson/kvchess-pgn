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
	
	public class SideToMove extends Sprite {
		private var _width:uint;
		private var _height:uint;
		private var _foreground:uint;
		private var _lineStyleWidth: Number = 2.0;
		private var _whiteToMove:Shape;
		private var _blackToMove:Shape;
		private var _name:String;
		
/// Constructor		
		
		public function SideToMove(width:uint, height:uint, lm:LayoutManager, name:String) {
			_width = width;
			_height = height;
			_name = name;
			_foreground = lm.getBorderTextColor(name);
			_lineStyleWidth = _width / 15;
			_whiteToMove = createIndicator(0xFFFFFF);
			_blackToMove = createIndicator(0x000000);
		}

/// Internal Functions		
		
		internal function setWhiteToMove(whiteToMove:Boolean):void {
			if (numChildren > 0) {
				removeChildAt(0);
			}
			if (whiteToMove) {
				addChild(_whiteToMove);
			} else {
				addChild(_blackToMove);
			}
		}

/// Private Functions		
		
		private function createIndicator(color:uint): Shape {
			var rect:Shape = new Shape();
			rect.graphics.lineStyle (_lineStyleWidth, _foreground);
			rect.graphics.beginFill (color, 1);
			rect.graphics.drawRoundRect(0, 0, _width, _height, 1, 1);
			rect.graphics.endFill();
			return rect;
		}
	}
}