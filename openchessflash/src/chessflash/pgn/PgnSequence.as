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
	
	public class PgnSequence {
		
		private var _level:int;
		private var _parent:PgnNode;
		private var _nodes:Array;
		private var _plyCount:int = 0;
		private var _board:Board;
		private var _fen:String;
		private var _valid:Boolean = true;
		private var _textStartPos:int;
		private var _pgnGame:PgnGame;
		
/// Constructor		
		
		public function PgnSequence(level:int, parent:PgnNode=null) {
			_level = level;
			_nodes = new Array();
			_parent = parent;
		}

/// Public Functions		
		
		public function getLevel() : int {
			return _level;
		}
		
		public function getNodeCount():int {
			return _nodes.length;
		}
		
		public function getNode(id:int): PgnNode {
			return (id >= 0 && id < _nodes.length) ? _nodes[id] : null;
		}
		
		public function nextMove(node:PgnNode):PgnMove {
			var node2:PgnNode = nextNode(node);
			while (node2 != null) {
				if (node2.getType() == PgnNode.PGNMOVE) {
					break;
				}
				node2 = nextNode(node2);
			}
			return node2 as PgnMove;
		}

		// climb backwards up the tree towards first move
		public function prevMove(node:PgnNode):PgnMove {
			var id:int;
			var sequence:PgnSequence;
			while (node != null) {
				id = node.getId() - 1;
				if (id >= 0) {
					sequence = node.getParent(); // maybe not this sequence
					node = sequence.getNode(id);
				} else {
					node = null;
					if (node != null) {
						sequence = node.getParent();
						node = sequence.prevNode(node); // undo last move of previous sequence
					}
				}
				if (node != null && node.getType() == PgnNode.PGNMOVE) {
					return node as PgnMove;
				}
			}
			return null as PgnMove;	
		}

/// Internal Functions		
		
		internal function getParent(): PgnNode {
			return _parent;
		}
		
		internal function setFen(fen:String):void {
			_fen = fen;
		}
		
		internal function invalidate():void {
			_valid = false;
		}
		
		internal function getValid():Boolean {
			return _valid;
		}
		
		internal function setBoard(board:Board):void {
			_board = board;
		}

		internal function getPlyCount():int {
			return _plyCount;
		}
		
		internal function getPgnGame():PgnGame {
			return _pgnGame;
		}
		
		internal function setPgnGame(pgnGame:PgnGame):void {
			_pgnGame = pgnGame;
		}
		
		internal function addNode(node:PgnNode): void {
			node.setParent(this);
			_nodes.push(node);
			node.setId(_nodes.length - 1);
			getPgnGame().addToAllNodes(node);
			if (_valid) {
				if (node.getType() == PgnNode.PGNMOVE) {
					validateMove(node); // validate move
					_plyCount++;
				}
			}
		}
		
		internal function nextNode(node:PgnNode):PgnNode {
			var id:int = (node == null) ? -1 : node.getId();
			return (id >= -1 && id < (_nodes.length - 1)) ? _nodes[id + 1] : null;
		}

		internal function prevNode(node:PgnNode):PgnNode {
			var id:int;
			if (node != null) {
				id = node.getId() - 1;
				if (id >= 0) {
					return _nodes[id];
				} else {
					return null;
				}
			}
			return null;	
		}


		internal function lastNode():PgnNode {
			return _nodes[_nodes.length - 1] as PgnNode;
		}
		
		internal function getSubSequenceName(start:int, pieces:String) : String {
			var i:int = start;
			var node:PgnNode;
			var moveNode:PgnMove;
			var moveDots:PgnNode;
			var moveNumber:PgnNode;
			// back up to a move node if possible
			while (i > -1) {
				node = _nodes[i] as PgnNode;
				if (node.getType() == PgnNode.PGNMOVE) {
					moveNode = node as PgnMove;
					break;
				}
				i--;
			}
			// back up to a move number node if possible
			while (i > -1) {
				node = _nodes[i] as PgnNode;
				if (node.getType() == PgnNode.PGNMOVENUMBER) {
					moveNumber = node;
					break;
				}
				if (node.getType() == PgnNode.PGNMOVEDOTS) {
					moveDots = node;
				}
				i--;
			}
			var val:String = "";
			if (moveNumber != null) {
				val += moveNumber.getText()
			}
			if (moveNode != null && !moveNode.whiteToMove()) { 
				val += "...";
			} else {
				val += ".";
			}
			if (moveNode != null) {
				val += moveNode.getXlateMoveText(pieces);
			}
			return val;
		}
		
		internal function getSequenceName(start:int, pieces:String):String {
			var i:int;
			var val:String = "";
			var node:PgnNode;
			for (i = start; i < _nodes.length; i++) {
				node = _nodes[i] as PgnNode;
				if (node.getType() == PgnNode.PGNMOVENUMBER) {
					val += node.getText();
				} else if (node.getType() == PgnNode.PGNMOVEDOTS) {
					val += node.getText();
				} else if (node.getType() == PgnNode.PGNMOVE ) {
					val += node.getXlateMoveText(pieces);
					return val;
				}
			}
			return val;
		}
		
		internal function getPgnText(pos:int, pieces:String):String {
			_board = null; // we no longer need the board
			if (_textStartPos == 0) _textStartPos = pos;
			var i:int;
			var val:String = "";
			var node:PgnNode;
			for (i = 0; i < _nodes.length; i++) {
				node = _nodes[i] as PgnNode;
				val += node.getPgnText(_textStartPos + val.length, pieces);
			}
			return val;
		}
		
		internal function getBoard():Board {
			if (_board == null) {
				_board = new Board();
				_board.initialize(_fen);
			}
			return _board;
		}

/// Private Functions		

		private function validateMove(node: PgnNode): void {
			var movenode:PgnMove = node as PgnMove;
			return movenode.validate();
		}

	}
}