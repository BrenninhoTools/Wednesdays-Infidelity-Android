package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxColor;
import openfl.display.Graphics;

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
			targetOffset.x = sideOffset;
		}
	}

	override function updateInternalSpritePositions():Void
	{
		super.updateInternalSpritePositions();

		if (canvas != null && sideOffset > 0)
			canvas.x += sideOffset * totalScaleX;
	}

	override public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0, ?graphics:Graphics):Void
	{
		if (FlxG.renderBlit || sideOffset <= 0)
		{
			super.fill(Color, BlendAlpha, FxAlpha, graphics);
			return;
		}

		final targetGraphics = (graphics == null) ? canvas.graphics : graphics;

		targetGraphics.overrideBlendMode(null);
		targetGraphics.beginFill(Color, FxAlpha);
		targetGraphics.drawRect(viewMarginLeft - sideOffset - 1, viewMarginTop - 1, viewWidth + 2, viewHeight + 2);
		targetGraphics.endFill();
	}
}
