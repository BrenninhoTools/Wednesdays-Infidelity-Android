package mobile;

import flixel.FlxCamera;
import flixel.FlxG;

class WideCamera extends FlxCamera
{
	public var zoomMultiplier(default, set):Float = 1;

	public function new()
	{
		super();
		if (ScreenUtil.side > 0)
		{
			ScreenUtil.extendCamera(this);
			zoomMultiplier = ScreenUtil.fullWidth / FlxG.width;
		}
	}

	function set_zoomMultiplier(value:Float):Float
	{
		zoomMultiplier = value;
		setScale(zoom * zoomMultiplier, zoom * zoomMultiplier);
		return value;
	}

	override function set_zoom(value:Float):Float
	{
		zoom = (value == 0) ? FlxCamera.defaultZoom : value;
		setScale(zoom * zoomMultiplier, zoom * zoomMultiplier);
		return zoom;
	}
}
