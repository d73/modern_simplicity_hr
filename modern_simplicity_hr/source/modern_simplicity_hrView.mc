using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Activity as Act;
using Toybox.ActivityMonitor as ActMon;

class modern_simplicity_hrView extends Ui.WatchFace {

	// Variables used by the watch face
	var barSize = 5;
	var iconSize = 24;
	var batteryCriticalLevel = 15;
	var inactiveBarColor = Gfx.COLOR_DK_GRAY;
	var activeMoveBarColor = inactiveBarColor;
	var hearticon;
	var messageicon;

	function initialize() {
		WatchFace.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.WatchFace(dc));
		hearticon = Ui.loadResource(Rez.Drawables.heart);
		messageicon = Ui.loadResource(Rez.Drawables.message);
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
	}

	// Update the drawable
	function onUpdate(dc) {
		// use and reuse two generic vars to save memory
		var tempDrawable;
		var tempObject;

		// Time
		tempObject = Sys.getClockTime();
		var hour = tempObject.hour.format("%02d");
		var min = tempObject.min.format("%02d");
		tempDrawable = View.findDrawableById("l_time");
		tempDrawable.setText(Lang.format("$1$:$2$", [hour, min]));

		// Heart rate
		tempObject = ActMon.getHeartRateHistory(1, true);
		tempObject = tempObject.next();
		var heartrate = tempObject.heartRate;
		if (heartrate == 255) {
			heartrate = 0;
		}
		tempDrawable = View.findDrawableById("l_heartrate");
		tempDrawable.setText(Lang.format("$1$", [heartrate]));
		tempDrawable.locX = barSize + 2 + iconSize + 2;

		// Date
		tempObject = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var month = tempObject.month;
		var day = tempObject.day;
		var wday = tempObject.day_of_week;
		tempDrawable = View.findDrawableById("l_date");
		tempDrawable.setText(Lang.format("$1$ $2$ $3$", [wday, day.format("%02d"), month]));
		tempDrawable.locY = dc.getHeight() - 30;

		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);

		// draw heart icon
		dc.drawBitmap(6, 10, hearticon);

		// Battery level
		tempObject = Sys.getSystemStats();
		var battery = tempObject.battery;

		// Draw the battery bar
		var batterybarsize = dc.getHeight() * battery / 100;
		// inactive battery bar
 		dc.setColor(inactiveBarColor, inactiveBarColor);
	 	dc.fillRectangle(dc.getWidth() - barSize, 0, barSize, dc.getHeight() - batterybarsize);
		// active battery bar
		var batteryBarColor;
		if (battery <= batteryCriticalLevel) {
			batteryBarColor = Gfx.COLOR_RED;
		} else if (battery > 50) {
			batteryBarColor = Gfx.COLOR_GREEN;
		} else {
			batteryBarColor = Gfx.COLOR_YELLOW;
		}
 		dc.setColor(batteryBarColor, batteryBarColor);
	 	dc.fillRectangle(dc.getWidth() - barSize, dc.getHeight() - batterybarsize, barSize, batterybarsize);

		// Move level
		tempObject = ActMon.getInfo();
		var movelevel = tempObject.moveBarLevel; // 0-5
		var movebarsize = 0;
		if (movelevel == 0) {
			movebarsize = 0;
		} else if (movelevel == 1) {
			activeMoveBarColor = Gfx.COLOR_YELLOW;
			movebarsize = dc.getHeight() * 0.5;
		} else if (movelevel == 2) {
			activeMoveBarColor = Gfx.COLOR_ORANGE;
			movebarsize = dc.getHeight() * 5/8;
		} else if (movelevel == 3) {
			activeMoveBarColor = Gfx.COLOR_ORANGE;
			movebarsize = dc.getHeight() * 6/8;
		} else if (movelevel == 4) {
			activeMoveBarColor = Gfx.COLOR_ORANGE;
			movebarsize = dc.getHeight() * 7/8;
		} else if (movelevel == 5) {
			activeMoveBarColor = Gfx.COLOR_RED;
			movebarsize = dc.getHeight();
		}
		// inactive move bar
 		dc.setColor(inactiveBarColor, inactiveBarColor);
	 	dc.fillRectangle(0, 0, barSize, dc.getHeight() - movebarsize);
		// active move bar
 		dc.setColor(activeMoveBarColor, activeMoveBarColor);
	 	dc.fillRectangle(0, dc.getHeight() - movebarsize, barSize, movebarsize);

		// Notifications
		tempObject = Sys.getDeviceSettings();
		var notifications = tempObject.notificationCount;
		if (notifications > 0) {
			dc.drawBitmap(dc.getWidth() - barSize - 2 - iconSize, 10, messageicon);
		}
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	// The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
	}

	// Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
	}
}
