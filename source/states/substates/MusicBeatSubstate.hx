package states.substates;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import input.Controls;
import input.PlayerSettings;
import song.Conductor.BPMChangeEvent;
import song.Conductor;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public var mobileCamera:FlxCamera;
	public var backButton:mobile.MobileButton;

	public function addBackButton():mobile.MobileButton
	{
		#if mobile
		if (mobileCamera == null)
		{
			mobileCamera = new FlxCamera();
			mobileCamera.bgColor.alpha = 0;
			FlxG.cameras.add(mobileCamera, false);
		}

		backButton = mobile.MobileButton.createBack(this, mobileCamera);
		add(backButton);
		#end
		return backButton;
	}

	override function create()
	{
		super.create();

		#if mobile
		mobile.ScreenUtil.fitBackgrounds(this);
		#end
	}

	override function destroy()
	{
		if (mobileCamera != null)
		{
			if (FlxG.cameras.list.contains(mobileCamera))
				FlxG.cameras.remove(mobileCamera);
			mobileCamera = null;
		}

		super.destroy();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
