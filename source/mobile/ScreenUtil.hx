package mobile;

import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;

class WideScaleMode extends RatioScaleMode
{
	public var wide:Bool;

	var targetWidth:Int = ScreenUtil.BASE_WIDTH;

	public function new(wide:Bool)
	{
		super();
		this.wide = wide;
	}

	override public function onMeasure(width:Int, height:Int):Void
	{
		targetWidth = ScreenUtil.getGameWidth(wide, width, height);
		ScreenUtil.resizeCameras(targetWidth);
		super.onMeasure(width, height);
	}

	override function setGlobalSize(width:Int, height:Int):Void
	{
		super.setGlobalSize(targetWidth, height);
	}
}

class ScreenUtil
{
	public static inline var BASE_WIDTH:Int = 1280;
	public static inline var BASE_HEIGHT:Int = 720;

	public static function getGameWidth(wide:Bool, stageWidth:Int, stageHeight:Int):Int
	{
		if (!wide || stageWidth <= 0 || stageHeight <= 0)
			return BASE_WIDTH;

		var ratio:Float = Math.max(stageWidth, stageHeight) / Math.min(stageWidth, stageHeight);
		if (ratio <= BASE_WIDTH / BASE_HEIGHT)
			return BASE_WIDTH;

		return Std.int(Math.min(Math.ceil(BASE_HEIGHT * ratio), BASE_HEIGHT * 2.4));
	}

	public static function resizeCameras(newWidth:Int)
	{
		if (FlxG.width == newWidth)
			return;

		var oldWidth:Int = FlxG.width;

		for (camera in FlxG.cameras.list)
		{
			if (camera != null && camera.width == oldWidth)
				camera.setSize(newWidth, camera.height);
		}
	}

	public static function apply(wide:Bool)
	{
		#if mobile
		#if android
		var method:Dynamic = lime.system.JNI.createStaticMethod('org/haxe/extension/ScreenUtil', 'setFullscreen', '(Z)V');
		if (method != null)
			method(wide);
		#end

		FlxG.scaleMode = new WideScaleMode(wide);
		#end
	}
}
