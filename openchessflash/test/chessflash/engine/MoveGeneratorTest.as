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
	
	public class MoveGeneratorTest extends TestCase {

		private static const FEN1:String = "4k3/8/8/8/8/8/8/4K3 b - - 0 1";
		private static const FEN2:String = "3qk3/8/8/8/8/8/8/3QK3 b - - 0 1";
		private static const FEN3:String = "3qk3/8/8/8/3N4/8/8/3QK3 b - - 0 1";
		private static const FEN4:String = "3qk3/8/8/8/3N4/8/8/2BQK3 b - - 0 1";
		private static const FEN5:String = "3qk3/8/8/8/3N4/8/8/R1BQK3 b - - 0 1";
		private static const FEN6:String = "3qk3/8/8/8/3N4/8/PPPP4/R1BQK3 b - - 0 1";

		private static const FEN7:String = "k1R5/8/1K6/8/8/8/8/8 b - - 0 1"; // checkmate
		private static const FEN8:String = "kR6/8/1K6/8/8/8/8/8 b - - 0 1"; // move
		private static const FEN9:String = "k7/1R6/1K6/8/8/8/8/8 b - - 0 1"; // stalemate
		private static const FEN10:String = "k7/7P/1K6/8/8/8/8/8 W - - 0 1"; // pawn promo
		private static const FEN11:String = "k5q1/7P/1K6/8/8/8/8/8 W - - 0 1"; // pawn promo
		private static const FEN12:String = "r3k2r/8/8/8/8/8/8/R3K2R W KQkq - 0 1"; // W castle
		private static const FEN13:String = "r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1"; // b castle
		private static const FEN14:String = "k7/1R6/1K6/8/3pPp2/8/8/8 b - e3 0 1"; // b en passant
		private static const FEN15:String = "K7/1r6/1k6/3PpP2/8/8/8/8 W - e6 0 1"; // b en passant

 		public function MoveGeneratorTest(testMethod:String=null) {
 			super(testMethod);
 		}

		public function testMoveGenerator(): void {
			var mg:MoveGenerator = new MoveGenerator(null);
			
			var board:Board = new Board();
			board.initialize(FEN8);
		
			assertEquals("Move list length for FEN8 :", 1, board._moveList.length);
		}

		public function testMoveGeneratorPawnEp(): void {
			var board:Board = new Board();
			board.initialize(FEN14);
			assertEquals("Move list length for FEN14 :", 4, board._moveList.length);

			board.initialize(FEN15);
			assertEquals("Move list length for FEN15 :", 4, board._moveList.length);
		}
		
		public function testMoveGeneratorPawnPromo(): void {
			var board:Board = new Board();
			board.initialize(FEN10);
			assertEquals("Move list length for FEN10 :", 10, board._moveList.length);

			board.initialize(FEN11);
			assertEquals("Move list length for FEN11 :", 14, board._moveList.length);
		}

		public function testMoveGeneratorCastles(): void {
			var board:Board = new Board();
			board.initialize(FEN12);
			
			assertEquals("Move list length for FEN12 :", 26, board._moveList.length);

			board.initialize(FEN13);
			var castles:int = Move.createMove(Board.E8, Board.G8, Piece.KING, Board.BLACK);
			castles = Move.setCastling(castles);
			board.makeMove(castles);
			board.unMakeMove(castles);

			assertEquals("Move list length for FEN13 :", 26, board._moveList.length);
		}

		public function testIsSquareAttackedByPawn(): void {
			var board:Board = new Board();
			board.initialize(FEN6); // just Ks & Qs on home squares plus N@d4,B@c1,R@a1, qside Ps
			assertFalse("a1",MoveGenerator.isSquareAttacked(Board.A1, Board.WHITE, board));
			assertTrue("b1",MoveGenerator.isSquareAttacked(Board.B1, Board.WHITE, board));
			assertTrue("c1",MoveGenerator.isSquareAttacked(Board.C1, Board.WHITE, board));
			assertTrue("d1",MoveGenerator.isSquareAttacked(Board.D1, Board.WHITE, board));
			assertTrue("e1",MoveGenerator.isSquareAttacked(Board.E1, Board.WHITE, board));
			assertTrue("f1",MoveGenerator.isSquareAttacked(Board.F1, Board.WHITE, board));
			assertFalse("g1",MoveGenerator.isSquareAttacked(Board.G1, Board.WHITE, board));
			assertFalse("h1",MoveGenerator.isSquareAttacked(Board.H1, Board.WHITE, board));
			assertTrue("b2",MoveGenerator.isSquareAttacked(Board.B2, Board.WHITE, board));
			assertTrue("a2",MoveGenerator.isSquareAttacked(Board.A2, Board.WHITE, board));
			assertFalse("a8",MoveGenerator.isSquareAttacked(Board.A8, Board.WHITE, board));
			assertTrue("c2",MoveGenerator.isSquareAttacked(Board.C2, Board.WHITE, board));
			assertTrue("d2",MoveGenerator.isSquareAttacked(Board.D2, Board.WHITE, board));
			assertTrue("e2",MoveGenerator.isSquareAttacked(Board.E2, Board.WHITE, board));
			assertTrue("f2",MoveGenerator.isSquareAttacked(Board.F2, Board.WHITE, board));
			assertFalse("g2",MoveGenerator.isSquareAttacked(Board.G2, Board.WHITE, board));
			assertTrue("b3",MoveGenerator.isSquareAttacked(Board.B3, Board.WHITE, board));
			assertFalse("a4",MoveGenerator.isSquareAttacked(Board.A4, Board.WHITE, board));
			assertTrue("f3",MoveGenerator.isSquareAttacked(Board.F3, Board.WHITE, board));
			assertTrue("g4",MoveGenerator.isSquareAttacked(Board.G4, Board.WHITE, board));
			assertTrue("h5",MoveGenerator.isSquareAttacked(Board.H5, Board.WHITE, board));
			assertFalse("D4",MoveGenerator.isSquareAttacked(Board.D4, Board.WHITE, board));
			assertFalse("d5",MoveGenerator.isSquareAttacked(Board.D5, Board.WHITE, board));
			assertFalse("d6",MoveGenerator.isSquareAttacked(Board.D6, Board.WHITE, board));
			assertFalse("d7",MoveGenerator.isSquareAttacked(Board.D7, Board.WHITE, board));
			assertFalse("d8",MoveGenerator.isSquareAttacked(Board.D8, Board.WHITE, board));
			assertFalse("f4",MoveGenerator.isSquareAttacked(Board.F4, Board.WHITE, board));
			assertFalse("g5",MoveGenerator.isSquareAttacked(Board.G5, Board.WHITE, board));
			assertFalse("h6",MoveGenerator.isSquareAttacked(Board.H6, Board.WHITE, board));

			assertTrue("e3",MoveGenerator.isSquareAttacked(Board.E3, Board.WHITE, board));
			assertTrue("d3",MoveGenerator.isSquareAttacked(Board.D3, Board.WHITE, board));
			assertTrue("c3",MoveGenerator.isSquareAttacked(Board.C3, Board.WHITE, board));
			assertTrue("b3",MoveGenerator.isSquareAttacked(Board.B3, Board.WHITE, board));
			assertTrue("a3",MoveGenerator.isSquareAttacked(Board.A3, Board.WHITE, board));

			assertFalse("e4",MoveGenerator.isSquareAttacked(Board.E4, Board.WHITE, board));
			assertFalse("d4",MoveGenerator.isSquareAttacked(Board.D4, Board.WHITE, board));
			assertFalse("c4",MoveGenerator.isSquareAttacked(Board.C4, Board.WHITE, board));
			assertFalse("b4",MoveGenerator.isSquareAttacked(Board.B4, Board.WHITE, board));
			assertFalse("a4",MoveGenerator.isSquareAttacked(Board.A4, Board.WHITE, board));

			assertFalse("d3",MoveGenerator.isSquareAttacked(Board.D3, Board.BLACK, board));
			assertTrue("D4 BLACK",MoveGenerator.isSquareAttacked(Board.D4, Board.BLACK, board));
			assertTrue("d5",MoveGenerator.isSquareAttacked(Board.D5, Board.BLACK, board));
		}
		
		public function testIsSquareAttackedByRook(): void {
			var board:Board = new Board();
			board.initialize(FEN5); // just Ks & Qs on home squares plus N@d4,B@c1,R@a1
			assertFalse("a1",MoveGenerator.isSquareAttacked(Board.A1, Board.WHITE, board));
			assertTrue("b1",MoveGenerator.isSquareAttacked(Board.B1, Board.WHITE, board));
			assertTrue("c1",MoveGenerator.isSquareAttacked(Board.C1, Board.WHITE, board));
			assertTrue("d1",MoveGenerator.isSquareAttacked(Board.D1, Board.WHITE, board));
			assertTrue("e1",MoveGenerator.isSquareAttacked(Board.E1, Board.WHITE, board));
			assertTrue("f1",MoveGenerator.isSquareAttacked(Board.F1, Board.WHITE, board));
			assertFalse("g1",MoveGenerator.isSquareAttacked(Board.G1, Board.WHITE, board));
			assertFalse("h1",MoveGenerator.isSquareAttacked(Board.H1, Board.WHITE, board));
			assertTrue("b2",MoveGenerator.isSquareAttacked(Board.B2, Board.WHITE, board));
			assertTrue("a2",MoveGenerator.isSquareAttacked(Board.A2, Board.WHITE, board));
			assertTrue("a8",MoveGenerator.isSquareAttacked(Board.A8, Board.WHITE, board));
			assertTrue("c2",MoveGenerator.isSquareAttacked(Board.C2, Board.WHITE, board));
			assertTrue("d2",MoveGenerator.isSquareAttacked(Board.D2, Board.WHITE, board));
			assertTrue("e2",MoveGenerator.isSquareAttacked(Board.E2, Board.WHITE, board));
			assertTrue("f2",MoveGenerator.isSquareAttacked(Board.F2, Board.WHITE, board));
			assertFalse("g2",MoveGenerator.isSquareAttacked(Board.G2, Board.WHITE, board));
			assertTrue("b3",MoveGenerator.isSquareAttacked(Board.B3, Board.WHITE, board));
			assertTrue("a4",MoveGenerator.isSquareAttacked(Board.A4, Board.WHITE, board));
			assertTrue("f3",MoveGenerator.isSquareAttacked(Board.F3, Board.WHITE, board));
			assertTrue("g4",MoveGenerator.isSquareAttacked(Board.G4, Board.WHITE, board));
			assertTrue("h5",MoveGenerator.isSquareAttacked(Board.H5, Board.WHITE, board));
			assertTrue("d3",MoveGenerator.isSquareAttacked(Board.D3, Board.WHITE, board));
			assertTrue("D4",MoveGenerator.isSquareAttacked(Board.D4, Board.WHITE, board));
			assertFalse("d5",MoveGenerator.isSquareAttacked(Board.D5, Board.WHITE, board));
			assertFalse("d6",MoveGenerator.isSquareAttacked(Board.D6, Board.WHITE, board));
			assertFalse("d7",MoveGenerator.isSquareAttacked(Board.D7, Board.WHITE, board));
			assertFalse("d8",MoveGenerator.isSquareAttacked(Board.D8, Board.WHITE, board));
			assertTrue("e3",MoveGenerator.isSquareAttacked(Board.E3, Board.WHITE, board));
			assertTrue("f4",MoveGenerator.isSquareAttacked(Board.F4, Board.WHITE, board));
			assertTrue("g5",MoveGenerator.isSquareAttacked(Board.G5, Board.WHITE, board));
			assertTrue("h6",MoveGenerator.isSquareAttacked(Board.H6, Board.WHITE, board));
			assertTrue("a3",MoveGenerator.isSquareAttacked(Board.A3, Board.WHITE, board));

			assertFalse("d3",MoveGenerator.isSquareAttacked(Board.D3, Board.BLACK, board));
			assertTrue("D4 BLACK",MoveGenerator.isSquareAttacked(Board.D4, Board.BLACK, board));
			assertTrue("d5",MoveGenerator.isSquareAttacked(Board.D5, Board.BLACK, board));
		}

		public function testIsSquareAttackedByBishop(): void {
			var board:Board = new Board();
			board.initialize(FEN4); // just Ks & Qs on home squares plus W N on d4 + B@c1
			assertFalse("a1",MoveGenerator.isSquareAttacked(Board.A1, Board.WHITE, board));
			assertFalse("b1",MoveGenerator.isSquareAttacked(Board.B1, Board.WHITE, board));
			assertTrue("c1",MoveGenerator.isSquareAttacked(Board.C1, Board.WHITE, board));
			assertTrue("d1",MoveGenerator.isSquareAttacked(Board.D1, Board.WHITE, board));
			assertTrue("e1",MoveGenerator.isSquareAttacked(Board.E1, Board.WHITE, board));
			assertTrue("f1",MoveGenerator.isSquareAttacked(Board.F1, Board.WHITE, board));
			assertFalse("g1",MoveGenerator.isSquareAttacked(Board.G1, Board.WHITE, board));
			assertFalse("h1",MoveGenerator.isSquareAttacked(Board.H1, Board.WHITE, board));
			assertTrue("b2",MoveGenerator.isSquareAttacked(Board.B2, Board.WHITE, board));
			assertTrue("c2",MoveGenerator.isSquareAttacked(Board.C2, Board.WHITE, board));
			assertTrue("d2",MoveGenerator.isSquareAttacked(Board.D2, Board.WHITE, board));
			assertTrue("e2",MoveGenerator.isSquareAttacked(Board.E2, Board.WHITE, board));
			assertTrue("f2",MoveGenerator.isSquareAttacked(Board.F2, Board.WHITE, board));
			assertFalse("g2",MoveGenerator.isSquareAttacked(Board.G2, Board.WHITE, board));
			assertTrue("b3",MoveGenerator.isSquareAttacked(Board.B3, Board.WHITE, board));
			assertTrue("a4",MoveGenerator.isSquareAttacked(Board.A4, Board.WHITE, board));
			assertTrue("f3",MoveGenerator.isSquareAttacked(Board.F3, Board.WHITE, board));
			assertTrue("g4",MoveGenerator.isSquareAttacked(Board.G4, Board.WHITE, board));
			assertTrue("h5",MoveGenerator.isSquareAttacked(Board.H5, Board.WHITE, board));
			assertTrue("d3",MoveGenerator.isSquareAttacked(Board.D3, Board.WHITE, board));
			assertTrue("D4",MoveGenerator.isSquareAttacked(Board.D4, Board.WHITE, board));
			assertFalse("d5",MoveGenerator.isSquareAttacked(Board.D5, Board.WHITE, board));
			assertFalse("d6",MoveGenerator.isSquareAttacked(Board.D6, Board.WHITE, board));
			assertFalse("d7",MoveGenerator.isSquareAttacked(Board.D7, Board.WHITE, board));
			assertFalse("d8",MoveGenerator.isSquareAttacked(Board.D8, Board.WHITE, board));
			assertTrue("e3",MoveGenerator.isSquareAttacked(Board.E3, Board.WHITE, board));
			assertTrue("f4",MoveGenerator.isSquareAttacked(Board.F4, Board.WHITE, board));
			assertTrue("g5",MoveGenerator.isSquareAttacked(Board.G5, Board.WHITE, board));
			assertTrue("h6",MoveGenerator.isSquareAttacked(Board.H6, Board.WHITE, board));
			assertTrue("a3",MoveGenerator.isSquareAttacked(Board.A3, Board.WHITE, board));

			assertFalse("d3",MoveGenerator.isSquareAttacked(Board.D3, Board.BLACK, board));
			assertTrue("D4 BLACK",MoveGenerator.isSquareAttacked(Board.D4, Board.BLACK, board));
			assertTrue("d5",MoveGenerator.isSquareAttacked(Board.D5, Board.BLACK, board));
		}

		public function testIsSquareAttackedByKnight(): void {
			var board:Board = new Board();
			board.initialize(FEN3); // just Ks & Qs on their home squares plus W N on d4
			assertTrue(MoveGenerator.isSquareAttacked(Board.A1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.B1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.C1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.E1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.F1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.G1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.H1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.B2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.C2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.E2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.F2, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.G2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.B3, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.A4, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.F3, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.G4, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.H5, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D3, Board.WHITE, board));
			assertTrue("D4",MoveGenerator.isSquareAttacked(Board.D4, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.D5, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.D6, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.D7, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.D8, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.E3, Board.WHITE, board));

			assertFalse(MoveGenerator.isSquareAttacked(Board.D3, Board.BLACK, board));
			assertTrue("D4 BLACK",MoveGenerator.isSquareAttacked(Board.D4, Board.BLACK, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D5, Board.BLACK, board));
		}

		public function testIsSquareAttackedByQueen(): void {
			var board:Board = new Board();
			board.initialize(FEN2); // just Ks & Qs on their home squares
			assertTrue(MoveGenerator.isSquareAttacked(Board.A1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.B1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.C1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.E1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.F1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.G1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.H1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.B2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.C2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.E2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.F2, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.G2, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.B3, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.A4, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.F3, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.G4, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.H5, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D3, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D4, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D5, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D6, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D7, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D8, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.E3, Board.WHITE, board));
		}
		
		public function testIsSquareAttackedByKing(): void {
			var board:Board = new Board();
			board.initialize(FEN1); // just Ks on their home squares
			assertFalse(MoveGenerator.isSquareAttacked(Board.A1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.B1, Board.WHITE, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.C1, Board.WHITE, board));
			assertTrue(MoveGenerator.isSquareAttacked(Board.D1, Board.WHITE, board));// d1 -next to K at e1
			assertFalse(MoveGenerator.isSquareAttacked(Board.E1, Board.WHITE, board)); //e1
			assertTrue(MoveGenerator.isSquareAttacked(Board.F1, Board.WHITE, board)); //f1 -next to K at e1
			assertTrue(MoveGenerator.isSquareAttacked(Board.D2, Board.WHITE, board)); //d2 -next to K at e1
			assertTrue(MoveGenerator.isSquareAttacked(Board.E2, Board.WHITE, board)); //e2 -next to K at e1
			assertTrue(MoveGenerator.isSquareAttacked(Board.F2, Board.WHITE, board)); //f2 -next to K at e1
			assertFalse(MoveGenerator.isSquareAttacked(Board.D3, Board.WHITE, board)); //d3
			assertFalse(MoveGenerator.isSquareAttacked(Board.E3, Board.WHITE, board)); //e3
			assertFalse(MoveGenerator.isSquareAttacked(Board.E8, Board.WHITE, board)); //e8
			assertFalse(MoveGenerator.isSquareAttacked(Board.E7, Board.WHITE, board)); //e7

			assertFalse(MoveGenerator.isSquareAttacked(Board.A1, Board.BLACK, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.B1, Board.BLACK, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.C1, Board.BLACK, board));
			assertFalse(MoveGenerator.isSquareAttacked(Board.D1, Board.BLACK, board));// d1 -next to K at e8
			assertFalse(MoveGenerator.isSquareAttacked(Board.E1, Board.BLACK, board)); //e1
			assertTrue(MoveGenerator.isSquareAttacked(Board.F8, Board.BLACK, board)); //f8 -next to K at e8
			assertTrue(MoveGenerator.isSquareAttacked(Board.D7, Board.BLACK, board)); //d7 -next to K at e8
			assertTrue(MoveGenerator.isSquareAttacked(Board.E7, Board.BLACK, board)); //e7 -next to K at e8
			assertTrue(MoveGenerator.isSquareAttacked(Board.F7, Board.BLACK, board)); //f7 -next to K at e8
			assertFalse(MoveGenerator.isSquareAttacked(Board.D3, Board.BLACK, board)); //d3
			assertFalse(MoveGenerator.isSquareAttacked(Board.E3, Board.BLACK, board)); //e3
			assertFalse(MoveGenerator.isSquareAttacked(Board.E8, Board.BLACK, board)); //e8
			assertFalse(MoveGenerator.isSquareAttacked(Board.E2, Board.BLACK, board)); //e2
		}
	}
}