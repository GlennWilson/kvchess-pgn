package chessflash
{
	import flash.display.Sprite;
	import flash.display.LoaderInfo;

	[SWF( backgroundColor='0x225511', frameRate='10', width='570', height='600')]
	public class Inline600 extends PgnViewer {
		public function Inline600(args:String=null) : void {
			super(true, loaderInfo, args);
		}
	}
}