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
	 * A Chess Board.
	 * Maintains the state of the game, postion of the pieces, castling rights, etc.
	 * A move can be made on the board.
	 */
	public class Board {
		
		public static const WHITE:int =  0;
		public static const BLACK:int =  1;
		
		public static const A1:int =  0, B1:int =  1, C1:int =  2, D1:int =  3, E1:int =  4, F1:int =  5, G1:int =  6, H1:int =  7;
		public static const A2:int =  8, B2:int =  9, C2:int = 10, D2:int = 11, E2:int = 12, F2:int = 13, G2:int = 14, H2:int = 15;
		public static const A3:int = 16, B3:int = 17, C3:int = 18, D3:int = 19, E3:int = 20, F3:int = 21, G3:int = 22, H3:int = 23;
		public static const A4:int = 24, B4:int = 25, C4:int = 26, D4:int = 27, E4:int = 28, F4:int = 29, G4:int = 30, H4:int = 31;
		public static const A5:int = 32, B5:int = 33, C5:int = 34, D5:int = 35, E5:int = 36, F5:int = 37, G5:int = 38, H5:int = 39;
		public static const A6:int = 40, B6:int = 41, C6:int = 42, D6:int = 43, E6:int = 44, F6:int = 45, G6:int = 46, H6:int = 47;
		public static const A7:int = 48, B7:int = 49, C7:int = 50, D7:int = 51, E7:int = 52, F7:int = 53, G7:int = 54, H7:int = 55;
		public static const A8:int = 56, B8:int = 57, C8:int = 58, D8:int = 59, E8:int = 60, F8:int = 61, G8:int = 62, H8:int = 63;

		public static const WKSCASTLE:int =  0x0001;
		public static const WQSCASTLE:int =  0x0002;
		public static const BKSCASTLE:int =  0x0004;
		public static const BQSCASTLE:int =  0x0008;
		public static const WINCHECK:int  =  0x0010;
		public static const BINCHECK:int  =  0x0020;
		private static const HASHFACTOR1:int = 0x14102;
		private static const HASHFACTOR2:int = 0x5795612;
		
		public var _whitePieces:BitBoard;
		public var _blackPieces:BitBoard;
		public var _side:uint;            /* Color of side on move: 0=white, 1=black */
		public var _whiteKingPos:int;
		public var _blackKingPos:int;

		public var _ep:int;              /* Location of en passant square; -1 if none */
		public var _flags:int;      /* Flags related to castle privileges */
		public var _whiteMaterial:int;   /* Total material by side not inc. king */
		public var _blackMaterial:int;   /* Total material by side not inc. king */
		public var _moveList:Array;

		private var _whitePawn:BitBoard;
		private var _whiteRook:BitBoard;
		private var _whiteKnight:BitBoard;
		private var _whiteBishop:BitBoard;
		private var _whiteQueen:BitBoard;
		private var _whiteKing:BitBoard;
		
		private var _blackPawn:BitBoard;
		private var _blackRook:BitBoard;
		private var _blackKnight:BitBoard;
		private var _blackBishop:BitBoard;
		private var _blackQueen:BitBoard;
		private var _blackKing:BitBoard;

		// maintain state for 1 move prior
		private var _stateArray:Array = new Array();

/// Constructor		
		
		public function Board() {
		}
		
/// Public Functions		
		
		public function toString():String {
			var rank:int;
			var file:int;
			var myString:String = "Board:";
			if (_flags & WKSCASTLE != 0) myString += "K";
			if (_flags & WQSCASTLE != 0) myString += "Q";
			if (_flags & BKSCASTLE != 0) myString += "k";
			if (_flags & WQSCASTLE != 0) myString += "q";
			myString += " ";
			myString += "K@" + _whiteKingPos + " k@" + _blackKingPos;

			for (rank = 8; rank >= 1; rank--) {
					myString += "\n";
				for (file = 1; file <= 8; file++) {
					var index:int = (rank - 1) * 8 + file - 1;
					myString += getPiece(index);
				}
			}
			
			return myString;
		}
		
		public function initialize(fenString:String = null): void {
			if (fenString == null) fenString = Fen.getDefaultFen();
			var fen:Fen = new Fen(fenString);
			var i:int;
			var bitBoard:BitBoard;
			var fenPiece:int;
			
			_whitePawn = new BitBoard(0,0,0,0);
			_whiteRook = new BitBoard(0,0,0,0);
			_whiteKnight = new BitBoard(0,0,0,0);
			_whiteBishop = new BitBoard(0,0,0,0);
			_whiteQueen = new BitBoard(0,0,0,0);
			_whiteKing = new BitBoard(0,0,0,0);
			
			_blackPawn = new BitBoard(0,0,0,0);
			_blackRook = new BitBoard(0,0,0,0);
			_blackKnight = new BitBoard(0,0,0,0);
			_blackBishop = new BitBoard(0,0,0,0);
			_blackQueen = new BitBoard(0,0,0,0);
			_blackKing = new BitBoard(0,0,0,0);

			for (i = 0; i < 64; i++) {
				fenPiece = fen.getPieceFenAtIndex(i);
				if (fenPiece != 0) {
					switch (fenPiece) {
						case Piece.WPAWN: _whitePawn.setBit(i); continue;
						case Piece.WROOK: _whiteRook.setBit(i); continue;
						case Piece.WKNIGHT: _whiteKnight.setBit(i); continue;
						case Piece.WBISHOP: _whiteBishop.setBit(i); continue;
						case Piece.WQUEEN: _whiteQueen.setBit(i); continue;
						case Piece.WKING: _whiteKing.setBit(i); _whiteKingPos = i;  continue;

						case Piece.BPAWN: _blackPawn.setBit(i); continue;
						case Piece.BROOK: _blackRook.setBit(i); continue;
						case Piece.BKNIGHT: _blackKnight.setBit(i); continue;
						case Piece.BBISHOP: _blackBishop.setBit(i); continue;
						case Piece.BQUEEN: _blackQueen.setBit(i); continue;
						case Piece.BKING: _blackKing.setBit(i); _blackKingPos = i; continue;
					}
				}
			}

			_whiteMaterial  = 0;// 2 * Evaluate.ROOK_VALUE + 2 * Evaluate.KNIGHT_VALUE + 2 * Evaluate.BISHOP_VALUE 
				//+ Evaluate.QUEEN_VALUE + 8*Evaluate.PAWN_VALUE;
			_blackMaterial = _whiteMaterial;
			_ep = fen.enPassantTargetSquare();
			_flags = 0;
			if (fen.canBCastleKS()) {
				_flags |= BKSCASTLE;
			}
			if (fen.canBCastleQS()) {
				_flags |= BQSCASTLE;
			}
			if (fen.canWCastleQS()) {
				_flags |= WQSCASTLE;
			}
			if (fen.canWCastleKS()) {
				_flags |= WKSCASTLE;
			}
			if (fen.getWhiteToMove()) {
				_side = WHITE;
			} else {
				_side = BLACK;
			}
			
			updatePieces();
			_moveList = new Array();

			if (MoveGenerator.isSquareAttacked(_whiteKingPos, BLACK, this)) {
				setWhiteInCheck();
			}
			
			if (MoveGenerator.isSquareAttacked(_blackKingPos, WHITE, this)) {
				setBlackInCheck();
			}
			var moveGenerator:MoveGenerator = new MoveGenerator(this);
			moveGenerator.generate();
			moveGenerator.cleanMoves();
			cleanMoveList();
		}

		// deep copy board
		public function copy():Board {
			var board:Board = new Board();

			board._whitePawn = _whitePawn.copy();
			board._whiteRook = _whiteRook.copy();
			board._whiteKnight = _whiteKnight.copy();
			board._whiteBishop = _whiteBishop.copy();
			board._whiteQueen = _whiteQueen.copy();
			board._whiteKing = _whiteKing.copy();
			
			board._blackPawn = _blackPawn.copy();
			board._blackRook = _blackRook.copy();
			board._blackKnight = _blackKnight.copy();
			board._blackBishop = _blackBishop.copy();
			board._blackQueen = _blackQueen.copy();
			board._blackKing = _blackKing.copy();

			board._whitePieces = _whitePieces.copy();
			board._blackPieces = _blackPieces.copy();
			board._side = _side;
			board._whiteKingPos = _whiteKingPos;
			board._blackKingPos = _blackKingPos;

			board._ep = _ep;
			board._flags = _flags;
			board._whiteMaterial = _whiteMaterial;
			board._blackMaterial = _blackMaterial;
			board._moveList = new Array(_moveList.length);
			for (var i:int = 0; i < _moveList.length; i++) {
				board._moveList[i] = _moveList[i];
			}
			board._stateArray = new Array(_stateArray.length);
			for (i = 0; i < _stateArray.length; i++) {
				board._stateArray[i] = _stateArray[i] as int;
			}
			_stateArray;

			return board;
		}

		// lightweight move maker to check for illegal moves, check, etc.
		// keeps previous lightweight state to restore
		// can only be one try move pending at a time
		// gew: may now work for an unlimited sequence of moves but that has not been tested.
		public function makeMove(move:int):void {
			if (move == Move.NULLMOVE) {
				pushState();
				_side = 1 - _side;
				_ep = -1;
				return;
			}

			var from:int = Move.fromSquare(move);
			var to:int = Move.toSquare(move);
			var piece:int = Move.movingPiece(move);
			var cappiece:int = Move.capturedPiece(move);
			var myPieceBB:BitBoard = getBitBoard(_side, piece);
			var promo:int = Move.promotionPiece(move);
			
			pushState();
		
			_ep = Move.getEnpassantTargetSquare(move);
			
			if (piece == Piece.KING) {
				clearCanCastleKS(_side);
				clearCanCastleQS(_side);
				if (_side == WHITE) {
					_whiteKingPos = to;
				} else {
					_blackKingPos = to;
				}
			}
			// set castling flags based on pieces moving for side to move
			if ((_side == WHITE) && (from == Board.H1 || to == Board.H1 )) {
				clearCanCastleKS(WHITE);
			}
			if ((_side == WHITE) && (from == Board.A1 || to == Board.A1 )) {
				clearCanCastleQS(WHITE);
			}
			
			if ((_side == BLACK) && (from == Board.H8 || to == Board.H8 )) {
				clearCanCastleKS(BLACK);
			}
			if ((_side == BLACK) && (from == Board.A8 || to == Board.A8 )) {
				clearCanCastleQS(BLACK);
			}

			// set castling flags based on capturing on opponents rooks home square
			// todo: movegenerator does not validate that rook is there!
			if (cappiece != 0) {
				if ((_side == WHITE) && (to == Board.H8 )) {
					clearCanCastleKS(BLACK);
				}
				if ((_side == WHITE) && (to == Board.A8 )) {
					clearCanCastleQS(BLACK);
				}
				
				if ((_side == BLACK) && (to == Board.H1 )) {
					clearCanCastleKS(WHITE);
				}
				if ((_side == BLACK) && (to == Board.A1 )) {
					clearCanCastleQS(WHITE);
				}
			}
			
			myPieceBB.clearBit(from);
			if (!Move.isPromotion(move)) {
				myPieceBB.setBit(to);
			} else {
				var myPromoBB:BitBoard = getBitBoard(_side, promo);
				myPromoBB.setBit(to);
			}
			// update pieces
			var pieces:BitBoard = getPieces(_side);
			pieces.clearBit(from);
			pieces.setBit(to);
			
			if (Move.isCastling(move)) { // now move the rook
				var myRookBB:BitBoard = getBitBoard(_side, Piece.ROOK);
				myRookBB.clearBit(Move.fromSquare2(move));
				myRookBB.setBit(Move.toSquare2(move));
				pieces.clearBit(Move.fromSquare2(move));
				pieces.setBit(Move.toSquare2(move));
			}
			
			if (cappiece != 0) {
				var yourPieceBB:BitBoard = getBitBoard(1 - _side, cappiece);
				if (Move.isEnpassant(move)) {
					var epto:int = Move.getEnpassantCaptureSquare(move);
					yourPieceBB.clearBit(epto);
					pieces = getPieces(1 - _side);
					pieces.clearBit(epto);
					
				} else {
					yourPieceBB.clearBit(to);
					pieces = getPieces(1 - _side);
					pieces.clearBit(to);
				}
			}
			_side = 1 - _side;
		}
		
		public function unMakeMove(move:int):void {
			popState();
			
			_side = 1 - _side;
			var from:int = Move.fromSquare(move);
			var to:int = Move.toSquare(move);
			var piece:int = Move.movingPiece(move);
			var cappiece:int = Move.capturedPiece(move);
			var myPieceBB:BitBoard = getBitBoard(_side, piece);
			var promo:int = Move.promotionPiece(move);

			if (piece == Piece.KING) {
				if (_side == WHITE) {
					_whiteKingPos = from;
				} else {
					_blackKingPos = from;
				}
			}

			if (!Move.isPromotion(move)) {
				myPieceBB.clearBit(to);
			} else {
				var myPromoBB:BitBoard = getBitBoard(_side, promo);
				myPromoBB.clearBit(to);
			}
			myPieceBB.setBit(from);
			// update pieces
			var pieces:BitBoard = getPieces(_side);
			pieces.clearBit(to);
			pieces.setBit(from);

			if (Move.isCastling(move)) { // now unmove the rook
				var myRookBB:BitBoard = getBitBoard(_side, Piece.ROOK);
				myRookBB.clearBit(Move.toSquare2(move));
				myRookBB.setBit(Move.fromSquare2(move));
				pieces.clearBit(Move.toSquare2(move));
				pieces.setBit(Move.fromSquare2(move));
			}

			if (cappiece != 0) {
				var yourPieceBB:BitBoard = getBitBoard(1 - _side, cappiece);
				if (Move.isEnpassant(move)) {
					var epto:int = Move.getEnpassantCaptureSquare(move);
					yourPieceBB.setBit(epto);
					pieces = getPieces(1 - _side);
					pieces.setBit(epto);
				} else {
					yourPieceBB.setBit(to);
					pieces = getPieces(1 - _side);
					pieces.setBit(to);
				}
			}
		}

/// Public Functions		
		
		internal function canWCastleKS():Boolean {
			return (_flags & WKSCASTLE) != 0;
		}
		
		internal function canWCastleQS():Boolean {
			return (_flags & WQSCASTLE) != 0;
		}

		internal function canBCastleQS():Boolean {
			return (_flags & BQSCASTLE) != 0;
		}

		internal function canBCastleKS():Boolean {
			return (_flags & BKSCASTLE) != 0;
		}

		internal function isSideInCheck(side:int): Boolean {
			if (side == WHITE) {
				return isWhiteInCheck();
			}
			return isBlackInCheck();
		}
		
		internal function setWhiteInCheck():void {
			_flags |= WINCHECK;
		}

		internal function setBlackInCheck():void {
			_flags |= BINCHECK;
		}

		internal function isCheckMate():Boolean {
			return isSideInCheck(_side) && _moveList.length == 0;
		}
		
		internal function isStaleMate() : Boolean {
			return !isSideInCheck(_side) && _moveList.length == 0;
		}
		
		internal function isWhiteInCheck():Boolean {
			return (_flags & WINCHECK) != 0;
		}

		internal function isBlackInCheck():Boolean {
			return (_flags & BINCHECK) != 0;
		}

		internal function getPieceAt(square:int, side:int):int {
			var bb:BitBoard;
			if (side == WHITE) {
				if (_whitePawn.getBit(square)) return Piece.PAWN;
				if (_whiteKnight.getBit(square)) return Piece.KNIGHT;
				if (_whiteBishop.getBit(square)) return Piece.BISHOP;
				if (_whiteRook.getBit(square)) return Piece.ROOK;
				if (_whiteQueen.getBit(square)) return Piece.QUEEN;
				if (_whiteKing.getBit(square)) return Piece.KING;
				return 0;
			}
			if (_blackPawn.getBit(square)) return Piece.PAWN;
			if (_blackKnight.getBit(square)) return Piece.KNIGHT;
			if (_blackBishop.getBit(square)) return Piece.BISHOP;
			if (_blackRook.getBit(square)) return Piece.ROOK;
			if (_blackQueen.getBit(square)) return Piece.QUEEN;
			if (_blackKing.getBit(square)) return Piece.KING;
			return 0;
		}
		
		internal function addMoveToList(move:int):void {
			_moveList.push(move);
		}
		
		internal function invalidateMove(index:int):void {
			_moveList[index] = 0;
		}
		
		// remove null moves
		internal function cleanMoveList():void {
			var newMoveList:Array = new Array();
			var index:int;
			for (index = 0; index < _moveList.length; index++) {
				var move:int = _moveList[index] as int;
				if (move != 0) {
					newMoveList.push(move);
				}
			}
			_moveList = newMoveList;
		}
		
		internal function updatePieces():void {
			_whitePieces = BitBoard.sor(_whitePawn, _whiteRook, _whiteKnight, _whiteBishop, _whiteQueen, _whiteKing);
			_blackPieces = BitBoard.sor(_blackPawn, _blackRook, _blackKnight, _blackBishop, _blackQueen, _blackKing);
		}
		
		internal function clearCanCastleKS(color:int): void {
			switch (color) {
				case BLACK: (_flags &= ~BKSCASTLE); break;
				case WHITE: (_flags &= ~WKSCASTLE); break;
			}
		}

		internal function clearCanCastleQS(color:int): void {
			switch (color) {
				case BLACK: (_flags &= ~BQSCASTLE); break;
				case WHITE: (_flags &= ~WQSCASTLE); break;
			}
		}

		internal function canCastleKS(color:int): Boolean {
			switch (color) {
				case BLACK: return (_flags & BKSCASTLE) != 0;
				case WHITE: return (_flags & WKSCASTLE) != 0;
			}
			return false;
		}
		
		internal function canCastleQS(color:int): Boolean {
			switch (color) {
				case BLACK: return (_flags & BQSCASTLE) != 0;
				case WHITE: return (_flags & WQSCASTLE) != 0;
			}
			return false;
		}

		internal function canCastle(color:int): Boolean {
			return canCastleKS(color) || canCastleQS(color);
		}

		internal function getPieces(color:int):BitBoard {
			switch (color) {
				case BLACK: return _blackPieces;
				case WHITE: return _whitePieces;
			}
			return null;
		}
		
		internal function getKingPos(color:int) :int{
			switch (color) {
				case BLACK: return _blackKingPos;
				case WHITE: return _whiteKingPos;
			}
			return -1;
		}
		
		internal function getBitBoard(color:int, piece: int):BitBoard {
			switch (color) {
				case BLACK:
				switch (piece) {
					case Piece.PAWN: return _blackPawn; 
					case Piece.ROOK: return _blackRook;
					case Piece.KNIGHT: return _blackKnight;
					case Piece.BISHOP: return _blackBishop;
					case Piece.QUEEN: return _blackQueen;
					case Piece.KING: return _blackKing;
				}
				case WHITE:
				switch (piece) {
					case Piece.PAWN: return _whitePawn;
					case Piece.ROOK: return _whiteRook;
					case Piece.KNIGHT: return _whiteKnight;
					case Piece.BISHOP: return _whiteBishop;
					case Piece.QUEEN: return _whiteQueen;
					case Piece.KING: return _whiteKing;
				}
			}
			return null;
		}
		
		internal function getPiece(square:int):String {
			if (_blackPawn.getBit(square)) return "p";	
			if (_blackRook.getBit(square)) return "r";	
			if (_blackKnight.getBit(square)) return "n";	
			if (_blackBishop.getBit(square)) return "b";	
			if (_blackQueen.getBit(square)) return "q";	
			if (_blackKing.getBit(square)) return "k";	
			if (_whitePawn.getBit(square)) return "P";	
			if (_whiteRook.getBit(square)) return "R";	
			if (_whiteKnight.getBit(square)) return "N";	
			if (_whiteBishop.getBit(square)) return "B";	
			if (_whiteQueen.getBit(square)) return "Q";	
			if (_whiteKing.getBit(square)) return "K";
			return "-";
		}
		
/// Private Functions		

		private function popState():void {
			_ep = _stateArray.pop() as int;
			_flags = _stateArray.pop() as int;
		}

		private function pushState():void {
			_stateArray.push(_flags);
			_stateArray.push(_ep);
		}
	}
}