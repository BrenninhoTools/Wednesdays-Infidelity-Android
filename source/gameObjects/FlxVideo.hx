package gameObjects;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxTimer;
import input.PlayerSettings;
#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideo as VlcVideo;
#end

class FlxVideo extends FlxBasic
{
	public var finishCallback:Void->Void = null;

	public var skipable:Bool = false;

	#if VIDEOS_ALLOWED
	var video:VlcVideo;
	var finished:Bool = false;
	#end

	public function new(name:String, ?skip:Bool, ?focus:Bool = true)
	{
		super();

		#if PRIVATE_BUILD
		skipable = true;
		#else
		if (skip != null)
			skipable = skip;
		#end

		#if VIDEOS_ALLOWED
		video = new VlcVideo();
		video.onEndReached.add(finishVideo);
		video.onEncounteredError.add(function(message:String)
		{
			finishVideo();
		});
		FlxG.addChildBelowMouse(video);

		if (video.load(name))
		{
			new FlxTimer().start(0.001, function(tmr:FlxTimer)
			{
				if (!finished && video != null)
					video.play();
			});
			FlxG.signals.postUpdate.add(checkSkip);
		}
		else
		{
			new FlxTimer().start(0.001, function(tmr:FlxTimer)
			{
				finishVideo();
			});
		}
		#end
	}

	#if VIDEOS_ALLOWED
	function checkSkip()
	{
		if (!skipable || finished || video == null || !video.isPlaying)
			return;

		var pressed:Bool = PlayerSettings.player1.controls.ACCEPT;

		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressed = true;
		}
		#end

		if (pressed)
			finishVideo();
	}

	function finishVideo()
	{
		if (finished)
			return;

		finished = true;

		if (FlxG.signals.postUpdate.has(checkSkip))
			FlxG.signals.postUpdate.remove(checkSkip);

		if (video != null)
		{
			video.stop();
			if (FlxG.game.contains(video))
				FlxG.removeChild(video);
			video.dispose();
			video = null;
		}

		if (finishCallback != null)
			finishCallback();
	}
	#end

	override function destroy()
	{
		#if VIDEOS_ALLOWED
		if (FlxG.signals.postUpdate.has(checkSkip))
			FlxG.signals.postUpdate.remove(checkSkip);

		if (video != null)
		{
			finished = true;
			video.stop();
			if (FlxG.game.contains(video))
				FlxG.removeChild(video);
			video.dispose();
			video = null;
		}
		#end

		super.destroy();
	}
}
