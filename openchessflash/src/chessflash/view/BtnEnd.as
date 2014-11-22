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
	
	public class BtnEnd extends BtnBase {
		
/// Constructor		
		
		public function BtnEnd(width:uint, height:uint, lm:LayoutManager, up:Boolean, name:String) {
			super(width, height, lm, up, name);
		}
		
/// Override Protected Functions		
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			sprite.addChild(background);
			var image1:Shape = createRoundedTriangleRight(_foreground, _alphaUp);
			var image2:Shape = createRoundedRightBar(_foreground, _alphaUp);
			sprite.addChild(image1);
			sprite.addChild(image2);
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			var image1:Shape = createRoundedTriangleRight(_foreground, _alphaOver);
			var image2:Shape = createRoundedRightBar(_foreground, _alphaOver);
			
			if (!down) {
				image1.x = 2;
				image2.x = 2;
			}
			sprite.addChild(background);
			sprite.addChild(image1);
			sprite.addChild(image2);
			return sprite;
		}

		private function createRoundedTriangleRight(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle (_lineStyleWidth, _foreground);
			triangle.graphics.beginFill(color, alpha);
			triangle.graphics.moveTo(0, 0);
			triangle.graphics.lineTo(_width - _lineStyleWidth + 1, _height / 2);
			triangle.graphics.lineTo(0, _height);
			triangle.graphics.lineTo(0, 0);
			triangle.graphics.endFill();
			return triangle;
		}

/// Private Functions		
		
		private function createRoundedRightBar(color:uint, alpha:Number): Shape {
			var bar:Shape = new Shape();
			bar.graphics.lineStyle (_lineStyleWidth, _foreground);
			bar.graphics.beginFill (color, alpha);
			bar.graphics.moveTo(_width, _height);
			bar.graphics.lineTo(_width, 0);
			bar.graphics.endFill();
			return bar;
		}
	}
}