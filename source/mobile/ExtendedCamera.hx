package mobile;

import flixel.FlxCamera;
import flixel.FlxG;

class ExtendedCamera extends FlxCamera
{
	public var sideOffset(default, null):Float = 0;

	public function new()
	{
		super();

		sideOffset = ScreenUtil.side;
		if (sideOffset > 0)
		{
			x = -sideOffset;
			setSize(ScreenUtil.fullWidth, height);
		}
	}

	override function updateInternalSpritePositions():Void
	{
		super.updateInternalSpritePositions();

		if (canvas != null && sideOffset > 0)
			canvas.x += sideOffset * totalScaleX;
	}
}
