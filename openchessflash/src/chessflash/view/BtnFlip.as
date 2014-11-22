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
	
	public class BtnFlip extends BtnBase {

/// Constructor		
		
		public function BtnFlip( width:uint, height:uint, lm:LayoutManager, up:Boolean, name:String) {
			super(width, height, lm, up, name);
		}
		
/// Override Protected Functions		
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			sprite.addChild(background);
			sprite.addChild(createRoundedTriangleUp(0xFFFFFF, _alphaUp));
			sprite.addChild(createRoundedTriangleDown(0x000000, _alphaUp));
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			var image1:Shape = createRoundedTriangleUp(0x000000, _alphaOver);
			var image2:Shape = createRoundedTriangleDown(0xFFFFFF, _alphaOver);
			
			if (!down) {
				image1.y = 2;
				image2.y = 2;
			}
			sprite.addChild(background);
			sprite.addChild(image1);
			sprite.addChild(image2);

			return sprite;
		}

/// Private Functions		
		
		private function createRoundedTriangleUp(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle(_lineStyleWidth/2, _foreground);
			triangle.graphics.beginFill(color, alpha);
			triangle.graphics.moveTo(0, 3*_height/5);
			triangle.graphics.lineTo(_width/2, _height);
			triangle.graphics.lineTo(_width, 3*_height/5);
			triangle.graphics.lineTo(0, 3*_height/5);
			triangle.graphics.endFill();
			return triangle;
		}

		
		private function createRoundedTriangleDown(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle(_lineStyleWidth/2, _foreground);
			triangle.graphics.beginFill(color, alpha);
			triangle.graphics.moveTo(0, 2*_height/5);
			triangle.graphics.lineTo(_width/2, 0);
			triangle.graphics.lineTo(_width, 2*_height/5);
			triangle.graphics.lineTo(0, 2*_height/5);
			triangle.graphics.endFill();
			return triangle;
		}
	}
}