package mobile;

import flixel.util.FlxSave;

class ScreenUtil
{
	public static inline var BASE_WIDTH:Int = 1280;
	public static inline var BASE_HEIGHT:Int = 720;

	public static function isFull():Bool
	{
		#if mobile
		var save:FlxSave = new FlxSave();
		save.bind('funkin', 'ninjamuffin99');
		var full:Bool = save.data.screenStyle == 'Full';
		save.destroy();
		return full;
		#else
		return false;
		#end
	}

	public static function getGameWidth(full:Bool):Int
	{
		if (!full)
			return BASE_WIDTH;

		var ratio:Float = getAspectRatio();
		if (ratio <= BASE_WIDTH / BASE_HEIGHT)
			return BASE_WIDTH;

		return Std.int(Math.min(Math.ceil(BASE_HEIGHT * ratio), BASE_HEIGHT * 2.4));
	}

	public static function getAspectRatio():Float
	{
		#if android
		var method:Dynamic = lime.system.JNI.createStaticMethod('org/haxe/extension/ScreenUtil', 'getAspectRatio', '()F');
		if (method != null)
		{
			var ratio:Float = method();
			if (ratio > 0)
				return ratio;
		}
		#end

		var stage = openfl.Lib.current.stage;
		var width:Float = Math.max(stage.stageWidth, stage.stageHeight);
		var height:Float = Math.min(stage.stageWidth, stage.stageHeight);
		return height > 0 ? width / height : BASE_WIDTH / BASE_HEIGHT;
	}

	public static function apply(full:Bool)
	{
		#if android
		var method:Dynamic = lime.system.JNI.createStaticMethod('org/haxe/extension/ScreenUtil', 'setFullscreen', '(Z)V');
		if (method != null)
			method(full);
		#end
	}
}
