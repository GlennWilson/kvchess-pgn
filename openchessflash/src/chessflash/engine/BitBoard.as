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
	 * A Bitboard.
	 * Represents the 64 squares of the chessboard and some binary state for each of those squares.
	 * Includes methods to manipulate and extract information from a bitboard.
	 * For general information on bitboards see: http://en.wikipedia.org/wiki/Bitboard
	 * 
	 * If flash had a 64 bit unsigned long this code would be simpler.  As it is, the 64 bits
	 * are represented by two 32bit unsigned ints.
	 * 
	 * The position of all White pieces on the board is contained in a group of bitboards for 
	 * white pawns, white knights, white queens, white rooks, white bishops and the white king.
	 * The same is true for the Black pieces.  
	 * 
	 * Bitboards are used to store that state of the board and in move generation.
	 */
	public class BitBoard {
		/*  Some special BitBoards  */
		public static const NULL_BITBOARD:BitBoard = new BitBoard( 0x00000000, 0x00000000,0x00000000, 0x00000000);
		public static const ALL_BITBOARD:BitBoard = new BitBoard( 0xFFFFFFFF, 0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF);
		
		private static const SIXTEEN_BITS:uint = 0x0FFFF;
		private static const TOPBIT:uint = 0x80000000;
		private static const TOPBITHALF:uint = 0x8000;
		private static const TOPBITHALFTEST:uint = 0x10000;
		
		// changing into 4 parts each of which will hold 16 values
		private var _part1:uint = 0; // 0-31 a1-h4 // now 0-15
		private var _part2:uint = 0; // 32-63 a5-h8 // now 15-31
		private var _part3:uint = 0; // 32-47
		private var _part4:uint = 0; // 48-63
		
/// Constructor

		/**
		 * Constructor
		 * @param	part1 squares 0-31 a1-h4
		 * @param	part2 squares 32-63 a5-h8
		 */
		public function BitBoard(part1:uint, part2:uint, part3:uint, part4:uint) {
			_part1 = part1 & SIXTEEN_BITS;
			_part2 = part2 & SIXTEEN_BITS;
			_part3 = part3 & SIXTEEN_BITS;
			_part4 = part4 & SIXTEEN_BITS;
		}
		
/// Public Static Functions

		/**
		 * Static method to bitwise OR an array of bitboards
		 * @param	...args bitboards to OR
		 * @return new ORed bitboard
		 */
		internal static function sor(...args:Array):BitBoard {
			var bb:BitBoard = args[0] as BitBoard;
			var part1:int = bb._part1;
			var part2:int = bb._part2;
			var part3:int = bb._part3;
			var part4:int = bb._part4;
			
			for (var i:int = 1; i < args.length; i++) {
				bb = args[i] as BitBoard;
				part1 |= bb._part1;
				part2 |= bb._part2;
				part3 |= bb._part3;
				part4 |= bb._part4;
			}
			return new BitBoard(part1, part2, part3, part4);
		}

/// Public Functions
		
		/**
		 * Are the two bitboards equal
		 * @param	other bitboard to compare
		 * @return true if they are equal
		 */
		public function equals(other:BitBoard):Boolean {
			if (other == null) {
				return false;
			} else {
				return _part1 == other._part1 && _part2 == other._part2 && _part3 == other._part3 && _part4 == other._part4;
			}
		}
		
/// Internal Functions
		
		/*
		 * returns the position (square number) of the leftmost ON bit or -1 if none.
		 * For performance, the current implementation skips half of the comparisons 
		 * and shifts per "part" when it can tell that part is empty.
		*/
		internal function leftmost():int {
			var mask:uint;
			var biton:int = 0;
			if (_part1 > 0 ) {
					mask = TOPBITHALF;
					for (biton = 0; biton < 16; biton++) {
						if ((_part1 & mask) != 0) {
							return biton;
						}
						mask >>>= 1;
					}
			}
			
			if (_part2 > 0 ) {
					mask = TOPBITHALF;
					for (biton = 0; biton < 16; biton++) {
						if ((_part2 & mask) != 0) {
							return biton + 16;
						}
						mask >>>= 1;
					}
			}
			
			if (_part3 > 0 ) {
					mask = TOPBITHALF;
					for (biton = 0; biton < 16; biton++) {
						if ((_part3 & mask) != 0) {
							return biton + 32;
						}
						mask >>>= 1;
					}
			}

			if (_part4 > 0 ) {
					mask = TOPBITHALF;
					for (biton = 0; biton < 16; biton++) {
						if ((_part4 & mask) != 0) {
							return biton + 48;
						}
						mask >>>= 1;
					}
			}

			return -1;
		}

		/**
		 * Is the bitboard non-zero?
		 * @return true if this bitboard is non zero
		 */
		internal function notZero():Boolean {
			return _part1 != 0 || _part2 != 0 || _part3 != 0 || _part4 != 0 ;
		}

		/**
		 * Bitwise NOT 
		 * @return new NOTed bitboard
		 */
		internal function not():BitBoard {
			// gew may need to AND with 0x0000FFFF or similar to keep top bits clean
			return new BitBoard(~_part1, ~_part2, ~_part3, ~_part4);
		}

		/**
		 * Bitwise AND
		 * @param	other bitboard to AND with this one
		 * @return new ANDed bitboard
		 */
		internal function and(other:BitBoard):BitBoard {
			
			return new BitBoard(_part1 & other._part1, _part2 & other._part2, _part3 & other._part3, _part4 & other._part4);
		}

		
		/**
		 * Bitwise OR
		 * @param	other Bitboard to OR with this one
		 * @return new ORed bitboard
		 */
		internal function or(other:BitBoard):BitBoard {
			return new BitBoard(_part1 | other._part1, _part2 | other._part2,_part3 | other._part3, _part4 | other._part4 );
		}

		/**
		 * Set bit on this bitboard by square number
		 * @param	i square number to set. Must be in range 0-63.
		 */
		internal function setBit(i:int):void {
			if (i < 16) {
				_part1 |= (TOPBITHALF >>> i);
				return;
			} 
			if (i < 32) {
				_part2 |= (TOPBITHALF >>> (i-16));
				return;
			} 
			if (i < 48) {
				_part3 |= (TOPBITHALF >>> (i-32));
				return;
			} 
			_part4 |= (TOPBITHALF >>> (i-48));
		}
		
		/**
		 * Create a string representation of thie Bitboard
		 * @return hexidecimal string
		 */
		internal function toString():String {
			return _part1.toString(16) +":" + _part2.toString(16);
		}
		
		/**
		 * Clear Bit at square number (0-63)
		 * @param	i square number
		 */
		internal function clearBit(i:int):void {
			if (i < 16) {
				_part1 &= ~(TOPBITHALF >>> i);
				return;
			}
			if (i < 32) {
				_part2 &= ~(TOPBITHALF >>> (i-16));
				return;
			}
			if (i < 48) {
				_part3 &= ~(TOPBITHALF >>> (i-32));
				return;
			}
			_part4 &= ~(TOPBITHALF >>> (i-48));
		}
		
		/**
		 * Make a copy 
		 * @return new bitboard copy of this one
		 */
		internal function copy():BitBoard {
			return new BitBoard(_part1, _part2, _part3, _part4);
		}
		
		/**
		 * Get a bit state for a square (0-63) as a boolean
		 * @param	index square number
		 * @return true iff the bit is set
		 */
		internal function getBit(index:uint):Boolean {
			if (index < 16) {
				return (_part1 & (TOPBITHALF >>> index)) != 0;
			}
			if (index < 32) {
				return (_part2 & (TOPBITHALF >>> (index-16))) != 0;
			}
			if (index < 48) {
				return (_part3 & (TOPBITHALF >>> (index-32))) != 0;
			}
			return (_part4 & (TOPBITHALF >>> (index-48))) != 0;
		}
	}
}