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

import QtWebEngine 1.7

Item {
    Connections {
        target:plasmoid
        function onActivated() {
            console.log("Plasmoid revealed to user")
            gptWebView.forceActiveFocus();
            gptWebView.runJavaScript("setInputFocus();");
        }
        function onStatusChanged() {
            console.log("Plasmoid status chagned : "+status)
        }
        function hideOnWindowDeactivateChanged() {
            console.log("Plasmoid hideOnWindowDeactivateChanged chagned")
        }
        function onExpandedChanged() {
            console.log("Plasmoid onExpandedChanged")
        }
    }
    // Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground

    Plasmoid.fullRepresentation: ColumnLayout {
        Layout.minimumWidth: 256 * PlasmaCore.Units.devicePixelRatio
        Layout.minimumHeight:  720 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredWidth: 480 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 920 * PlasmaCore.Units.devicePixelRatio

        anchors.fill: parent
        Row {
            spacing:2 * PlasmaCore.Units.devicePixelRatio
            Image {
                height:parent.height
                width:height
                source:"assets/logo.svg"
            }
            Text {
                id:titleText
                Layout.alignment:Qt.AlignTop
                Layout.fillWidth:true
                z:100

                height:16 * PlasmaCore.Units.devicePixelRatio
                text:i18n("Chat GPT")
                color:"white"
            }
        }
        WebEngineView {
            id:gptWebView
            Layout.fillHeight:true 
            Layout.fillWidth:true

            focus: true

            url:"https://chat.openai.com/chat"
            profile: WebEngineProfile {
                storageName: "chat-gpt"
            }
            onLoadingChanged:  {
                 if(WebEngineView.LoadSucceededStatus == loadRequest.status) {
                    var themeLightness = (isDark(theme.backgroundColor) ? 'dark' : 'light') ;
                    console.log(" Page successfully loaded  loading custom scripts...");
                    gptWebView.runJavaScript("
                    var meta = document.createElement('meta');
                        meta.name = 'prefers-color-scheme';
                        meta.content =  '"+ themeLightness + "';
                        document.getElementsByTagName('head')[0].appendChild(meta);
                    ");
                    gptWebView.runJavaScript("function setInputFocus() {
                        let inputElement = document.querySelector('textarea.m-0');
                        inputElement.focus();
                    }");
                }
            }

            onJavaScriptConsoleMessage :{
                console.log("Chat-GPT : "+message);
            }

            onNavigationRequested :if(request.navigationType == WebEngineNavigationRequest.LinkClickedNavigation){
                Qt.openUrlExternally(request.url);
            }

            function isDark(color) {
                var luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
                return (luminance < 0.5);
            }
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
            Button {
                text: i18n("Focus")
                 icon.name: "view-refresh"
                 onClicked: {
                     gptWebView.forceActiveFocus();
                     gptWebView.runJavaScript("setInputFocus();");
                }
            }
            // Button {
            //     text: i18n("Speek to me")
            //     icon.name:"microphone-sensitivity-high"
            // }
        }
    }

}
 
