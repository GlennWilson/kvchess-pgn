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
	 * Representations of Pieces, both generic (PAWN) and with color (WPAWN).
	 */
	public class Piece {
		public static const PAWN:int = 1;
		public static const KNIGHT:int = 2;
		public static const BISHOP:int = 3;
		public static const ROOK:int = 4;
		public static const QUEEN:int = 5;
		public static const KING:int = 6;

		public static const WPAWN:int = 1;
		public static const WKNIGHT:int = 2;
		public static const WBISHOP:int = 3;
		public static const WROOK:int = 4;
		public static const WQUEEN:int = 5;
		public static const WKING:int = 6;
		
		public static const BPAWN:int = 9;
		public static const BKNIGHT:int = 10;
		public static const BBISHOP:int = 11;
		public static const BROOK:int = 12;
		public static const BQUEEN:int = 13;
		public static const BKING:int = 14;

		public static function pieceFromChar(piece:String) : int {
			return "PNBRQK".indexOf(piece) + 1; // 0-6
		}
	}
}