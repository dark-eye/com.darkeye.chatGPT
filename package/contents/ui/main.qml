/*
*    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
*    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.3
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import QtWebEngine 1.9
// import QtWebEngineCore 1.15
// import QtWebChannel 1.0

Item {
	id:root
	property bool themeMismatch: false;
	property int nextReloadTime: 0
	property int reloadRetries: 0

	// Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground
	Plasmoid.compactRepresentation: Item {
		anchors.fill:parent
		PlasmaCore.SvgItem {
			anchors.centerIn : parent
			width:parent.width < parent.height ? parent.width : parent.height
			height:width

			svg : PlasmaCore.Svg {
				imagePath:Qt.resolvedUrl("assets/logo.svg");
			}

			MouseArea {
				anchors.fill:parent
				onClicked: {
					plasmoid.expanded = !plasmoid.expanded
				}
			}
		}
	}
	Plasmoid.fullRepresentation: ColumnLayout {
		Layout.minimumWidth: 256 * PlasmaCore.Units.devicePixelRatio
		Layout.minimumHeight:  512 * PlasmaCore.Units.devicePixelRatio
		Layout.preferredWidth: 480 * PlasmaCore.Units.devicePixelRatio
		Layout.preferredHeight: 920 * PlasmaCore.Units.devicePixelRatio


		//-----------------------------  Helpers ------------------
		// Added workaround by @zontafil thank you!
		Timer {
			id:exposeTimer

			interval:plasmoid.configuration.focusInterval ? plasmoid.configuration.focusInterval : 0
			running:false
			onTriggered: {
				gptWebView.forceActiveFocus();
				gptWebView.focus=true;
				gptWebView.runJavaScript("document.userScripts.setInputFocus();");
				console.log("Plasmoid exposeTimer :"+plasmoid.expanded )
			}
		}

		Connections {
			target:plasmoid
			function onActivated() {
				console.log("Plasmoid revealed to user")
			}
			function onStatusChanged() {
				console.log("Plasmoid status changed "+plasmoid.status)
			}
			function hideOnWindowDeactivateChanged() {
				console.log("Plasmoid hideOnWindowDeactivateChanged changed")
			}
			function onExpandedChanged() {
				if(gptWebView && plasmoid.expanded) {
					if(gptWebView.LoadStatus == WebEngineView.LoadFailedStatus) {
						gptWebView.reload();
					}

					exposeTimer.start();
				}
				if(!plasmoid.expanded && root.themeMismatch && plasmoid.configuration.matchTheme ) {
					root.themeMismatch = false;
					gptWebView.reloadAndBypassCache();
				}
				console.log("Plasmoid onExpandedChanged :"+plasmoid.expanded )
			}
		}

		//------------------------------------- UI -----------------------------------------

		anchors.fill: parent
		Column {
			anchors {
				right:parent.right;
				left: parent.left;
				top:parent.top;
			}
			height: 24 * PlasmaCore.Units.devicePixelRatio
			spacing: 2 * PlasmaCore.Units.devicePixelRatio
			Row {
				anchors {
					right:pinButton.left;
					left: parent.left;
					top:parent.top;
					bottom:parent.bottom
				}
				spacing: 2 * PlasmaCore.Units.devicePixelRatio
				PlasmaCore.SvgItem {
					height:parent.height
					width:height
					svg: PlasmaCore.Svg {
						imagePath:Qt.resolvedUrl("./assets/logo.svg");
					}
				}
				Text {
					id:titleText
					Layout.alignment:Qt.AlignCenter
					Layout.fillWidth:true
					height:parent.height
					verticalAlignment:Text.AlignVCenter
					text:i18n("Chat-GPT")
					color:theme.textColor
				}
			}
			Button {
				id:pinButton
				height:24 * PlasmaCore.Units.devicePixelRatio
				width:height
				anchors {
					right: parent.right;
					top:parent.top;
				}
				checkable: true
				icon.name: "window-pin"
				checked: plasmoid.configuration.pin
				onCheckedChanged: plasmoid.configuration.pin = checked
			}
			//-------------------- Connections  -----------------------
			Binding {
				target: plasmoid
				property: "hideOnWindowDeactivate"
				value: !plasmoid.configuration.pin
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
					//persistentStoragePath:"~/.local/share/plasmashell/QtWebEngine/ChatGPT/"
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

				settings.javascriptCanAccessClipboard: plasmoid.configuration.allowClipboardAccess

				onLoadingChanged:  {
					if(WebEngineView.LoadSucceededStatus === loadRequest.status) {
						root.reloadRetries = 0;
						var themeLightness = (isDark(theme.backgroundColor) ? 'dark' : 'light') ;
						gptWebView.runJavaScript("document.userScripts.setConfig("+JSON.stringify(plasmoid.configuration)+");");
						gptWebView.runJavaScript("document.userScripts.setSendOnEnter();");
						gptWebView.runJavaScript("document.userScripts.getTheme();",function(theme) {
							console.log("GetTheme run :" + theme);
							if( !plasmoid.expanded && plasmoid.configuration.matchTheme && (!theme ||  theme !== themeLightness)) {
								gptWebView.runJavaScript("document.userScripts.setTheme('"+themeLightness+"');");
								gptWebView.relreloadAndBypassCacheoad();
							} else  if(plasmoid.configuration.matchTheme && theme !== themeLightness) {
								root.themeMismatch = true;
							}
						});
						gptWebView.runJavaScript("document.userScripts.setTheme('"+themeLightness+"');");

					} else if(WebEngineView.LoadFailedStatus === loadRequest.status &&
						!plasmoid.expanded &&
						Date.now() > root.nextReloadTime && root.reloadRetries < 10) {
						console.log("Failed  when loading  page, reloading as  we are hidden..");
					gptWebView.reload();
					root.reloadRetries +=1;
					root.nextReloadTime = Date.now() + 1000*(2**root.reloadRetries);
						}
				}

				onJavaScriptConsoleMessage : if (Qt.application.arguments[0] == "plasmoidviewer") {
					console.log("Chat-GPT : " + message);
				}

				onNavigationRequested :if(request.navigationType == WebEngineNavigationRequest.LinkClickedNavigation){
					if(request.url.toString().match(/https?\:\/\/chat\.openai\.com/)) {
						gptWebView.url = request.url;
					} else {
						Qt.openUrlExternally(request.url);
						request.action = WebEngineNavigationRequest.IgnoreRequest;
					}
				} else {
					console.log(request.url)
				}

				function isDark(color) {
					var luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
					return (luminance < 0.5);
				}
			}
		}
		WebEngineView {
			id:gptWebViewInspector
			enabled: false
			visible: false
			z:100
			height:parent.height /2

			Layout.fillWidth:true
			Layout.alignment:Qt.AlignBottom
			inspectedView:enabled ? gptWebView : null
		}
		Row {
			id:proLinkContainer
			Layout.fillWidth:true
			visible:false;
			TextField {
				id:proLinkField

				enabled: proLinkContainer.visible
				Layout.fillWidth:true

				placeholderText:i18n("Paste the accesss link that was send to your email.")
				text:""
			}
			Button {
				// text: i18n("ChatGPT Pro")
				enabled: proLinkContainer.visible
				icon.name: "go-next"
				onClicked:  {
					gptWebView.url = proLinkField.text;
					proLinkContainer.visible= false;
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
				text: i18n("Im a Pro")
				visible:gptWebView.url.toString().match(/chat\.openai\.com\/auth/);
				icon.name: "x-office-contact"
				onClicked: proLinkContainer.visible = true;
			}
			Button {
				text: i18n("Back to ChatGPT")
				visible:!gptWebView.url.toString().match(/chat\.openai\.com\/(|chat|auth)/);
				enabled:visible
				icon.name: "edit-undo"
				onClicked: gptWebView.url = "https://chat.openai.com/chat";
			}
			Button {
				text: i18n("Debug")
				visible: Qt.application.arguments[0] == "plasmoidviewer" || plasmoid.configuration.debugConsole
				enabled:visible
				icon.name: "view-refresh"
				onClicked: {
					gptWebViewInspector.visible = !gptWebViewInspector.visible;
					gptWebViewInspector.enabled = visible || gptWebViewInspector.visible
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


