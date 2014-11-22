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
	public class PgnNode {
		public static const PGNMOVE:int = 1;
		public static const PGNLINECOMMENT:int = 2;
		public static const PGNBRACECOMMENT:int = 3;
		public static const PGNESCAPECOMMENT:int = 4;
		public static const PGNGAMETERMINATION:int = 5;
		public static const PGNNAG:int = 6;
		public static const PGNMOVENUMBER:int = 7;
		public static const PGNMOVEDOTS:int = 8;
		public static const PGNANNOTATIONS:int = 8;

		protected var _parent: PgnSequence;
		protected var _type: int;
		protected var _text: String;
		protected var _textLength:int;
		protected var _moveLength:int;
		protected var _children: Array; // array of arrays of PgnSequence
		protected var _id:int = -1;
		protected var _annotations:Array;
		protected var _nags:Array;
		protected var _comments:Array;
		protected var _move:int = 0;
		
		private var _textStartPos:int;

/// Constructor		
		
		public function PgnNode(type:int, text:String, parent:PgnSequence=null) {
			_parent = parent;
			_type = type;
			_text = text;
			_children = new Array();
			_nags = new Array();
			_comments = new Array();
			_annotations = new Array();
		}
		
/// Public Functions		
		
		public function getMove():int {
			return _move;
		}

		public function getTextStartPos(): int {
			return _textStartPos;
		}
		
		public function getTextLength(): int {
			return _textLength;
		}

		public function getMoveLength(): int {
			return _moveLength;
		}

		public function getVariationNames(includeMainline:Boolean, pieces:String) : Array {
			if (_children.length == 0) {
				return new Array(0);
			}
			var names:Array;
			var i:int;
			if (includeMainline) {
				names = new Array(_children.length+1);
				names[0] = _parent.getSubSequenceName(_id, pieces);
				for (i = 0; i < _children.length; i++) {
					names[i+1] = (_children[i] as PgnSequence).getSequenceName(0, pieces);
				}
				return names;
			} else {
				names = new Array(_children.length);
				for (i = 0; i < _children.length; i++) {
					names[i] = (_children[i] as PgnSequence).getSequenceName(0, pieces);
				}
				return names;
			}
		}
		
		public function getVariation(index:int):PgnSequence {
			if (index < _children.length) return _children[index] as PgnSequence;
			return null;
		}
		
		public function getParent():PgnSequence {
			return _parent;
		}
		
		public function getType() : int {
			return _type;
		}
		
/// Internal Functions		
		
		internal function addNag(text:String):void {
			_nags.push(text);
		}
		
		internal function addComment(text:String):void {
			_comments.push(text);
		}

		internal function addAnnotation(text:String):void {
			_annotations.push(text);
		}

		internal function setParent(parent:PgnSequence):void {
			_parent = parent;
		}
		
		internal function getVariationCount() :int {
			return _children.length;
		}
		
		// copy current board; undo last move made for children sequence
		internal function addSequence():PgnSequence {
			var sequence:PgnSequence = new PgnSequence(_parent.getLevel() + 1, this);
			sequence.setPgnGame(getParent().getPgnGame());
			_children.push(sequence);

			var move:int;
			var movenode:PgnMove;
			var board:Board;
			if (getType() == PGNMOVE) {
				movenode = this as PgnMove;
			} else {
				movenode = getParent().prevMove(this);
			}
			if (movenode != null) {
				board = getParent().getBoard().copy();
		
				move = movenode.getMove();
				if (getParent().getValid()) {
					board.unMakeMove(move);
					sequence.setBoard(board);
				}
			}
			
			return sequence;
		}

		internal function getText() : String {
			return _text;
		}
		
		internal function getXlateMoveText(pieces:String) : String {
			return xlateMove(cleanString(_text), pieces);
		}

		internal function setId(id:int) : void {
			_id = id;
		}
		
		internal function getId() : int {
			return _id;
		}
		
		internal function toString():String {
			return _text;
		}
		
		internal function getPgnText(pos:int, pieces:String):String {
			if (_textStartPos == 0) _textStartPos = pos;
			var i:int;
			var val:String;
			var sequence:PgnSequence;
			var seqText:String;
			
			if (_text == null) return "";
			if (_type == PGNMOVENUMBER) {
				val = cleanString(_text) + getComments();
				_moveLength = cleanString(_text).length;
			} else if (_type == PGNMOVE) {
				val = getXlateMoveText(pieces);
				for (i = 0; i < _nags.length; i++) {
					val += getNagText(_nags[i]);
				}
                val += getAnnotations();
				_moveLength = val.length;
				var nodenext:PgnNode = this.getParent().nextNode(this);
				val += " "  + getComments();
			} else if (_type == PGNNAG) {
				val = getNagText(_text) + " "  + getComments();
				_moveLength = val.length;
			} else if (_type == PGNBRACECOMMENT) {
				val = cleanString(_text);
				if (val.charAt(val.length - 1) != " ") val += " ";
				val += getComments();
			} else if (_type == PGNANNOTATIONS) {
				val = _text + " ";
				_moveLength = val.length;
				val += " "  + getComments();
			} else  {
				val = cleanString(_text) + getComments();
			}
			_textLength = val.length;
			
			if (_children.length > 0) {
				sequence = _children[0] as PgnSequence;
				if (sequence.getLevel() == 1) {
					val += " \n\t[";
				} else {
					val += " (";
				}
			}
			
			for (i = 0; i < _children.length; i++) {
				sequence = _children[i] as PgnSequence;
				seqText = seqText == null ? cleanString(sequence.getPgnText(val.length+pos, pieces))  
					: seqText + ";" + cleanString(sequence.getPgnText(val.length+seqText.length+1+pos,pieces));
			}
			
			if (sequence != null) {
				if (sequence.getLevel() == 1) {
					val += seqText + "]\n";
				} else {
					val += seqText + ") ";
				}
			}
			return val;
		}
		
/// Private Functions		
		
			private function xlateMove(move:String, pieces:String):String {
				if (pieces == null || pieces.length == 0 ) return move;
				if (move == null || move.length == 0 ) return move;
				var piece:String = move.substr(0, 1);
				var location:int = "KQRBNP".indexOf(piece, 0);
				if (location < 0 || location >= pieces.length)  {
					return xlateMovePromo(move, pieces);  // could be pawn promo needing xlation
				}
				var newmove:String = null;
				newmove = pieces.substr(location, 1) + move.substr(1);
				return xlateMovePromo(newmove, pieces);
			}
			
			private function xlateMovePromo(move:String, pieces:String):String {
				if (!Move.isPromotion(_move)) {
					return move;
				}
				var location:int = move.indexOf("=", 0);
				if (location < 0 || location >= (move.length-1)) return move; // no translation
				var piece:String = move.substr(location + 1, 1); // promo piece to xlate
				
				var location2:int = "KQRBNP".indexOf(piece, 0);
				if (location2 < 0 || location2 >= pieces.length) return move; // no translation
				if (move.indexOf(piece) < 0) return move; // impossible ? no translation
				var newmove:String = move.replace(piece, pieces.substr(location2,1));
				return newmove;
							
				
			}
			
			private function getAnnotations():String {
			var val:String = "";
			for (var i:int = 0; i < _annotations.length; i++) {
				var anno:String = _annotations[i] as String;
				val += anno;
				//if (val.charAt(val.length - 1) != " ") val += " ";
			}	
			return val;
		}

		private function getComments():String {
			var val:String = "";
			for (var i:int = 0; i < _comments.length; i++) {
				var cmmt:String = _comments[i] as String;
				val += cmmt;
				if (val.charAt(val.length - 1) != " ") val += " ";
			}	
			return cleanString(val);
		}
		
		private function getNagText(text:String):String {
			var nag:int = parseInt(text);
			var nagtext:String;
			switch(nag) {
				case 1: return "!";
				case 2: return "?";
				case 3: return "!!";
				case 4: return "??";
				case 5: return "!?";
				case 6: return "?!";
				case 10: 
				case 11:
				case 12: return "=";
				case 13: return "unclear";
				case 14: return "+/=";
				case 15: return "=/+";
				case 16: return "+/-";
				case 17: return "-/+";
				case 18: return "+-";
				case 19: return "-+";
				case 20: return "+-";
				case 21: return "-+";
				case 142: return "(better)";
				case 146: return "N";
			}
			return "";
		}
		
		private function cleanString(input:String):String {
			while (input.indexOf("\n") >= 0) {
				input = input.replace("\n", " ");
			}
			while (input.indexOf("\r") >= 0) {
				input = input.replace("\r", " ");
			}
			while (input.indexOf("\f") >= 0) {
				input = input.replace("\f", " ");
			}
			while (input.indexOf("\t") >= 0) {
				input = input.replace("\t", " ");
			}
			return input;
		}
	}
}