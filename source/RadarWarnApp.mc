import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Timer;
using Toybox.Math;

class RadarWarnApp extends Application.AppBase {
    var nearestRadarDistance as Float or Null = null;
    var alreadyAlerted as Boolean = false;
    var gpsFind as Boolean = false;
    var lastAccuracy as Number = -1;
    var radarPasado as Boolean = false;
    var distanciaAnterior as Float or Null = null;
    var approachingCount as Number = 0;
    var numAlerts as Number = 0;
    var _poller as Timer.Timer or Null = null;
    var alert_distance as Float = 5000.0f;

    const RADAR_COORD_ERROR_M = 150.0f;
    const ALERT_EXIT_M = 5500.0f;
    const NUM_ALERTS = 3;
    const ALERT_DISTANCE  = 5000.0f;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        // Callback vacío — solo despierta el GPS en el reloj físico
        System.println("Activando GPS...");
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:_warmup)
        );
    }

    // Callback vacío obligatorio para despertar el GPS
    function _warmup(info as Position.Info) as Void {}

    // Llamado desde RadarWarnView.onShow()
    function startPolling() as Void {
        System.println("Polling GPS...");
        if (_poller == null) {
            _poller = new Timer.Timer();
            _poller.start(method(:_pollGps), 2000, true);
        }
    }

    // Llamado desde RadarWarnView.onHide()
    function stopPolling() as Void {
        if (_poller != null) {
            _poller.stop();
            _poller = null;
        }
    }

    // Se ejecuta cada 2 segundos
    function _pollGps() as Void {
        var info = Position.getInfo();

        if (info == null || info.position == null) {
            gpsFind = false;
            lastAccuracy = -1;
            WatchUi.requestUpdate();
            return;
        }
        System.println("Polling GPS 2...");
        lastAccuracy = info.accuracy;

        if (info.accuracy == Position.QUALITY_NOT_AVAILABLE ||
            info.accuracy == Position.QUALITY_LAST_KNOWN) {
            gpsFind = false;
            WatchUi.requestUpdate();
            return;
        }

        gpsFind = true;

        var coords = info.position.toDegrees();
        var myLat = coords[0] as Float;
        var myLon = coords[1] as Float;


        var minDist = findNearestRadarDistance(myLat, myLon);
        
        System.println("Posición GPS: " +coords + " (Acc: " + info.accuracy.toString() + "m)");

        if (minDist == null) {
            nearestRadarDistance = null;
            radarPasado = false;
            alreadyAlerted = false;
            WatchUi.requestUpdate();
            return;
        } 
        var gpsError = estimateGpsErrorMeters(info.accuracy);
        var effectiveDist = conservativeDistance(minDist, gpsError,RADAR_COORD_ERROR_M);

        smoothDistance(effectiveDist);
        System.println("Distancia al radar más cercano: " + (nearestRadarDistance as Float).format("%.1f") + "m (Efectiva: " + effectiveDist.format("%.1f") + "m, GPS error estimado: " + gpsError.format("%.1f") + "m)");

        var isApproaching = true;

        if (distanciaAnterior != null) {
            var prev = distanciaAnterior as Float;

            if (minDist < prev - 20.0f) {
                approachingCount++;
                radarPasado = false;
            } else if (minDist > prev + 80.0f) {
                approachingCount = 0;
                radarPasado = true;
            }

            isApproaching = approachingCount >= 2;
        }
        distanciaAnterior = minDist;

        if (isApproaching && effectiveDist <= alert_distance && numAlerts <= NUM_ALERTS) {
            alert_distance = alert_distance * 0.5f;
            if (alert_distance < 100.0f) {
                numAlerts = NUM_ALERTS;
                alreadyAlerted = true;
                System.println("Alerta máxima alcanzada, no se alertará de nuevos radares hasta que se aleje.");
            } else {
                triggerAlert();
                numAlerts = numAlerts + 1;
                if (numAlerts == NUM_ALERTS) {
                    System.println("Alerta máxima alcanzada, no se alertará de nuevos radares hasta que se aleje.");
                    alreadyAlerted = true;
                }
            }
            
        }

        if (alreadyAlerted && effectiveDist > ALERT_EXIT_M) {
            alreadyAlerted = false;
            numAlerts = 0;
            alert_distance = ALERT_DISTANCE;
            System.println("Se ha alejado del radar, se restablecen las alertas.");
        }

        WatchUi.requestUpdate();
    }
    
    function smoothDistance(newDist as Float) as Float {
        if (nearestRadarDistance == null) {
            nearestRadarDistance = newDist;
        } else {
            nearestRadarDistance = ((nearestRadarDistance as Float) * 0.7f) + (newDist * 0.3f);
        }

        return nearestRadarDistance as Float;
    }

    function triggerAlert() as Void {
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

    function onStop(state as Dictionary?) as Void {
        stopPolling();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new RadarWarnView()];
    }
}

function getApp() as RadarWarnApp {
    return Application.getApp() as RadarWarnApp;
}