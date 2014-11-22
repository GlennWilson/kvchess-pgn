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
	
	import flash.net.URLLoader;
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
	import flash.net.navigateToURL;
	
	public class AdView extends Sprite {

		private var _lm:LayoutManager;
		private var _headerField:TextField;
		private const _header:String = "KnightVision (C) 2008-2013 Glenn Wilson. " + LayoutManager.VERSION;
//		private const _header:String = "Click here for PGN and FAQ. " + LayoutManager.VERSION;
		private var _format:TextFormat;
		private var _textButton:BtnHeader;
		private var _pgnString:String;
		
/// Constructor		
		
		public function AdView(lm:LayoutManager) {
			_lm = lm;
			display();
		}

		public function setPgnString(pgnString:String) : void {
			_pgnString = pgnString;
		}
		
/// Private Functions		
		
		private function display():void {
			graphics.beginFill(_lm._headerBackgroundColor);
			graphics.lineStyle( 1, _lm._headerBackgroundColor, 1);
			graphics.drawRect(0, 0, _lm._adwidth, _lm._adheight);
			graphics.endFill();
			
			_headerField = createHeaderField();
			_textButton = new BtnHeader(_headerField.width, _headerField.height, _lm, _format, _header);
			_textButton.enabled = true;
					
			addChild(_headerField);
			addChild(_textButton);	
			_textButton.addEventListener(MouseEvent.CLICK, clickHeader);
		}

		private function createHeaderField():TextField {
			var textField:TextField = new TextField();
			textField.border = true;
			textField.borderColor = _lm._moveTextBackgroundColor;
			textField.condenseWhite = true;
			textField.width = _lm._adwidth;
			textField.height = _lm._adheight;
			textField.wordWrap = true;
			
			_format = new TextFormat();
			_format.align = TextFormatAlign.CENTER;
			_format.color = _lm._headerForegroundColor;
			_format.bold = true;
			_format.underline = true;
			_format.font = "arial";
			_format.size = _lm._adheight * 0.6;
			_format.kerning = true;
			textField.setTextFormat(_format);
			textField.y = 0;
			
			return textField;	
		}
		
		private function clickHeader(event:MouseEvent) : void {
			if (_pgnString == null) {
				flash.net.navigateToURL(new URLRequest("http://kvchess.com/"));
			} else {
				var pgnEscape:String = escape(_pgnString);
				if (pgnEscape.length > 7000) { // http get length issue
					pgnEscape = pgnEscape.substr(0, 7000);
				}
				var url:URLRequest = new URLRequest("http://kvchess.com/publish.html?pgndata=" 
					+ pgnEscape);
				flash.net.navigateToURL(url);
			}
		}
	}
}