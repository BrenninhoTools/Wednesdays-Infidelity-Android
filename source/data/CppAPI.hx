package data;

class CppAPI
{
	public static function obtainRAM():Int
	{
		#if (windows || linux)
		return WindowsData.obtainRAM();
		#else
		return 4096;
		#end
	}

	public static function darkMode()
	{
		#if windows
		WindowsData.setWindowColorMode(DARK);
		#end
	}

	public static function lightMode()
	{
		#if windows
		WindowsData.setWindowColorMode(LIGHT);
		#end
	}

	public static function setWindowOppacity(a:Float)
	{
		#if windows
		WindowsData.setWindowAlpha(a);
		#end
	}

	public static function _setWindowLayered()
	{
		#if windows
		WindowsData._setWindowLayered();
		#end
	}
}
