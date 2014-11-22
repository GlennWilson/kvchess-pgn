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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.MouseEvent;
	import flash.events.EventPhase;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import chessflash.pgn.PgnState;
	
	
	public class BoardView extends Sprite {
		public var _whiteToMove:Boolean;

		private var _lm:LayoutManager;
		private var _controller:Controller;
		private var _pgnState:PgnState;
		private var _name:String;
		
		private static const COLUMNS:uint = 8;;
		private static const ROWS:uint = 8;
		private static const SQUARES_COUNT:uint = 64;
		private static const COLUMN_NAMES:String = "abcdefghijklmnopqrstuvwxyz";

		// child objects
		private var _overlay:Shape; // layer for arrows and marks on board
		private var _squares:Array;
		private var _linkChessFlash:LinkChessFlash;
		private var _rewindButton:BtnRewind;
		private var _takebackButton:BtnBack;
		private var _playButton:BtnPlay;
		private var _endButton:BtnEnd;
		private var _flipButton:BtnFlip;
		private var _sideToMoveIndicator:SideToMove;

		// move entry variables from, to
		private var _fromsquare:int;
		private var _fromClicked:Boolean;
		private var _tosquare:int;
		private var _toClicked:Boolean;
		
		// remember last arrow drawn to redraw if board flipped
		private var _arrowFrom:int = -1;
		private var _arrowTo:int = -1;
		
		private var _drawn:Boolean = false;
		private var _boardLabels:Array;
		
/// Constructor
		
		public function BoardView(lm:LayoutManager, controller:Controller, pgnState:PgnState, 
				name:String) {

			_lm = lm;
			_controller = controller;
			_pgnState = pgnState;
			_name = name;
			
			_squares = new Array(SQUARES_COUNT);
			_boardLabels = new Array(32);
			
			var index:uint = 0;
			var currentColor:uint = _lm.getDarkColor(_name);
			
			for (var col:uint = 0; col < COLUMNS; col++) {
				if (col % 2 == 0) {
					currentColor = _lm.getDarkColor(_name);
				} else {
					currentColor = _lm.getLightColor(_name);
				}
				
				for (var row:uint = 0; row < ROWS; row++) {
					index = indexFromColRow(col, row);
					_squares[index] = new Square(index, currentColor, _lm._squaresize, this);
					if (currentColor == _lm.getDarkColor(_name)) {
						currentColor = _lm.getLightColor(_name);
					} else {
						currentColor = _lm.getDarkColor(_name);
					}
				}
			}
			display();
		}
		
/// Public Functions
		
		public function setPgnString(pgnString:String) : void {
			if (_linkChessFlash != null) {
				_linkChessFlash.setPgnString(pgnString);
			}
		}

		public function setWhiteToMove(whiteToMove:Boolean):void {
			_whiteToMove = whiteToMove;
			setSideToMoveIndicator();
		}
		
		// allow specific move entry by clicking board
		public function setMoveToAccept(fromSquare:int, toSquare:int):void {
			_fromClicked = false;
			_toClicked = false;
			_fromsquare = fromSquare;
			_tosquare = toSquare;
			(_squares[fromSquare] as Square).setAcceptClick();
			(_squares[toSquare] as Square).setAcceptClick();
		}
		
		// clear move to accept
		public function clearMoveToAccept():void {
			if (_fromsquare > 0) {
				(_squares[_fromsquare] as Square).clearAcceptClick();
			}
			if (_tosquare > 0) {
				(_squares[_tosquare] as Square).clearAcceptClick();
			}
		}

		public function setInitialMove(move:uint):void {
			while (moreMovesBackward()) {
				playTakeBack();
			}
			
			for (var m:uint = 0; (m < move) && moreMovesForward(); m++) {
				doPlay();
			}
			
			if (!moreMovesForward() && moreMovesBackward()) {
				setMoveBackwardFocus();
			}
		}
		
		public function setPgnState(state:PgnState) : void {
			_pgnState = state;
		}
		
		public function getPgnState():PgnState {
			return _pgnState;
		}
		
		public function getName():String {
			return _name;
		}

		public function setPiece(index:int, piece:int):int {
			var square:Square = _squares[index] as Square;
			return square.setPieceFen(piece);
		}

		public function clearPiece(index:int):int {
			var square:Square = _squares[index] as Square;
			return square.clearPiece();
		}

		public function clearHighlightsAndArrows() : void {
			var square:Square;
			for (var i:int = 0; i < 64; i++) {
				square = _squares[i] as Square;
				square.removeHighlight();
			}
			clearArrows();
		}
		
		public function setHighlight(index:uint) : void {
			var square:Square = _squares[index] as Square;
			square.highlight();
		}

		public function setMoveForwardFocus():void {
			try {
				this.stage.focus = _playButton;
			} catch (error:Error) {
				// jangaroo not implemented focus
			}

		}
		
		public function setBtnStates() : void {
			if (!_lm._diagramMode) {
				// if at 1st move, then no takeback/rewind
				if (!moreMovesBackward()) {
					_takebackButton.enabled = false;
					_rewindButton.enabled = false;
				} else {
					_takebackButton.enabled = true;
					_rewindButton.enabled = true;
				}
				// if at last move then no play/end
				if (!moreMovesForward()) {
					_playButton.enabled = false;
					_endButton.enabled = false;
				} else {
					_playButton.enabled = true;
					_endButton.enabled = true;
				}
			}
		}
		
		public function drawArrow(fromIndex:uint, toIndex:uint) : void {
			if (fromIndex < 0 || toIndex < 0) return;
			if (fromIndex >= SQUARES_COUNT || toIndex >= SQUARES_COUNT) return;
			
			_arrowFrom = fromIndex;
			_arrowTo = toIndex;

			var squareFrom:Square = _squares[fromIndex] as Square;
			var squareTo:Square = _squares[toIndex] as Square;
			
			var deltaX:Number = squareTo.x - squareFrom.x;
			var deltaY:Number = squareTo.y - squareFrom.y;
			var hypotenuse:Number = Math.sqrt(deltaX *deltaX + deltaY*deltaY);

			var angle:Number;
			if (deltaX < 0 ){
				angle = Math.acos(deltaX / hypotenuse);
			} else {
				angle = Math.asin(deltaY / hypotenuse);
			}
			
			if (deltaY < 0 && angle > 0) {
				angle = -angle;
			}
			
			var angleR:Number= angle - Math.PI + Math.PI / 4;
			var angleL:Number= angle - Math.PI - Math.PI / 4 ;
			var length:Number = _lm._squaresize / 4;

			var xR:Number = squareTo.x + _lm._squaresize / 2 + length * Math.cos(angleR);
			var yR:Number = squareTo.y + _lm._squaresize / 2 + length * Math.sin(angleR);
			var xL:Number = squareTo.x + _lm._squaresize / 2 + length * Math.cos(angleL);
			var yL:Number = squareTo.y + _lm._squaresize / 2 + length * Math.sin(angleL);
				
			_overlay.graphics.lineStyle(3, 0xff0000, 1);
			_overlay.graphics.moveTo(squareFrom.x + _lm._squaresize / 2, 
					squareFrom.y + _lm._squaresize / 2);
					
			_overlay.graphics.lineTo(squareTo.x + _lm._squaresize / 2, 
					squareTo.y + _lm._squaresize / 2);
					
			_overlay.graphics.lineTo(xR, yR);
			_overlay.graphics.moveTo(squareTo.x + _lm._squaresize / 2, 
					squareTo.y + _lm._squaresize / 2);
					
			_overlay.graphics.lineTo(xL, yL);
		}

/// Internal Functions		
		
		internal function squareClicked(index:int):void {
			if (index == _fromsquare) {
				(_squares[index] as Square).highlight();
				_fromClicked = true;
			} else if (index == _tosquare) {
				(_squares[index] as Square).highlight();
				_toClicked = true;
			}
			
			if (_fromClicked && _toClicked) { // move made
				// call controller to tell it the move was made
				doPlay();
			}
		}

/// Private Functions
		
		private function setMoveBackwardFocus():void {
			try {
				this.stage.focus = _takebackButton;
			} catch (error:Error) {
				// jangaroo not implemented focus
			}
		}

		private function clearArrows() : void {
			if (_overlay != null) {
				_overlay.graphics.clear();
			}
			_arrowFrom = -1;
			_arrowTo = -1;
		}

		private function display():void {
			// draw borders
			drawBorders();
					
			// ranks and files
			drawTextAroundBoard();
						
			// place the squares
			var index:uint = 0;
			var square:Square;
			for (var col:uint = 0; col < COLUMNS; col++) {
				for (var row:uint = 0; row < 8; row++) {
					index = indexFromColRow(col, row);
					square = _squares[index] as Square;
					square.x = xLocationFromCol(col);
					square.y = yLocationFromRow(row);
					addChild(square);
				}
			}
			
			// Buttons and Side to Move Indicator
			addButtons();
			setBtnStates();
			setSideToMoveIndicator();
			
			// Arrows Overlay
			_overlay = new Shape();
			addChild(_overlay);
			
			// Add Keyboard listener
			this.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);			
		}
		
		private function drawBorders():void {
			if (_drawn) {
				return;
			}
			// draw main border
			graphics.beginFill(_lm.getBorderColor(_name));
			graphics.lineStyle( 1, _lm.getBorderColor(_name), 1);
			graphics.drawRect(0, 0, _lm._squaresize * 8 + _lm._bordersize * 2 + 4, 
					_lm._squaresize * 8 + _lm._bordersize * 3 + 4);
			graphics.endFill();
			
			// line around board
			graphics.beginFill(0x000000);
			graphics.lineStyle(1, 0x000000, 1);
			graphics.drawRect(_lm._bordersize, _lm._bordersize, 
					_lm._squaresize * 8 + 5, _lm._squaresize * 8 + 5);
			graphics.endFill();
			_drawn = true;
		}

		private function drawTextAroundBoard() : void {
			// labels in the border
			var labelFormat:TextFormat = new TextFormat("arial");
			labelFormat.color = _lm.getBorderTextColor(_name);
			var textsize:int = _lm._bordersize * .7;
			labelFormat.size = textsize;
			labelFormat.bold =  true;
			
			var textField:TextField;
			var i:uint;
			// rows
			for (i = 0; i < ROWS; i++) {
				// left side
				if (_lm._labelsLeft) {
					if (_boardLabels[i] != null) {
						textField = _boardLabels[i];
					} else {
						textField = new TextField();
						textField.text = String(i+1);
						textField.setTextFormat(labelFormat);
						textField.selectable = false;
					}
					textField.x = _lm._bordersize/4;
					textField.y = yLocationFromRow(i) + _lm._bordersize/2;
					addChild(textField);
				}
				
				// right side
				if (_lm._labelsRight) {
					if (_boardLabels[i+8] != null) {
						textField = _boardLabels[i+8];
					} else {
						textField = new TextField();
						textField.text = String(i+1);
						textField.setTextFormat(labelFormat);
						textField.selectable = false;
					}
					textField.x = _lm._squaresize * 8 + _lm._bordersize * 1.5;
					textField.y = yLocationFromRow(i) + _lm._bordersize/2;
					addChild(textField);
				}
			}

			// columns
			for (i = 0; i < COLUMNS; i++) {
				// top
				if (_lm._labelsTop){
					if (_boardLabels[i+16] != null) {
						textField = _boardLabels[i+16];
					} else {
						textField = new TextField();
						textField.text = COLUMN_NAMES.charAt(i);// .toUpperCase();
						textField.setTextFormat(labelFormat);
						textField.selectable = false;
					}
					textField.x = xLocationFromCol(i) + _lm._squaresize / 2 - textsize / 2;
					textField.y = (_lm._bordersize - textsize) / 2 - 2;
					addChild(textField);
				}
				
				// bottom
 				if (_lm._labelsBottom) {
					if (_boardLabels[i+24] != null) {
						textField = _boardLabels[i+24];
					} else {
						textField = new TextField();
						textField.text = COLUMN_NAMES.charAt(i);// .toUpperCase();
						textField.setTextFormat(labelFormat);
						textField.selectable = false;
					}
					textField.x = xLocationFromCol(i) + _lm._squaresize / 2 - textsize / 2;
					textField.y =  _lm._squaresize * 8 + _lm._bordersize + (_lm._bordersize - textsize) / 2 + 2;
					addChild(textField);
				}
			}
		}

		private function addButtons():void {
			// add buttons
			var btnHeight:Number = _lm._bordersize * .8;
			var btnY:Number = _lm._squaresize * 8 + _lm._bordersize * 3 + 4 - _lm._bordersize;
			
			if (!_lm._diagramMode) {
				// add buttons - rewind
				_rewindButton = new BtnRewind(btnHeight, btnHeight, _lm, true, _name);
				_rewindButton.enabled = true;
				_rewindButton.x = 2 * _lm._squaresize + _lm._bordersize * 1.7; 
				_rewindButton.y = btnY;
				addChild(_rewindButton);
				_rewindButton.addEventListener(MouseEvent.CLICK, clickRewind);

				// add buttons - takeback
				_takebackButton = new BtnBack(btnHeight, btnHeight, _lm, true, _name);
				_takebackButton.enabled = true;
				_takebackButton.x = 3 * _lm._squaresize + _lm._bordersize * 1.7; 
				_takebackButton.y = btnY;
				addChild(_takebackButton);
				_takebackButton.addEventListener(MouseEvent.CLICK, clickTakeback);

				// add buttons - play
				_playButton = new BtnPlay(btnHeight, btnHeight, _lm, true, _name);
				_playButton.enabled = true;
				_playButton.x = 4 * _lm._squaresize + _lm._bordersize * 1.7; 
				_playButton.y = btnY;
				addChild(_playButton);
				_playButton.addEventListener(MouseEvent.CLICK, clickPlay);

				// add buttons - end
				_endButton = new BtnEnd(btnHeight, btnHeight, _lm, true, _name);
				_endButton.enabled = true;
				_endButton.x = 5 * _lm._squaresize + _lm._bordersize * 1.7; 
				_endButton.y = btnY;
				addChild(_endButton);
				_endButton.addEventListener(MouseEvent.CLICK, clickEnd);

			}  else {
				// diagram mode
			}

			// add buttons - flip
			_flipButton = new BtnFlip(btnHeight, btnHeight, _lm, true, _name);
			_flipButton.enabled = true;
			_flipButton.x = 6 * _lm._squaresize + _lm._bordersize * 1.7; 
			_flipButton.y = btnY;
			_flipButton.enabled = true;
			addChild(_flipButton);
			_flipButton.addEventListener(MouseEvent.CLICK, clickFlip);
			
			// side to move indicator
			if (_sideToMoveIndicator == null) {
				_sideToMoveIndicator = new SideToMove(btnHeight, btnHeight, _lm, _name);
				_sideToMoveIndicator.x = 7 * _lm._squaresize + _lm._bordersize * 1.7; 
				_sideToMoveIndicator.y = btnY;
			}
			addChild(_sideToMoveIndicator);

			if (_linkChessFlash == null) {
				_linkChessFlash = new LinkChessFlash(_lm);
				_linkChessFlash.x = 1;
				_linkChessFlash.y = btnY - 1;
			}
			addChild(_linkChessFlash);
		}

		private function keyPressed(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.RIGHT) {
				// move forward
				doPlay();
			} else if (event.keyCode == Keyboard.LEFT) {
				// move backward
				playTakeBack();
			}
		}

		private function flip():void {
			// remove all child objects 
			while (numChildren > 0) {
				removeChildAt(0);
			}
			
			_rewindButton = null;
			_takebackButton = null;
			_playButton = null;
			_endButton = null;
  			_flipButton = null;

			// reverse white at bottom
			_lm._whiteAtBottom = !_lm._whiteAtBottom;

			// and redisplay the board
			display();
			
			//redraw the current arrow if any
			drawArrow(_arrowFrom, _arrowTo);
		}

		private function clickEnd(event:MouseEvent) : void {
			while (moreMovesForward()) {
				doPlay();
			}
			setMoveBackwardFocus();
		}

		private function clickFlip(event:MouseEvent) : void {
			flip();
			setMoveForwardFocus()
		}
		
		private function clickRewind(event:MouseEvent) : void {
			while (moreMovesBackward()) {
				playTakeBack();
			}
			setMoveForwardFocus()
		}

		private function clickPlay(event:MouseEvent) : void {
			doPlay();
			setMoveForwardFocus();
		}
		
		private function setSideToMoveIndicator():void {
			_sideToMoveIndicator.setWhiteToMove(_whiteToMove);
		}

		private function doPlay() : void {
			var move:int;

			if (moreMovesForward()) {
					move = _controller.moveForward(this);
					_controller.execute(move, this, false);
			}
			setBtnStates();
		}

		private function clickTakeback(event:MouseEvent) : void {
			playTakeBack();
			setMoveBackwardFocus();
		}

		private function playTakeBack() : void {
			var move:int;
			
			if (moreMovesBackward()) {
				move = _controller.moveBackward(this);
				_controller.takeback(move, this);
			}
			setBtnStates();
		}

		private function xLocationFromCol(col:uint):uint {
			if (_lm._whiteAtBottom) {
				return col * _lm._squaresize + _lm._bordersize + 3;
			} else {
				return (COLUMNS - col - 1) * _lm._squaresize + _lm._bordersize + 3;
			}
		}
	
		private function yLocationFromRow(row:uint):uint {
			if (_lm._whiteAtBottom) {
				return _lm._squaresize * (ROWS - row - 1) + _lm._bordersize + 3;
			} else {
				return _lm._squaresize * row + _lm._bordersize + 3;				
			}
		}

		private static function indexFromColRow(col:uint, row:uint):uint {
			return row * COLUMNS + col;
		}
		
		private function moreMovesForward():Boolean {
			var state:PgnState = getPgnState();
			return state != null && state.moreMovesForward();
		}
		
		private function moreMovesBackward():Boolean {
			var state:PgnState = getPgnState();
			return state != null && state.moreMovesBackward();
		}

	}
}