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
	static var leftAligned:Map<FlxSprite, String> = new Map<FlxSprite, String>();

	public static function alignLeft(sprite:FlxSprite, imagePath:String)
	{
		if (sprite != null)
			leftAligned.set(sprite, imagePath);
	}

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
		{
			leftAligned.clear();
			return;
		}

		var bgCamera:FlxCamera = new FlxCamera();
		bgCamera.bgColor = 0xFF000000;
		extendCamera(bgCamera, true);

		for (camera in FlxG.cameras.list)
			camera.bgColor.alpha = 0;

		FlxG.cameras.insert(bgCamera, 0, false);

		for (sprite in backgrounds)
		{
			if (leftAligned.exists(sprite))
			{
				placeLeftWithMirror(state, sprite, leftAligned.get(sprite), bgCamera);
				continue;
			}

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

		leftAligned.clear();
	}

	static function placeLeftWithMirror(state:FlxState, sprite:FlxSprite, imagePath:String, bgCamera:FlxCamera)
	{
		var extra:Float = side;

		sprite.scrollFactor.x = 1;
		sprite.x = -extra;
		sprite.cameras = [bgCamera];

		var gap:Int = Math.ceil(fullWidth - sprite.width);
		if (gap <= 0)
			return;

		var source:openfl.display.BitmapData = openfl.utils.Assets.getBitmapData(imagePath, false);
		if (source == null)
			return;

		var scale:Float = sprite.scale.x;
		var sourceGap:Int = Std.int(Math.min(source.width, Math.ceil(gap / scale)));
		var mirrorData = new openfl.display.BitmapData(sourceGap, source.height, true, 0);
		mirrorData.draw(source, new openfl.geom.Matrix(-1, 0, 0, 1, source.width, 0));

		var mirror:FlxSprite = new FlxSprite().loadGraphic(mirrorData);
		mirror.scale.set(sprite.scale.x, sprite.scale.y);
		mirror.updateHitbox();
		mirror.antialiasing = sprite.antialiasing;
		mirror.scrollFactor.set(1, sprite.scrollFactor.y);
		mirror.x = sprite.x + sprite.width;
		mirror.y = sprite.y;
		mirror.cameras = [bgCamera];

		var index:Int = state.members.indexOf(sprite);
		state.insert(index < 0 ? 0 : index + 1, mirror);
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

	public static function spreadHUD(members:Array<FlxBasic>, camera:FlxCamera)
	{
		var extra:Float = side;
		if (extra <= 0 || members == null)
			return;

		for (member in members)
		{
			if (member == null || !member.exists)
				continue;

			if (member is FlxTypedGroup)
			{
				var group:FlxTypedGroup<FlxBasic> = cast member;
				spreadHUD(group.members, camera);
				continue;
			}

			if (!(member is FlxSprite) || member is gameObjects.StrumNote || member is gameObjects.HealthIcon || member is MobileButton)
				continue;

			var sprite:FlxSprite = cast member;
			var cameras = sprite.getCameras();
			if (cameras == null || cameras.length == 0 || cameras[0] != camera)
				continue;

			if (!(sprite is FlxText) && sprite.width >= FlxG.width - 4)
			{
				sprite.scale.x *= fullWidth / sprite.width;
				sprite.updateHitbox();
				sprite.x = -extra;
				continue;
			}

			var center:Float = sprite.x + sprite.width / 2;
			if (center < FlxG.width / 3)
				sprite.x -= extra;
			else if (center > FlxG.width * 2 / 3)
				sprite.x += extra;
		}
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
