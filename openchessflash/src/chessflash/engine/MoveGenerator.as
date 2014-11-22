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
	 * The Move Generator.
	 */
	public class MoveGenerator {

		private var _board:Board;
		
		private static var _bigBoardtoBoard:Array  =
		[
		  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		  -1,  0,  1,  2,  3,  4,  5,  6,  7, -1,
		  -1,  8,  9, 10, 11, 12, 13, 14, 15, -1,
		  -1, 16, 17, 18, 19, 20, 21, 22, 23, -1,
		  -1, 24, 25, 26, 27, 28, 29, 30, 31, -1,
		  -1, 32, 33, 34, 35, 36, 37, 38, 39, -1,
		  -1, 40, 41, 42, 43, 44, 45, 46, 47, -1,
		  -1, 48, 49, 50, 51, 52, 53, 54, 55, -1,
		  -1, 56, 57, 58, 59, 60, 61, 62, 63, -1,
		  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 
		];
		
		private static var _boardtoBigBoard:Array  =
		[
	 	 21, 22, 23, 24, 25, 26, 27, 28,
		 31, 32, 33, 34, 35, 36, 37, 38,
		 41, 42, 43, 44, 45, 46, 47, 48,
		 51, 52, 53, 54, 55, 56, 57, 58,
		 61, 62, 63, 64, 65, 66, 67, 68,
		 71, 72, 73, 74, 75, 76, 77, 78,
		 81, 82, 83, 84, 85, 86, 87, 88,
		 91, 92, 93, 94, 95, 96, 97, 98,
		];

		private static var _movesBitboardKnight:Array = new Array(64);
		private static var _movesBitboardKing:Array = new Array(64);

		
/// Constructor		
		
		public function MoveGenerator(board:Board) {
			_board = board;
		}

/// Public Static Functions		
		
		internal static function isSquareAttacked(square:int, side:int, board:Board):Boolean {
			// is square attacked ('checked') by side?
			var bb:BitBoard;
			var bb2:BitBoard;
			bb = moveBitboardKnight(square, BitBoard.ALL_BITBOARD);
			if (bb.and(board.getBitBoard(side, Piece.KNIGHT)).notZero()) { // attacked by a knight
				return true;
			}
			
			bb = moveBitboardKing(square, BitBoard.ALL_BITBOARD);
			if (bb.and(board.getBitBoard(side, Piece.KING)).notZero()) { // attacked by a king
				return true;
			}
			
			bb = moveBitboardBishop(square, board.getPieces(1-side), board.getPieces(side));
			bb2 = board.getBitBoard(side, Piece.BISHOP).or(board.getBitBoard(side, Piece.QUEEN));
			if (bb.and(bb2).notZero()) { // attacked by a queen or bishop
				return true;
			}

			bb = moveBitboardRook(square, board.getPieces(1-side), board.getPieces(side) );
			bb2 = board.getBitBoard(side, Piece.ROOK).or(board.getBitBoard(side, Piece.QUEEN));
			if (bb.and(bb2).notZero()) { // attacked by a queen or rook
				return true;
			}

			// check to see if opponent could CAPTURE my *PAWN* from target square, if they had a pawn there.
			//  If true, then my pawn attacks the target square.
			bb = moveBitboardPawn(1-side, square, BitBoard.ALL_BITBOARD, board.getBitBoard(side, Piece.PAWN));
			if (bb.notZero()) { // attacked by a pawn	
				return true;
			}
			return false;
		}
		
/// Public Functions
		
		public function generate() : void {
			var side:int;
			var piece:int; 
			var from:int;

			var bb:BitBoard, 
				oppPieces:BitBoard, 
				myPieces:BitBoard, 
				notMyPieces:BitBoard;
				
			_board._moveList = new Array();
			side = _board._side;
			myPieces = _board.getPieces(side);
			oppPieces = _board.getPieces(1 - side);
			notMyPieces = myPieces.not();
			
			/* Knight */
			bb = _board.getBitBoard(side, Piece.KNIGHT).copy();
			while (bb.notZero()) {
				from = bb.leftmost();
				bb.clearBit(from);
				addBitboardMoves(from, moveBitboardKnight(from, notMyPieces),Piece.KNIGHT);
			}

			/* King */
			moveKingCastle(myPieces, oppPieces); // Castling
			bb = _board.getBitBoard(side, Piece.KING).copy();
			while (bb.notZero()) {
				from = bb.leftmost();
				bb.clearBit(from);
				addBitboardMoves(from, moveBitboardKing(from, notMyPieces),Piece.KING);
			}
			
			/* Rook */
			bb = _board.getBitBoard(side, Piece.ROOK).copy();
			while (bb.notZero()) {
				from = bb.leftmost();
				bb.clearBit(from);
				addBitboardMoves(from, moveBitboardRook(from, myPieces, oppPieces),Piece.ROOK);
			}

			/* Bishop */
			bb = _board.getBitBoard(side, Piece.BISHOP).copy();
			while (bb.notZero()) {
				from = bb.leftmost();
				bb.clearBit(from);
				addBitboardMoves(from, moveBitboardBishop(from, myPieces, oppPieces),Piece.BISHOP);
			}

			/* Queen */
			bb = _board.getBitBoard(side, Piece.QUEEN).copy();
			while (bb.notZero()) {
				from = bb.leftmost();
				bb.clearBit(from);
				addBitboardMoves(from, moveBitboardQueen(from, myPieces, oppPieces),Piece.QUEEN);
			}

			/* Pawn */
			bb = _board.getBitBoard(side, Piece.PAWN).copy();
			if (_board._ep != -1) { // en passant
				movePawnEp(bb, _board._ep);
			}
			while (bb.notZero()) {
				from = bb.leftmost();
				bb.clearBit(from);
				addBitboardMoves(from, moveBitboardPawn(side, from, myPieces, oppPieces),Piece.PAWN);
			}
		}

		// remove if left in check
		// add info on captured piece
		// add info on check status
		public function cleanMoves():void {
			var invalidCount:int = 0; // number of invalidated moves
			var side:int = _board._side;
			var otherside:int = 1 - side;
			var ksquare:int = _board.getKingPos(side);
			var ksquareother:int = _board.getKingPos(otherside);
			var moves:Array = _board._moveList;
			var move:int;
			var i:int;
			var newboard:Board;
			var pieceMoving:int;
			var fromSquare:int;
			var toSquare:int;
			var capturedPiece:int;
			var promotioPiece:int;
			var squareToCheck:int;
			
			for (i = 0; i < moves.length; i++) {
				move = moves[i] as int;
				fromSquare = Move.fromSquare(move);
				toSquare = Move.toSquare(move);
				pieceMoving = Move.movingPiece(move);
				capturedPiece = _board.getPieceAt(toSquare, otherside);
				if (capturedPiece != 0) { // todo IF King captured; invalidate prior ply move?
					move = Move.setCapture(move, capturedPiece, otherside);
					moves[i] = move;	
				}
				_board.makeMove(move);
				if (pieceMoving == Piece.KING) {
					squareToCheck = toSquare;
				} else {
					squareToCheck = ksquare;
				}
				
				if (isSquareAttacked(squareToCheck, otherside, _board)) {
					_board.invalidateMove(i);
					invalidCount++;
				} else { // update move with info
					if (isSquareAttacked(ksquareother, side, _board)) {
						move = Move.setCheck(move);
						moves[i] = move;	
					}
				}
				_board.unMakeMove(move);
			}

			if (invalidCount > 0) {
				_board.cleanMoveList();
			}
		}
			
/// Private Static Functions

		private static function moveBitboardBishop(square:int, myPieces:BitBoard, oppPieces:BitBoard):BitBoard {
			var bbfromSquare:int;
			var toSquare:int;
			var moves:BitBoard;
			var bbtoSquare:int;

			bbfromSquare = _boardtoBigBoard[square];
			moves = new BitBoard(0, 0, 0, 0);

			bbtoSquare = bbfromSquare - 11;
			toSquare = _bigBoardtoBoard[bbtoSquare];
			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare -= 11;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}
			
			bbtoSquare = bbfromSquare - 9;
			toSquare = _bigBoardtoBoard[bbtoSquare];
			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare -= 9;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}

			bbtoSquare = bbfromSquare + 11;
			toSquare = _bigBoardtoBoard[bbtoSquare];

			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare += 11;
				toSquare = _bigBoardtoBoard[bbtoSquare];

			}
			
			bbtoSquare = bbfromSquare + 9;
			toSquare = _bigBoardtoBoard[bbtoSquare];

			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare += 9;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}
			return moves;
		}

		private static function moveBitboardRook(square:int, myPieces:BitBoard, oppPieces:BitBoard):BitBoard {
			var bbfromSquare:int;
			var toSquare:int;
			var moves:BitBoard;
			var bbtoSquare:int;

			bbfromSquare = _boardtoBigBoard[square];
			moves = new BitBoard(0, 0, 0, 0);
			bbtoSquare = bbfromSquare - 10;
			toSquare = _bigBoardtoBoard[bbtoSquare];
			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare -= 10;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}
			
			bbtoSquare = bbfromSquare - 1;
			toSquare = _bigBoardtoBoard[bbtoSquare];
			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare -= 1;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}

			bbtoSquare = bbfromSquare + 10;
			toSquare = _bigBoardtoBoard[bbtoSquare];
			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare += 10;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}
			
			bbtoSquare = bbfromSquare + 1;
			toSquare = _bigBoardtoBoard[bbtoSquare];

			while (toSquare != -1) {
				if (myPieces.getBit(toSquare)) { // can't move on top of own pieces
					break;
				}
				moves.setBit(toSquare); // can move or capture
				if (oppPieces.getBit(toSquare)) { // capture
					break; // and stop moving in that direction
				}
				bbtoSquare++;
				toSquare = _bigBoardtoBoard[bbtoSquare];
			}
			return moves;
		}

		private static function moveBitboardPawn(side:int,square:int, myPieces:BitBoard, oppPieces:BitBoard):BitBoard {
			if (side == Board.WHITE) {
				return moveBitboardWPawn(square, myPieces, oppPieces);
			} else {
				return moveBitboardBPawn(square, myPieces, oppPieces);
			}
		}
		
		private static function moveBitboardWPawn(square:int, myPieces:BitBoard, oppPieces:BitBoard):BitBoard {
			var bbfromSquare:int;
			var toSquare:int;
			var moves:BitBoard;

			bbfromSquare = _boardtoBigBoard[square];
			moves = new BitBoard(0, 0, 0, 0);

			// can I capture?
		    toSquare = _bigBoardtoBoard[bbfromSquare + 9];
			if (toSquare != -1) {
				if (oppPieces.getBit(toSquare)) { //something to capture?
					moves.setBit(toSquare);
				}
			}

			// can I capture?
		    toSquare = _bigBoardtoBoard[bbfromSquare + 11];
			if (toSquare != -1) {
				if (oppPieces.getBit(toSquare)) { //something to capture?
					moves.setBit(toSquare);
				}
			}

			// can I move forward 1 square?
		    toSquare = _bigBoardtoBoard[bbfromSquare + 10];
			if (toSquare != -1) {
				if (!oppPieces.getBit(toSquare) && !myPieces.getBit(toSquare)) {
					moves.setBit(toSquare);
					
					// can I move forward 2 square?
					if (square >>> 3 == 1) { // on the second rank?
						toSquare = _bigBoardtoBoard[bbfromSquare + 20];
						if (!oppPieces.getBit(toSquare) && !myPieces.getBit(toSquare)) {
							moves.setBit(toSquare);	
						}
					}
				}
			}
			return moves;
		}

		private static function moveBitboardBPawn(square:int, myPieces:BitBoard, oppPieces:BitBoard):BitBoard {
			var bbfromSquare:int;
			var toSquare:int;
			var moves:BitBoard;

			bbfromSquare = _boardtoBigBoard[square];
			moves = new BitBoard(0, 0, 0, 0);

			// can I capture?
		    toSquare = _bigBoardtoBoard[bbfromSquare - 9];
			if (toSquare != -1) {
				if (oppPieces.getBit(toSquare)) { //something to capture?
					moves.setBit(toSquare);
				}
			}

			// can I capture?
		    toSquare = _bigBoardtoBoard[bbfromSquare - 11];
			if (toSquare != -1) {
				if (oppPieces.getBit(toSquare)) { //something to capture?
					moves.setBit(toSquare);
				}
			}

			// can I move forward 1 square?
		    toSquare = _bigBoardtoBoard[bbfromSquare - 10];
			if (toSquare != -1) {
				if (!oppPieces.getBit(toSquare) && !myPieces.getBit(toSquare)) {
					moves.setBit(toSquare);
					// can I move forward 2 square?
					if (square >>> 3 == 6) { // on the seventh rank?
						toSquare = _bigBoardtoBoard[bbfromSquare - 20];
						if (!oppPieces.getBit(toSquare) && !myPieces.getBit(toSquare)) {
							moves.setBit(toSquare);
						}
					}
				}
			}
			return moves;
		}
		
		
		private static function moveBitboardKnight(square:int, notMyPieces:BitBoard):BitBoard {
			var bbfromSquare:int;
			var toSquare:int;
			var moves:BitBoard;

			moves = _movesBitboardKnight[square] as BitBoard;  // get from array
			if (moves == null) { // create if not already in array
				moves = new BitBoard(0, 0, 0, 0);
				bbfromSquare = _boardtoBigBoard[square];
				toSquare = _bigBoardtoBoard[bbfromSquare - 21];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare - 19];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare - 12];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare - 8];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 21];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 19];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 12];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 8];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				_movesBitboardKnight[square] = moves;
			}
			return moves.and(notMyPieces);
		}

		private static function moveBitboardKing(fromSquare:int, notMyPieces:BitBoard):BitBoard {
			var bbfromSquare:int;
			var toSquare:int;
			var moves:BitBoard;

			moves = _movesBitboardKing[fromSquare] as BitBoard; // get from array
			if (moves == null) { // create if not already in array
				moves = new BitBoard(0, 0, 0, 0);
				bbfromSquare = _boardtoBigBoard[fromSquare];

				toSquare = _bigBoardtoBoard[bbfromSquare - 11];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare - 10];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare - 9];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare - 1];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 11];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 10];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 9];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				toSquare = _bigBoardtoBoard[bbfromSquare + 1];
				if (toSquare != -1) {
					moves.setBit(toSquare);
				}
				_movesBitboardKing[fromSquare] = moves;
			}
			return moves.and(notMyPieces);
		}


