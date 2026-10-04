import Quickshell
import qs.lock
import qs.notifications
import qs.picker
import qs.screentime
import qs.sysmon
import qs.updates
import qs.usage
import qs.weather

ShellRoot {
    Bar {
        sysmonPanel: sysmonPanel
        usagePanel: usagePanel
        updatesPanel: updatesPanel
        pickerPanel: pickerPanel
        notificationsPanel: notificationsPanel
        screentimePanel: screentimePanel
        weatherPanel: weatherPanel
    }

    SysmonPanel { id: sysmonPanel }
    UsagePanel { id: usagePanel }
    WeatherPanel { id: weatherPanel }
    UpdatesPanel { id: updatesPanel }
    NotificationsPanel { id: notificationsPanel }
    NotificationPopups {}
    ScreentimePanel { id: screentimePanel }
    Launcher {}
    Lock {}
    Capture {}
    PickerOverlay {}
    PickerPanel { id: pickerPanel }
}
