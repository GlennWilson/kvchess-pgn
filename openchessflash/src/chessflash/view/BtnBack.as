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
	
	public class BtnBack extends BtnBase {

/// Constructor		
		
		public function BtnBack(width:uint, height:uint, lm:LayoutManager, up:Boolean, name:String) {
			super(width, height, lm, up, name);
			this.focusRect = true; // override default behavior for BtnBase
		}
		
/// Override Protected Functions		
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var image:Shape  = createRoundedTriangleLeft(_foreground, _alphaUp);
			var background:Shape = createBackground();
			sprite.addChild(background);
			sprite.addChild(image);
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var image:Shape  = createRoundedTriangleLeft(_foreground, _alphaOver);
			var sprite:Sprite = new Sprite();
			var background:Shape = createBackground();
			if (!down) {
				image.x = -2;
			}
			sprite.addChild(background);
			sprite.addChild(image);
			return sprite;
		}
		
/// Private Functions		

		private function createRoundedTriangleLeft(color:uint, alpha:Number): Shape {
			var triangle:Shape = new Shape();
			triangle.graphics.lineStyle (_lineStyleWidth, _foreground);
			triangle.graphics.beginFill (color, alpha);
			triangle.graphics.moveTo(_width, _height);
			triangle.graphics.lineTo(0, _height / 2);
			triangle.graphics.lineTo(_width, 0);
			triangle.graphics.lineTo(_width, _height);
			triangle.graphics.endFill();
			return triangle;
		}
	}
}