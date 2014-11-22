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
	public interface Controller {

/// Used by MoveTextView
		/**
		 * Notify the Controller that the user has clicked / selected Pgn Text beginning at
		 * the character position index.  This is used to be able to change the view and board 
		 * state to the move text clicked / selected by user.
		 * 
		 * @param	index Selected character index in the PgnText
		 */
		function selectMoveText(index:int): void;

/// Used by BoardView
		/**
		 * What is the next move in the forward direction?
		 * Also indicates an interest in moving forward and may trigger
		 * related actions such as scrolling text, variation tabs, etc.
		 * Generally followed by execute(move, board, autoMove).
		 * @param	board the board to get the next move for
		 * @return the move
		 */
		function moveForward(board:BoardView):int;

		/**
		 * What is the next move in the backward direction?
		 * Also indicates an interest in moving backward and may trigger
		 * related actions such as scrolling text, variation tabs, etc.
		 * Generally followed by takeback(move, board).
		 * @param	board the board to get the next move for
		 * @return the move
		 */
		function moveBackward(board:BoardView):int;
		
		/**
		 * Make the move on the board.  If autoMove, may result in, for example, arrows
		 * displayed with the moves so the user can easier identify the moves made
		 * and multiple automoves may be queued with a time delay in between.
		 * @param	move move to play
		 * @param	board board to play it on
		 * @param	autoMove are we automoving?
		 */
		function execute(move:int, board:BoardView, autoMove:Boolean):void;

		/**
		 * UnMake the move on the board.
		 * @param	move move to play
		 * @param	board board to play it on
		 */
		function takeback(move:int, board:BoardView):void;
		
//		/**
//		 * Is sound muted?
//		 * @return muted state
//		 */
//		function isMuted():Boolean;
		
//		/**
//		 * Flipsound muted state.
//		 * @return new muted state
//		 */
//		function flipMuted():Boolean;
		
	}
}