package mobile;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;

class TouchUtil
{
	public static inline var TAP_DISTANCE:Float = 40;
	public static inline var SWIPE_DISTANCE:Float = 90;

	static var initialized:Bool = false;
	static var mouseStart:FlxPoint = FlxPoint.get();

	public static var pressed(get, never):Bool;
	public static var justPressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var tapped(get, never):Bool;

	public static var swipedUp(get, never):Bool;
	public static var swipedDown(get, never):Bool;
	public static var swipedLeft(get, never):Bool;
	public static var swipedRight(get, never):Bool;

	public static function init()
	{
		if (initialized)
			return;

		initialized = true;

		#if (!mobile && FLX_MOUSE)
		FlxG.signals.preUpdate.add(function()
		{
			if (FlxG.mouse.justPressed)
				mouseStart.set(FlxG.mouse.viewX, FlxG.mouse.viewY);
		});
		#end
	}

	static function forEachPointer(callback:(FlxPointer, Bool, Bool, Bool, Float, Float) -> Bool):Bool
	{
		#if mobile
		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (callback(touch, touch.pressed, touch.justPressed, touch.justReleased, touch.viewX - touch.justPressedPosition.x,
				touch.viewY - touch.justPressedPosition.y))
				return true;
		}
		#end
		#elseif FLX_MOUSE
		var mouse = FlxG.mouse;
		if (callback(mouse, mouse.pressed, mouse.justPressed, mouse.justReleased, mouse.viewX - mouseStart.x, mouse.viewY - mouseStart.y))
			return true;
		#end

		return false;
	}

	public static function pointerOverlaps(pointer:FlxPointer, object:FlxBasic, ?camera:FlxCamera):Bool
	{
		if (object is FlxObject)
		{
			var obj:FlxObject = cast object;
			var cam:FlxCamera = camera != null ? camera : obj.getDefaultCamera();
			var view:FlxPoint = pointer.getViewPosition(cam);
			if (cam is ExtendedCamera)
				view.x -= cast(cam, ExtendedCamera).sideOffset / cam.zoom;
			var screen:FlxPoint = obj.getScreenPosition(null, cam);
			var left:Float = screen.x;
			var top:Float = screen.y;

			if (object is FlxSpriteGroup)
			{
				var group:FlxSpriteGroup = cast object;
				left += group.findMinX() - group.x;
				top += group.findMinY() - group.y;
			}

			var result:Bool = view.x >= left && view.x < left + obj.width && view.y >= top && view.y < top + obj.height;
			view.put();
			screen.put();
			return result;
		}

		return pointer.overlaps(object, camera);
	}

	static function isTap(dx:Float, dy:Float):Bool
	{
		return Math.sqrt(dx * dx + dy * dy) < TAP_DISTANCE;
	}

	static function get_pressed():Bool
	{
		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isPressed);
	}

	static function get_justPressed():Bool
	{
		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isJustPressed);
	}

	static function get_justReleased():Bool
	{
		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isJustReleased);
	}

	static function get_tapped():Bool
	{
		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isJustReleased && isTap(dx, dy));
	}

	public static function pressedOn(object:FlxBasic, ?camera:FlxCamera):Bool
	{
		if (object == null)
			return false;

		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isPressed && pointerOverlaps(p, object, camera));
	}

	public static function justPressedOn(object:FlxBasic, ?camera:FlxCamera):Bool
	{
		if (object == null)
			return false;

		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isJustPressed && pointerOverlaps(p, object, camera));
	}

	public static function tappedOn(object:FlxBasic, ?camera:FlxCamera):Bool
	{
		if (object == null)
			return false;

		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy) return isJustReleased && isTap(dx, dy) && pointerOverlaps(p, object, camera));
	}

	public static function tappedIndex<T:FlxBasic>(members:Array<T>, ?camera:FlxCamera):Int
	{
		if (members == null || !tapped)
			return -1;

		for (i in 0...members.length)
		{
			var member = members[i];
			if (member != null && member.exists && member.visible && tappedOn(member, camera))
				return i;
		}

		return -1;
	}

	static function swipe(direction:Int):Bool
	{
		return forEachPointer(function(p, isPressed, isJustPressed, isJustReleased, dx, dy)
		{
			if (!isJustReleased || Math.sqrt(dx * dx + dy * dy) < SWIPE_DISTANCE)
				return false;

			var horizontal:Bool = Math.abs(dx) > Math.abs(dy);

			return switch (direction)
			{
				case 0: !horizontal && dy < 0;
				case 1: !horizontal && dy > 0;
				case 2: horizontal && dx < 0;
				default: horizontal && dx > 0;
			}
		});
	}

	static function get_swipedUp():Bool
		return swipe(0);

	static function get_swipedDown():Bool
		return swipe(1);

	static function get_swipedLeft():Bool
		return swipe(2);

	static function get_swipedRight():Bool
		return swipe(3);
}
