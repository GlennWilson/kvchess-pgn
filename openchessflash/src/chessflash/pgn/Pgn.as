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

	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.fscommand;
	
	
	 /* Pgn File Format notes:
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
	 * MOVETEXT SECTION
	 */

	 /**
	 * Load and parse a PGN file and create a PgnGame.
	 * 
     */
	public class Pgn {
//		private static var _debug:Boolean = false;
//		private static var _dCnt:int = 0;
		private const WHITESPACE:String = " \t\n\r\f";
		private const DIGITS:String = "0123456789";
		private const FILES:String = "abcdefghABCDEFGH";
		private const RANKS:String = "12345678";
		private const PIECES:String = "PRNBQK";
		private const MOVECHARACTERS:String = FILES + RANKS + PIECES + "xX:-=Oo+#";
		private const GAMETERMCHARACTERS:String = "01-2/";
		private static const HASHFACTOR1:int = 0x14102;
		private static const HASHFACTOR2:int = 0x5795612;
		
		private var _eof:Boolean;
		private var _level: int;
		
		private var _pgnGame:PgnGame;
		private var _pgnCallback:PgnCallback;
		private var _originalString:String;
		private var _pgnStringArray:Array;
		private var _pgnString: String;
		private var _pgnPtr: int;
		private var _pgnLineIndex: int;
		private var _pgnUrl:String;
		
/// Constructor
		
		public function Pgn(pgnCallback:PgnCallback, pgnUrl:String, pgnData:String) {
			_pgnCallback = pgnCallback;
			init();
			
			if (pgnData != null && pgnData.length > 2) {
				processPgnData(pgnData); // process data and return
			} else {
				_pgnUrl = parsePgnUrl(pgnUrl);
				startLoad(); // load data asynchronously and call the callback when done
			}
		}

/// Public Functions		

		public function getPgnGame() : PgnGame {
			return _pgnGame;
		}
		
		public function getPgnString() :String {
			return _originalString;
		}

/// Private Functions

		private function processPgnData(pgnData:String):void {
				_originalString = pgnData;
				_pgnStringArray = cleanString(_originalString);
				_pgnString = _pgnStringArray[_pgnLineIndex];
				_pgnGame = new PgnGame();
				parsePgn();
		}
		
        private function parsePgnUrl(pgnUrl:String):String {
			if (pgnUrl != null && pgnUrl.length > 4) {
				if (pgnUrl.indexOf("http://") > -1) { 
					return pgnUrl; // this is the whole url as it has http:// in it
				} else {
					return "http://chessflash.com/sites/default/files/users/" + pgnUrl;
				}
			} else {
				return "http://chessflash.com/sites/default/files/users/NoPgnFile.pgn";
			}
		}
		
		private function cleanString(input:String):Array {
			while (input.indexOf("\t") >= 0) {
				input = input.replace("\t", " ");
			}
			while (input.indexOf("\f") >= 0) {
				input = input.replace("\n", " ");
			}

			var arr:Array;
			arr = input.split("\n"); 
			for (var i:int = 0; i < arr.length; i++) {
				var tmp:String = arr[i] as String;
				while (tmp.indexOf("  ") >= 0) { // replace all two space with one space.  Better way?
					tmp = tmp.replace("  ", " ");
				}
				// make it end with a space because we slam them together later
				if ((tmp.length > 0 && tmp.charAt(tmp.length - 1) != " ")) {
					tmp += " ";
				}
				arr[i] = tmp;
			}
			
			return arr;
		}

		private function skipWhiteSpace() : void {
			var value:String = getChar();
			while (!_eof && value != null && isX(value, WHITESPACE)) {
				value = getChar();
			}
			ungetChar();
		}			
		
		private function readUntil(untilString:String) : String {
			var token:String;
			var achar:String = getChar();
			while (achar != null && untilString.indexOf(achar) == -1) {
				if (token == null) {
					token = achar;
				} else {
					token += achar;
				}
				achar = getChar();
			}
			return token;
		}
		
		private function readToEol() : String {
			var line:String = _pgnString.substr(_pgnPtr); // the rest of this line
			_pgnPtr = _pgnString.length; // move ptr to past end of this line
			return line;
		}
		
		private function readWhile(whileString:String) : String {
			var token:String;
			var achar:String = getChar();
			while (achar != null && whileString.indexOf(achar) != -1) {
				if (token == null) {
					token = achar;
				} else {
					token += achar;
				}
				achar = getChar();
			}
			ungetChar();
			return token;
		}

		// modified readWhile to try to be smarter about moves and common move errors
		private function readMove() : String {
			var lastCharDigit:Boolean = false;
			var inCastling:Boolean = false;
			var whileString:String = MOVECHARACTERS;
			var token:String;
			var achar:String = getChar();
			while (achar != null && whileString.indexOf(achar) != -1) {
				if (lastCharDigit && DIGITS.indexOf(achar) != -1) { 
					// two digits in a row!! Can't happen in a legal move.  Stop and put the character back
					// problem may be a missing space between blacks move and the following move number.
					break; // (and unget this bad move char).
				}
				if (inCastling && DIGITS.indexOf(achar) != -1) { 
					// Castling followed by a digit! Can't happen in a legal move.  Stop and put the character back
					// problem may be a missing space between blacks move and the following move number.
					break; // (and unget this bad move char).
				}
				lastCharDigit = DIGITS.indexOf(achar) != -1;
				if (!inCastling) {
					inCastling = "Oo".indexOf(achar) != -1;
				}
				if (token == null) {
					token = achar;
				} else {
					token += achar;
				}
				achar = getChar();
			}
			ungetChar();
			return token;
		}

		private function getChar():String {
			if (_pgnPtr < _pgnString.length) {
				return _pgnString.charAt(_pgnPtr++);
			} else if (_pgnLineIndex < (_pgnStringArray.length-1)) {
				_pgnLineIndex++;
				_pgnPtr = 0;
				_pgnString = _pgnStringArray[_pgnLineIndex] as String;
				return getChar();
			} else {
				_eof = true;
				return null;
			}
		}
		
		private function ungetChar():void  {
			if (_pgnPtr >= 1) {
				_pgnPtr --;
			} else if (_pgnLineIndex > 0) {
				_pgnLineIndex--;
				_pgnString = _pgnStringArray[_pgnLineIndex] as String;
				_pgnPtr = _pgnString.length - 1;
			}
		}
		
		private function isX(achar:String, x:String) : Boolean {
			return x.indexOf(achar) >= 0;
		}
		
		private function parsePgn(): void {
			parseTagPairSection();
			parseMoveTextSection();
		}
		
		// called in the tag pair section
		private function parseTagPairSection(): void {
			while (!_eof) {
				skipWhiteSpace();
				var achar:String = getChar();
				if (achar == "[" ) { // got a tag start
					inTag();
				} else if (achar == ";") { // got a line comment
					readToEol();
				} else if (achar == "%") { // got a line escape
					readToEol();
				} else { // must be done with tags
					ungetChar();
					return;
				}
			}
		}
		
		private function inTag() : void {
			var tagname:String = readUntil(WHITESPACE);
			skipWhiteSpace();
			getChar(); // must be "
			var value:String = readUntil("\"");
			_pgnGame.addTag(tagname, value);
			readUntil("]");
		}
		
		private function parseMoveTextSection():void {
			var value:String;
			var char2:String;
			var moveText:PgnNode;
			var sequence:PgnSequence = _pgnGame._pgnSequence;
			
			while (!_eof) {
		
				skipWhiteSpace();
				var achar:String = getChar();
				if (_eof || achar == null) {
					// do nothing
				} else if (achar == "-") {
					var bchar:String = getChar ();
					if (bchar == "-") {
						// this is null move indicator
						moveText = new PgnMove (0, "--");
						sequence.addNode (moveText);
					}
				} else if (achar == "$" ) { // got a NAG
					value = readWhile(DIGITS);
					if (moveText != null && moveText.getType() == PgnNode.PGNMOVE) {
						moveText.addNag(value);
					} else {
						moveText = new PgnText(PgnNode.PGNNAG, value);
						sequence.addNode(moveText);
					}	
				} else if (achar == ";") { // got a line comment
					value = readToEol();
					moveText = new PgnText(PgnNode.PGNLINECOMMENT, value);	
					sequence.addNode(moveText);
				} else if (achar == "%") { // got a line escape
					value = readToEol();
					moveText = new PgnText(PgnNode.PGNESCAPECOMMENT, value);
					sequence.addNode(moveText);
				} else if (achar == "{") { // Brace Comment
					value = readUntil("}"); 
					if (moveText == null) {
						moveText = new PgnText(PgnNode.PGNBRACECOMMENT, value);
						sequence.addNode(moveText);
					} else {
						moveText.addComment(value);
					}
				} else if (achar == "(") { // RAV Begin increment level
					_level++;
					sequence = moveText.addSequence();
				} else if (achar == ")") { // RAV end decrement level
					_level--;
					moveText = sequence.getParent(); //
					if (moveText == null) {
					} else {
						sequence = moveText.getParent();
					}
				} else if (achar == ".") { // Dot
					value = readWhile(".");
					moveText = new PgnText(PgnNode.PGNMOVEDOTS, plusNull(achar,value));
					sequence.addNode(moveText);
				} else if (achar == "*") { // Star
					moveText = new PgnText(PgnNode.PGNGAMETERMINATION, achar);
					sequence.addNode(moveText);
				} else if (isX(achar,DIGITS)) { // move number or game termination
					char2 = getChar();
					if ((achar == "0" || achar == "1") && (char2 == "-" || char2 == "/")) { 
						value = achar + char2 + readWhile(GAMETERMCHARACTERS);
						moveText = new PgnText(PgnNode.PGNGAMETERMINATION, value);
						sequence.addNode(moveText);
					} else {
						ungetChar();
						ungetChar();
						value = readWhile(DIGITS); 
						moveText = new PgnText(PgnNode.PGNMOVENUMBER, value);
						sequence.addNode(moveText);
					}
				} else if (isX(achar,PIECES) || isX(achar,FILES) || achar == "O" || achar == "o") { // A Piece or File or castling
					value = achar + readMove();
					moveText = new PgnMove(0, value);
					sequence.addNode(moveText);
				} else if (achar == "!" || achar == "?" ) {
					value = plusNull(achar, readWhile("+#!?")); 
					if (moveText != null && moveText.getType() == PgnNode.PGNMOVE) {
						moveText.addAnnotation(value);
					} else {
						moveText = new PgnText(PgnNode.PGNANNOTATIONS, value);
						sequence.addNode(moveText);
					}	
				} else if (achar == "[") { // tag start -- must be beginnning of another pgn game; exit
					return;
				} else { // done or skip unknown characters?
					// do nothing
				}
			}
			
		}
		
		private function plusNull(one:String, two:String):String {
			if (two == null) return one;
			if (one == null) return two;
			return one + two;
		}
		
		private function init():void {
			_pgnLineIndex = 0;
			_pgnPtr = 0;
			_pgnStringArray = new Array(0);
			_eof = false;
			_level = 0;
			
		}
		private function startLoad():void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadComplete);
    		loader.load(new URLRequest(_pgnUrl));
		}

		private function loadComplete(event:Event): void {
			var loader:URLLoader = URLLoader(event.target);
			_originalString = loader.data as String;
			process();
		}

		private function process(): void {
			_pgnStringArray = cleanString(_originalString);
			_pgnString = _pgnStringArray[_pgnLineIndex];
			_pgnGame = new PgnGame();
			parsePgn();
			_pgnCallback.loaded();
		}

//		public static function xtrace(msg:Object):void {
//			if (_debug) {
//				fscommand("trace", (_dCnt++) + " " +  msg.toString());
//			}
//		} 

	}
}