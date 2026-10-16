package mobile;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
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
	static var checked:Map<FlxSprite, Bool> = new Map<FlxSprite, Bool>();

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

	public static function createCamera():FlxCamera
	{
		#if mobile
		return new ExtendedCamera();
		#else
		return new FlxCamera();
		#end
	}

	public static function fitScreen(state:FlxState)
	{
		if (side <= 0 || state == null || state is states.game.CutsceneState)
			return;

		var current:FlxState = state;
		while (current != null)
		{
			fitMembers(current, current.members);
			current = current.subState;
		}
	}

	static function fitMembers(state:FlxState, members:Array<FlxBasic>)
	{
		if (members == null)
			return;

		var i:Int = 0;
		while (i < members.length)
		{
			var member:FlxBasic = members[i];
			i++;

			if (member == null || !member.exists)
				continue;

			if (member is FlxTypedGroup)
			{
				var group:FlxTypedGroup<FlxBasic> = cast member;
				fitMembers(state, group.members);
				continue;
			}

			if (!(member is FlxSprite) || member is FlxText || member is MobileButton || member is FlxSpriteGroup || member is gameObjects.Note
				|| member is gameObjects.StrumNote || member is gameObjects.NoteSplash)
				continue;

			var sprite:FlxSprite = cast member;
			if (checked.exists(sprite))
				continue;

			checked.set(sprite, true);
			fitSprite(state, sprite);
		}
	}

	static function isSolid(sprite:FlxSprite):Bool
	{
		if (sprite.graphic == null || sprite.graphic.key == null || sprite.shader != null)
			return false;

		return ~/^[0-9]+x[0-9]+:/.match(sprite.graphic.key);
	}

	static function fitSprite(state:FlxState, sprite:FlxSprite)
	{
		var cameras = sprite.getCameras();
		if (cameras == null || cameras.length == 0 || !(cameras[0] is ExtendedCamera))
			return;

		var camera:ExtendedCamera = cast cameras[0];
		var extra:Float = camera.sideOffset;
		if (extra <= 0)
			return;

		var scroll:Float = camera.scroll.x * sprite.scrollFactor.x;
		var left:Float = sprite.x - scroll;

		if (sprite.width < FlxG.width - 80 || left > 80 || left + sprite.width < FlxG.width - 80)
			return;

		var solid:Bool = isSolid(sprite);
		if (!solid && sprite.height < FlxG.height - 80)
			return;

		if (leftAligned.exists(sprite))
		{
			placeLeftWithMirror(state, sprite, leftAligned.get(sprite), extra, scroll);
			return;
		}

		var full:Float = FlxG.width + extra * 2;

		if (sprite.width < full)
		{
			var centerX:Float = sprite.x + sprite.width / 2;
			var centerY:Float = sprite.y + sprite.height / 2;
			var factor:Float = (full + 2) / sprite.width;

			if (solid)
				sprite.scale.x *= factor;
			else
				sprite.scale.set(sprite.scale.x * factor, sprite.scale.y * factor);

			sprite.updateHitbox();
			sprite.x = centerX - sprite.width / 2;
			sprite.y = centerY - sprite.height / 2;
			left = sprite.x - scroll;
		}

		var minLeft:Float = FlxG.width + extra - sprite.width;
		var maxLeft:Float = -extra;
		var target:Float = Math.max(minLeft, Math.min(maxLeft, left));
		sprite.x += target - left;
	}

	static function placeLeftWithMirror(state:FlxState, sprite:FlxSprite, imagePath:String, extra:Float, scroll:Float)
	{
		sprite.x = scroll - extra;

		var gap:Int = Math.ceil(FlxG.width + extra * 2 - sprite.width);
		if (gap <= 0)
			return;

		var source:openfl.display.BitmapData = openfl.utils.Assets.getBitmapData(imagePath, false);
		if (source == null)
			return;

		var scale:Float = sprite.scale.x;
		var sourceGap:Int = Std.int(Math.min(source.width, Math.ceil(gap / scale) + 2));
		var mirrorData = new openfl.display.BitmapData(sourceGap, source.height, true, 0);
		mirrorData.draw(source, new openfl.geom.Matrix(-1, 0, 0, 1, source.width, 0));

		var mirror:FlxSprite = new FlxSprite().loadGraphic(mirrorData);
		mirror.scale.set(sprite.scale.x, sprite.scale.y);
		mirror.updateHitbox();
		mirror.antialiasing = sprite.antialiasing;
		mirror.scrollFactor.set(sprite.scrollFactor.x, sprite.scrollFactor.y);
		mirror.x = sprite.x + sprite.width - 1;
		mirror.y = sprite.y;
		mirror.cameras = sprite.cameras;
		checked.set(mirror, true);

		var index:Int = state.members.indexOf(sprite);
		state.insert(index < 0 ? 0 : index + 1, mirror);
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
			FlxG.signals.preStateSwitch.add(function()
			{
				checked.clear();
				leftAligned.clear();
			});
			FlxG.signals.preStateCreate.add(function(state:FlxState)
			{
				if (wide && !(state is states.game.PlayState))
					FlxG.cameras.reset(new ExtendedCamera());
			});
			FlxG.signals.postUpdate.add(function()
			{
				if (wide)
					fitScreen(FlxG.state);
			});
		}
		#end
	}
}
