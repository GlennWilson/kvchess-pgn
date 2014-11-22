-- AsUnit --

To run and create the AsUnit tests with ChessFlash, add the AsUnit as3 Framework source 
to this directory. The project will build and run without AsUnit, but AsUnit is required 
to execute the unit tests.

Download AsUnit-Framework-20071011.zip (or newer) from http://sourceforge.net/projects/asunit
Copy the asunit folder (under as3) to this directory.

With AsUnit added, the FlashDevelop project tree structure should look something like:

ChessFlash (AS3)
  asunit
    asunit
      errors
	  framework
	  runner
	  textui
	  util
	  readme.txt (this file).
  bin (created when you build)
  lib
  src
    chessflash
	  ...
  test
    chessflash
       ...
	  
Of course, AsUnit may be added to your project locally in other ways.  The above is one approach.

-- Optional AsUnit Code Change --

Note: in the asunit class asunit\textui\ResultPrinter.as I make the following change for better 
error reporting:

From:
		protected function printDefectHeader(booBoo:TestFailure, count:int):void {
			// I feel like making this a println, then adding a line giving the throwable a chance to print something
			// before we get to the stack trace.
			var startIndex:uint = textArea.text.length;
			println(count + ") " + booBoo.failedTest());
			var endIndex:uint = textArea.text.length;

			var format:TextFormat = textArea.getTextFormat();
			format.bold = true;

			// GROSS HACK because of bug in flash player - TextField isn't accepting formats...
			setTimeout(onFormatTimeout, 1, format, startIndex, endIndex);
		}

To (added the line with //gew):
		protected function printDefectHeader(booBoo:TestFailure, count:int):void {
			// I feel like making this a println, then adding a line giving the throwable a chance to print something
			// before we get to the stack trace.
			var startIndex:uint = textArea.text.length;
			println(count + ") " + booBoo.failedTest());
			println("\t" + booBoo.thrownException()); //gew
			var endIndex:uint = textArea.text.length;

			var format:TextFormat = textArea.getTextFormat();
			format.bold = true;

			// GROSS HACK because of bug in flash player - TextField isn't accepting formats...
			setTimeout(onFormatTimeout, 1, format, startIndex, endIndex);
		}

