import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
     ConfigCategory {
        name: i18n("Advanced")
        icon: "tools"
        source: "configAdvanced.qml"
    }
}
