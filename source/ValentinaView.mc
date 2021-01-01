using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian as Date;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Mon;

class ValentinaView extends WatchUi.WatchFace {

	var background;
	var centerX = 195;
    var centerY = 195;
    var handWidth = 4;
    var handMinLength = 180;
    var handMinColor = Graphics.COLOR_PINK;
    var handHrLength = 140;
    var handHrColor = Graphics.COLOR_PINK;
    var handSecLength = 180;
    var handSecColor = Graphics.COLOR_BLUE;
    var hours = new [ 8 ];
    var hoursColor = 0xF5BFED;
    var batteryColor = Graphics.COLOR_GREEN;

    function initialize() {
    	var count = 0;
    	for (var i = 5; i <= 55; i += 5) {
    		if (i % 15) { // ignore 15/30/45/60
       			hours[count] = getHand(centerX, centerY, i, 190, 2, 175, false);
       			count += 1;
    		}
    	}
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        background = WatchUi.loadResource(Rez.Drawables.background);
        //setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        dc.drawBitmap(0,0,background);
        
        drawBattery(dc);
        drawHeartrate(dc);
        drawCalories(dc);
        drawStep(dc);
        drawHours(dc);
        drawClock(dc);
        drawDate(dc);
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
    
    private function drawBattery(dc) {
    	var battery = System.getSystemStats().battery;	
    	dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
    	dc.drawText(210, 30, Graphics.FONT_XTINY, battery.format("%d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    	
    	var x = 168;
    	var width = 31*(battery/100);
    	dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[x,25], [x+width,25], [x+width,39], [x,39]]);
    }
    
    private function drawHeartrate(dc) {
    	// search last heartrate from the newest 
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(null, true);
    	var currentHeartrate = "";
    	while (heartrateIterator != null) {
    		var sample = heartrateIterator.next();
    		if (sample == null) {
    			break;
    		}
			if(sample.heartRate != Mon.INVALID_HR_SAMPLE) {
				currentHeartrate = sample.heartRate.format("%d");
				break;
			}
		}
    
    	dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
    	dc.drawText(335, 190, Graphics.FONT_XTINY, currentHeartrate, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    private function drawCalories(dc) {
    	var calories = Mon.getInfo().calories.toString();
    	dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
    	dc.drawText(20, 174, Graphics.FONT_XTINY, calories, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    private function drawStep(dc) {
    	var steps = Mon.getInfo().steps.toString();
    	dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
    	dc.drawText(280, 265, Graphics.FONT_XTINY, steps, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    private function drawDate(dc) {
    	var now = Time.now();
		var date = Date.info(now, Time.FORMAT_SHORT);
		var dateString = Lang.format("$1$/$2$", [date.day, date.month]);
		date = Date.info(now, Time.FORMAT_LONG);
		var dayOfWeek = Lang.format("$1$", [date.day_of_week]);
    	dc.setColor(Graphics.COLOR_PINK, Graphics.COLOR_TRANSPARENT);
    	dc.drawText(60, 260, Graphics.FONT_XTINY, dayOfWeek, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    	dc.drawText(110, 260, Graphics.FONT_XTINY, dateString, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
   	
   	private function drawHours(dc) {
		for (var i = 0; i < hours.size(); i += 1) {   	
    		dc.setColor(hoursColor, Graphics.COLOR_TRANSPARENT);
      		dc.fillPolygon(hours[i]);
      	}
    }
    
    private function drawClock(dc) {
        var time = System.getClockTime();
		var minute = time.min.toFloat() + time.sec.toFloat()/60;
        var minuteHand = getHand(centerX, centerY, minute, handMinLength, handWidth, 0, true);
        var hour = (((time.hour % 12) * 60 + (time.min)).toFloat() / 12);
        var hourHand = getHand(centerX, centerY, hour, handHrLength, handWidth, 0, true);
		var secondHand = getHand(centerX, centerY, time.sec, handSecLength, 1, 5, false);
		
		dc.setColor(handSecColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(secondHand);

        dc.setColor(handHrColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(hourHand);

        dc.setColor(handMinColor, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(minuteHand);
        
        //dc.fillCircle(centerX, centerY, 3);
    }
    
    // centerX = x coord of circle centre
	// centerY = y coord of "
	// minute = from 0 to 59 representing where to point the hand
	// length = how long the hand will be, in pixels
	// width = how wide the base of the hand will be, in pixels
	// radius = how far from the centre to start the hand. 0 is at the centre. Can be + or -
	// is3Sided = if true, will be a triangle pointing to the minute. If false, will be a rectangle.
    private function getHand(centerX, centerY, minute, length, width, radius, is3Sided) {
    	var angle = minute * Math.PI / 30;
        var handShape;
        if (is3Sided) {
        	handShape = [ [-width, -radius], [0, -length], [width, -radius] ];
    	}
    	else {
    		handShape = [ [-width, -radius], [-width, -length], [width, -length], [width, -radius] ];
    	}
        var result = new [handShape.size()];
        var cosAngle = Math.cos(angle);
        var sinAngle = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < result.size(); i += 1) {
            var x = (handShape[i][0] * cosAngle) - (handShape[i][1] * sinAngle);
            var y = (handShape[i][0] * sinAngle) + (handShape[i][1] * cosAngle);
            result[i] = [ centerX+x, centerY+y];
        }
        return result;
    }
}
