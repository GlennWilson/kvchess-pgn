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
	
	public class BtnStart extends BtnBase {

/// Constructor
		
		public function BtnStart(width:uint, height:uint, lm:LayoutManager) {
			super(width, height, lm, true, LayoutManager.BV_MAIN);
		}
			
/// Override Protected Functions			
		
		override protected function createUpState(): Sprite {
			var image:Shape = createRoundedTriangleRight(_foreground, _alphaUp);
			var sprite:Sprite = new Sprite();
			sprite.addChild(image);
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var image:Shape  = createRoundedTriangleRight(_foreground , 1);	
			var sprite:Sprite = new Sprite();
			if (!down) {
				image.x = 2;
			}
			sprite.addChild(image);
			return sprite;
		}

/// Private Functions		
		
		private function createRoundedTriangleRight(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle(_lineStyleWidth, _lm.getLightColor(LayoutManager.BV_MAIN), alpha);
			triangle.graphics.beginFill(color, alpha);
			triangle.graphics.moveTo(0, 0);
			triangle.graphics.lineTo(_width, _height / 2);
			triangle.graphics.lineTo(0, _height);
			triangle.graphics.lineTo(0, 0);
			triangle.graphics.endFill();
			return triangle;
		}
	}
}