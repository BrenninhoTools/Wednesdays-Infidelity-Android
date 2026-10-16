package states.options;

import data.ClientPrefs;
import data.Progression;
import gameObjects.Option;

class MobileOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu';

		var option:Option = new Option('Invisible Hitbox', 'If checked, the hitbox lanes stay invisible while you play.', 'invisibleHitbox', 'bool', false);
		addOption(option);

		var option:Option = new Option('Invisible Pause Button', 'If checked, the pause button is hidden during songs.\nYou can still tap its corner or use the back gesture to pause.',
			'invisiblePauseButton', 'bool', false);
		addOption(option);

		var option:Option = new Option('Unlock All', 'If checked, the game treats Story Mode as completed,\nunlocking every week and song. Unchecking restores your old progress.',
			'unlockAll', 'bool', false);
		option.onChange = onChangeUnlockAll;
		addOption(option);

		super();
	}

	function onChangeUnlockAll()
	{
		if (ClientPrefs.unlockAll)
			Progression.unlockAll();
		else
			Progression.restoreLocked();

		ClientPrefs.saveSettings();
	}
}
