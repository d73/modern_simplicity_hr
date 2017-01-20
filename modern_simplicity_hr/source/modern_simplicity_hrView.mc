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
	var Settings = Sys.getDeviceSettings();
	var barWidth = 5;
	var inactiveBarColor = Gfx.COLOR_DK_GRAY;
	var activeMoveBarColor = Gfx.COLOR_RED;
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
    	
    	// any notifications?
    	var notifications = Settings.notificationCount;
        
        // battery level
    	tempObject = Sys.getSystemStats();
    	var battery = tempObject.battery;
		
        // Get and show the current time
        tempObject = Sys.getClockTime();
		var hour = tempObject.hour.format("%02d");
		var min = tempObject.min.format("%02d");

		// hours
        tempDrawable = View.findDrawableById("l_hour");
        tempDrawable.setText(Lang.format("$1$", [hour]));
        tempDrawable.locY = dc.getHeight() / 2 - 60;

		// min
        tempDrawable = View.findDrawableById("l_min");
        tempDrawable.setText(Lang.format("$1$", [min]));
        tempDrawable.locY = dc.getHeight() / 2;
        
		// move bar
		tempObject = ActMon.getInfo();
		var movelevel = tempObject.moveBarLevel; // 0-5
		
		// heart rate
		tempObject = ActMon.getHeartRateHistory(1, true);
		tempObject = tempObject.next();
		var heartrate = tempObject.heartRate;
        tempDrawable = View.findDrawableById("l_heartrate");
        tempDrawable.setText(Lang.format("$1$", [heartrate]));
        tempDrawable.locX = dc.getWidth() - 35;

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
        
        // Draw the battery bar
        var batterybarsize = dc.getHeight() * battery / 100;
	    // inactive battery bar
 		dc.setColor(inactiveBarColor, inactiveBarColor);
     	dc.fillRectangle(dc.getWidth() - barWidth, 0, barWidth, dc.getHeight() - batterybarsize);

	    // active battery bar
	    var batteryBarColor;
	    if (battery <= 15) {
	    	batteryBarColor = Gfx.COLOR_RED;
	    } else if (battery > 50) {
	    	batteryBarColor = Gfx.COLOR_GREEN;
	    } else {
	    	batteryBarColor = Gfx.COLOR_YELLOW;
	    }
 		dc.setColor(batteryBarColor, batteryBarColor);
     	dc.fillRectangle(dc.getWidth() - barWidth, dc.getHeight() - batterybarsize, barWidth, batterybarsize);
        
        // Draw the move bar
	    var movebarsize = dc.getHeight() * movelevel / 5;
	    
	    // inactive move bar
 		dc.setColor(inactiveBarColor, inactiveBarColor);
     	dc.fillRectangle(0, 0, barWidth, dc.getHeight() - movebarsize);

	    // active move bar
 		dc.setColor(activeMoveBarColor, activeMoveBarColor);
     	dc.fillRectangle(0, dc.getHeight() - movebarsize, barWidth, movebarsize);

		// draw heart icon
		dc.drawBitmap(dc.getWidth() - 32, 10, hearticon);
		
		// draw notification notification if needed
    	if (notifications > 0) {
			dc.drawBitmap(10, 10, messageicon);
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
