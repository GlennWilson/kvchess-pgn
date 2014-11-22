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
	
	public class BtnScroll extends BtnBase {
		
/// Constructor
		
		public function BtnScroll(width:uint, height:uint, up:Boolean, lm:LayoutManager) {
			super(width, height, lm, up);
		}
		
/// Override Protected Functions			
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var image:Shape;
			if (_up) {
				image=createTriangleUp(_lm._scrollbarColor, _alphaUp);
			} else {
				image=createTriangleDown(_lm._scrollbarColor, _alphaUp);
			}
			image.x = 1;
			sprite.addChild(image);
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var sprite:Sprite = new Sprite();
			
			var image:Shape;
			if (_up) {
				image = createTriangleUp(_lm._scrollbarColor, _alphaOver);
			} else {
				image = createTriangleDown(_lm._scrollbarColor, _alphaOver);
			}
			image.x = 1;			
			if (!down) {
				if (_up) {
					image.y = -2;
				} else {
					image.y = 2;
				}
			}
			sprite.addChild(image);

			return sprite;
		}
		
		override protected function createBackground(): Shape {
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1, _lm._scrollbarColor, 0);
			rect.graphics.beginFill(_lm._scrollbarColor, 0);
			rect.graphics.drawRoundRect(0, 0, _width, _height, 1);
			rect.graphics.endFill();
			return rect;
		}

/// Private Functions		

		private function createTriangleDown(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle(_lineStyleWidth/2, color);
			triangle.graphics.beginFill(color, alpha);
			triangle.graphics.moveTo(2, 2 * _height / 5);
			triangle.graphics.lineTo(_width / 2, _height - 2);
			triangle.graphics.lineTo(_width - 2, 2 * _height / 5);
			triangle.graphics.lineTo(2, 2 * _height / 5);
			triangle.graphics.endFill();
			return triangle;
		}

		
		private function createTriangleUp(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle(_lineStyleWidth/2, color);
			triangle.graphics.beginFill(color, alpha);
			triangle.graphics.moveTo(2, 3 * _height / 5);
			triangle.graphics.lineTo(_width / 2, 2);
			triangle.graphics.lineTo(_width - 2, 3 * _height/5);
			triangle.graphics.lineTo(2, 3 *_height / 5);
			triangle.graphics.endFill();
			return triangle;
		}
	}
}