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
package chessflash.engine {

	/**
	 * Parses and encapsulates FEN representation of a chessboard state.
	 * See: http://en.wikipedia.org/wiki/Forsyth-Edwards_Notation 
	 * and http://www.very-best.de/pgn-spec.htm section 16.1
	 */
	public class Fen {
		public static const DEFAULT_FEN:String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
		private const VALID_CHARS:String = "-RNBQKPrnbqkp";
		
		private var _fenString:String;
		private var _valid:Boolean = true;
		private var _piecePlacement: String;
		private var _pieceString:String;
		private var _activeColor: String;
		private var _castlingAvailability:String;
		private var _enPassantTarget:String;
		private var _halfMoveClock:String;
		private var _fullMoveNumber:String;
		private var _errorMsg:String;

/// Constructor

		public function Fen(fenString:String=DEFAULT_FEN) : void {
			_fenString = fenString;
			splitFen();
			splitPiecePosition();
			validatePiecePosition();
		}
		
/// Public Static Functions

		public static function getDefaultFen():String {
			return DEFAULT_FEN;
		}
		
/// Public Functions

		public function getWhiteToMove():Boolean {
			return _activeColor.toLowerCase() != "b";
		}
				
		public function getPieceFenAtIndex(index:uint): int {
			var piece:String = _pieceString.charAt(index);
			if (piece == "-") {
				return 0;
			} else {
				return getPieceFromFen(piece);
			}
		}

/// Internal Functions
		
		/**
		 *  16.1.7 En passant target square
		 * http://www.very-best.de/pgn-spec.htm
		 * The fourth field is the en passant target square. If there is no en passant target square 
		 * then the single character symbol "-" appears. If there is an en passant target square then 
		 * is represented by a lowercase file character immediately followed by a rank digit. Obviously, 
		 * the rank digit will be "3" following a white pawn double advance (Black is the active color) 
		 * or else be the digit "6" after a black pawn double advance (White being the active color).
		 * The en passant target square is given if and only if the last move was a pawn advance of two 
		 * squares. Therefore, an en passant target square field may have a square name even if there is 
		 * no pawn of the opposing side that may immediately execute the en passant capture. 
		 * @return ep target square or -1 if none.
		 */
		internal function enPassantTargetSquare():int {
			if (_enPassantTarget == null || _enPassantTarget.length == 0 || _enPassantTarget == "-") {
				return -1;
			}
			if (_enPassantTarget.length != 2) {
				return -1;
			}
			var char1:String = _enPassantTarget.charAt(0);
			var char2:String = _enPassantTarget.charAt(1);
			return "abcdefgh".indexOf(char1) + (parseInt(char2)-1) * 8;
		}
		
		internal function canWCastleKS():Boolean {
			return _castlingAvailability.indexOf("K") != -1;
		}
		
		internal function canWCastleQS():Boolean {
			return _castlingAvailability.indexOf("Q") != -1;
		}

		internal function canBCastleQS():Boolean {
			return _castlingAvailability.indexOf("q") != -1;
		}

		internal function canBCastleKS():Boolean {
			return _castlingAvailability.indexOf("k") != -1;
		}

		internal function getErrorMsg():String {
			return _errorMsg;
		}
		
		internal function getValid():Boolean {
			return _valid;
		}
		
/// private functions	

		private function validatePiecePosition():void {
			if (!_valid) { // we already know it is invalid
				return;
			}
			
			if (_pieceString == null) {
				_errorMsg = "Missing or invalid FEN string.";
				_valid = false;
				return;
			}

			if (_pieceString.length != 64) {
				_errorMsg = "FEN string has " + _piecePlacement.length + " squares (must have 64).";
				_valid = false;
				return;
			}

			var piece:String;
			var pos:int;
			for (var i:uint = 0; i < 64; i++) {
				piece = _pieceString.charAt(i);
				pos = VALID_CHARS.indexOf(piece);
				if (pos < 0) {
					_valid = false;
					_errorMsg = "Invalid piece character in FEN string (" + piece +")."; 
					return;
				}
			}
		}

		private function getPieceFromFen(piece:String): int {
			switch (piece) {
				case "-": return 0;
				case "p": return Piece.BPAWN;
				case "r": return Piece.BROOK;
				case "n": return Piece.BKNIGHT;
				case "b": return Piece.BBISHOP;
				case "q" : return Piece.BQUEEN;
				case "k" : return Piece.BKING;
				case "P" : return Piece.WPAWN;
				case "R" : return Piece.WROOK;
				case "N" : return Piece.WKNIGHT;
				case "B" : return Piece.WBISHOP;
				case "Q" : return Piece.WQUEEN;
				case "K" : return Piece.WKING;
			}
			return 0;
		}

		private function splitPiecePosition():void {
			var positionSplit:Array = _piecePlacement.split("/", 8);
			for (var i:uint = 0; i < 8; i++) {
				var destString:String = positionSplit[i] as String;
				while (destString.search("8")>=0) {
					destString = destString.replace("8", "--------");
				}
				while (destString.search("7")>=0) {
					destString = destString.replace("7", "-------");
				}
				while (destString.search("6")>=0) {
					destString = destString.replace("6", "------");
				}
				while (destString.search("5")>=0) {
					destString = destString.replace("5", "-----");
				}
				while (destString.search("4")>=0) {
					destString = destString.replace("4", "----");
				}
				while (destString.search("3")>=0) {
					destString = destString.replace("3", "---");
				}
				while (destString.search("2")>=0) {
					destString = destString.replace("2", "--");
				}
				while (destString.search("1")>=0) {
					destString = destString.replace("1", "-");
				}
				if (_pieceString == null) {
					_pieceString = destString;
				} else {
					_pieceString = destString + _pieceString;
				}
			}
		}
		
		private function splitFen():void {
			var fenSplit:Array = _fenString.split(" ", 6);

			if (fenSplit.length < 1) {
				_errorMsg = "Missing or invalid FEN string.";
				_valid = false;
				return;
			}
			_piecePlacement = fenSplit[0] as String;

			if (fenSplit.length < 2) {
				return;
			}
			_activeColor = fenSplit[1] as String;

			if (fenSplit.length < 3) {
				_valid = false;
				return;
			}
			_castlingAvailability = fenSplit[2] as String;			

			if (fenSplit.length < 4) {
				return;
			}
			_enPassantTarget = fenSplit[3] as String;			
			
			if (fenSplit.length < 5) {
				return;
			}
			_halfMoveClock = fenSplit[4] as String;			
			
			if (fenSplit.length < 6) {
				return;
			}
			_fullMoveNumber = fenSplit[4] as String;			
		}
	}
}