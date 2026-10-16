package org.haxe.extension;

import android.app.Activity;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

public class ScreenUtil {

	public static void setFullscreen(final boolean full) {
		final Activity activity = Extension.mainActivity;
		if (activity == null) {
			return;
		}

		activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Window window = activity.getWindow();

				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
					WindowManager.LayoutParams params = window.getAttributes();
					params.layoutInDisplayCutoutMode = full
						? WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
						: WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_DEFAULT;
					window.setAttributes(params);
				}

				window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
				window.getDecorView().setSystemUiVisibility(
					View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
					| View.SYSTEM_UI_FLAG_FULLSCREEN
					| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
					| View.SYSTEM_UI_FLAG_LAYOUT_STABLE
					| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
					| View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
			}
		});
	}

	public static float getAspectRatio() {
		Activity activity = Extension.mainActivity;
		if (activity == null) {
			return 16f / 9f;
		}

		android.util.DisplayMetrics metrics = new android.util.DisplayMetrics();
		activity.getWindowManager().getDefaultDisplay().getRealMetrics(metrics);
		float width = Math.max(metrics.widthPixels, metrics.heightPixels);
		float height = Math.min(metrics.widthPixels, metrics.heightPixels);
		return height > 0 ? width / height : 16f / 9f;
	}
}
