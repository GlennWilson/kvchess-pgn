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
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
    import flash.geom.Rectangle;
	
	public class ScrollBar extends Sprite {
		private var _lm:LayoutManager;
		private var _tf:TextField;
		private var _width:int;
		private var _height:int;
		private var _boxHeight:int;
		private var _boxWidth:int;;
		private var _boxMaxHeight:int;
		private var _boxMinHeight:int;
		private var _scrollTop:int;
		private var _scrollBottom:int;
		private var _foreground:uint;
		private var _background:uint;
		private var _upBtn:BtnScroll;
		private var _downBtn:BtnScroll;
		private var _scrollBox:Sprite;
		private var _sliding:Boolean = false;
		
/// Constructor
		
		public function ScrollBar(lm:LayoutManager, tf:TextField) {
			_lm = lm;
			_tf = tf;
			_width = _lm._scrollBarWidth;
			_height = _lm._mtvheight - 2;
			display();
		}
		
/// Internal Functions
		
		internal function setBtnStates():void {
			if (_tf.scrollV == 1 ) {  
				if (_upBtn.enabled) {
					_upBtn.enabled = false;
				}
			} else {
				if (!_upBtn.enabled) {
					_upBtn.enabled = true;
				}
			}

			if (_tf.scrollV == _tf.maxScrollV ) { 
				if (_downBtn.enabled) {
					_downBtn.enabled = false;
				}
			} else {
				if (!_downBtn.enabled) {
					_downBtn.enabled = true;
				}
			}
			updateSliderLocation();
		}
		
/// Private Functions		
		
        private function stopSliding(e:MouseEvent):void {
            _scrollBox.stopDrag();
			removeStageListeners(e);
		}        

		private function display():void {
			graphics.beginFill(_lm._scrollbarColor, 0.25);
			graphics.lineStyle( 1, _lm._scrollbarColor, 1);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			_upBtn = new BtnScroll(_width, _width, true, _lm);
			_upBtn.enabled = true;
			_upBtn.x = 0;
			_upBtn.y = 0;
			addChild(_upBtn);
			_upBtn.addEventListener(MouseEvent.MOUSE_DOWN, onUpButtonMouseDown);
			
			_downBtn = new BtnScroll(_width, _width, false, _lm);
			_downBtn.enabled = true;
			_downBtn.x = 0;
			_downBtn.y = _height - _width;
			addChild(_downBtn);
			_downBtn.addEventListener(MouseEvent.MOUSE_DOWN, onDownButtonMouseDown);

			_scrollBox = createScrollBox();
			_scrollBox.x = 2;
			_scrollBox.y = getScrollBoxTopY();
			addChild(_scrollBox);
            _scrollBox.addEventListener(MouseEvent.MOUSE_DOWN, boxPress);
			
			setBtnStates();
		}
		
        private function boxPress(event:MouseEvent):void {
            _scrollBox.startDrag(false, new Rectangle(_scrollBox.x, _scrollTop, 
					0, _scrollBottom - _scrollTop - _scrollBox.height));
					
            stage.addEventListener(MouseEvent.MOUSE_MOVE, updatePercent);
            stage.addEventListener(MouseEvent.MOUSE_UP, stopSliding);
			stage.addEventListener(Event.MOUSE_LEAVE, removeStageListeners);			
        } 
		
        private function updatePercent(event:MouseEvent):void {
            if (_sliding) return;
			_sliding = true;
			event.updateAfterEvent();
            var percentage:Number = (_scrollBox.y - _scrollTop)
					/ (_scrollBottom - _scrollTop - _scrollBox.height);
					
            var scrolltotop:Number = percentage * _tf.maxScrollV;
			_tf.scrollV = scrolltotop;
			setBtnStates();
			_sliding = false;
        }
		
        private function updateSliderLocation():void {
           if (_sliding) return;
			var numVisibleLines:int = _tf.bottomScrollV - (_tf.scrollV - 1);
			var max:int = _tf.maxScrollV;
			var current:int = _tf.scrollV;
			var percentage:Number;
			if (current == 1) {
				percentage = 0;
			} else if (current == max) {
				percentage = 1;	
			} else {
				percentage = 1 - (max - current) / max;
			}
		   _scrollBox.y =  (_scrollBottom - _scrollTop - _scrollBox.height) * percentage + _scrollTop;
        }

		private function getScrollBoxTopY():int {
			var top:int;
			return 100;
		}
		
		private function getScrollBoxBottomY():int {
			return 150;
		}
		
		private function createScrollBox(): Sprite {
			_scrollTop = _upBtn.height + 3;
			_scrollBottom = _height - _downBtn.height - 2;
			_boxMaxHeight = _scrollBottom - _scrollTop;
			_boxMinHeight = 20;
			_boxHeight = getScrollBoxBottomY() - getScrollBoxTopY();
			_boxWidth = _width - 4;

			var numVisibleLines:int = _tf.bottomScrollV - (_tf.scrollV - 1);
			var h1:int = _tf.scrollV;
			var h2:int = _tf.maxScrollV;
			if (h2 == 0) h2 = 1;
			var percent:Number = 1.0 * numVisibleLines / _tf.numLines;
			_boxHeight = percent * _boxMaxHeight;
			_boxHeight = _boxHeight < _boxMinHeight ? _boxMinHeight: _boxHeight;
			
			var rect:Sprite = new Sprite();
			rect.graphics.lineStyle(1, _lm._scrollbarColor, 1);
			rect.graphics.beginFill(_lm._scrollbarColor, .5);
			rect.graphics.drawRect(0, 0, _boxWidth	, _boxHeight);
			rect.graphics.endFill();
			
			rect.graphics.lineStyle(1, _lm._scrollbarColor, 1);

			rect.graphics.moveTo(2, _boxHeight / 2);
			rect.graphics.lineTo(_boxWidth - 2, _boxHeight / 2); 
			rect.graphics.moveTo(2, _boxHeight / 2 - 2);
			rect.graphics.lineTo(_boxWidth - 2, _boxHeight / 2 - 2); 
			rect.graphics.moveTo(2, _boxHeight / 2 + 2);
			rect.graphics.lineTo(_boxWidth - 2, _boxHeight / 2 + 2); 

			rect.graphics.moveTo(2, _boxHeight / 2 - 4);
			rect.graphics.lineTo(_boxWidth - 2, _boxHeight / 2 - 4); 
			rect.graphics.moveTo(2, _boxHeight / 2 + 4);
			rect.graphics.lineTo(_boxWidth - 2, _boxHeight / 2 + 4); 

			return rect;
		}

		
		/************************************************************************/
		// On scroll buttons mouse keep generating "scroll events" while it is down
		/************************************************************************/
		private function onUpButtonMouseDown( event:MouseEvent ):void {
			_tf.scrollV -= 1;
			setBtnStates();
			stage.addEventListener(MouseEvent.MOUSE_UP, removeStageListeners);
			stage.addEventListener(Event.MOUSE_LEAVE, removeStageListeners);
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrameUp);
		}

		private function onDownButtonMouseDown(event:MouseEvent):void {
			_tf.scrollV += 1;
			setBtnStates();
			stage.addEventListener(MouseEvent.MOUSE_UP, removeStageListeners);
			stage.addEventListener(Event.MOUSE_LEAVE, removeStageListeners);
			stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrameDown);
		}

		private function onStageEnterFrameUp(event:Event):void {
			_tf.scrollV -= 1;
			setBtnStates();
		}

		private function onStageEnterFrameDown(event:Event):void {
			_tf.scrollV += 1;
			setBtnStates();
		}

		private function removeStageListeners(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, removeStageListeners);
			stage.removeEventListener(Event.MOUSE_LEAVE, removeStageListeners);
			stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrameUp);
			stage.removeEventListener(Event.ENTER_FRAME, onStageEnterFrameDown);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, updatePercent);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopSliding);
		}
		/************************************************************************/
	}
}