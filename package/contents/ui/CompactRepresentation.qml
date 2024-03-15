import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg

Item {
    anchors.fill: parent

    KSvg.SvgItem {
        anchors.centerIn: parent
        width: parent.width < parent.height ? parent.width : parent.height
        height: width
        imagePath: Qt.resolvedUrl("assets/logo.svg");

        MouseArea {
            anchors.fill: parent

            onClicked: {
                expanded = !expanded
            }
        }
    }
}
