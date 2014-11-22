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

	public class BitBoardTest extends TestCase {

 		public function BitBoardTest(testMethod:String=null) {
 			super(testMethod);
 		}

		public function testBitBoardNot():void {
			var bb:BitBoard = BitBoard.NULL_BITBOARD;

			var bb1:BitBoard = bb.not();
			var bb2:BitBoard = bb1.not();
			assertEquals("not test1", bb, bb2);
			assertEquals("not test2", bb1, BitBoard.ALL_BITBOARD);
		}

		public function testBitBoardLeftmost():void {
			var bb:BitBoard = new BitBoard(0, 0,0,0);
			var index:int;
			var index2:int;

			var i:int;
			bb.setBit(63);

			for (i = 0; i < 10; i++) {
				index2 = bb.leftmost();
				assertEquals("Error 5:", index2, 63);
			}
		}

		public function testBitBoardSetBit():void {
			var bb:BitBoard = new BitBoard(0, 0,0,0);
			var index:int;
			var index2:int;

			var i:int;
			for (i = 0; i < 1; i++) {
				for (index = 0; index < 64; index++) {
					bb.setBit(index);
					index2 = bb.leftmost();
					assertEquals("Error 5:", index2, index);
					bb.clearBit(index);
				}

				for (index = 63; index >= 0; index--) {
					bb.setBit(index);
					index2 = bb.leftmost();
					assertEquals("Error 6:", index2, index);
					bb.clearBit(index);
				}
			}
		}

		public function testBitBoard():void {
			var bb:BitBoard = new BitBoard(0, 0,0,0);
			var index:int;
			var value:Boolean;
			var index2:int;
			for (index = 0; index < 64; index++) {
				value = bb.getBit(index);
				assertFalse("Error 1", value);
			}
			
			for (index = 0; index < 64; index++) {
				bb.setBit(index);
			}
			var bb2:BitBoard = new BitBoard(0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF);
			assertEquals("bb equals", bb, bb2);
	
			for (index = 0; index < 64; index++) {
				value = bb.getBit(index);
				assertTrue("Error 2", value);
			}
			//return;
			for (index = 0; index < 64; index++) {
				bb.clearBit(index);
			}

			for (index = 0; index < 64; index++) {
				value = bb.getBit(index);
				assertFalse("Error 3", value);
			}

			for (index = 0; index < 64; index++) {
				bb.setBit(index);
			}
			
			for (index = 0; index < 64; index++) {
				index2 = bb.leftmost();
				assertEquals("Error 4", index, index2);
				bb.clearBit(index);
			}
		}
	}
}