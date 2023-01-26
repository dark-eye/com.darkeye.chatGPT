/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import QtWebEngine 1.0

Item {
    Plasmoid.fullRepresentation: ColumnLayout {
        Layout.minimumWidth: 256 * PlasmaCore.Units.devicePixelRatio
        Layout.minimumHeight:  720 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredWidth: 480 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 920 * PlasmaCore.Units.devicePixelRatio

        anchors.fill: parent
        Text {
            id:titleText
            Layout.alignment:Qt.AlignTop
            Layout.fillWidth:true
            z:100

            height:16 * PlasmaCore.Units.devicePixelRatio
            text:i18n("Chat GPT")
            color:"white"
        }
        WebEngineView {
            id:gptWebView
            Layout.fillHeight:true 
            Layout.fillWidth:true
            url:"https://chat.openai.com/chat"
        }
        Row {
            id:toolRow
            Layout.alignment:Qt.AlignBottom
            height:24 * PlasmaCore.Units.devicePixelRatio
            spacing: 5 *  PlasmaCore.Units.devicePixelRatio
            Button {
                text: i18n("Reload")
                 icon.name: "view-refresh"
                 onClicked: gptWebView.reload();
            }
            // Button {
            //     text: i18n("Speek to me")
            //     icon.name:"microphone-sensitivity-high"
            // }
        }
    }

}
 
