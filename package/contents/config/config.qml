import QtQuick 2.3
import org.kde.plasma.configuration 2.0

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
