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
	
import flash.text.TextFormat;

	import flash.display.Stage;
	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;

	public class LayoutManager {

		public static const BV_MAIN:String = "Main";
		public static const BV_VARS:String = "Variation";
		public static const VERSION:String = "V2.31"; // Version String displayed

		private var _stage:Stage;
		private var _loaderInfo:LoaderInfo;
		public  static var _debug:Boolean = false;
		
		/** Default Colors  *************************************************/
		public const DEFAULT_LIGHT_COLOR:uint = 0xf4f4fF;
		public const DEFAULT_DARK_COLOR:uint = 0x0072b9;
		public const DEFAULT_BORDER_COLOR:uint = DEFAULT_LIGHT_COLOR;
		public const DEFAULT_BORDER_TEXT_COLOR:uint = 0x494949;

		/** Mode Options *************************************************/
		public var _diagramMode:Boolean;
		public var _boardOnly:Boolean;
		public var _tabMode:Boolean;
		public var _twoBoardMode:Boolean;
		public var _autoPlay:Boolean; //delay pgn loading until...
		public var _puzzle:Boolean; //puzzle/practice - human plays one side
		public var _humanPlaysWhite:Boolean; // 

		/** PGN Data *************************************************/
		public var _pgnData:String; // pgn data embedded in line
		
		/** Orientation Options *************************************************/
		public var _boardLocation:String;// not fully supported today // T, B, L, R: top, bottom, left, right
		public var _orientation:String; // H or V: horizontal or vertical
		
		/** Board Options *************************************************/
		public var _labelsTop:Boolean;
		public var _labelsBottom:Boolean;
		public var _labelsLeft:Boolean;
		public var _labelsRight:Boolean;
		public var _whiteAtBottom:Boolean;

		/** Colors  *************************************************/
		// per board
		private var _lightColor:uint;
		private var _darkColor:uint;
		private var _lightColor2:uint;
		private var _darkColor2:uint;
		private var _borderColor:uint;
		private var _borderTextColor:uint;
		private var _borderColor2:uint;
		private var _borderTextColor2:uint;

		// single instance colors
		public var _backgroundColor:uint;
		public var _scrollbarColor:uint;
		public var _headerBackgroundColor:uint;
		public var _headerForegroundColor:uint;
		public var _moveTextForegroundColor:uint;
		public var _moveTextBackgroundColor:uint;
		public var _moveTextVariationsColor:uint;
		public var _moveTextMainlineColor:uint;
		
		/** Sizing *************************************************/
		public var _squaresize:uint;
		public var _bordersize:uint;
		public var _htHeight:int;
		public var _mtheight:int;
		public var _mtvheight:int;
		public var _mtwidth:int;
		public var _mtvwidth:int;
		public var _varBtnWidth:int;
		public var _varBtnHeight:int;
		public var _scrollBarWidth:int;
		public var _adheight:int;
		public var _adwidth:int;

		/** X Y Locations *************************************************/
		public var _boardView1X:int = 2;
		public var _boardView1Y:int = 2;
		public var _boardView2X:int;
		public var _boardView2Y:int =2;
		public var _headerViewX:int = 2;
		public var _headerViewY:int;
		public var _adViewX:int = 2;
		public var _adViewY:int;
		public var _mtViewX:int = 2;
		public var _mtViewY:int;
		public var _varBtnX:int;

		/** Move Text Formats *************************************************/
		public var _defaultTextFormat:TextFormat;
		public var _defaultMoveFormat:TextFormat;
		public var _mainlineTextFormat:TextFormat;
		public var _mainlineMoveFormat:TextFormat;
		public var _variationTextFormat:TextFormat;
		public var _variationMoveFormat:TextFormat;

		public var _pieces:String;
		public var _initialMove:uint;
		
		private var _queryString:Object;
		private var _pairDict:Dictionary;
        private var _pairs:Array;
		public static var JANGAROO:Boolean;
		public var _tsize:int; // used for text size to estimate word wrap in MoveTextView
		
/// Constructor		
		
		public function LayoutManager(stage:Stage, loaderInfo:LoaderInfo, jangaroo:Boolean, queryString:String=null):void {
			_stage = stage;
			_loaderInfo = loaderInfo;
			_queryString = queryString;
			JANGAROO = jangaroo;
			parseQueryString();
			
			/** Mode Options *************************************************/
			_puzzle = getParamBoolean("puzzle", false);
			_humanPlaysWhite = getParamBoolean("humanplayswhite", true);
			_autoPlay = getParamBoolean("autoplay", false);
			_twoBoardMode = getParamBoolean("twoboards", false);
			_diagramMode = getParamBoolean("diagramonly", false);
			if (JANGAROO) {
				_tabMode = getParamBoolean("tabmode", false); // jangaroo
				_boardOnly = getParamBoolean("boardonly", true);// jangaroo
			} else {
				_tabMode = getParamBoolean("tabmode", true); // now on by default
				_boardOnly = getParamBoolean("boardonly", false);
			}
			_pieces = getParamString("pieces", "");

			_initialMove = getParamInteger("initialmove", 0);
			
			_pgnData = getParamString("pgndata", "");
			//_pgnData = getParamString("pgndata", "1. c4 f5 2. c5 f4 3. c6 f3 4. cxb7 fxg2 5. bxa8=Q (5. bxa8=R) (5. bxa8=B) (5.bxa8=N) 5... gxh1=R (5... gxh1=Q) (5... gxh1=B) (5... gxh1=N 6. Nf3 Bb7) *");
			//_pgnData = getParamString("pgndata",  "[Event \"Blitz:15'\"][Site \"Hewlett-Packard\"][Date \"2009.02.03\"][Round \"?\"][White \"Chaisson, Terry\"][Black \"1650L, Go\"][Result \"0-1\"][ECO \"B01\"][Annotator \"Chaisson,Terry\"][PlyCount \"48\"][EventDate \"2009.??.??\"][TimeControl \"900\"]{318MB, Fritz10.ctg} 1. e4 d5 2. exd5 Qxd5 3. Nc3 Qa5 4. d4 Nf6 5. Nf3 Bg4 6.Be2 Ne4 7. O-O Bxf3 8. Bxf3 Nxc3 9. bxc3 Qxc3 10. Bd2 Qxd4 {I thought I was losing now because I'm down two pawns but I am actually winning due to the threat of Bxb7 followed by Bxa8} 11. Re1 $2 Qb6 {I wondered why he moved here and then I finally saw the weak b7 pawn} 12. Rb1 $1 Qf6 13. Bxb7 e5 14. Bxa8 Nd7 15. Bc3 {I first tried to play 15.Qd5 but the computer wouldn't let me. It took me a minute to figure out that my bishop was blocking the way} Bc5 16. Bf3 Qf4 17. Qd5 Qh4 18. Bxe5 Bxf2+ 19. Kh1 Bxe1 20.g3 Bxg3 {Here I panicked. I could only see his threats and forgot where mybishop was. Bxg3 wins easily} 21. Qd2 {My game quickly falls apart after this.} Bxe5 22. Re1 O-O 23. Bc6 Rd8 24. Rxe5 Nxe5 0-1");
			//_pgnData =  getParamString("pgndata", "1. e4 d5 2. -- dxe4 3. Nc3 Bf5 4. b3 -- 5. Qe2 Nf6 * ");
			if (_pgnData != null && _pgnData.length < 2) {
				_pgnData = null;
			}
			
			if (_pgnData != null) {
				_autoPlay = true;
			}
			
			if (_diagramMode) {
				_twoBoardMode = false;
				_tabMode = false;
				_boardOnly = true;
				_autoPlay = true;
			}
			if (_boardOnly && _twoBoardMode && !_tabMode) {
				_tabMode = true;  //gotta be on to navigate
			}
			
			/** Orientation Options *************************************************/
			_orientation = getParamString("orientation", "H").charAt(0).toUpperCase(); // Horizontal
			if ("HV".indexOf(_orientation) < 0) _orientation = "V";
			_boardLocation = getParamString("boardlocation", "T").charAt(0).toUpperCase(); // TOP
			_boardLocation = "T";  // only T and L (mean the same) supported today.
			if ("TBLR".indexOf(_boardLocation) < 0) _boardLocation = "T";
			if (_orientation == "H") {
				if (_boardLocation == "T") {
					_boardLocation = "L";
				} else if (_boardLocation == "B") {
					_boardLocation = "R";
				}
			} else {
				if (_boardLocation == "L") {
					_boardLocation = "T";
				} else if (_boardLocation == "R") {
					_boardLocation = "B";
				}
			}

			/** Board Options *************************************************/
			_labelsBottom = getParamBoolean("labelsbottom", true);
			_labelsTop = getParamBoolean("labelstop", false);
			_labelsLeft = getParamBoolean("labelsleft", true);
			_labelsRight = getParamBoolean("labelsright", false);
			_whiteAtBottom = getParamBoolean("whiteatbottom", _humanPlaysWhite);

			/** Colors  *************************************************/
			_lightColor = getParamColor("light", DEFAULT_LIGHT_COLOR);
			_darkColor = getParamColor("dark", DEFAULT_DARK_COLOR);
			_lightColor2 = getParamColor("light2", _lightColor);
			_darkColor2 = getParamColor("dark2", _darkColor);
			_borderColor = getParamColor("border", DEFAULT_BORDER_COLOR);
			_borderTextColor = getParamColor("bordertext", DEFAULT_BORDER_TEXT_COLOR);
			_borderColor2 = getParamColor("border2", _borderColor);
			_borderTextColor2 = getParamColor("bordertext2", _borderTextColor);

			_backgroundColor = getParamColor("background", 0xffffff);
			_headerBackgroundColor = getParamColor("headerbackground", _darkColor);
			_headerForegroundColor = getParamColor("headerforeground", 0xFFFFFF);
			_moveTextForegroundColor = getParamColor("mtforeground", 0x000000);
			_moveTextBackgroundColor = getParamColor("mtbackground", _backgroundColor);
			_moveTextVariationsColor = getParamColor("mtvariations", 0xFF0000);
			_moveTextMainlineColor = getParamColor("mtmainline", 0x000000);
			_scrollbarColor = getParamColor("scrollbar", _headerBackgroundColor);
			
			/** Sizing *************************************************/
			var w:uint = stage.stageWidth - 4;
			var h:uint = stage.stageHeight - 4;
			
			var bh:int = h;
			var bw:int = w;
			if (_twoBoardMode && !_boardOnly) { // two board plus movetext
				bh = h / 2; // half for board, half for movetext or the other board
				bw = w / 2; // half for board, half for movetext or the other board
			} else if (_twoBoardMode && _boardOnly ) { // two boards only
				if (_orientation == "V") {
					bh = h / 2;
				} else {
					bw = w / 2;
				}
			} else if (!_twoBoardMode && !_boardOnly) { // One board plus movetext
				if (_orientation == "V") {
					bh = h * .6;
				} else {
					bw = w / 2;
				}
			} else if (!_twoBoardMode && _boardOnly) { // One board only
			}

			if (_tabMode) { 
				bw = bw * .75; //take out width of tab variation btns
			}
			var m:uint = Math.min(bw - 4, bh * 0.945 - 4); //adjust for height of buttons below board 
			_squaresize = m / 9.1;
			_bordersize = _squaresize / 2;
			
			if (_orientation == "V") {
				_mtheight = h - boardHeight();
				_mtwidth = w - 2;
				_adwidth = _mtwidth;
			} else {
				_mtheight = h;
				_mtwidth = w - boardWidth(true);
				_adwidth = _mtwidth;
				}
			
			// text size base for move text text field
			var tsize:int =  (_mtheight < _mtwidth ? _mtheight : _mtwidth) / 25;
			if (tsize < 12) tsize = 12;
			if (tsize > 16) tsize = 16;

			_htHeight = (tsize * 1.3) * 4;
			_adheight = _htHeight / 3;

			_mtvheight = _mtheight - _htHeight - _adheight;
			
			_varBtnWidth = 3 * _squaresize;
			_varBtnHeight = .9 * _squaresize;
			
			/** X Y Locations *************************************************/
			if (_boardLocation == "L" || _boardLocation == "T") {
				_boardView1X = 2;
				_boardView1Y = 2;

				if (_orientation == "V") {
					_boardView2X = boardWidth(false) + _boardView1X;
					_boardView2Y = 2;
				} else {
					_boardView2X = 2; 
					_boardView2Y = boardHeight() + _boardView1Y;
				}

				if (_orientation == "V") {
					_headerViewX = 3;
					_headerViewY = h - _mtheight;
					_adViewX = 3;
					_adViewY = _headerViewY + _htHeight;
					_mtViewY = _adViewY + _adheight;
					_mtViewX = 3;
					if (_twoBoardMode) {
						_varBtnX = _boardView2X + boardWidth(false)   - _squaresize*.75;
					} else {
						_varBtnX = boardWidth(false)    - _squaresize*.75;
					}
				} else {
					_headerViewX = w - _mtwidth;
					_headerViewY = 2;
					_adViewX = w - _mtwidth;
					_adViewY = _headerViewY + _htHeight;
					_mtViewY = _adViewY + _adheight;
					_mtViewX = w - _mtwidth;
					_varBtnX = boardWidth(false)    - _squaresize*.75;
				}
			} else {  // board to right or bottom
				_headerViewX = 3;
				_headerViewY = 2;

				if (_orientation == "V") {
					_boardView1X = 2;
					_boardView1Y = h - boardHeight(); 
					_boardView2X = boardWidth(false) + _boardView1X;
					_boardView2Y = _boardView1Y;
				} else {
					_boardView1X = w - boardWidth(true) + 8;
					_boardView1Y = 2;
					_boardView2X = _boardView1X; 
					_boardView2Y = boardHeight() + _boardView1Y;
				}

				if (_orientation == "V") {
					_adViewX = 3;
					_adViewY = _headerViewY + _htHeight;
					_mtViewY = _adViewY + _adheight;
					_mtViewX = 3;
					if (_twoBoardMode) {
						_varBtnX = boardWidth(false) + _boardView2X    - _squaresize*.75;
					} else {
						_varBtnX = boardWidth(false)    - _squaresize*.75;
					}
				} else {
					_adViewX = 3;
					_adViewY = _headerViewY + _htHeight;
					_mtViewY = _adViewY + _adheight;
					_mtViewX = 3;
					_varBtnX = boardWidth(false) + _boardView2X - _squaresize*.75;
				}
				
			}
			
			if (_twoBoardMode && _boardOnly ) { // fixup for special case
				// reverses usual sense of horz and vert
				_boardView1X = 2;
				_boardView1Y = 2;

				if (_orientation == "H") {
					_boardView2X = boardWidth(false) + _boardView1X;
					_boardView2Y = 2;
					_varBtnX = boardWidth(false) + _boardView2X    - _squaresize*.75;
				} else {
					_boardView2X = 2; 
					_boardView2Y = boardHeight() + _boardView1Y;
					_varBtnX = boardWidth(false)    - _squaresize*.75;
				}
			}
			
			_scrollBarWidth = _squaresize * .7;
			_scrollBarWidth = _scrollBarWidth > 21 ? 21 : _scrollBarWidth;
			_scrollBarWidth = _scrollBarWidth < 11 ? 11 : _scrollBarWidth;
			
			_mtvwidth = _mtwidth - _scrollBarWidth; // reduce by scrollbar width
			
			/** Move Text Formats *************************************************/
			_defaultTextFormat = new TextFormat();
			_defaultTextFormat.bold = false;
			_defaultTextFormat.color = _moveTextForegroundColor;
			_defaultTextFormat.font = "arial";
			_defaultTextFormat.size = tsize;
			_defaultTextFormat.italic = false;

			_defaultMoveFormat = new TextFormat();
			_defaultMoveFormat.bold = true;
			_defaultMoveFormat.color = _moveTextForegroundColor;
			_defaultMoveFormat.font = "arial";
			_defaultMoveFormat.size = tsize;
			_defaultMoveFormat.italic = false;

			_mainlineTextFormat = new TextFormat();
			_mainlineTextFormat.color = _moveTextMainlineColor;
			_mainlineTextFormat.bold = false;
			_mainlineTextFormat.italic = false;
			_mainlineTextFormat.font = "arial";
			_mainlineTextFormat.size = tsize * 1.2;
			_tsize = tsize * 1.2;
			
			_mainlineMoveFormat = new TextFormat();
			_mainlineMoveFormat.color = _moveTextMainlineColor;
			_mainlineMoveFormat.bold = true;
			_mainlineMoveFormat.italic = false;
			_mainlineMoveFormat.font = "arial";
			_mainlineMoveFormat.size = tsize * 1.2;

			_variationTextFormat = new TextFormat();
			_variationTextFormat.bold = false;
			_variationTextFormat.color = _moveTextVariationsColor;
			_variationTextFormat.italic = false;
			_variationTextFormat.font = "arial";
			_variationTextFormat.size = tsize * 1.1;

			_variationMoveFormat = new TextFormat();
			_variationMoveFormat.bold = true;
			_variationMoveFormat.color = _moveTextVariationsColor;
			_variationMoveFormat.italic = false;
			_variationMoveFormat.font = "arial";
			_variationMoveFormat.size = tsize * 1.1;
		}

/// Public Functions	
		
//		public static function xtrace(msg:Object):void {
//			if (LayoutManager._debug) {
//				fscommand("trace", msg.toString());
//			}
//		} 

		public function getVarBtnY(index:int):int {
			if (_twoBoardMode) {
				return index * _squaresize + _squaresize / 2 + _boardView2Y;
			}
			return index * _squaresize + _squaresize / 2 + _boardView1Y;
		}
		
		public function getLightColor(name:String):uint {
			if (name == BV_MAIN) return _lightColor;
			return _lightColor2;
		}
		
		public function getDarkColor(name:String):uint {
			if (name == BV_MAIN) return _darkColor;
			return _darkColor2;
		}

		public function getBorderColor(name:String):uint {
			if (name == BV_MAIN) return _borderColor;
			return _borderColor2;
		}

		public function getBorderTextColor(name:String):uint {
			if (name == BV_MAIN) return _borderTextColor;
			return _borderTextColor2;
		}
		
		public function getVarBtnColorBackground():uint {
			if (_twoBoardMode) return getBorderColor(BV_VARS);
			return getBorderColor(BV_MAIN);
		}

		public function getVarBtnColorForeground():uint {
			if (_twoBoardMode) return getBorderTextColor(BV_VARS);
			return getBorderTextColor(BV_MAIN);
		}

		public function getParamColor(name:String, defaultColor:uint):uint {
			var color:Number = Number.NaN;

			//var paramObj:Object = LoaderInfo(_loaderInfo).parameters;
			var paramColor:String = getLoaderOrQueryValue(name);

			if (paramColor != null) {
				if (paramColor.toUpperCase().indexOf("0X") != 0) paramColor = "0x" + paramColor;
				color = parseInt(paramColor);
			} 
			if (isNaN(color)) {
				color = defaultColor;
			}
			return color;
		}

		public function getParamBoolean(name:String, defaultValue:Boolean):Boolean {
			var bool:Boolean = defaultValue;			
			
			//var paramObj:Object = LoaderInfo(_loaderInfo).parameters;
			var paramBoolean:String = getLoaderOrQueryValue(name);

			if (paramBoolean != null) {
				var param:String = paramBoolean.toUpperCase();
				if (param == "TRUE" || param=="1") {
					bool = true;
				} else {
					bool = false;
				}
			} 
			return bool;
		}

		
		public function getParamInteger(name:String, defaultValue:int):int {
			var integer:int = defaultValue;
			
			//var paramObj:Object = LoaderInfo(_loaderInfo).parameters;
			var paramInteger:String = getLoaderOrQueryValue(name);
			
			if (paramInteger != null) {
				integer = parseInt(paramInteger);
				if (isNaN(integer)) {
					integer = defaultValue;
				}
			}
 
			return integer;
		}

		public function getParamString(name:String, defaultValue:String):String {
			var param:String = defaultValue;

			//var paramObj:Object = LoaderInfo(_loaderInfo).parameters;
			var paramString:String = getLoaderOrQueryValue(name);

			if (paramString != null) {
				param = paramString;
			} 
			return param;
		}

/// Private Functions		
		
		private function boardWidth(withTab:Boolean):int { 
			if (_tabMode && withTab) return _squaresize * 12.5 + 4;
			return _squaresize * 9.5 + 4;
		}
		
		private function boardHeight():int { 
			return _squaresize * 10 + 4;
		}
		
		private function getLoaderOrQueryValue(name:String) : String {
			// loader value takes precedence if present
			var value:String = getLoaderValue(name);
			if (value == null) {
				value = getQueryValue(name);
			}
			return value;
		}
		
		private function getLoaderValue(name:String) : String {
			if (_loaderInfo == null) {
				return null;
			}
			var paramObj:Object = LoaderInfo(_loaderInfo).parameters;
			var paramVal:Object = paramObj[name];
			if (paramVal != null) {
				return paramVal.toString();
			}
			return null;
		}

		private function getQueryValue(name:String):String {
			if (_pairDict == null) {
				return null;
			}
            return _pairDict[name];
        }
		
		private function parseQueryString():void {
			if (_queryString == null) {
				return;
			}
			
            _pairDict = new Dictionary(true);
            _pairs = _queryString.split("?")[1].split("&");
			
            var pairName:String;
            var pairValue:String;
           
            for (var i:int = 0; i <_pairs.length; i++)
            {
                pairName = _pairs[i].split("=")[0];
                pairValue = _pairs[i].split("=")[1];
                _pairDict[pairName] = unescape(pairValue);
            }
		}

	}
}