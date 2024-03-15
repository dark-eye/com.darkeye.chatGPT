import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id:root

    property int cfg_focusInterval: focusInterval.value
    property int cfg_maxReloadTime: maxReloadTime.value
    property bool cfg_debugConsole: debugConsole.checked

    Kirigami.FormLayout {
        id: page

        Layout.fillHeight:true

        QQC2.Slider {
            Kirigami.FormData.label:i18n("Focus input after  : %1ms",focusInterval.value );
            id: focusInterval
            from:0
            stepSize:10
            value:0
            to:1000
            live:true
        }

        QQC2.Label {
            opacity: 0.7
            font.italic: true
            text:i18n("This is a workaround to allow input field to be fcoused when using the widget shortcut.") +
                        "\n" +
                i18n("incrase the timeout if theres  issues with focusing on the input  when using  the shortcut.");
        }

        QQC2.CheckBox {
            id: debugConsole
            Layout.alignment: Qt.AlignBottom
            Kirigami.FormData.label: i18n("Show debug console")
        }


        QQC2.Slider {
            Kirigami.FormData.label:i18n("Max realod is set to  : %1 second ",maxReloadTime.value );
            id: maxReloadTime
            from:0
            stepSize:10
            value:30
            to:3600
            live:true
        }
        QQC2.Label {
            opacity: 0.7
            font.italic: true
            text:i18n("This is a limit on how often the widget will try to auto reload the page (when hidden) if the page failed to load.");
        }
    }
}
