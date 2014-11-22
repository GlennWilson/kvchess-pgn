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
	 * Holds values for simple material evaluation.
	 */
	public class Evaluate {
		public static const PAWN_VALUE:int =   100;	
		public static const KNIGHT_VALUE:int = 300;
		public static const BISHOP_VALUE:int = 300;
		public static const ROOK_VALUE:int = 500;
		public static const QUEEN_VALUE:int = 900;
	}
}