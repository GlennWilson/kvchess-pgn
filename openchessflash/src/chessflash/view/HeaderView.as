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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.net.navigateToURL;

	
	public class HeaderView extends Sprite {
		private var _lm:LayoutManager;
		private var _headerField:TextField;
		private var _header:String;
		private var _format:TextFormat;
		private var _textButton:BtnHeader;
		private var _delay:int = 0;
		
/// Constructor		
		
		public function HeaderView(lm:LayoutManager, header:String) {
			_lm = lm;
			_header = header;
			display();
		}

/// Public Functions		
		
		public function setText(header:String):void {
			_header = header == null ? "  " : header;
			setText2();	
//			this.stage.addEventListener(Event.ENTER_FRAME, onSetTextDelay);
		}
		
/// Private Functions		
		
		private function onSetTextDelay(x:int,event:Event):void {
			_delay++;
			this.stage.removeEventListener(Event.ENTER_FRAME, onSetTextDelay);
			setText2();
		}

		private function setText2():void {
			if (_textButton != null) removeChild(_textButton);
			_textButton = null;
			_headerField.text = _header;
			_format.underline = false;
			_headerField.setTextFormat(_format);
		}

		private function createHeaderField():TextField {
			var textField:TextField = new TextField();
			textField.border = true;
			textField.borderColor = _lm._moveTextBackgroundColor;
			textField.condenseWhite = true;
			textField.width = _lm._mtwidth;
			textField.height = _lm._htHeight;
			textField.wordWrap = true;
			
			_format = new TextFormat();
			_format.align = TextFormatAlign.CENTER;
			_format.color = _lm._headerForegroundColor;
			_format.bold = true;
			_format.font = "arial";
			_format.size = _lm._mainlineTextFormat.size;
			_format.kerning = true;
			_format.underline = true;
			textField.setTextFormat(_format);
			textField.y = 0;
			
			return textField;	
		}

		private function display():void {
			graphics.beginFill(_lm._headerBackgroundColor);
			graphics.lineStyle( 1, _lm._headerBackgroundColor, 1);
			graphics.drawRect(0, 0, _lm._mtwidth, _lm._htHeight);
			graphics.endFill();
			
			_headerField = createHeaderField();
			_textButton = new BtnHeader(_headerField.width, _headerField.height, _lm, _format, _header);
			_textButton.enabled = true;
					
			addChild(_headerField);
			addChild(_textButton);	
			_textButton.addEventListener(MouseEvent.CLICK, clickHeader);
		}

		private function clickHeader(event:MouseEvent) : void {
			flash.net.navigateToURL(new URLRequest("http://kvchess.com/"));
		}

	}
}