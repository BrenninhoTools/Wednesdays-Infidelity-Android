package mobile;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.TouchEvent;
import openfl.utils.Assets;

class TouchCursor extends Sprite
{
	static var instance:TouchCursor;

	public static var enabled(default, set):Bool = true;

	static inline var HOTSPOT_X:Float = 8;
	static inline var HOTSPOT_Y:Float = 16;
	static inline var SCREEN_RATIO:Float = 0.11;

	var bitmap:Bitmap;
	var touches:Int = 0;
	var fading:Bool = false;

	public static function init()
	{
		#if mobile
		if (instance != null)
			return;

		var path:String = 'shared:assets/shared/images/mobile/touchCursor.png';
		if (!Assets.exists(path))
			return;

		instance = new TouchCursor(Assets.getBitmapData(path, false));
		Lib.current.stage.addChild(instance);
		#end
	}

	static function set_enabled(value:Bool):Bool
	{
		enabled = value;
		if (instance != null && !value)
		{
			instance.visible = false;
			instance.touches = 0;
		}
		return value;
	}

	function new(data:BitmapData)
	{
		super();

		bitmap = new Bitmap(data, AUTO, true);
		addChild(bitmap);
		mouseEnabled = false;
		mouseChildren = false;
		visible = false;

		var stage = Lib.current.stage;
		stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	function updateSize()
	{
		var stage = Lib.current.stage;
		var size:Float = Math.min(stage.stageWidth, stage.stageHeight) * SCREEN_RATIO;
		var scale:Float = size / bitmap.bitmapData.height;
		bitmap.scaleX = bitmap.scaleY = scale;
		bitmap.x = -HOTSPOT_X * scale;
		bitmap.y = -HOTSPOT_Y * scale;
	}

	function moveTo(stageX:Float, stageY:Float)
	{
		updateSize();
		x = stageX;
		y = stageY;

		if (parent != null)
			parent.setChildIndex(this, parent.numChildren - 1);
	}

	function onTouchBegin(event:TouchEvent)
	{
		touches++;
		if (!enabled)
			return;

		moveTo(event.stageX, event.stageY);
		fading = false;
		alpha = 1;
		visible = true;
	}

	function onTouchMove(event:TouchEvent)
	{
		if (!enabled)
			return;

		moveTo(event.stageX, event.stageY);
	}

	function onTouchEnd(event:TouchEvent)
	{
		touches = touches > 0 ? touches - 1 : 0;
		if (touches == 0)
			fading = true;
	}

	function onEnterFrame(event:Event)
	{
		if (!fading || !visible)
			return;

		alpha -= 0.08;
		if (alpha <= 0)
		{
			alpha = 0;
			visible = false;
			fading = false;
		}
	}
}
