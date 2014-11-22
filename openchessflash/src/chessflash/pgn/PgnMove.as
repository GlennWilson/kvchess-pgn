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
package chessflash.pgn {
	
	import chessflash.engine.Board;
	import chessflash.engine.Move;
	import chessflash.engine.MoveGenerator;
	
	/**
	 * Two Sections:
	 * TAGPAIR SECTION
	 * MOVETEXT SECTION
	 * TAGPAIR SECTION
	 * Tag : [Key "Value"]  left bracket, tag name, tag value, and right bracket.
	 * Brace Comment { any text } ; do not nest
	 * RAV ( moves )  ; may be nested
	 * <> ; reserved
	 * moves
	 * NAG
	 * Annotations
	 * Game End
	 * Line Comment
	 *   ; anywhere on line
	 *   % must be first char on lne
	 * Tokens
	 *  {} () <> . * $0-$255
	 * 
	 * TAGPAIR SECTION
	 *   tags, comments, escape
	 *   
	 * MOVETEXT SECTION
	 *   
	 * PgnMoveText
	 *    _level
	 *    _parent
	 *    _array of children PgnMoveText Arrays
	 * 
	 *  --> Move
     * 	   This Move
	 *     optional annotation
	 *  --> Text
	 *     Comments (line, brace, escape, game termination, NAG)
	 */
	public class PgnMove extends PgnNode {
		private static var _debug:Boolean = false;		

		private var _side:int;
		private var _valid:Boolean = true;
		
/// Constructor		
		
		public function PgnMove(move:int, text:String, parent:PgnSequence=null) {
			super(PGNMOVE, text, parent);
			_move = move;
		}
		
/// Public Functions		
		
		public function whiteToMove():Boolean {
			return _side == Board.WHITE;
		}
		
/// Internal Functions		

		internal function getSide():int {
			return _side;
		}

		internal function validate():void {
			var board:Board = getParent().getBoard();
			var movegenerator:MoveGenerator = new MoveGenerator(board);
			movegenerator.generate();
			movegenerator.cleanMoves();
			var i:int;			
			
			var move:int = Move.findMove(_text, board._moveList);
			_move = move;
			_side = board._side;
			if (move == Move.NOMOVE) { // was not able to match themove
				_text += " **Impossible or ambiguous move:(" + _text +")"; 
				_text += " Possible moves:";
				for (i = 0; i < board._moveList.length; i++) {
					_text += " " + Move.moveSan(board._moveList[i], board._moveList);
				}
				_text += ". Please correct the PGN file or report a defect if the PGN file is correct.";
				_valid = false;
				getParent().invalidate();
			} else {
				if (_debug) {
					_text += "[DEBUG:(move=" + Number(move).toString(16) 
						+ ":piece=" + Move.movingPiece(move) 
						+ ":from=" + Move.fromSquare(move) 
						+ ":to=" + Move.toSquare(move) 
						+ ":cap=" + Move.capturedPiece(move) 
						+ ":ep=" + Move.isEnpassant(move)
						+ ":promo=" + Move.isPromotion(move) 
						+ ":castling=" + Move.isCastling(move) + ")";
					for (i = 0; i < board._moveList.length; i++) {
						_text += " " + Move.moveSan(board._moveList[i], board._moveList);
					}
					_text += "]BEFORE:" + board.toString() ;
				}
				board.makeMove(move);
				if (_debug) {
					_text += "]AFTER:" + board.toString() ;
				}
				_valid = true;
			}
		}
		
		internal function getValid():Boolean {
			return _valid;
		}
	}
}