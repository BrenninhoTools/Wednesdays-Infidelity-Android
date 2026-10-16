package data;

import flixel.FlxG;
import states.menus.StoryMenuState;

class Progression
{
	public static var beatMainWeek:Bool = false;
	public static var badEnding:Bool = false;
	public static var goodEnding:Bool = false;
	public static var beatHell:Bool = false;

	public static var weekProgress:Map<String, {song:String, weekMisees:Int}> = [];

	public static function load()
	{
		if (FlxG.save.data.beatmainweek != null) // W.I SAVES
		{
			beatMainWeek = FlxG.save.data.beatmainweek;
		}
		if (FlxG.save.data.gotbadending != null)
		{
			badEnding = FlxG.save.data.gotbadending;
		}
		if (FlxG.save.data.gotgoodending != null)
		{
			goodEnding = FlxG.save.data.gotgoodending;
		}
		if (FlxG.save.data.beathell != null)
		{
			beatHell = FlxG.save.data.beathell;
		}
		if (FlxG.save.data.weekProgress != null)
		{
			weekProgress = FlxG.save.data.weekProgress;
		}
	}

	public static function save()
	{
		FlxG.save.data.beatmainweek = beatMainWeek;
		FlxG.save.data.gotbadending = badEnding;
		FlxG.save.data.gotgoodending = goodEnding;
		FlxG.save.data.beathell = beatHell;
		FlxG.save.data.weekProgress = weekProgress;

		FlxG.save.flush();
	}

	public static function unlockAll()
	{
		if (FlxG.save.data.lockedProgressBackup == null)
		{
			var weeks:Map<String, Bool> = new Map<String, Bool>();
			for (week => completed in StoryMenuState.weekCompleted)
				weeks.set(week, completed);

			FlxG.save.data.lockedProgressBackup = {
				beatMainWeek: beatMainWeek,
				badEnding: badEnding,
				goodEnding: goodEnding,
				beatHell: beatHell,
				weekCompleted: weeks
			};
		}

		beatMainWeek = true;
		badEnding = true;
		goodEnding = true;
		beatHell = true;

		WeekData.reloadWeekFiles(true);
		for (week in WeekData.weeksList)
			StoryMenuState.weekCompleted.set(week, true);

		FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
		save();
	}

	public static function restoreLocked()
	{
		var backup:Dynamic = FlxG.save.data.lockedProgressBackup;
		if (backup == null)
			return;

		beatMainWeek = backup.beatMainWeek == true;
		badEnding = backup.badEnding == true;
		goodEnding = backup.goodEnding == true;
		beatHell = backup.beatHell == true;

		var weeks:Map<String, Bool> = backup.weekCompleted;
		StoryMenuState.weekCompleted = weeks != null ? weeks : new Map<String, Bool>();
		FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
		FlxG.save.data.lockedProgressBackup = null;
		save();
	}

	public static function reset()
	{
		FlxG.save.data.lockedProgressBackup = null;
		ClientPrefs.unlockAll = false;
		FlxG.save.data.unlockAll = false;

		beatMainWeek = false;
		badEnding = false;
		goodEnding = false;
		beatHell = false;
		weekProgress = [];

		save();
	}
}
