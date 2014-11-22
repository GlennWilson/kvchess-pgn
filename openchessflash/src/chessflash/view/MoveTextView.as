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
	
	import flash.ui.Mouse;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class MoveTextView extends Sprite {
		private var _lm:LayoutManager;
		private var _textField:TextField;
		private var _scroller:ScrollBar;
		private var _header:String;
		private var _text:String;
		private var _controller:Controller;
		
		private var _lines:int = 13;
		private var _limitedSupport:Boolean = false; // set on errors to stop trying unsupported items
		
/// Constructor		
		
		public function MoveTextView(lm:LayoutManager, controller:Controller, text:String) {
			_lm = lm;
			_text = _text;
			_controller = controller;
			display();
		}

/// Public Functions		
		
		public function setText(text:String):void {
			_text = text;
			if (_text == null) _text = " ";
			if (LayoutManager.JANGAROO) { // No wordwrap in Jangaroo 1.02 TextField. TODO
				_textField.text = wordWrap(_text); 
			} else {
				_textField.text = _text; 
			}
			_textField.setTextFormat(_lm._defaultTextFormat);

			_scroller = createScrollBar();
			_scroller.y = 1;
			_scroller.x = _lm._mtvwidth - 1;
			addChild(_scroller);
		}
		
		// replace space with \n to indicate where to break lines
		// temporary measure while Jangaroo TextField does not support word wrap
		private function wordWrap(text:String) : String {
			var newSplitLines:Array = new Array(0);
			
			var fontSize:Number =  _lm._tsize;
			var width:int = _lm._mtvwidth;
			var charsPerLine:int = 2 * width / fontSize; // a rough guess TODO refine
			// 1. split text out into full lines based on any \n
			var fullLines : Array = text.split('\n');
			// 2. further split out full lines based on any ' ' (space)
			for (var i:int = 0; i < fullLines.length; i++) {
				var spacedLines : Array = fullLines[i].split(' ');
				var aline:String = spacedLines[0];
				for (var j:int = 1; j < spacedLines.length; j++) {
					if ((aline.length + 1 + spacedLines[j].length) <= charsPerLine) {
						aline += ' ' + spacedLines[j];
					} else {
						newSplitLines.push(aline);
						aline = spacedLines[j];
					}
				}
				newSplitLines.push(aline);
			}
			return newSplitLines.join('\n');
		}
		
		// method for Controller -- sync up movetextview with the current move
		public function highlightMoveText(start:int, length:int):void {
			highlightMoveTextBackward(start, length);
			highlightMoveTextForward(start, length);
		}

		public function highlightMoveTextForward(start:int, length:int):void {
			_textField.setSelection(start, start + length);
			var line:int = -1;
			try {
				line = _textField.getLineIndexOfChar(start);
			} catch (error:Error) {
				_limitedSupport = true;
				// jangaroo 1.02 not implemented getLineIndexOfChar
			}
			if (line > -1) {
				_lines = _textField.bottomScrollV - (_textField.scrollV - 1);
				if ((line - _textField.scrollV) >= (_lines-3)) _textField.scrollV = _textField.scrollV + 2;
			}
			_scroller.setBtnStates();
		}

		public function highlightMoveTextBackward(start:int, length:int):void {
			_textField.setSelection(start, start + length);
			var line:int = -1;
			try {
				line = _textField.getLineIndexOfChar(start);
			} catch (error:Error) {
				_limitedSupport = true;
				// jangaroo not implemented getLineIndexOfChar
			}
			if (line > -1) {
				_lines = _textField.bottomScrollV - (_textField.scrollV - 1);
				if ((line - _textField.scrollV) < 2) _textField.scrollV = _textField.scrollV - 2;
			}
			_scroller.setBtnStates();
		}

		// method for Controller 
		public function formatMoveText(start:int, length:int, format:TextFormat):void {
			if (_limitedSupport) {
				return; // jangaroo 1.02 limited support for setTextFormat (does all not specified range)
			}
			_textField.setTextFormat(format, start, start + length);
		}

/// Private Functions		
		
		private function createScrollBar():ScrollBar {
			var scroller:ScrollBar = new ScrollBar(_lm, _textField);
			return scroller;
		}
		
		private function createTextField():TextField {
			var textField:TextField = new TextField();
			textField.border = true;
			textField.borderColor = _lm._moveTextBackgroundColor;
			if (_text == null) _text = " ";
			textField.text = _text;
			textField.condenseWhite = true;
			textField.width = _lm._mtvwidth;
			textField.height = _lm._mtvheight;
			textField.wordWrap = true;
			textField.alwaysShowSelection = true;
			textField.setTextFormat(_lm._mainlineMoveFormat);
			
			textField.y = 0;
			_lines = _lm._mtvheight / (.7*_lm._squaresize);
			return textField;	
		}

		private function display():void {
			// draw border
			// main border
			graphics.beginFill(_lm._moveTextBackgroundColor);
			graphics.lineStyle( 1, _lm._moveTextBackgroundColor, 1);
			graphics.drawRect(0, 0, _lm._mtwidth, _lm._mtvheight);
			graphics.endFill();
			
			_textField = createTextField();	
			_textField.addEventListener(MouseEvent.CLICK, onClick);
			addChild(_textField);
			_textField.setSelection(0, 0);
			
			_lines = _textField.bottomScrollV - (_textField.scrollV - 1);
		}
		
		private function onClick(event:MouseEvent): void {
			var index:int = -1;
			var mx:int = mouseX;
			var my:int = mouseY;

			try {
				index = _textField.getCharIndexAtPoint(mx - _textField.x, my - _textField.y);
			} catch (error:Error) {
				_limitedSupport = true;
				// jangaroo 1.02 not implemented getCharIndexAtPoint
			}
			if (index > -1) {
				_controller.selectMoveText(index);
			}
		}
	}
}