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
	import flash.display.DisplayObject;

	public class BtnMute extends BtnBase {
		public var _muted:Boolean;
		private var _upstateMuted:DisplayObject;
		private var _overstateMuted:DisplayObject;
		private var _downstateMuted:DisplayObject;
		
/// Constructor	
		
		public function BtnMute(width:uint, height:uint, lm:LayoutManager, up:Boolean, name:String, muted:Boolean) {
			_muted = muted;
			super(width, height, lm, up, name);
			_upstateMuted = createStateMuted(false, _alphaUp);
			_downstateMuted = createStateMuted(true, _alphaOver);
			_overstateMuted = createStateMuted(false, _alphaOver);
		}

/// Override Protected Functions			
		
		override protected function createUpState(): Sprite {
			var sprite:Sprite = new Sprite();
			var image1:Shape = createSpeaker(_foreground, _alphaUp);
			sprite.addChild(image1);
			return sprite;
		}
		
		override protected function createOverState(down:Boolean): Sprite {
			var sprite:Sprite = new Sprite();
			var image1:Shape = createSpeaker(_foreground, _alphaOver);
			
			if (!down) {
				image1.x = -2;
			}
			
			sprite.addChild(image1);
			return sprite;
		}
		
/// Private Functions		
		
		private function createStateMuted(down:Boolean, alpha:Number): Sprite {
			var sprite:Sprite = new Sprite();
			var image1:Shape = createSpeaker(_foreground, alpha);
			
			if (down) {
				image1.x = -2;
			}
			
			sprite.addChild(image1);
			return sprite;
		}

		private function createSpeaker(color:uint, alpha:Number): Shape {
			var speaker:Shape = new Shape();
			speaker.graphics.lineStyle (_lineStyleWidth, _foreground,alpha);
			speaker.graphics.beginFill (color, alpha);

			// speaker core box
			speaker.graphics.drawRect(1, _height/3, _width/6, _height/3);
			
			// speaker cone angled
			speaker.graphics.moveTo(_width/6+2, _height / 3);
			speaker.graphics.lineTo(.6 * _width, _height / 12);
			speaker.graphics.lineTo(.6 * _width, _height -  _height / 12);
			speaker.graphics.lineTo(_width/6+2, _height - _height/3);
			speaker.graphics.lineTo(_width/6+2, _height/3);
		
			speaker.graphics.endFill();

			// sound lines
			if (_muted) {
				speaker.graphics.moveTo((.6 * _width + _width - _lineStyleWidth)/2, _height/3);
				speaker.graphics.lineTo((.6 * _width + _width - _lineStyleWidth)/2, _height - _height/3);

				speaker.graphics.moveTo(_width - _lineStyleWidth, _height/5);
				speaker.graphics.lineTo(_width - _lineStyleWidth, _height - _height/5);
			}			
			return speaker;
		}
	}
}