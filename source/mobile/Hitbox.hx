package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.display.Shape;
import openfl.geom.Matrix;

class HitboxHint extends FlxSprite
{
	public var isPressed:Bool = false;
	public var wasPressed:Bool = false;

	var baseAlpha:Float;
	var pressedAlpha:Float;
	var fadeTween:FlxTween;

	public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, invisible:Bool)
	{
		super(x, y);

		loadGraphic(createGraphic(width, height, color));
		scrollFactor.set();
		antialiasing = false;

		baseAlpha = invisible ? 0 : 0.12;
		pressedAlpha = invisible ? 0 : 0.45;
		alpha = baseAlpha;
	}

	static function createGraphic(width:Int, height:Int, color:FlxColor):BitmapData
	{
		var shape:Shape = new Shape();
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(width, height, 0, 0, 0);

		var border:Int = 6;
		shape.graphics.beginFill(color.rgb, 1);
		shape.graphics.drawRect(0, 0, width, height);
		shape.graphics.drawRect(border, border, width - border * 2, height - border * 2);
		shape.graphics.endFill();

		shape.graphics.beginGradientFill(GradientType.RADIAL, [color.rgb, color.rgb], [0, 0.6], [60, 255], matrix);
		shape.graphics.drawRect(border, border, width - border * 2, height - border * 2);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(width, height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	public function setPressed(value:Bool)
	{
		wasPressed = isPressed;
		isPressed = value;

		if (isPressed != wasPressed && pressedAlpha > 0)
		{
			if (fadeTween != null)
				fadeTween.cancel();

			fadeTween = FlxTween.tween(this, {alpha: isPressed ? pressedAlpha : baseAlpha}, isPressed ? 0.05 : 0.15);
		}
	}

	override function destroy()
	{
		if (fadeTween != null)
			fadeTween.cancel();
		fadeTween = null;
		super.destroy();
	}
}

class Hitbox extends FlxTypedSpriteGroup<HitboxHint>
{
	static final LANE_COLORS:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
	static final DODGE_COLOR:FlxColor = 0xFFFFFF00;

	public var lanes:Array<HitboxHint> = [];
	public var dodgeHint:HitboxHint;
	public var hitboxCamera:FlxCamera;
	public var excludeObject:FlxSprite;

	public function new(?camera:FlxCamera, withDodge:Bool = false)
	{
		super();

		hitboxCamera = camera;

		var invisible:Bool = data.ClientPrefs.invisibleHitbox;
		var laneWidth:Int = Std.int(FlxG.width / 4);
		var dodgeHeight:Int = withDodge ? Std.int(FlxG.height * 0.25) : 0;
		var laneHeight:Int = FlxG.height - dodgeHeight;

		for (i in 0...4)
		{
			var hint = new HitboxHint(laneWidth * i, dodgeHeight, laneWidth, laneHeight, LANE_COLORS[i], invisible);
			lanes.push(hint);
			add(hint);
		}

		if (withDodge)
		{
			dodgeHint = new HitboxHint(0, 0, FlxG.width, dodgeHeight, DODGE_COLOR, invisible);
			add(dodgeHint);
		}

		scrollFactor.set();

		if (camera != null)
			cameras = [camera];

		FlxG.signals.preUpdate.add(updateHints);
	}

	function updateHints()
	{
		var blocked:Bool = excludeObject != null && excludeObject.exists && TouchUtil.pressedOn(excludeObject, hitboxCamera);

		for (hint in members)
		{
			if (hint != null)
				hint.setPressed(visible && !(blocked && hint == dodgeHint) && TouchUtil.pressedOn(hint, hitboxCamera));
		}
	}

	public function pressed(lane:Int):Bool
	{
		return lanes[lane] != null && lanes[lane].isPressed;
	}

	public function justPressed(lane:Int):Bool
	{
		return lanes[lane] != null && lanes[lane].isPressed && !lanes[lane].wasPressed;
	}

	public function justReleased(lane:Int):Bool
	{
		return lanes[lane] != null && !lanes[lane].isPressed && lanes[lane].wasPressed;
	}

	public var dodgeJustPressed(get, never):Bool;

	function get_dodgeJustPressed():Bool
	{
		return dodgeHint != null && dodgeHint.isPressed && !dodgeHint.wasPressed;
	}

	override function destroy()
	{
		if (FlxG.signals.preUpdate.has(updateHints))
			FlxG.signals.preUpdate.remove(updateHints);

		lanes = null;
		dodgeHint = null;
		hitboxCamera = null;
		excludeObject = null;
		super.destroy();
	}
}
