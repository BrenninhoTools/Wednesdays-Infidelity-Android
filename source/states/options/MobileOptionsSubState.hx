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

		var option:Option = new Option('Hitbox Mode', 'Four Lanes splits the screen into four touch lanes.\nArrows puts your strums at the bottom and hides the opponent notes.',
			'hitboxMode', 'string', 'Four Lanes', ['Four Lanes', 'Arrows']);
		addOption(option);

		var option:Option = new Option('Screen Style', 'Original keeps the 16:9 screen with black borders.\nFull fills the whole screen without stretching. Restart the game to apply.',
			'screenStyle', 'string', 'Original', ['Original', 'Full']);
		option.onChange = onChangeScreenStyle;
		addOption(option);

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

	function onChangeScreenStyle()
	{
		ClientPrefs.saveSettings();
		mobile.ScreenUtil.apply(ClientPrefs.screenStyle == 'Full');
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
