import QtQuick 2.3
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    anchors.fill: parent
    
    PlasmaCore.SvgItem {
        anchors.centerIn: parent
        width: parent.width < parent.height ? parent.width : parent.height
        height: width

        svg: PlasmaCore.Svg {
            imagePath: Qt.resolvedUrl("assets/logo.svg");
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                plasmoid.expanded = !plasmoid.expanded
            }
        }
    }
}