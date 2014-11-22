package chessflash
{
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	
	[SWF( backgroundColor='0x225511', frameRate='10', width='370', height='400')]
	public class Inline400 extends PgnViewer {
		public function Inline400(args:String=null) : void {
			super(true, loaderInfo, args);
		}
	}
}