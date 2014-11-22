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
	
	public class BoardTest extends TestCase {
		private static const FEN1:String = "4k3/8/8/8/8/8/8/4K3 b - - 0 1";
		private static const FEN2:String = "k1R5/8/1K6/8/8/8/8/8 b - - 0 1"; // checkmate
		private static const FEN3:String = "kR6/8/1K6/8/8/8/8/8 b - - 0 1"; // move
		private static const FEN4:String = "k7/1R6/1K6/8/8/8/8/8 b - - 0 1"; // stalemate

 		public function BoardTest(testMethod:String=null) {
 			super(testMethod);
 		}

		public function testCheck():void {
			var board:Board = new Board();
			board.initialize();
			assertFalse("WINC", board.isWhiteInCheck());
			assertFalse("BINC", board.isBlackInCheck());
			assertFalse("CM", board.isCheckMate());
			assertFalse("SM", board.isStaleMate());

			board.initialize(FEN2);
			assertFalse("WINC2", board.isWhiteInCheck());
			assertTrue("BINC2", board.isBlackInCheck());
			assertTrue("CM2", board.isCheckMate());
			assertFalse("SM2", board.isStaleMate());

			board.initialize(FEN3);
			assertFalse("WINC3", board.isWhiteInCheck());
			assertTrue("BINC3", board.isBlackInCheck());
			assertFalse("CM3", board.isCheckMate());
			assertFalse("SM3", board.isStaleMate());

			board.initialize(FEN4);
			assertFalse("WINC4", board.isWhiteInCheck());
			assertFalse("BINC4", board.isBlackInCheck());
			assertFalse("CM4", board.isCheckMate());
			assertTrue("SM5", board.isStaleMate());
		}			

		public function testBoard():void {
			var board:Board = new Board();
			board.initialize();
			assertTrue("WCKS", board.canWCastleKS());
			assertTrue("WCQS", board.canWCastleQS());
			assertTrue("BCKS", board.canBCastleKS());
			assertTrue("BCQS", board.canBCastleQS());
			assertEquals("ep",-1, board._ep);
			assertEquals("side",Board.WHITE, board._side);

			board.initialize(FEN1);
			assertFalse("WCKS2", board.canWCastleKS());
			assertFalse("WCQS2", board.canWCastleQS());
			assertFalse("BCKS2", board.canBCastleKS());
			assertFalse("BCQS2", board.canBCastleQS());
			assertEquals("ep2",-1, board._ep);
			assertEquals("side2",Board.BLACK, board._side);
		} 
		
		public function testMakeMove():void {
			var board:Board = new Board();
			board.initialize();
			var movegenerator:MoveGenerator = new MoveGenerator(board);
			movegenerator.generate();
			movegenerator.cleanMoves();
			var move:int = Move.findMove("e4", board._moveList);
			assertTrue("move not null 1", move != Move.NOMOVE);
			assertEquals("move eq 1", "e4", Move.moveSan(move, board._moveList));
			board.makeMove(move);

			movegenerator.generate();
			movegenerator.cleanMoves();
			var move2:int = Move.findMove("d5", board._moveList);
			board.makeMove(move2);
			assertTrue("move not null 2", move2 != Move.NOMOVE);
			assertEquals("move eq 2", "d5", Move.moveSan(move2, board._moveList));

			movegenerator.generate();
			movegenerator.cleanMoves();
			move2 = Move.findMove("b3", board._moveList);
			board.makeMove(move2);
			assertTrue("move not null 3", move2 != Move.NOMOVE);
			assertEquals("move eq 3", "b3", Move.moveSan(move2, board._moveList));
		} 
	}
}