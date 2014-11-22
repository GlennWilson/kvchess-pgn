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
package chessflash.view {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import chessflash.engine.Piece;

		public class Pieces {
		
		[Embed(source = '../../../lib/b_bishop.png')]
		private static var BLACK_BISHOP:Class;
		private static const BBBM:Bitmap = new BLACK_BISHOP();
		public static const BB:BitmapData = BBBM.bitmapData;
		
		[Embed(source = '../../../lib/b_king.png')]
		private static var BLACK_KING:Class;
		private static const BKBM:Bitmap = new BLACK_KING();
		public static const BK:BitmapData = BKBM.bitmapData;

		[Embed(source = '../../../lib/b_knight.png')]
		private static var BLACK_KNIGHT:Class;
		private static const BNBM:Bitmap = new BLACK_KNIGHT();
		public static const BN:BitmapData = BNBM.bitmapData;

		[Embed(source = '../../../lib/b_pawn.png')]
		private static var BLACK_PAWN:Class;
		private static const BPBM:Bitmap = new BLACK_PAWN();
		public static const BP:BitmapData = BPBM.bitmapData;

		[Embed(source = '../../../lib/b_queen.png')]
		private static var BLACK_QUEEN:Class;
		private static const BQBM:Bitmap = new BLACK_QUEEN();
		public static const BQ:BitmapData = BQBM.bitmapData;

		[Embed(source = '../../../lib/b_rook.png')]
		private static var BLACK_ROOK:Class;
		private static const BRBM:Bitmap = new BLACK_ROOK();
		public static const BR:BitmapData = BRBM.bitmapData;
		
		[Embed(source = '../../../lib/w_bishop.png')]
		private static var WHITE_BISHOP:Class;
		private static const WBBM:Bitmap = new WHITE_BISHOP();
		public static const WB:BitmapData = WBBM.bitmapData;
		
		[Embed(source = '../../../lib/w_king.png')]
		private static var WHITE_KING:Class;
		private static const WKBM:Bitmap = new WHITE_KING();
		public static const WK:BitmapData = WKBM.bitmapData;
		
		[Embed(source = '../../../lib/w_knight.png')]
		private static var WHITE_KNIGHT:Class;
		private static const WNBM:Bitmap = new WHITE_KNIGHT();
		public static const WN:BitmapData = WNBM.bitmapData;

		[Embed(source = '../../../lib/w_pawn.png')]
		private static var WHITE_PAWN:Class;
		private static const WPBM:Bitmap = new WHITE_PAWN();
		public static const WP:BitmapData = WPBM.bitmapData;

		[Embed(source = '../../../lib/w_queen.png')]
		private static var WHITE_QUEEN:Class;
		private static const WQBM:Bitmap = new WHITE_QUEEN();
		public static const WQ:BitmapData = WQBM.bitmapData;

		[Embed(source = '../../../lib/w_rook.png')]
		private static var WHITE_ROOK:Class;
		private static const WRBM:Bitmap = new WHITE_ROOK();
		public static const WR:BitmapData = WRBM.bitmapData;

		// 2x
				[Embed(source = '../../../lib/b_bishop_2x.png')]
		private static var BLACK_BISHOP_2x:Class;
		private static const BBBM_2x:Bitmap = new BLACK_BISHOP_2x();
		public static const BB_2x:BitmapData = BBBM_2x.bitmapData;
		
		[Embed(source = '../../../lib/b_king_2x.png')]
		private static var BLACK_KING_2x:Class;
		private static const BKBM_2x:Bitmap = new BLACK_KING_2x();
		public static const BK_2x:BitmapData = BKBM_2x.bitmapData;

		[Embed(source = '../../../lib/b_knight_2x.png')]
		private static var BLACK_KNIGHT_2x:Class;
		private static const BNBM_2x:Bitmap = new BLACK_KNIGHT_2x();
		public static const BN_2x:BitmapData = BNBM_2x.bitmapData;

		[Embed(source = '../../../lib/b_pawn_2x.png')]
		private static var BLACK_PAWN_2x:Class;
		private static const BPBM_2x:Bitmap = new BLACK_PAWN_2x();
		public static const BP_2x:BitmapData = BPBM_2x.bitmapData;

		[Embed(source = '../../../lib/b_queen_2x.png')]
		private static var BLACK_QUEEN_2x:Class;
		private static const BQBM_2x:Bitmap = new BLACK_QUEEN_2x();
		public static const BQ_2x:BitmapData = BQBM_2x.bitmapData;

		[Embed(source = '../../../lib/b_rook_2x.png')]
		private static var BLACK_ROOK_2x:Class;
		private static const BRBM_2x:Bitmap = new BLACK_ROOK_2x();
		public static const BR_2x:BitmapData = BRBM_2x.bitmapData;
		
		[Embed(source = '../../../lib/w_bishop_2x.png')]
		private static var WHITE_BISHOP_2x:Class;
		private static const WBBM_2x:Bitmap = new WHITE_BISHOP_2x();
		public static const WB_2x:BitmapData = WBBM_2x.bitmapData;
		
		[Embed(source = '../../../lib/w_king_2x.png')]
		private static var WHITE_KING_2x:Class;
		private static const WKBM_2x:Bitmap = new WHITE_KING_2x();
		public static const WK_2x:BitmapData = WKBM_2x.bitmapData;
		
		[Embed(source = '../../../lib/w_knight_2x.png')]
		private static var WHITE_KNIGHT_2x:Class;
		private static const WNBM_2x:Bitmap = new WHITE_KNIGHT_2x();
		public static const WN_2x:BitmapData = WNBM_2x.bitmapData;

		[Embed(source = '../../../lib/w_pawn_2x.png')]
		private static var WHITE_PAWN_2x:Class;
		private static const WPBM_2x:Bitmap = new WHITE_PAWN_2x();
		public static const WP_2x:BitmapData = WPBM_2x.bitmapData;

		[Embed(source = '../../../lib/w_queen_2x.png')]
		private static var WHITE_QUEEN_2x:Class;
		private static const WQBM_2x:Bitmap = new WHITE_QUEEN_2x();
		public static const WQ_2x:BitmapData = WQBM_2x.bitmapData;

		[Embed(source = '../../../lib/w_rook_2x.png')]
		private static var WHITE_ROOK_2x:Class;
		private static const WRBM_2x:Bitmap = new WHITE_ROOK_2x();
		public static const WR_2x:BitmapData = WRBM_2x.bitmapData;

		// big
		/* Temporary (?) remove big icons -- 1) are they really needed 2) what is memory impact
		[Embed(source = '../../../lib/b_bishop_big.png')]
		private static var BLACK_BISHOP_big:Class;
		private static const BBBM_big:Bitmap = new BLACK_BISHOP_big();
		public static const BB_big:BitmapData = BBBM_big.bitmapData;
		
		[Embed(source = '../../../lib/b_king_big.png')]
		private static var BLACK_KING_big:Class;
		private static const BKBM_big:Bitmap = new BLACK_KING_big();
		public static const BK_big:BitmapData = BKBM_big.bitmapData;

		[Embed(source = '../../../lib/b_knight_big.png')]
		private static var BLACK_KNIGHT_big:Class;
		private static const BNBM_big:Bitmap = new BLACK_KNIGHT_big();
		public static const BN_big:BitmapData = BNBM_big.bitmapData;

		[Embed(source = '../../../lib/b_pawn_big.png')]
		private static var BLACK_PAWN_big:Class;
		private static const BPBM_big:Bitmap = new BLACK_PAWN_big();
		public static const BP_big:BitmapData = BPBM_big.bitmapData;

		[Embed(source = '../../../lib/b_queen_big.png')]
		private static var BLACK_QUEEN_big:Class;
		private static const BQBM_big:Bitmap = new BLACK_QUEEN_big();
		public static const BQ_big:BitmapData = BQBM_big.bitmapData;

		[Embed(source = '../../../lib/b_rook_big.png')]
		private static var BLACK_ROOK_big:Class;
		private static const BRBM_big:Bitmap = new BLACK_ROOK_big();
		public static const BR_big:BitmapData = BRBM_big.bitmapData;
		
		[Embed(source = '../../../lib/w_bishop_big.png')]
		private static var WHITE_BISHOP_big:Class;
		private static const WBBM_big:Bitmap = new WHITE_BISHOP_big();
		public static const WB_big:BitmapData = WBBM_big.bitmapData;
		
		[Embed(source = '../../../lib/w_king_big.png')]
		private static var WHITE_KING_big:Class;
		private static const WKBM_big:Bitmap = new WHITE_KING_big();
		public static const WK_big:BitmapData = WKBM_big.bitmapData;
		
		[Embed(source = '../../../lib/w_knight_big.png')]
		private static var WHITE_KNIGHT_big:Class;
		private static const WNBM_big:Bitmap = new WHITE_KNIGHT_big();
		public static const WN_big:BitmapData = WNBM_big.bitmapData;

		[Embed(source = '../../../lib/w_pawn_big.png')]
		private static var WHITE_PAWN_big:Class;
		private static const WPBM_big:Bitmap = new WHITE_PAWN_big();
		public static const WP_big:BitmapData = WPBM_big.bitmapData;

		[Embed(source = '../../../lib/w_queen_big.png')]
		private static var WHITE_QUEEN_big:Class;
		private static const WQBM_big:Bitmap = new WHITE_QUEEN_big();
		public static const WQ_big:BitmapData = WQBM_big.bitmapData;

		[Embed(source = '../../../lib/w_rook_big.png')]
		private static var WHITE_ROOK_big:Class;
		private static const WRBM_big:Bitmap = new WHITE_ROOK_big();
		public static const WR_big:BitmapData = WRBM_big.bitmapData;
*/
		public static function getPieceBMDfromPiece(piece:int, size:int): BitmapData {
			if (size < 50) {
				switch (piece) {
					case Piece.BPAWN: return BP;
					case Piece.BROOK: return BR;
					case Piece.BKNIGHT: return BN;
					case Piece.BBISHOP: return BB;
					case Piece.BQUEEN : return BQ;
					case Piece.BKING : return BK;
					case Piece.WPAWN : return WP;
					case Piece.WROOK : return WR;
					case Piece.WKNIGHT : return WN;
					case Piece.WBISHOP : return WB;
					case Piece.WQUEEN : return WQ;
					case Piece.WKING : return WK;
				}
				return null;
			} 
			
//			if (size < 84) {
				switch (piece) {
					case Piece.BPAWN: return BP_2x;
					case Piece.BROOK: return BR_2x;
					case Piece.BKNIGHT: return BN_2x;
					case Piece.BBISHOP: return BB_2x;
					case Piece.BQUEEN : return BQ_2x;
					case Piece.BKING : return BK_2x;
					case Piece.WPAWN : return WP_2x;
					case Piece.WROOK : return WR_2x;
					case Piece.WKNIGHT : return WN_2x;
					case Piece.WBISHOP : return WB_2x;
					case Piece.WQUEEN : return WQ_2x;
					case Piece.WKING : return WK_2x;
				}
				return null;
//			}
/*	Temporary (?) remove big icons -- 1) are they really needed 2) what is memory impact		
				switch (piece) {
					case Piece.BPAWN: return BP_big;
					case Piece.BROOK: return BR_big;
					case Piece.BKNIGHT: return BN_big;
					case Piece.BBISHOP: return BB_big;
					case Piece.BQUEEN : return BQ_big;
					case Piece.BKING : return BK_big;
					case Piece.WPAWN : return WP_big;
					case Piece.WROOK : return WR_big;
					case Piece.WKNIGHT : return WN_big;
					case Piece.WBISHOP : return WB_big;
					case Piece.WQUEEN : return WQ_big;
					case Piece.WKING : return WK_big;
				}
				return null;
*/
		}
	}
}