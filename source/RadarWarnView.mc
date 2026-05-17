import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

class RadarWarnView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        var width = dc.getWidth();
        var height = dc.getHeight();

        var clock = System.getClockTime();

        var hourText = clock.hour < 10
            ? "0" + clock.hour.toString()
            : clock.hour.toString();

        var minText = clock.min < 10
            ? "0" + clock.min.toString()
            : clock.min.toString();

        var timeText = hourText + ":" + minText;

        dc.drawText(
            width / 2,
            height / 4,
            Graphics.FONT_LARGE,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var app = Application.getApp() as RadarWarnApp;
        var distance = app.getNearestRadarDistance();

        var distanceText = "Buscando GPS...";

        if (distance != null) {
            if (distance >= 1000.0) {
                var km = distance / 1000.0;
                distanceText = km.format("%.1f") + " km";
            } else {
                distanceText = distance.toNumber().toString() + " m";
            }
        }

        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_LARGE,
            distanceText,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            width / 2,
            height * 3 / 4,
            Graphics.FONT_SMALL,
            "Radar mas cercano",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
