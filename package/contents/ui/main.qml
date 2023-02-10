/*
    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.3
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import QtWebEngine 1.9

Item {
    // Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground
    Plasmoid.compactRepresentation:  Image {
                anchors.fill:parent
                smooth: true
                cache:true
                asynchronous:true
                mipmap:true
                fillMode: Image.PreserveAspectFit
                source:"assets/logo.svg"
                MouseArea {
                    anchors.fill:parent
                    onClicked: { 
                        plasmoid.expanded = !plasmoid.expanded
                    }
                }
            }
    Plasmoid.fullRepresentation: ColumnLayout {
        Layout.minimumWidth: 256 * PlasmaCore.Units.devicePixelRatio
        Layout.minimumHeight:  720 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredWidth: 480 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 920 * PlasmaCore.Units.devicePixelRatio

         Connections {
            target:plasmoid
            function onActivated() {
                console.log("Plasmoid revealed to user")
            }
            function onStatusChanged() {
                console.log("Plasmoid status chagned "+plasmoid.status)
            }
            function hideOnWindowDeactivateChanged() {
                console.log("Plasmoid hideOnWindowDeactivateChanged chagned")
            }
            function onExpandedChanged() {
                if(gptWebView && plasmoid.expanded) {
                    gptWebView.forceActiveFocus();
                    gptWebView.focus=true;
                    gptWebView.runJavaScript("document.userScripts.setInputFocus();");
                }
                console.log("Plasmoid onExpandedChanged :"+plasmoid.expanded )
            }
        }

        anchors.fill: parent
        Row {
            spacing:2 * PlasmaCore.Units.devicePixelRatio
            Image {
                height:parent.height
                width:height
                smooth: true
                cache:true
                asynchronous:true
                mipmap:true
                fillMode: Image.PreserveAspectFit
                source:"assets/logo.svg"
            }
            Text {
                id:titleText
                Layout.alignment:Qt.AlignCenter
                Layout.fillWidth:true
                verticalAlignment:Text.AlignVCenter
                height:24 * PlasmaCore.Units.devicePixelRatio
                text:i18n("Chat-GPT")
                color:"white"
            }
        }
        FocusScope {
            Layout.fillHeight:true
            Layout.fillWidth:true
            WebEngineView {
                id:gptWebView
                anchors.fill:parent

                focus: true

                url:"https://chat.openai.com/chat"

                profile: WebEngineProfile {
                    id:chatGptProfile
                    storageName: "chat-gpt"
                    offTheRecord:false
                    // persistentStoragePath:"/home/eran/.local/share/plasmashell/QtWebEngine/ChatGPT/"
                    httpCacheType: WebEngineProfile.DiskHttpCache
                    persistentCookiesPolicy:WebEngineProfile.ForcePersistentCookies
                    userScripts: [
                        WebEngineScript {
                            injectionPoint:WebEngineScript.DocumentCreation
                            name:"helperFunctions"
                            worldId:WebEngineScript.MainWorld
                            sourceUrl:"./js/helper_functions.js"
                        }
                    ]
                }
                onLoadingChanged:  {
                    if(WebEngineView.LoadSucceededStatus == loadRequest.status) {
                        var themeLightness = (isDark(theme.backgroundColor) ? 'dark' : 'light') ;
                        gptWebView.runJavaScript("document.userScripts.setConfig("+JSON.stringify(plasmoid.configuration)+");");
                        gptWebView.runJavaScript("document.userScripts.setSendOnEnter();");
                        // gptWebView.runJavaScript("
                        // var meta = document.createElement('meta');
                        //     meta.name = 'prefers-color-scheme';
                        //     meta.content =  '"+ themeLightness + "';
                        //     document.getElementsByTagName('head')[0].appendChild(meta);
                        // ");
                        // gptWebView.runJavaScript("function setInputFocus() {
                        //     let inputElement = document.querySelector('textarea.m-0');
                        //     if(inputElement) {
                        //         inputElement.focus();
                        //     }
                        // }");
                    }
                }

                onJavaScriptConsoleMessage :{
                    console.log("Chat-GPT : " + message);
                }

                onNavigationRequested :if(request.navigationType == WebEngineNavigationRequest.LinkClickedNavigation){
                    if(request.url.toString().match(/https?\:\/\/chat\.openai\.com/)) {
                        gptWebView.url = request.url;
                    } else {
                        request.action = WebEngineNavigationRequest.IgnoreRequest;
                        Qt.openUrlExternally(request.url);
                    }
                }

                function isDark(color) {
                    var luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
                    return (luminance < 0.5);
                }
                WebEngineView {
                    id:gptWebViewInspector
                    enabled:false
                    visible: false
                    z:100
                    anchors {
                        left:parent.left
                        right:parent.right
                        bottom:parent.bottom
                    }
                    height:parent.height /2
                    Layout.fillWidth:true
                
                    inspectedView:gptWebView
                }
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
                text: i18n("Back to ChatGPT")
                visible:!gptWebView.url.toString().match(/chat\.openai\.com\/(chat|auth)/);
                enabled:visible
                 icon.name: "edit-undo"
                 onClicked: gptWebView.url = "https://chat.openai.com/chat";
            }
            Button {
                text: i18n("Debug")
                visible: Qt.application.arguments[0] == "plasmoidviewer"
                enabled:visible
                 icon.name: "view-refresh"
                 onClicked: {
                     gptWebViewInspector.enabled = gptWebViewInspector.visible = !gptWebViewInspector.visible;
                 }
            }
            // Button {
            //     text: i18n("Speek to me")
            //     icon.name:"microphone-sensitivity-high"
            //      onClicked: {
            //          console.log(chatGptProfile.persistentStoragePath)
            //      }
            // }
        }
    }

}
 
