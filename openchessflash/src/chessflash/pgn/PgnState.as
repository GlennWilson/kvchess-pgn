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

	import chessflash.engine.Move;
	
	public class PgnState {
		public var _currentSequence:PgnSequence;
		public var _currentNode:PgnNode;
		public var _currentMove:PgnMove;
		public var _pastEnd:Boolean = false;
		
/// Public Functions
		
		public function getCurrentMoveNode():PgnMove {
			return _currentMove;
		}

		public function init(pgnGame:PgnGame):void {
			_pastEnd = false;
			_currentSequence = pgnGame._pgnSequence;
			_currentNode = _currentSequence.getNode(0);
			if (_currentNode.getType() == PgnNode.PGNMOVE) {
				_currentMove = _currentNode as PgnMove;
			} else {
				_currentMove = _currentSequence.nextMove(_currentNode);
			}
		}

		public function getNextMove(pgnGame:PgnGame): int {
			var move:int = getCurrentMove();
			
			if (moreMovesForward() && _currentSequence.nextMove(_currentMove) != null) {
				_currentMove = _currentSequence.nextMove(_currentMove);
			} else {
				_pastEnd = true;
			}

			return move;	
		}

		public function getPreviousMove(pgnGame:PgnGame): int {
			if (moreMovesBackward()) {
				if (_pastEnd) {
					_pastEnd = false;
					return getCurrentMove();
				}
				_currentMove = _currentSequence.prevMove(_currentMove);
				return getCurrentMove();
			} else {
				return Move.NOMOVE;
			}
		}
		
		public function moreMovesBackward():Boolean {
			if (_currentMove == null) { // no current move
				return false;
			}
			if (_pastEnd && _currentMove != null) return true;
			return _currentSequence.prevMove(_currentMove) != null;
		}

		public function moreMovesForward():Boolean {
			if (_currentMove == null || _pastEnd) { // no current move
				return false;
			}
			return true;
		}

/// Private Functions

		private function getCurrentMove(): int {
			return _currentMove == null ? Move.NOMOVE : _currentMove.getMove();
		}

	}
}