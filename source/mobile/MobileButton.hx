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

	var playingTap:Bool = false;
	var fired:Bool = false;

	public function new(x:Float, y:Float, image:String, prefix:String, ?camera:FlxCamera)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('mobile/' + image, 'shared').addBorder(flixel.math.FlxPoint.weak(1, 1));
		animation.addByPrefix('tap', prefix, 48, false);
		animation.play('tap', true);
		animation.stop();
		animation.curAnim.curFrame = 0;
		animation.onFinish.add(onTapFinished);
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
		if (!fired)
			return false;

		fired = false;
		return true;
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
		if (playingTap)
			return;

		playingTap = true;
		fired = false;

		if (animation.curAnim == null)
			onTapFinished('tap');
		else
			animation.play('tap', true);
	}

	function onTapFinished(name:String)
	{
		if (!playingTap)
			return;

		playingTap = false;
		fired = true;

		if (animation.curAnim != null)
		{
			animation.stop();
			animation.curAnim.curFrame = 0;
		}

		if (onTap != null)
			onTap();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!playingTap && exists && isOwnerOnTop() && TouchUtil.tappedOn(this, getCam()))
			playTap();
	}

	override function draw()
	{
		if (isBackButton && !isOwnerOnTop())
		{
			for (button in backButtons)
			{
				if (button != this && button.exists && button.isOwnerOnTop())
					return;
			}
		}

		super.draw();
	}

	public static function anyBackTapped():Bool
	{
		for (button in backButtons)
		{
			if (button != null && button.exists && button.isOwnerOnTop() && button.tapped)
				return true;
		}

		return false;
	}

	override function destroy()
	{
		backButtons.remove(this);
		animation.onFinish.remove(onTapFinished);
		owner = null;
		onTap = null;
		super.destroy();
	}
}
