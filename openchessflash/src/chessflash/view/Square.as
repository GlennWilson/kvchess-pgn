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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.events.MouseEvent;
	
	public class Square extends Sprite {
		private var _index: uint;
		private var _color: uint;
		private var _size: uint;
		private var _board:BoardView; //parent BoardView
		private var _originalPieceFen:int;
		private var _originalPiece:BitmapData;
		private var _scaledPiece:BitmapData;
		private var _scaledBitmap:Bitmap;
		private var _highlight:Shape;
		private var _hasHighlight:Boolean;
		private static const HASHFACTOR1:int = 0x14102;
		private static const HASHFACTOR2:int = 0x5795612;
		public var _acceptClick:Boolean;
		
		private const SCALE_FACTOR:Number = 1;
		private static var _cacheScaledBitmap:Array = new Array(15);
		
/// Constructor		
		
		public function Square(index:uint, color:uint, size:uint, board:BoardView) {
			//cacheAsBitmap = true;
			_index = index;
			_color = color;
			_size = size;
			_board = board;
			drawRect(_color);
			this.width = _size;
			this.height = _size;
			addEventListener(MouseEvent.CLICK, clicked);
		}
		
/// Public Functions		
		
		public override function toString():String {
			return "Square at index=" + _index;
			
		}

/// Internal Functions		
		
		internal function setAcceptClick() : void {
			_acceptClick = true;
		}
		
		internal function clearAcceptClick() : void {
			_acceptClick = false;
		}

		internal function removeHighlight():void {
			if (_highlight != null && _hasHighlight) { // remove previous highlight
				removeChild(_highlight);
			}
			_hasHighlight = false;
		}

		internal function highlight():void {
			removeHighlight();
			if (_highlight == null) {
				_highlight = new Shape();
				_highlight.graphics.lineStyle(1, 0xFF0000, 0.5);
				_highlight.graphics.drawRect(0, 0, _size, _size);
				_highlight.graphics.lineStyle(1, 0xFFFFFF, 0.5);
				_highlight.graphics.drawRect(2, 2, _size-4, _size-4);
				_highlight.graphics.lineStyle(1, 0x000000, 0.5);
				_highlight.graphics.drawRect(3, 3, _size-6, _size-6);
				_highlight.graphics.endFill();
			}
			addChildAt(_highlight, 0); // under the piece, if any
			_hasHighlight = true;
		}
		
		internal function setPieceFen(piece:int):int {
			var oldPiece:int = _originalPieceFen;
			var pieceBMD:BitmapData = Pieces.getPieceBMDfromPiece(piece, _size);
			var oldPieceBMD:BitmapData = setPiece(pieceBMD, piece);
			return oldPiece;
		}
		
		internal function clearPiece():int {
			if (_scaledBitmap != null) {
				saveBitmapToCache(_originalPieceFen,_scaledBitmap);
				removeChild(_scaledBitmap);
				_scaledBitmap = null;
			}
			var piece:int = _originalPieceFen;
			_originalPiece = null;
			_originalPieceFen = 0;
			_scaledPiece = null;
			return piece;
		}


/// Private Functions

		private function clicked(event:MouseEvent):void {
			if (_acceptClick) {
				//tell boardView
				_board.squareClicked(_index);
			}
		}
		
		// just draw graphic rectangle
		private function drawRect(color:uint):void{
			graphics.beginFill(color);
			graphics.lineStyle( 1, color, 1);
			graphics.drawRect(0, 0, _size, _size);
			graphics.endFill();
		}

		private function setPiece(piece:BitmapData, pieceFen:int):BitmapData {
			var oldPiece:BitmapData = _originalPiece; 
			if (oldPiece != null && _scaledBitmap != null) {
				saveBitmapToCache(_originalPieceFen,_scaledBitmap);
				removeChild(_scaledBitmap);
			}
			if (piece == null) {
				_originalPiece = null;
				_scaledBitmap = null;
				_scaledPiece = null;
				return oldPiece;
			}
			_originalPiece = piece;
			_originalPieceFen = pieceFen;

			_scaledBitmap = retrieveScaledBitmapFromCache(_originalPieceFen);
			
			if (_scaledBitmap != null) {
				addChild(_scaledBitmap);
				return oldPiece;
			}

			try {
				if (piece.width != _size*SCALE_FACTOR ) { // need to scale it
					var scaleFactor:Number = _size*SCALE_FACTOR / piece.width;
					_scaledPiece = new BitmapData(_size*SCALE_FACTOR, _size*SCALE_FACTOR, true, 0x00FFFFFF);
					var scaleMatrix:Matrix = new Matrix();
					scaleMatrix.scale( scaleFactor, scaleFactor);
					_scaledPiece.draw(_originalPiece, scaleMatrix, null, null, null, true);
				} else {
					_scaledPiece = piece;
				}
				_scaledBitmap = new Bitmap(_scaledPiece);
				_scaledBitmap.x = _size * (1-SCALE_FACTOR)/2;
				_scaledBitmap.y = _size * (1-SCALE_FACTOR)/2;
				addChild(_scaledBitmap);
			} catch (error:Error) {
				// todo 
			}
			return oldPiece;
		}

		internal function saveBitmapToCache(pieceIndex:int, bitmap:Bitmap):void {
			if (_cacheScaledBitmap[pieceIndex] == null) {
				_cacheScaledBitmap[pieceIndex] = bitmap;
			}			
		}
		
		internal function retrieveScaledBitmapFromCache(pieceIndex:int): Bitmap {
			if (_cacheScaledBitmap[pieceIndex] != null) {
				var scaledBitmap:Bitmap = _cacheScaledBitmap[pieceIndex];
				_cacheScaledBitmap[pieceIndex] = null;
				return scaledBitmap;
			}
			return null;
		}

	}
}