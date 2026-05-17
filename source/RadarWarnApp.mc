import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
using Toybox.Math;

class RadarWarnApp extends Application.AppBase {
    var nearestRadarDistance as Float or Null = null;
    var alreadyAlerted = false;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        if (state != null && state.get(:launchedFromGlance) == true) {
            System.println("Launched from glance");
        } else {
            System.println("Launched normally");
        }
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onLocationUpdate)); // Llama a onLocationUpdate de forma periódica con la ubicación actualizada
    }

    function onLocationUpdate(info as Position.Info) as Void {
        if (info.accuracy == Position.QUALITY_NOT_AVAILABLE) {
            return;
        }

        var coords = info.position.toDegrees(); // [lat, lon]
        var myLat = coords[0] as Lang.Float;
        var myLon = coords[1] as Lang.Float;
        var nearRadar = false;
        var minDist = null;
        for (var i = 0; i < RADAR_POINTS.size(); i++) {
            var point = RADAR_POINTS[i]  as Lang.Array<Float>;

            var radarLat = point[0] as Float;
            var radarLon = point[1] as Float;

            var dist = haversine(myLat, myLon, radarLat, radarLon);
            if (minDist == null || dist < minDist) {
                minDist = dist;
            }

            if (dist < 1000.0) {
                nearRadar = true;
            }
            nearestRadarDistance = minDist;

            if (nearRadar) {
                if (!alreadyAlerted) {
                    triggerAlert();
                    alreadyAlerted = true;
                }
            } else {
                alreadyAlerted = false;
            }

            WatchUi.requestUpdate();
        }
    }

    function triggerAlert() as Void{
        if (Attention has :vibrate) {
            var vibeData = [
                new Attention.VibeProfile(25, 2000),
                new Attention.VibeProfile(50, 2000),
                new Attention.VibeProfile(100, 2000)
            ];
            Attention.vibrate(vibeData);
        }
    }
    function getNearestRadarDistance() as Float or Null {
        return nearestRadarDistance;
    }
    function haversine(lat1 as Float, lon1 as Float, lat2 as Float, lon2 as Float) as Float {
        var earthRadius = 6371000.0; // metros

        var dLat = degreesToRadians(lat2 - lat1);
        var dLon = degreesToRadians(lon2 - lon1);

        var rLat1 = degreesToRadians(lat1);
        var rLat2 = degreesToRadians(lat2);

        var a =
            Math.sin(dLat / 2.0) * Math.sin(dLat / 2.0) +
            Math.cos(rLat1) * Math.cos(rLat2) *
            Math.sin(dLon / 2.0) * Math.sin(dLon / 2.0);

        var c = 2.0 * Math.atan2(Math.sqrt(a), Math.sqrt(1.0 - a));

        return earthRadius * c;
    }

    function degreesToRadians(degrees as Float) as Float {
        return degrees * Math.PI / 180.0;
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        System.exit();
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new RadarWarnView()];
    }

}

function getApp() as RadarWarnApp {
    return Application.getApp() as RadarWarnApp;
}