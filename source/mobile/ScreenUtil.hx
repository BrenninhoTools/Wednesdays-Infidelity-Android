package mobile;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.FlxText;

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

	public static var offsetX(get, never):Float;

	static function get_offsetX():Float
	{
		return FlxG.width > BASE_WIDTH ? (FlxG.width - BASE_WIDTH) / 2 : 0;
	}

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

	static var fitHooked:Bool = false;

	public static function fitBackgrounds(state:FlxState)
	{
		if (state == null || FlxG.width <= BASE_WIDTH)
			return;

		if (state is states.game.PlayState || state is states.substates.GameOverSubstate || state is states.game.CutsceneState)
			return;

		fitMembers(state.members);

		if (!(state is states.substates.ResetScoreSubState) && !(state is states.substates.StoryProgress))
			shiftMembers(state.members, offsetX);
	}

	static function shiftMembers(members:Array<FlxBasic>, offset:Float)
	{
		for (member in members)
		{
			if (member == null || !member.exists || member is MobileButton)
				continue;

			if (member is FlxTypedGroup)
			{
				var group:FlxTypedGroup<FlxBasic> = cast member;
				shiftMembers(group.members, offset);
			}
			else if (member is flixel.FlxObject)
			{
				var object:flixel.FlxObject = cast member;
				var left:Float = object.x;
				var right:Float = object.x + object.width;
				var centered:Bool = Math.abs(left - (FlxG.width - object.width) / 2) < 2;

				if (!centered && left >= -2 && right <= BASE_WIDTH + 2)
					object.x += offset;
			}
		}
	}

	static function fitMembers(members:Array<FlxBasic>)
	{
		for (member in members)
		{
			if (member == null || !member.exists)
				continue;

			if (member is FlxTypedGroup)
			{
				var group:FlxTypedGroup<FlxBasic> = cast member;
				fitMembers(group.members);
			}
			else if (member is FlxSprite && !(member is FlxText) && !(member is MobileButton))
			{
				fitSprite(cast member);
			}
		}
	}

	static function fitSprite(sprite:FlxSprite)
	{
		if (sprite.width < BASE_WIDTH - 80 || sprite.width >= FlxG.width || sprite.height < BASE_HEIGHT - 80)
			return;

		if (sprite.x > 80 || sprite.x + sprite.width < BASE_WIDTH - 80)
			return;

		var factor:Float = FlxG.width / sprite.width;
		var centerY:Float = sprite.y + sprite.height / 2;

		sprite.scale.set(sprite.scale.x * factor, sprite.scale.y * factor);
		sprite.updateHitbox();
		sprite.x = (FlxG.width - sprite.width) / 2;
		sprite.y = centerY - sprite.height / 2;
	}

	public static function hookBackgroundFit()
	{
		if (fitHooked)
			return;

		fitHooked = true;
		FlxG.signals.postStateSwitch.add(function()
		{
			fitBackgrounds(FlxG.state);
		});
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
		hookBackgroundFit();
		#end
	}
}
