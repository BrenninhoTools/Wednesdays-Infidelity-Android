package mobile;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.FlxText;

class ScreenUtil
{
	public static inline var BASE_WIDTH:Int = 1280;
	public static inline var BASE_HEIGHT:Int = 720;

	public static var wide(default, null):Bool = false;

	public static var side(get, never):Float;
	public static var fullWidth(get, never):Int;

	static var hooked:Bool = false;

	static function get_side():Float
	{
		if (!wide || FlxG.scaleMode == null || FlxG.scaleMode.scale.x <= 0)
			return 0;

		return Math.max(0, Math.ceil(FlxG.scaleMode.offset.x / FlxG.scaleMode.scale.x));
	}

	static function get_fullWidth():Int
	{
		return Std.int(FlxG.width + side * 2);
	}

	public static function extendCamera(camera:FlxCamera, keepLayout:Bool = false):FlxCamera
	{
		if (camera == null)
			return camera;

		var extra:Float = side;
		if (extra <= 0)
			return camera;

		camera.x = -extra;
		camera.setSize(fullWidth, camera.height);

		if (keepLayout)
			camera.scroll.x = -extra;

		return camera;
	}

	public static function fillBackgrounds(state:FlxState)
	{
		if (state == null || side <= 0)
			return;

		if (state is states.game.PlayState || state is states.game.CutsceneState)
			return;

		var backgrounds:Array<FlxSprite> = [];
		findBackgrounds(state.members, backgrounds);
		if (backgrounds.length == 0)
			return;

		var bgCamera:FlxCamera = new FlxCamera();
		bgCamera.bgColor = 0xFF000000;
		extendCamera(bgCamera, true);

		for (camera in FlxG.cameras.list)
			camera.bgColor.alpha = 0;

		FlxG.cameras.insert(bgCamera, 0, false);

		for (sprite in backgrounds)
		{
			var centerX:Float = sprite.x + sprite.width / 2;
			var centerY:Float = sprite.y + sprite.height / 2;
			var factor:Float = fullWidth / sprite.width;

			if (factor > 1)
			{
				sprite.scale.set(sprite.scale.x * factor, sprite.scale.y * factor);
				sprite.updateHitbox();
			}

			sprite.scrollFactor.x = 1;
			sprite.x = centerX - sprite.width / 2;
			sprite.y = centerY - sprite.height / 2;
			sprite.cameras = [bgCamera];
		}
	}

	static function findBackgrounds(members:Array<FlxBasic>, result:Array<FlxSprite>)
	{
		for (member in members)
		{
			if (member == null || !member.exists)
				continue;

			if (member is FlxTypedGroup)
			{
				var group:FlxTypedGroup<FlxBasic> = cast member;
				findBackgrounds(group.members, result);
			}
			else if (member is FlxSprite && !(member is FlxText) && !(member is MobileButton))
			{
				var sprite:FlxSprite = cast member;
				if (isBackground(sprite))
					result.push(sprite);
			}
		}
	}

	static function isBackground(sprite:FlxSprite):Bool
	{
		if (sprite.width < BASE_WIDTH - 80 || sprite.height < BASE_HEIGHT - 80)
			return false;

		if (sprite.x > 80 || sprite.x + sprite.width < BASE_WIDTH - 80)
			return false;

		var cameras = sprite.getCameras();
		if (cameras != null && cameras.length > 0 && cameras[0] != FlxG.cameras.list[0])
			return false;

		return true;
	}

	public static function apply(isWide:Bool)
	{
		#if mobile
		wide = isWide;

		#if android
		var method:Dynamic = lime.system.JNI.createStaticMethod('org/haxe/extension/ScreenUtil', 'setFullscreen', '(Z)V');
		if (method != null)
			method(isWide);
		#end

		FlxG.scaleMode = new RatioScaleMode();

		if (!hooked)
		{
			hooked = true;
			FlxG.signals.postStateSwitch.add(function()
			{
				fillBackgrounds(FlxG.state);
			});
		}
		#end
	}
}
