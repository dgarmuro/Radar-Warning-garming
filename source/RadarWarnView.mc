import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.Lang;

class RadarWarnView extends WatchUi.View {

    private const COLOR_BG     = 0x000000;
    private const COLOR_WHITE  = 0xFFFFFF;
    private const COLOR_ACCENT = 0xCCFF00;
    private const COLOR_DIM    = 0x444444;
    private const COLOR_INFO   = 0x4A9EFF;
    private const COLOR_WARN   = 0xFF8C00;

    function initialize() {
        View.initialize();
    }

   function onShow() as Void {
        Application.getApp().startPolling();
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        Application.getApp().stopPolling();
    }

    function onUpdate(dc as Dc) as Void {
        var w  = dc.getWidth();
        var h  = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        // Fondo negro
        dc.setColor(COLOR_BG, COLOR_BG);
        dc.clear();

        // Anillo decorativo
        dc.setPenWidth(2);
        dc.setColor(0x1A1A1A, COLOR_BG);
        dc.drawCircle(cx, cy, (w / 2) - 8);

        // Hora
        var clock    = System.getClockTime();
        var timeText = _pad(clock.hour) + ":" + _pad(clock.min); // Para mostrar siempre dos dígitos

        dc.setColor(COLOR_WHITE, COLOR_BG);
        dc.drawText(
            cx,
            h * 36 / 100,
            Graphics.FONT_NUMBER_MEDIUM,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Separador corto bajo la hora
        var sepY = h * 52 / 100;
        dc.setPenWidth(1);
        dc.setColor(0x222222, COLOR_BG);
        dc.drawLine(cx - 36, sepY, cx + 36, sepY);

        // Distancia / estado
        var app      = Application.getApp() as RadarWarnApp;
        var distance = app.getNearestRadarDistance();

        _drawStatus(dc, cx, h, distance, app.gpsFind);
    }

    private function _drawStatus(
        dc as Dc,
        cx as Number,
        h as Number,
        distance as Float or Null,
        gpsReady as Boolean
    ) as Void {

        var labelY = h * 52 / 100;
        var valueY = h * 65 / 100;
        var iconY  = h * 78 / 100;

        if (distance != null) {

            dc.setColor(COLOR_DIM, COLOR_BG);
            dc.drawText(
                cx,
                labelY,
                Graphics.FONT_XTINY,
                "RADAR CERCA APROX.",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            var col = (distance < 2000.0f) ? COLOR_WARN : COLOR_ACCENT;

            dc.setColor(col, COLOR_BG);
            var valueText = _formatDistanceValue(distance);
            var unitText  = _formatDistanceUnit(distance);

            dc.drawText(
                cx - 12,
                valueY,
                Graphics.FONT_NUMBER_MILD,
                valueText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.drawText(
                cx + 25,
                valueY + 4,
                Graphics.FONT_XTINY,
                unitText,
                Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
            );

            _drawRadarIcon(dc, cx, iconY, col);

        } else if (gpsReady) {

            dc.setColor(COLOR_DIM, COLOR_BG);
            dc.drawText(
                cx,
                labelY,
                Graphics.FONT_XTINY,
                "RADAR",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.setColor(COLOR_INFO, COLOR_BG);
            dc.drawText(
                cx,
                valueY,
                Graphics.FONT_SMALL,
                "NO RADAR CERCANO",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            _drawRadarIcon(dc, cx, iconY, COLOR_DIM);

        } else {

            dc.setColor(COLOR_DIM, COLOR_BG);
            dc.drawText(
                cx,
                h * 66 / 100,
                Graphics.FONT_SMALL,
                "BUSCANDO GPS",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    // Tres círculos concéntricos tipo radar
    private function _drawRadarIcon(
        dc as Dc,
        cx as Number,
        cy as Number,
        color as Number
    ) as Void {

        dc.setPenWidth(1);

        dc.setColor(0x1A1A1A, COLOR_BG);
        dc.drawCircle(cx, cy, 10);

        dc.setColor(COLOR_DIM, COLOR_BG);
        dc.drawCircle(cx, cy, 6);

        dc.setColor(color, COLOR_BG);
        dc.fillCircle(cx, cy, 2);
    }

    private function _formatDistanceValue(dist as Float) as String {
        if (dist >= 1000.0f) {
            return (dist / 1000.0f).format("%.1f");
        }

        var rounded = ((dist + 25.0f) / 50.0f).toNumber() * 50;
        return rounded.toString();
    }

    private function _formatDistanceUnit(dist as Float) as String {
        if (dist >= 1000.0f) {
            return "KM";
        }

        return "M";
    }

    private function _pad(val as Number) as String {
        return val < 10 ? "0" + val.toString() : val.toString();
    }
}