/// Private Functions

		/**
		 * create list of moves from a BitBoard 
		 */
		private function addBitboardMoves(from:int, bb:BitBoard, piece:int):void {
			var to:int;
			while (bb.notZero()) {
				to = bb.leftmost();
				bb.clearBit(to);
				if (piece == Piece.PAWN && (int(to / 8) == 7 || int(to / 8) == 0)) { // pawn promotion
					addPromotions(Move.createMove(from, to, piece, _board._side), _board._side);
				} else {
					addMove(Move.createMove(from, to, piece, _board._side));
				}
			 }
		}
	
		private function moveBitboardQueen(square:int, myPieces:BitBoard, oppPieces:BitBoard):BitBoard {
			var bishopMoves:BitBoard = moveBitboardBishop(square, myPieces, oppPieces);
			var rookMoves:BitBoard = moveBitboardRook(square, myPieces, oppPieces);
			return bishopMoves.or(rookMoves);
		}
		
		private function movePawnEp(myPawns:BitBoard, epTarget:int):void {
			if (epTarget < -1) return;
			var bbepTarget:int = _boardtoBigBoard[epTarget];
			var bbfromsquare:int;
			if (_board._side == Board.WHITE) { // white is moving
				bbfromsquare = _bigBoardtoBoard[bbepTarget - 9];
				if (bbfromsquare != -1 && myPawns.getBit(bbfromsquare)) { // I have a P in the right spot
					addMove(Move.setEnpassant(Move.setCapture(Move.createMove(
							bbfromsquare, epTarget, Piece.PAWN, Board.WHITE), Piece.PAWN, Board.BLACK)));
				}
				bbfromsquare = _bigBoardtoBoard[bbepTarget - 11];
				if (bbfromsquare != -1 && myPawns.getBit(bbfromsquare)) { // I have a P in the right spot
					addMove(Move.setEnpassant(Move.setCapture(Move.createMove(
							bbfromsquare, epTarget, Piece.PAWN, Board.WHITE), Piece.PAWN, Board.BLACK)));
				}
			} else { // black is moving
				bbfromsquare = _bigBoardtoBoard[bbepTarget + 9];
				if (bbfromsquare != -1 && myPawns.getBit(bbfromsquare)) { // I have a P in the right spot
					addMove(Move.setEnpassant(Move.setCapture(Move.createMove(
							bbfromsquare, epTarget, Piece.PAWN, Board.BLACK), Piece.PAWN, Board.WHITE)));
				}
				bbfromsquare = _bigBoardtoBoard[bbepTarget + 11];
				if (bbfromsquare != -1 && myPawns.getBit(bbfromsquare)) { // I have a P in the right spot
					addMove(Move.setEnpassant(Move.setCapture(Move.createMove(
							bbfromsquare, epTarget, Piece.PAWN, Board.BLACK), Piece.PAWN, Board.WHITE)));
				}
			}
		}

		/// todo : check that the rook square are occupied by rooks.
		/// in theory the castling flag should not be set unless that is true...
		/// but sometimes belts and suspenders are appropriate
		private function moveKingCastle(myPieces:BitBoard, oppPieces:BitBoard):void {
			//PgnViewer.xtrace("wkpos=" + _board._whiteKingPos +":");
			if (_board._side == Board.WHITE && _board.canWCastleKS() && _board._whiteKingPos == Board.E1) {
				if (!isSquareAttacked(Board.E1, Board.BLACK, _board)) {
					if (!isSquareAttacked(Board.F1, Board.BLACK, _board)) {
						if (!isSquareAttacked(Board.G1, Board.BLACK, _board)) {
							if (!myPieces.getBit(Board.F1) && !oppPieces.getBit(Board.F1)) {
								if (!myPieces.getBit(Board.G1) && !oppPieces.getBit(Board.G1)) {
									// can castle ks
									addMove(Move.setCastling(Move.createMove(
									        Board.E1, Board.G1, Piece.KING, Board.WHITE)));
								}
							}
						}
					}
				}
			}
			if (_board._side == Board.WHITE && _board.canWCastleQS()  && _board._whiteKingPos == Board.E1) {
				if (!isSquareAttacked(Board.E1, Board.BLACK, _board)) {
					if (!isSquareAttacked(Board.D1, Board.BLACK, _board)) {
						if (!isSquareAttacked(Board.C1, Board.BLACK, _board)) {
							if (!myPieces.getBit(Board.D1) && !oppPieces.getBit(Board.D1)) {
								if (!myPieces.getBit(Board.C1) && !oppPieces.getBit(Board.C1)) {
									// can castle QS
									addMove(Move.setCastling(Move.createMove(
									        Board.E1, Board.C1, Piece.KING, Board.WHITE)));
								}
							}
						}
					}
				}
			}
			if (_board._side == Board.BLACK && _board.canBCastleKS()  && _board._blackKingPos == Board.E8) {
				if (!isSquareAttacked(Board.E8, Board.WHITE, _board)) {
					if (!isSquareAttacked(Board.F8, Board.WHITE, _board)) {
						if (!isSquareAttacked(Board.G8, Board.WHITE, _board)) {
							if (!myPieces.getBit(Board.F8) && !oppPieces.getBit(Board.F8)) {
								if (!myPieces.getBit(Board.G8) && !oppPieces.getBit(Board.G8)) {
									// can castle ks
									addMove(Move.setCastling(Move.createMove(
									        Board.E8, Board.G8, Piece.KING, Board.BLACK)));
								}
							}
						}
					}
				}
			}
			if (_board._side == Board.BLACK && _board.canBCastleQS()  && _board._blackKingPos == Board.E8) {
				if (!isSquareAttacked(Board.E8, Board.WHITE, _board)) {
					if (!isSquareAttacked(Board.D8, Board.WHITE, _board)) {
						if (!isSquareAttacked(Board.C8, Board.WHITE, _board)) {
							if (!myPieces.getBit(Board.D8) && !oppPieces.getBit(Board.D8)) {
								if (!myPieces.getBit(Board.C8) && !oppPieces.getBit(Board.C8)) {
									// can castle QS
									addMove(Move.setCastling(Move.createMove(
									        Board.E8, Board.C8, Piece.KING, Board.BLACK)));
								}
							}
						}
					}
				}
			}
		}

		private function addMove(move:int):void {
			_board.addMoveToList(move);
		}

		private function addPromotions(move:int, side:int):void {
			addMove(Move.setPromotion(move, Piece.QUEEN, side));
			addMove(Move.setPromotion(move, Piece.KNIGHT, side));
			addMove(Move.setPromotion(move, Piece.ROOK, side));
			addMove(Move.setPromotion(move, Piece.BISHOP, side));
		}
		
	}
}