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
	 *	A move is an integer.  This class has static methods to
	 *	create, manipulate, retrieve move parts and test the move.
	 *	The int consists of 8 hex digits, numbered: 87654321
	 *	digits 1-3 have the from and to square encoded in them
	 *	digit 4 is the piece moving (hi bit is color)
	 *	digits 5 has flags for en passant, check, checkmate, and stalemate:
	 *	    0x00080000 = checkmate
	 *	    0x00040000 = stalemate
	 *	    0x00020000 = check 
	 *	    0x00010000 = en passant
	 *	digit 6 is the captured piece (hi bit is color)or 0 if not a capture 
	 *	digit 7 is the promotion piece (hi bit is color), or 0 if not a prommotion
	 *	digit 8 has ...
	 *	the sign bit is 0.
 	 * 
	 * 
	 */
	public class Move {

		public static const NOMOVE:int =        0x00000000; 
		public static const NULLMOVE:int =  (28 << 6) | 28;// createMoveWithColor (0, 28, 28); // no piece; moved from from e4 to e4

		private static const CHECKMATE:int =     0x00080000; 
		private static const STALEMATE:int =     0x00040000;
		private static const CHECK:int =         0x00020000;
		private static const ENPASSANT:int =     0x00010000;
		
		// copied from Board to avoid cyclic dependency; todo refactor out
	    private static const C1:int =  2, E1:int =  4, G1:int =  6;
		private static const C8:int = 58, E8:int = 60, G8:int = 62;


/// Public Static Functions		
		
		public static function fromSquare(move:int):int {
			return move & 0x3F;
		}

		public static function toSquare(move:int):int {
			return (move >> 6) & 0x3F;
		}

		public static function movingPiece(move:int):int { 
			return (move >> 12) & 0x07; 
		}

		public static function movingPieceWithColor(move:int):int { 
			return (move >> 12) & 0x0F; 
		}

		public static function promotionPieceWithColor(move:int):int { 
			return (move >> 24) & 0x0F; 
		}

		public static function isPromotion(move:int):Boolean {
			return (move & 0x0F000000) != 0;
		}
		
		public static function capturedPiece(move:int):int { 
			return (move >> 20) & 0x07;
		}

		public static function capturedPieceWithColor(move:int):int { 
			return (move >> 20) & 0x0F;
		}

		public static function isCastling(move:int):Boolean {
			if (movingPiece(move) != Piece.KING) return false;
			var from:int = fromSquare(move);
			var to:int = toSquare(move);
			return (from == E1 && (to == C1 || to == G1)) 
				|| (from == E8 && (to == C8 || to == G8));
		}

		public static function fromSquare2(move:int):int {
			if (!isCastling(move)) return -1;
			var to:int = toSquare(move);
			if (to == 2) { //W QS Castling
				return 0; // a1
			}
			if (to == 6) { // W KS Castling
				return 7; // h1
			}
			if (to == 58) { // B QS
				return 56;
			}
			return 63;
		}

		public static function toSquare2(move:int):int {
			if (!isCastling(move)) return -1;
			var to:int = toSquare(move);
			if (to == 2) { //W QS Castling
				return 3; // d1
			}
			if (to == 6) { // W KS Castling
				return 5; // f1
			}
			if (to == 58) { // B QS
				return 59;
			}
			return 61;
		}

		public static function movingPiece2WithColor(move:int):int {
			if (!isCastling(move)) return 0;
			var to:int = toSquare(move);
			if (to == 2) { //W QS Castling
				return Piece.WROOK;
			}
			if (to == 6) { // W KS Castling
				return Piece.WROOK; // WR
			}
			return Piece.BROOK;
		}

		public static function isEnpassant(move:int):Boolean {
			return (move & ENPASSANT) != 0;
		}
		
		// where the pawn was that actually got removed from the board
		public static function getEnpassantCaptureSquare(move:int):int {
			// the from rank plus the to file
			if (!isEnpassant(move)) return -1;
			return (fromSquare(move) & 0x38) | (toSquare(move) & 0x07);
		}

		public static function moveSan(move:int, moves:Array) : String {
			if (move == Move.NULLMOVE) {
				return "--";
			}
			var mArray:Array = moveSans(move, moves);
			var moveStr:String = mArray[0] as String;
			return moveStr;
		}
		
		public static function findMove(moveStr:String, moves:Array) : int {
			
			if (moveStr == "--") {
				return Move.NULLMOVE;
			}
			
			var i:int;
			var j:int;
			var mArray:Array;
			var move:int;
			var strippedMove:String = stripX(moveStr);
			var compare:String;
			
			for (i = 0; i < moves.length; i++) {
				move = moves[i] as int;
				mArray = moveSans(move, moves);
				for (j = 0; j < mArray.length; j++) {
					compare = mArray[j] as String;
					compare = stripX(compare);
					if (compare == strippedMove) {
						return move; // got a match
					}
				}
			}

			return NOMOVE; // nomatch
		}
		
/// Internal Static Functions	
		
		internal static function createMove(from:int, to:int, piece:int, sideMoving:int):int {
			return (((sideMoving << 3) | piece) <<12) | (to << 6) | from;
		}

		internal static function createMoveWithColor(piece:int, from:int, to:int):int {
			return (piece <<12) | (to << 6) | from;
		}

		// Pawn Promotions
		internal static function setPromotion(move:int, piece:int, side:int):int {
			return move | (((side << 3) | piece) << 24);
		}
		
		internal static function promotionPiece(move:int):int { 
			return (move >> 24) & 0x07; 
		}

		// Capture
		internal static function setCapture(move:int, piece:int, sideCaptured:int):int {
			return move | (((sideCaptured << 3) | piece) << 20);
		}

		internal static function isCapture(move:int):Boolean {
			return (move & 0x00F00000) != 0;
		}

		// Check
		internal static function setCheck(move:int):int {
			return move | CHECK; 
		}
		
		internal static function isCheck(move:int):Boolean {
			return (move & CHECK) != 0; 
		}

		// CheckMate
		internal static function setCheckmate(move:int):int {
			return move | CHECKMATE; 
		}

		internal static function isCheckmate(move:int):Boolean {
			return (move & CHECKMATE) != 0; 
		}

		// Stalemate
		internal static function setStalemate(move:int):int {
			return move | STALEMATE; 
		}

		internal static function isStalemate(move:int):Boolean {
			return (move & STALEMATE) != 0;
		}

		// Castling
		internal static function setCastling(move:int):int {
			return move; // NO Op
		}

		// En Passant
		internal static function setEnpassant(move:int):int {
			return move | ENPASSANT; 
		}

		// square to capture at after this 2 square pawn move (square "behind" the pawn).
		internal static function getEnpassantTargetSquare(move:int):int {
			if (movingPiece(move) == Piece.PAWN) { // it is a pawn move
				var delta:int = fromSquare(move) - toSquare(move);
				if (delta == 16 || delta == -16) { //moved two squares
					return toSquare(move) + delta / 2;
				}
			}
			return -1;
		}

		// Ambiguity on piece and destination square resolved with from file
		internal static function fromFileName(move:int):String {
			return "abcdefgh".charAt(fromSquare(move) % 8);
		}

		// Ambiguity on piece and destination square resolved with from rank
		internal static function fromRankName(move:int):String {
			return "12345678".charAt(fromSquare(move) / 8);
		}

		// Ambiguity on piece and destination square resolved with from square
		internal static function fromSquareName(move:int):String {
			return squareName(fromSquare(move));
		}

/// Private Static Functions		
		
		private static function addCheckandMate(move:int, moveString:String):String {
			if (isCheckmate(move)) return moveString + "#";
			if (isCheck(move)) return moveString + "+";
			return moveString;
		}

		private static function moveSans(move:int, moves:Array) : Array {
			var sanMoves:Array = new Array();
			var tosquare:int = toSquare(move);
			var tosquareName:String = squareName(tosquare);
			var moveString:String;
			var piece:int = movingPiece(move);
			var pieceString:String = pieceMoveName(piece);
			var capture:Boolean = isCapture(move);
						
			// Castling			
			if (isCastling(move)) {
				if (tosquare == C1 || tosquare == C8) {
					moveString = "O-O-O";
				} else {
					moveString = "O-O"
				}
				sanMoves.push(addCheckandMate(move, moveString));
				return sanMoves;	
			}

			if (!samePieceDest(move, moves)) { // no disambiguation needed
				if (piece == Piece.PAWN) {
					if (!capture) {
						moveString = tosquareName;
					} else {
						moveString = fromFileName(move) + "x" + tosquareName;
					}
					if (isPromotion(move)) {
						moveString += "=" + "-PNBRQK".charAt(promotionPiece(move));
					}
				} else {
					if (!capture) {
						moveString = pieceString + tosquareName;
					} else {
						moveString = pieceString + "x" + tosquareName;
					}
				} 
				sanMoves.push(addCheckandMate(move, moveString));
			}
			
			if (!samePieceDestFromfile(move, moves)) { // first (file) disambiguation works
				if (piece == Piece.PAWN) {
					if (capture) {
						moveString = fromFileName(move) + "x" + tosquareName;
					}
					if (isPromotion(move)) {
						moveString += "=" + "-PNBRQK".charAt(promotionPiece(move));
					}
				} else {
					if (!capture) {
						moveString = pieceString + fromFileName(move) + tosquareName;
					} else {
						moveString = pieceString + fromFileName(move) +"x" + tosquareName;
					}
				}
				if (piece != Piece.PAWN || capture) { // only makes sense for pawn captures
					sanMoves.push(addCheckandMate(move, moveString));
				}
			}
			
			if (!samePieceDestFromrank(move, moves)) { // second (rank) disambiguation works
				if (piece != Piece.PAWN) {
					if (!capture) {
						moveString = pieceString + fromRankName(move) + tosquareName;
					} else {
						moveString = pieceString + fromRankName(move) +"x" + tosquareName;
					}
					sanMoves.push(addCheckandMate(move, moveString));
				}
			}
			
			// fromsquare disambiguation
			if (piece == Piece.PAWN) {
				if (!capture) {
					moveString = fromSquareName(move) + tosquareName;
				} else {
					moveString = fromSquareName(move) + "x" + tosquareName;
				}
				if (isPromotion(move)) {
					moveString += "=" + "-PNBRQK".charAt(promotionPiece(move));
				}
			} else {
				if (!capture) {
					moveString = pieceString + fromSquareName(move) + tosquareName;
				} else {
					moveString = pieceString + fromSquareName(move) +"x" + tosquareName;
				}
			}
			sanMoves.push(addCheckandMate(move, moveString));
			
			return sanMoves;
		}

		private static function squareName(square:int) : String {
			var rank:int = square >> 3;
			var file:int = square % 8;
			var files:String = "abcdefgh";
			return files.charAt(file) + (rank + 1);
		}
		
		private static function pieceMoveName(piece:int): String {
			return"-PNBRQK".charAt(piece)
		}
		
		// ambiguous # 0; same piece and destination
		private static function samePieceDest(move:int, moves:Array) : Boolean {
			var piece:int = movingPiece(move);
			var tosquare:int = toSquare(move);
			var promo:int = promotionPiece(move);
			
			var i:int;

			for (i = 0; i < moves.length; i++) {
				var amove:int = moves[i] as int;
				if (amove == move) continue;
				if (movingPiece(amove) == piece) {
					if (toSquare(amove) == tosquare) {
						if (promotionPiece(amove) == promo) {
							return true;
						}
					}
				}
			}
			return false;	
		}

		// ambiguous # 1; same piece and destination and from file
		private static function samePieceDestFromfile(move:int, moves:Array) : Boolean {
			var piece:int = movingPiece(move);
			var tosquare:int = toSquare(move);
			var fromsquare:int = fromSquare(move);
			var fromFile:int = fromsquare % 8;
			var promo:int = promotionPiece(move);
			var i:int;

			for (i = 0; i < moves.length; i++) {
				var amove:int = moves[i] as int;
				if (amove == move) continue;
				if (movingPiece(amove) == piece) {
					if (toSquare(amove) == tosquare) {
						if ((fromSquare(amove) % 8 ) == fromFile) {
							if (promotionPiece(amove) == promo) {
								return true;
							}
						}
					}
				}
			}
			return false;	
		}

		// ambiguous # 2; same piece and destination and from rank
		private static function samePieceDestFromrank(move:int, moves:Array) : Boolean {
			var piece:int = movingPiece(move);
			var tosquare:int = toSquare(move);
			var fromsquare:int = fromSquare(move);
			var fromRank:int = int(fromsquare / 8);

			var i:int;

			for (i = 0; i < moves.length; i++) {
				var amove:int = moves[i] as int;
				if (amove == move) continue;
				if (movingPiece(amove) == piece) {
					if (toSquare(amove) == tosquare) {
						if ((int(fromSquare(amove)) / 8 ) == fromRank) {
							return true;
						}
					}
				}
			}
			return false;	
		}

		private static function stripX(move:String):String {
			var skip:String = "xX:*-=+#";
			var stripped:String;
			for (var i:int = 0; i < move.length; i++) {
				var achar:String = move.charAt(i);
				if (skip.indexOf(achar) == -1) {
					if (stripped == null) {
						stripped = achar;
					} else {
						stripped += achar;
					}
				}
			}
			return stripped;
		}
	}
}