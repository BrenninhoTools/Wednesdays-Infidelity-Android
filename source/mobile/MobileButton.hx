package mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class MobileButton extends FlxSprite
{
	static var backButtons:Array<MobileButton> = [];

	public var owner:FlxState;
	public var isBackButton:Bool = false;
	public var onTap:Void->Void;

	var animName:String;

	public function new(x:Float, y:Float, image:String, prefix:String, ?camera:FlxCamera)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('mobile/' + image, 'shared');
		animation.addByPrefix('tap', prefix, 24, false);
		animation.play('tap', true);
		animation.pause();
		animation.curAnim.curFrame = 0;
		animName = 'tap';
		antialiasing = data.ClientPrefs.globalAntialiasing;
		scrollFactor.set();
		updateHitbox();

		if (camera != null)
			cameras = [camera];
	}

	public static function createBack(owner:FlxState, ?camera:FlxCamera, scale:Float = 0.8):MobileButton
	{
		var button = new MobileButton(0, 0, 'backButton', 'back', camera);
		button.scale.set(scale, scale);
		button.updateHitbox();
		button.x = FlxG.width - button.width - 20;
		button.y = FlxG.height - button.height - 20;
		button.owner = owner;
		button.isBackButton = true;
		backButtons.push(button);
		return button;
	}

	public static function createPause(owner:FlxState, ?camera:FlxCamera, scale:Float = 0.8):MobileButton
	{
		var button = new MobileButton(0, 0, 'pauseButton', 'pause', camera);
		button.scale.set(scale, scale);
		button.updateHitbox();
		button.x = FlxG.width - button.width - 20;
		button.y = 20;
		button.owner = owner;
		return button;
	}

	public var tapped(get, never):Bool;

	function get_tapped():Bool
	{
		if (!exists || !active || !isOwnerOnTop())
			return false;

		return TouchUtil.tappedOn(this, getCam());
	}

	function getCam():FlxCamera
	{
		return (_cameras != null && _cameras.length > 0) ? _cameras[0] : null;
	}

	function isOwnerOnTop():Bool
	{
		if (owner == null)
			return true;

		var top:FlxState = FlxG.state;
		while (top != null && top.subState != null)
			top = top.subState;

		return top == owner;
	}

	public function playTap()
	{
		animation.play(animName, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (tapped)
		{
			playTap();
			if (onTap != null)
				onTap();
		}
	}

	public static function anyBackTapped():Bool
	{
		for (button in backButtons)
		{
			if (button != null && button.tapped)
			{
				button.playTap();
				return true;
			}
		}

		return false;
	}

	override function destroy()
	{
		backButtons.remove(this);
		owner = null;
		onTap = null;
		super.destroy();
	}
}
