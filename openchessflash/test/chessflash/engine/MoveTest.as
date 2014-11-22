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

	import asunit.framework.TestCase;
	
	public class MoveTest extends TestCase {

 		public function MoveTest(testMethod:String=null) {
 			super(testMethod);
 		}

		public function testCreateMove():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertEquals("from", Move.fromSquare(move), 1);
			assertEquals("to", Move.toSquare(move), 63);
			assertEquals("piece", Move.movingPiece(move), 7);
		}
		
		public function testCapture():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertEquals("cap piece 1", Move.capturedPiece(move), 0);
			assertFalse("is cap 1", Move.isCapture(move));
			move = Move.setCapture(move, 6, 1);
	
			assertEquals("from", Move.fromSquare(move), 1);
			assertEquals("to", Move.toSquare(move), 63);
			assertEquals("move piece", Move.movingPiece(move), 7);
			assertEquals("cap piece 2", Move.capturedPiece(move), 6);
			assertTrue("is cap 2", Move.isCapture(move));
		}

		public function testPromotion():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertEquals("promo piece 1", Move.promotionPiece(move), 0);
			assertFalse("is promo 1", Move.isPromotion(move));
			move = Move.setPromotion(move, Piece.KING, Board.BLACK);
	
			assertEquals("from", Move.fromSquare(move), 1);
			assertEquals("to", Move.toSquare(move), 63);
			assertEquals("move piece", Move.movingPiece(move), 7);
			assertEquals("promo piece 2", Move.promotionPiece(move), 6);
			assertEquals("promo piece 2", Move.promotionPieceWithColor(move), Piece.BKING);
			assertTrue("is promo 2", Move.isPromotion(move));
		}

		public function testCheckFlag():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertFalse("is check 1", Move.isCheck(move));
			move = Move.setCheck(move);
			assertTrue("is check 2", Move.isCheck(move));

			assertFalse("is checkmate", Move.isCheckmate(move));
			assertFalse("is stalemate", Move.isStalemate(move));
			assertFalse("is enpassant", Move.isEnpassant(move));
			assertFalse("is castling", Move.isCastling(move));
		}
		
		
		public function testCheckmateFlag():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertFalse("is checkmate 1", Move.isCheckmate(move));
			move = Move.setCheckmate(move);
			assertTrue("is checkmate 2", Move.isCheckmate(move));

			assertFalse("is stalemate", Move.isStalemate(move));
			assertFalse("is castling", Move.isCastling(move));
			assertFalse("is enpassant", Move.isEnpassant(move));
			assertFalse("is check", Move.isCheck(move));
		}

		public function testEnpassantFlag():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertFalse("is enpassant 1", Move.isEnpassant(move));
			move = Move.setEnpassant(move);
			assertTrue("is enpassant 2", Move.isEnpassant(move));

			assertFalse("is checkmate", Move.isCheckmate(move));
			assertFalse("is stalemate", Move.isStalemate(move));
			assertFalse("is castling", Move.isCastling(move));
			assertFalse("is check", Move.isCheck(move));
		}

		public function testStalemateFlag():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertFalse("is stalemate 1", Move.isStalemate(move));
			move = Move.setStalemate(move);
			assertTrue("is stalemate 2", Move.isStalemate(move));

			assertFalse("is checkmate", Move.isCheckmate(move));
			assertFalse("is enpassant", Move.isEnpassant(move));
			assertFalse("is castling", Move.isCastling(move));
			assertFalse("is check", Move.isCheck(move));
		}
		
		public function testCastlingFlag():void {
			var move:int = Move.createMove(1, 63, 7,1);
			assertFalse("is castling 1", Move.isCastling(move));
			move = Move.createMove(Board.E1, Board.G1, Piece.KING, Board.WHITE);
			assertTrue("is castling 2", Move.isCastling(move));

			assertFalse("is checkmate", Move.isCheckmate(move));
			assertFalse("is stalemate", Move.isStalemate(move));
			assertFalse("is enpassant", Move.isEnpassant(move));
			assertFalse("is check", Move.isCheck(move));
		}
		
		public function testAll():void {
			var move:int = Move.createMove(1, 63, 7,1);
			move = Move.setCastling(move);
			move = Move.setStalemate(move);
			move = Move.setEnpassant(move);
			move = Move.setCheckmate(move);
			move = Move.setCheck(move);
			move = Move.setCapture(move, 6, 1);
			move = Move.setPromotion(move, Piece.QUEEN, Board.BLACK);

			assertFalse("is castling", Move.isCastling(move)); // now checks the move, not just a flag
			assertTrue("is checkmate", Move.isCheckmate(move));
			assertTrue("is stalemate", Move.isStalemate(move));
			assertTrue("is enpassant", Move.isEnpassant(move));
			assertTrue("is check", Move.isCheck(move));
			assertEquals("from", Move.fromSquare(move), 1);
			assertEquals("to", Move.toSquare(move), 63);
			assertEquals("move piece", Move.movingPiece(move), 7);
			assertEquals("cap piece", Move.capturedPiece(move), 6);
			assertTrue("is cap", Move.isCapture(move));
			assertEquals("promo piece", Move.promotionPiece(move), Piece.QUEEN);
			assertEquals("promo piece 2", Move.promotionPieceWithColor(move), Piece.BQUEEN);
			assertTrue("is promo", Move.isPromotion(move));
			
		}
		
	}
}