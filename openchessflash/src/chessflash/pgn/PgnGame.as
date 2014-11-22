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
	import flash.utils.Dictionary;
	
	public class PgnGame {
		
		private var _tags:Dictionary; // tag name-value pair
		private var _tagList:Array;   // ordered tag names
		public var _pgnSequence:PgnSequence;  // array of the level 0 nodes
		public var _fen:String;
		private var _pgnText:String;
		private var _pgnHeader:String;
		public var _allNodes:Array = new Array();
		
/// Constructor
		
		public function PgnGame() {
			_tags = new Dictionary;
			_tagList = new Array();
			_pgnSequence = new PgnSequence(0);
			_pgnSequence.setPgnGame(this);
		}
		
/// Public Functions		
		
		public function getFenString() : String {
			return _fen;
		}
		
		public function findPgnMoveByCharIndex(index:int):PgnMove {
			var node: PgnNode = xfindPgnNodeByCharIndex(index);
			if (node != null) {
				if (node.getType() == PgnNode.PGNMOVE) return node as PgnMove;
				node = node.getParent().nextMove(node);
				// if (node != null) return node as PgnMove;
				// node = node.getParent().prevMove(node);
				return node as PgnMove;
			}
			return null;
		}

		public function getMovePathFromBeginningToNode(node:PgnNode) : Array {
			var moves:Array = new Array();
			var oldnode:PgnNode;
			if (node.getType() == PgnNode.PGNMOVE) {
				moves.push(PgnMove(node).getMove());
			}
			while (node != null) {
				oldnode = node;
				node = node.getParent().prevMove(node);
				if (node != null) {
					moves.push(PgnMove(node).getMove());
				} else {
					node = oldnode.getParent().getParent();	
				}
			}
			return moves;
		}
		
		public function getPgnHeader() :String {
			if (_pgnHeader != null) return _pgnHeader;
			
			var val:String = null;
			var i:int;
			var tag:String;

			var white:String = _tags["White"] == null ? "?" : _tags["White"];
			var whiteelo:String = _tags["WhiteElo"] == null ? "?" : _tags["WhiteElo"];
			var black:String = _tags["Black"] == null ? "?" : _tags["Black"];
			var blackelo:String = _tags["BlackElo"] == null ? "?" : _tags["BlackElo"];
			var event:String = _tags["Event"] == null ? "?" : _tags["Event"];
			var site:String = _tags["Site"] == null ? "?" : _tags["Site"];
			
			var date:String = _tags["Date"] == null ? "?" : _tags["Date"];
			if (date.charAt(0) == "?") date = "?";
			
			var round:String = _tags["Round"] == null ? "?" : _tags["Round"];
			if (round.charAt(0) != "?") round = "Round: "  + round;
			
			var eco:String = _tags["ECO"] == null ? "?" : _tags["ECO"];
			if (eco.charAt(0) == "?") {
				eco = "?";
			} else {
				eco = "ECO: " + eco;
			}

			if (whiteelo != "?") white += " (" + whiteelo + ")";
			if (blackelo != "?") black += " (" + blackelo + ")";
			if (white != "?" || black != "?") {
				val = white + " - " + black;
			} 
			
			var es:String = null;
			if (event != "?" ) es = event;
			if (site != "?") {
				es = es == null ? site : es + ", " + site; 
			}

			var dre:String = null;
			if (date != "?" ) dre = date;
			if (round != "?") {
				dre = dre == null ? round : dre + ", " + round; 				
			}
			if (eco != "?") {
				dre = dre == null ? eco : dre + ", " + eco; 				
			}
			
			if (es != null) {
				val = val == null ? es : val + "\n" + es;
			}
			if (dre != null) {
				val = val == null ? dre : val + "\n" + dre;
			}
			if (val == null) val = "";
		
			_pgnHeader = val;
			return _pgnHeader;
		}

		public function getPgnText(pieces:String) : String {
			if (_pgnText != null) return _pgnText;
			
			_pgnText = _pgnSequence.getPgnText(0, pieces) + "\n";
			return _pgnText;
		}

/// Internal Functions		
		
		internal function addToAllNodes(pgnNode: PgnNode):void {
			_allNodes.push(pgnNode);
		}
		
		internal function addTag(name:String, value:String) : void {
			_tags[name] = value;
			_tagList.push(name);
			if (name == "FEN") {
				_fen = value;
				_pgnSequence.setFen(_fen); 
			} else if (name.toUpperCase() == "FEN" && _fen == null) {
				_fen = value;
				_pgnSequence.setFen(_fen); 
			}
		}
		
		internal function getTag(name:String) : String {
			return _tags[name];
		}

/// Private Functions		
		
		private function xfindPgnNodeByCharIndex(index:int):PgnNode {
			for (var i:int = 0; i < _allNodes.length; i++) {
				var node: PgnNode = _allNodes[i] as PgnNode;
				if (node.getTextStartPos() <= index 
					&& (node.getTextStartPos() + node.getTextLength()) >= index) {
						return node;
				}
			}
			return null;
		}
	}
}