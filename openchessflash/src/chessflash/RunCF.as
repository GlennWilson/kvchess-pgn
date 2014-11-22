/*
Temporary copy from jooflash repo:
Well I just tried to use multiple stages with ChessFlash on one HTML page, and after two small fixed, it actually seems to work!
Because I don't want to release jangaroo-libs again right now, and the fix is in the bootstrap class "Run", you can copy the latest version of that class from Github:
https://github.com/CoreMedia/jangaroo-libs/blob/e1b20b1c13b82fbf4a424333f25597f3f90cf05c/jooflash/src/main/joo/joo/flash/Run.as
To avoid clashes with joo.flash.Run that comes with JooFlash, you should move the copy to another package (e.g. "chessflash.joo.flash") and then use your updated version of "Run" to start ChessFlash (I didn't test that part, but it should work).
It is then possible to load jangaroo-application-all.js on the main page and start the application multiple times with different stage ids and different params:

<div id="stage1">Loading stage 1...</div>
<div id="stage2">Loading stage 2...</div>
<script type="text/javascript" src="joo/jangaroo-application-all.js"></script>
<script>
  joo.classLoader.run("chessflash.joo.flash.Run", "stage1", "chessflash.Inline400", { ... });
  joo.classLoader.run("chessflash.joo.flash.Run", "stage2", "chessflash.Inline400", { ... });
</script>

Have fun,

-Frank-
*/
package chessflash {
import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.Stage;

import flash.events.Event;
import flash.utils.getDefinitionByName;

import joo.DynamicClassLoader;
import joo.JooClassDeclaration;
import joo.flash.RenderLoop;

public class RunCF {

  //noinspection JSFieldCanBeLocal
  private static var renderLoop:joo.flash.RenderLoop = new RenderLoop();

  public static function main(id : String, primaryDisplayObjectClassName : String,
                              parameters : Object = null,
                              widthStr : String = null, heightStr : String = null) : void {
    var classLoader:DynamicClassLoader = DynamicClassLoader.INSTANCE;
    classLoader.import_(primaryDisplayObjectClassName);
    classLoader.complete(function() : void {
      if (classLoader.debug) {
        trace("[INFO] Loaded Flash main class " + primaryDisplayObjectClassName + ".");
      }
      var primaryDisplayObjectClass : Object = getDefinitionByName(primaryDisplayObjectClassName);
      var cd:JooClassDeclaration = primaryDisplayObjectClass['$class'];
      var metadata:Object = cd.metadata;
      var swf:Object = {};
      var metadataSwf:Object = metadata['SWF'];
      if (metadataSwf) {
        for (var m:String in metadataSwf) {
          swf[m] = metadataSwf[m];
        }
      }
      if (widthStr) {
        swf.width = widthStr;
      }
      if (heightStr) {
        swf.height = heightStr;
      }
      var stage : Stage = new Stage(id, swf);
      // use Jangaroo tricks to add the DisplayObject to the Stage before its constructor is called:
      var displayObject:DisplayObject = DisplayObject(new cd.Public());
      stage.internalAddChildAt(displayObject, 0);
      var loaderInfo:LoaderInfo = new LoaderInfo();
      if (parameters) {
        for (var key:String in parameters) {
          loaderInfo.parameters[key] = parameters[key];
        }
      }
      displayObject['loaderInfo'] = loaderInfo;
      cd.constructor_.call(displayObject);
      displayObject.broadcastEvent(new Event(Event.ADDED_TO_STAGE, false, false));
      renderLoop.addStage(stage);
    });
  }

}
}