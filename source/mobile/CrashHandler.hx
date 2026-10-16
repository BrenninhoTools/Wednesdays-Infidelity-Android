package mobile;

import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class CrashHandler
{
	static var handled:Bool = false;

	public static function init()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCriticalError);
		#end
	}

	static function onUncaughtError(event:UncaughtErrorEvent)
	{
		event.preventDefault();
		event.stopImmediatePropagation();

		report(Std.string(event.error), CallStack.exceptionStack(true));
	}

	static function onCriticalError(message:Dynamic)
	{
		report(Std.string(message), CallStack.exceptionStack(true));
	}

	static function report(message:String, stack:Array<StackItem>)
	{
		if (handled)
			return;

		handled = true;

		var lines:Array<String> = [];
		for (item in stack)
		{
			switch (item)
			{
				case FilePos(_, file, line, _):
					lines.push('$file:$line');
				case Method(className, method):
					lines.push('$className.$method');
				default:
					lines.push(Std.string(item));
			}
		}

		var text:String = 'Error: $message\n\n' + lines.join('\n');
		var savedTo:String = save(text);

		if (savedTo != null)
			text += '\n\nSaved to: $savedTo';

		Application.current.window.alert(text, "Wednesday's Infidelity crashed");

		#if sys
		Sys.exit(1);
		#end
	}

	static function save(text:String):String
	{
		#if sys
		try
		{
			var folder:String = #if mobile lime.system.System.applicationStorageDirectory + 'crash/' #else './crash/' #end;
			if (!FileSystem.exists(folder))
				FileSystem.createDirectory(folder);

			var path:String = folder + 'WI_' + DateTools.format(Date.now(), '%Y-%m-%d_%H-%M-%S') + '.txt';
			File.saveContent(path, text);
			return path;
		}
		catch (e:Dynamic) {}
		#end

		return null;
	}
}
