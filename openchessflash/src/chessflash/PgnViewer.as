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
package chessflash {
	
	import chessflash.engine.Board;
	import chessflash.engine.Fen;
	import chessflash.engine.Move;
	import chessflash.engine.Piece;
	import chessflash.pgn.Pgn;
	import chessflash.pgn.PgnCallback;
	import chessflash.pgn.PgnGame;
	import chessflash.pgn.PgnMove;
	import chessflash.pgn.PgnNode;
	import chessflash.pgn.PgnSequence;
	import chessflash.pgn.PgnState;
	
	import chessflash.view.AdView;
	import chessflash.view.BoardView;
	import chessflash.view.BtnStart;
	import chessflash.view.BtnText;
	import chessflash.view.LayoutManager;
	import chessflash.view.MoveTextView;
	import chessflash.view.HeaderView;
	import chessflash.view.Controller;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import flash.display.StageAlign;
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import flash.display.StageScaleMode;

// used for debugging 	
//	import flash.system.fscommand;

//	[SWF( backgroundColor='0x225511', frameRate='10', width='370', height='393')]
	public class PgnViewer extends Sprite implements PgnCallback, Controller {
		private var _lm:LayoutManager;
		private var _variationBtns:Array;
		private const DEFAULT_FEN:String = Fen.getDefaultFen();
		private const BV_MAIN:String = "Main";
		private const BV_VARS:String = "Variation";

		private const DEFAULT_HEADER:String  = "KnightVision " + LayoutManager.VERSION + "\n\nHomepage: http://KVChess.com";
//		private const DEFAULT_HEADER:String  = "Click here to publish\nyour chess games and analysis.\nGet free mobile chess apps.";
		private static const DEFAULT_MOVETEXT:String = null;
		
		private var _variationsMoveNode:PgnMove;
		private var _fenString:String;
		private var _fen:Fen;
		private var _pgnUrl:String;  // url to a pgn file
		private var _introUrl:String; 
		private var _closingUrl:String;
		private var _closingPlayed:Boolean;
		private var _pgnGame:PgnGame;
		private	var _boardView1:BoardView; 
		private	var _boardView2:BoardView; 
		private	var _moveTextView:MoveTextView; 
		private	var _headerView:HeaderView; 
		private	var _adView:AdView; 
		private var _pgn:Pgn;
		private var _startBtn:BtnStart;
		private var _startTF:TextField;
		
		//delay puzzle move queue
		private var _queueBoard:BoardView;
		private var _queueForward:Boolean;
		private var _queuePending:Boolean;
		private var _queueCount:int;
		private var _delayCount:int = 0;
		private var _args:String;
		private var _loaderInfo:LoaderInfo;
		private var _jangaroo:Boolean;

/// Constructor


		public function PgnViewer(jangaroo:Boolean=false, loadInfo:LoaderInfo=null, args:String=null):void {
			_jangaroo = jangaroo;
			if (_jangaroo) {
				//cacheAsBitmap = true; <-- with movetext area shown crashes with jangaroo 1.02
				stage.cacheAsBitmap = true; //  <-- works with jangaroo 1.02 but not with flash
			}
			if (loadInfo != null) {
				_loaderInfo = loadInfo;
			} else {
				_loaderInfo = this.root.loaderInfo;
			}
			_args = args;
			if (this.stage != null) {
				stage.quality = "best";
				this.stage.frameRate = 10;
				stage.addEventListener(Event.ENTER_FRAME, onStageDelayLoad);
			}
			// initialize();
		}

		/// Implement PgnCallback

		/// Implements PgnCallback.loaded used in Pgn
		public function loaded():void {

			_pgnGame = _pgn.getPgnGame();
			if (_adView != null) {
				_adView.setPgnString(_pgn.getPgnString());
			}
			var pgnState:PgnState = new PgnState();
			pgnState.init(_pgnGame);

			if (!_lm._diagramMode) {
				_fenString = _pgnGame.getFenString();
				if (_fenString == null) {
					_fenString = DEFAULT_FEN;
				}
			}
			_fen = new Fen(_fenString);

			_boardView1.setPgnState(pgnState);
			resetBoardView(_boardView1);
			_boardView1.setPgnString(_pgn.getPgnString());
		
			if (_lm._twoBoardMode) {
				pgnState = new PgnState();
				pgnState.init(_pgnGame);
				
				_boardView2.setPgnState(pgnState);
				resetBoardView(_boardView2);
			}
			
			if (!_lm._diagramMode && !_lm._boardOnly) {
				_headerView.setText(getPgnHeaderText());
				_moveTextView.setText(getPgnGameText());
				formatSequence(_boardView1.getPgnState()._currentSequence, _lm._mainlineMoveFormat, _lm._mainlineTextFormat);
			}
			_boardView1.setMoveForwardFocus();
			_boardView1.setInitialMove(_lm._initialMove);
		
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);

			if (_lm._puzzle) {
				stage.addEventListener(Event.ENTER_FRAME, onStageEnterFrame);
				queuePuzzleMove(_boardView1, true);
			}
		}
		
/// Implement Controller
		
		/// implements Controller.selectMoveText used by MoveTextView
		///  sync up boardview with the selected node
		public function selectMoveText(index:int):void {
			var node:PgnMove = _pgnGame.findPgnMoveByCharIndex(index);
			if (node == null) return;
			if (_lm._tabMode && node.getParent().getLevel() == 1 && _variationBtns != null) { 
				for (var i:int = 0; i < _variationBtns.length; i++) {
					(_variationBtns[i] as BtnText).setSelected(false);
				}
			}
			selectMoveTextByNode(node);
		}
		
		/// implements Controller.execute used by  BoardView
		public function execute(move:int, board:BoardView, autoMove:Boolean):void {
			if (move == 0) return;
			
			board.clearHighlightsAndArrows();
			if (move != Move.NULLMOVE) {
				board.setHighlight(Move.fromSquare(move));
				board.setHighlight(Move.toSquare(move));
				if (autoMove) {
					board.drawArrow(Move.fromSquare(move), Move.toSquare(move)); 
				}
			}
			
			var piece:int = Move.movingPieceWithColor(move);
			if (move != Move.NULLMOVE) {
				board.clearPiece(Move.fromSquare(move));
			}
			
			if (Move.isCastling(move)) { 
				board.setPiece(Move.toSquare(move), piece);
				board.clearPiece(Move.fromSquare2(move));
				board.setPiece(Move.toSquare2(move), Move.movingPiece2WithColor(move));
			} else if (Move.isEnpassant(move)) { 
				board.clearPiece(Move.getEnpassantCaptureSquare(move));
				board.setPiece(Move.toSquare(move), piece);
			} else if (Move.isPromotion(move)) { 
				board.setPiece(Move.toSquare(move), Move.promotionPieceWithColor(move));
			} else if (move == Move.NULLMOVE) { 
				// do nothing
			} else {
				board.setPiece(Move.toSquare(move), piece);
			}

			if (!autoMove) { // never two in a row, at the moment, may change later
				queuePuzzleMove(board, true);
			}
		}

		/// implements Controller.takeback used by  BoardView
		public function takeback(move:int, board:BoardView):void {
			if (move == 0) return;
			
			board.clearHighlightsAndArrows();
			if (move != Move.NULLMOVE) {
				board.setHighlight(Move.fromSquare(move));
				board.setHighlight(Move.toSquare(move));
			}

			var piece:int = Move.movingPieceWithColor(move);
			if (Move.isCastling(move)) { // castling
				board.clearPiece(Move.toSquare(move));	
				board.setPiece(Move.fromSquare(move), piece);
				board.clearPiece(Move.toSquare2(move));
				board.setPiece(Move.fromSquare2(move), Move.movingPiece2WithColor(move));
			} else if (Move.isEnpassant(move)) {
				board.clearPiece(Move.toSquare(move));
				board.setPiece(Move.fromSquare(move), piece);
				board.setPiece(Move.getEnpassantCaptureSquare(move), Move.capturedPieceWithColor(move)); 
			} else if (Move.isPromotion(move)) { 
				board.setPiece(Move.fromSquare(move), piece);
				board.setPiece(Move.toSquare(move), Move.capturedPieceWithColor(move));
			} else if (move == Move.NULLMOVE) { 
				// do nothing
			} else {
				board.clearPiece(Move.toSquare(move));
				board.setPiece(Move.fromSquare(move),piece );
				board.setPiece(Move.toSquare(move), Move.capturedPieceWithColor(move));
			}
			setPuzzleMove(board, false);
		}

		/// implements Controller.moveForward used by  BoardView
		public function moveForward(board:BoardView):int {
			var state:PgnState = board.getPgnState();
			if (state == null) return 0;
			var pgnmove:PgnMove = state.getCurrentMoveNode();
			var move:int = state.getNextMove(_pgnGame);
			if (_moveTextView != null) {
				var nextmove:PgnMove = pgnmove.getParent().nextMove(pgnmove as PgnMove);
				if (nextmove != null) {
					_moveTextView.highlightMoveTextForward(nextmove.getTextStartPos(), nextmove.getMoveLength());
				}
				_moveTextView.highlightMoveTextForward(pgnmove.getTextStartPos(), pgnmove.getMoveLength());
			}
			pgnmove = state.getCurrentMoveNode();
			if (pgnmove != null) { 
				if (!state._pastEnd) { 
					board.setWhiteToMove(pgnmove.whiteToMove());
				} else { // at the end of the game or sequence
					board.setWhiteToMove(!pgnmove.whiteToMove());
					if (!_closingPlayed && pgnmove.getParent().getLevel() == 0) {
						_closingPlayed = true;
						//PlaySound.instance.play(_closingUrl, true);
					}
				}
			}
			setVariations(board);
			return move;
		}

		/// implements Controller.moveForward used by  BoardView
		public function moveBackward(board:BoardView):int {
			var state:PgnState = board.getPgnState();
			if (state == null) return 0;
			var move:int = state.getPreviousMove(_pgnGame);
			var pgnmove:PgnMove = state.getCurrentMoveNode();
			if (_moveTextView != null) { 	
				var prevmove:PgnMove = pgnmove.getParent().prevMove(pgnmove as PgnMove);
				if (prevmove != null) {
					_moveTextView.highlightMoveTextBackward(prevmove.getTextStartPos(), prevmove.getMoveLength());
				}
				_moveTextView.highlightMoveTextBackward(pgnmove.getTextStartPos(), pgnmove.getMoveLength());
			}
			if (pgnmove != null) {
				board.setWhiteToMove(pgnmove.whiteToMove());
			}
			setVariations(board);
			return move;
		}
	
// debugging aid
//		public static function xtrace(msg:Object):void {
//			if (LayoutManager._debug) {
//				fscommand("trace", msg.toString());
//			}
//		} 
		
/// Private Functions		

		private function moreMovesForward(board:BoardView):Boolean {
			var state:PgnState = board.getPgnState();
			return state != null && state.moreMovesForward();
		}
		
		private function getPgnGameText():String {
			return _pgnGame == null ? DEFAULT_MOVETEXT : 
				_pgnGame.getPgnText(_lm._pieces);
		}

		private function getPgnHeaderText():String {
			return _pgnGame == null ? DEFAULT_HEADER : _pgnGame.getPgnHeader();
		}

		private function clickedVariation(index:int) : void {
			if (_variationBtns != null && index < _variationBtns.length) {
				for (var i:int = 0; i < _variationBtns.length; i++) {
					(_variationBtns[i] as BtnText).setSelected(false);
				}
				if (index == 0 && !_lm._twoBoardMode) { // in one board mode, btn 0 is the main line
					selectMoveTextByNode(_variationsMoveNode);
				} else {
					var sequence:PgnSequence;
					if (!_lm._twoBoardMode) {
						sequence = _variationsMoveNode.getVariation(index - 1);
					} else {
						sequence = _variationsMoveNode.getVariation(index);
					}
					if (sequence != null) {
						var node:PgnNode = sequence.getNode(0);
						if (node.getType() != PgnNode.PGNMOVE) {
							node = sequence.nextMove(node);
						}
						selectMoveTextByNode(node as PgnMove);
					}
				}
				(_variationBtns[index] as BtnText).setSelected(true); // gew moved from above
			}
		}
		
		// 
		private function setVariations(board:BoardView) :void {
			if (!_lm._tabMode) return;
			var state:PgnState = board.getPgnState();
			if (state == null) return;
			if (board.getName() == BV_MAIN) {
				var movenode:PgnMove = board.getPgnState().getCurrentMoveNode();
				if (movenode == null || movenode.getParent().getLevel() != 0) {
					return;
				}
				var names:Array = movenode.getVariationNames(!_lm._twoBoardMode, _lm._pieces);
				if (names.length > 0) { // variations stay until we encounter others
					_variationsMoveNode = movenode;
					if (_variationBtns != null) {
						for (var j:int = 0; j < _variationBtns.length; j++) {
							removeChild(_variationBtns[j]);
						}
					}
					_variationBtns = new Array(names.length > 8 ? 8 : names.length); // max of 8 variations
					for (var i:int = 0; i < names.length; i++) {
						var btn:BtnText = new BtnText(names[i] as String, i, _lm);
						btn.enabled = true;
						btn.x = _lm._varBtnX; 
						btn.y = _lm.getVarBtnY(i);
						btn.addEventListener(MouseEvent.CLICK, onClickVariation);
						addChild(btn);
						_variationBtns[i] = btn;
					}
				}
			}
		}
		
		// make the move after .... time or frames or ... something
		private function queuePuzzleMove(board:BoardView, forward:Boolean):void {
			if (!_lm._puzzle) return; 
			if (_queuePending) return; // only 1 at a time
			if (!moreMovesForward(board)) return;
			_queueCount = this.stage.frameRate; // about 1 sec?
			_queueBoard = board;
			_queueForward = forward;
			_queuePending = true;
		}
		
		// set move for BoardView
		private function setPuzzleMove(board:BoardView, forward:Boolean):void {
			if (!_lm._puzzle) return; 
			if (!moreMovesForward(board)) return;
			if (board._whiteToMove != _lm._humanPlaysWhite) { // move forward one move
				if (forward) {
					execute(moveForward(board), board, true);
				} else {
					board.clearMoveToAccept();
					return;
				}
			} 
			if (!moreMovesForward(board)) return;
			var state:PgnState = board.getPgnState();
			if (state == null) return;
			var pgnmove:PgnMove = state.getCurrentMoveNode();
			var move:int = pgnmove.getMove();
			var fromsq:int = Move.fromSquare(move);
			var tosq:int = Move.toSquare(move);
			board.clearMoveToAccept();
			board.setMoveToAccept(fromsq, tosq);
		}

		/// used from selectMoveText
		private function selectMoveTextByNode(node:PgnMove):void {
			if (node == null) return;
			var board:BoardView = _boardView1;
			if (_lm._twoBoardMode && node.getParent().getLevel() != 0) { 
				board = _boardView2;
			}
			var sequence: PgnSequence = board.getPgnState()._currentSequence;
			if (sequence.getLevel() > 0) {
				formatSequence(board.getPgnState()._currentSequence, _lm._defaultMoveFormat,_lm._defaultTextFormat);
			}

			// go back to the original, initial position
			resetBoardView(board);
			var pgnState:PgnState = board.getPgnState(); // and original state
			pgnState.init(_pgnGame);
			
			var moves:Array = getMovePathFromBeginningToNode(node);
			var move:int;
			while (moves.length > 0) {
				move = moves.pop() as int;
				execute(move, board, false);
			}
			//sync pgnstate to this position
			pgnState._currentNode = node;
			pgnState._currentMove = node as PgnMove;
			pgnState._currentSequence = node.getParent();
			if (pgnState._currentSequence.getLevel() > 0) {
				formatSequence(board.getPgnState()._currentSequence, _lm._variationMoveFormat, _lm._variationTextFormat);
			}

			if (_moveTextView != null) {
				var nextmove:PgnMove = node.getParent().nextMove(node as PgnMove);
				if (nextmove != null) {
					_moveTextView.highlightMoveText(nextmove.getTextStartPos(), nextmove.getMoveLength());
				}
				_moveTextView.highlightMoveText(node.getTextStartPos(), node.getMoveLength());
			}
			execute(moveForward(board), board, false);
			board.setBtnStates();
			board.setMoveForwardFocus();
		}

		private function getMovePathFromBeginningToNode(node:PgnNode) : Array {
			return _pgnGame.getMovePathFromBeginningToNode(node);
		}
		
		private function onStageDelayLoad(event:Event):void {
			_delayCount++;
			if (_delayCount >= stage.frameRate) {
				stage.removeEventListener(Event.ENTER_FRAME, onStageDelayLoad);
				initialize();
			}
		}
		
		private function initialize():void {
			if (_lm == null) {
				_lm = new LayoutManager(this.stage, _loaderInfo, _jangaroo, _args);
			}
			
			_fenString = _lm.getParamString("fen", null);

            _pgnUrl = _lm.getParamString("pgnurl", "");
					//"");
					//"tchaisson/blindfold_1.pgn");
					//"http://glennwilson.com/games/200303070.pgn");
					//"Glenn Wilson/grieg.pgn");
			        //"banatt/Nimzovich - Alpin.PGN");
			        //"thechessdoctor/ReganShao.pgn");
					//"Glenn Wilson/TestData/TestComments.pgn");
					//"Glenn Wilson/TestData/BadData1.pgn");
					//"Glenn Wilson/TestData/BadData2.pgn");
					//"Glenn Wilson/TestData/BadData3.pgn");
					//"Glenn Wilson/TestData/BadData4.pgn");
					//"Glenn Wilson/TestData/BadData5.pgn");
					//"Glenn Wilson/TestData/BadData6.pgn");
					//"Liquid Egg Product/Takchess vs Liquid Egg Product, LEPers 2 Rd. 1.pgn");
					//"Glenn Wilson/Puzzle1.pgn");
					//"Glenn Wilson/zSaavedra.pgn");
					//"Glenn Wilson/Openings/PircAustrianAttack.pgn");
					//"Glenn Wilson/big_0.pgn");
					//"Glenn Wilson/lf-ko.pgn");
			
			_introUrl = _lm.getParamString("introurl", "");
			         //"Glenn Wilson/Puzzles/Morhpy-Baucher-1858.mp3,mp3/sym5-i.mp3");
			        //""); 
					//"Glenn Wilson/TestData/test.mp3");
					
			_closingUrl = _lm.getParamString("closingurl", ""); 
					//"Glenn Wilson/TestData/test.mp3");
			
			this.stage.showDefaultContextMenu = false;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;

			graphics.beginFill(_lm._backgroundColor);
			graphics.lineStyle( 1, _lm._backgroundColor, 1);
			graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			graphics.endFill();

			var defaultfen:Fen;
			if (_fenString == null) {
				defaultfen = new Fen();
			} else {
				defaultfen = new Fen(_fenString);
			}
			
			var pgnState:PgnState = new PgnState();
			
			_boardView1 = new BoardView(_lm, this, pgnState, BV_MAIN);
			_boardView1.x = _lm._boardView1X;
			_boardView1.y = _lm._boardView1Y;
			addChild(_boardView1);
			setFenBoardView(_boardView1, defaultfen);
			
			if (_lm._twoBoardMode) {
				pgnState = new PgnState();
				
				_boardView2 = new BoardView(_lm, this, pgnState, BV_VARS);
				_boardView2.x = _lm._boardView2X;
				_boardView2.y = _lm._boardView2Y;
				addChild(_boardView2);
				setFenBoardView(_boardView2, defaultfen);
			}
			
			if (!_lm._diagramMode && !_lm._boardOnly) {
				_headerView = new HeaderView(_lm, DEFAULT_HEADER);
				_headerView.y = _lm._headerViewY;
				_headerView.x = _lm._headerViewX;
				addChild(_headerView);

				_adView = new AdView(_lm);
				_adView.y = _lm._adViewY;
				_adView.x = _lm._adViewX;
				addChild(_adView);

				_moveTextView = new MoveTextView(_lm, this, DEFAULT_MOVETEXT);
				_moveTextView.y = _lm._mtViewY;
				_moveTextView.x = _lm._mtViewX;
				addChild(_moveTextView);
			}

			if (_lm._autoPlay) {
				startListener(null);
			} else {
				drawStartGraphics();
			}
		}

		private function drawStartGraphics(): void {
			var btnsize:int  = _lm._squaresize * 6; 
					
			_startBtn = new BtnStart(btnsize, btnsize * 2 / 3, _lm);
			_startBtn.enabled = true;
			_startBtn.x = _boardView1.x + _lm._bordersize + 3 + _lm._squaresize;
			_startBtn.y = _boardView1.y + _lm._bordersize + 3 + (_lm._squaresize * 8 - _startBtn.height) / 2 
					+ _startBtn.width / 30;

			_startTF = new TextField();
			var tsize:int = btnsize / 12;
			_startTF.width = btnsize * 0.6;
			_startTF.height = tsize * 2;
			_startTF.text = "Click to Play";
			_startTF.x = _startBtn.x + tsize;
			_startTF.y = _startBtn.y + _startBtn.height / 2 - _startTF.height / 2 - 3;
			var format:TextFormat = new TextFormat("arial", tsize, 
				_lm.getLightColor(LayoutManager.BV_MAIN), true);
				
			format.align = TextFormatAlign.LEFT;
			_startTF.setTextFormat(format);
			
			addChild(_startBtn);
			addChild(_startTF);
			
			_startBtn.addEventListener(MouseEvent.CLICK, startListener);
			_startTF.addEventListener(MouseEvent.CLICK, startListener);
		}
		
		private function startListener(event:MouseEvent) :  void {
			// intro starts here??
			//PlaySound.instance.play(_introUrl, true);
			if (_startBtn != null) removeChild(_startBtn);
			if (_startTF != null) removeChild(_startTF);
			if (_lm._pgnData == null) {
				_pgn = new Pgn(this, _pgnUrl, null);
			} else {
				_pgn = new Pgn(null, null, _lm._pgnData);
				loaded();
			}
		}

		private function setFenBoardView(board:BoardView, fen:Fen):void {
			board.clearHighlightsAndArrows();
			board.setWhiteToMove(fen.getWhiteToMove());
			for (var index:uint = 0; index < 64; index++) {
				var piece:int = fen.getPieceFenAtIndex(index);
				if (piece != 0) {
					board.setPiece(index, piece);
				} else {
					board.clearPiece(index);
				}
			}
		}

		private function onStageEnterFrame(event:Event):void {
			if (_queuePending) {
				_queueCount--;
				if (_queueCount < 0) {
					_queuePending = false;
					setPuzzleMove(_queueBoard, _queueForward);
				}
			}
		}

		private function keyPressed(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ESCAPE) {
				this.stage.focus = null;
			}
		}
		
		private function resetBoardView(board:BoardView):void {
			board.clearHighlightsAndArrows();

			board.setWhiteToMove(_fen.getWhiteToMove());
			for (var index:uint = 0; index < 64; index++) {
				var piece:int = _fen.getPieceFenAtIndex(index);
				if (piece != 0) {
					board.setPiece(index, piece);
				} else {
					board.clearPiece(index);
				}
			}
			setVariations(board);
			board.setBtnStates();
		}

		private function onClickVariation(event:MouseEvent):void {
			var target:BtnText = event.currentTarget as BtnText;
			if (target != null) {
				clickedVariation(target.getIndex());
			}
		}
		
		private function formatSequence(sequence:PgnSequence, formatMove:TextFormat, formatText:TextFormat) :void {
			if (_moveTextView == null) return;
			var i:int;
			var count:int = sequence.getNodeCount();
			for (i = 0; i < count; i++) {
				var node:PgnNode = sequence.getNode(i);
				var begin:int = node.getTextStartPos();
				var lenMove:int = node.getMoveLength();
				var lenText:int = node.getTextLength();
				if (lenMove > 0) {
					_moveTextView.formatMoveText(begin, lenMove, formatMove);
				}
				if (lenText > lenMove) {
					_moveTextView.formatMoveText(begin+lenMove, lenText-lenMove, formatText);
				}
			}
		}
	}
}