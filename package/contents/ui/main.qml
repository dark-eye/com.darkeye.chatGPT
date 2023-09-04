/*
*    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
*    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.3
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.19 as Kirigami

import QtWebEngine 1.9

Item {
	id: root
	property bool themeMismatch: false;
	property int nextReloadTime: 0
	property int reloadRetries: 0

	Plasmoid.compactRepresentation: CompactRepresentation {}

	Plasmoid.fullRepresentation: ColumnLayout {
		anchors.fill: parent

		Layout.minimumWidth: 256 * PlasmaCore.Units.devicePixelRatio
		Layout.minimumHeight:  512 * PlasmaCore.Units.devicePixelRatio
		Layout.preferredWidth: 520 * PlasmaCore.Units.devicePixelRatio
		Layout.preferredHeight: 840 * PlasmaCore.Units.devicePixelRatio

		//-----------------------------  Helpers ------------------
		// Added workaround by @zontafil thank you!
		
		Timer {
			id: exposeTimer

			interval: plasmoid.configuration.focusInterval ? plasmoid.configuration.focusInterval : 0
			running: false
			onTriggered: {
				gptWebView.forceActiveFocus();
				gptWebView.focus=true;
				gptWebView.runJavaScript("document.userScripts.setInputFocus();");
				console.log("Plasmoid exposeTimer :"+plasmoid.expanded )
			}
		}

		Connections {
			target: plasmoid
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

		ColumnLayout {
			spacing: Kirigami.Units.mediumSpacing

			PlasmaExtras.PlasmoidHeading {
				Layout.fillWidth: true

				ColumnLayout {					
					anchors.fill: parent
					Layout.fillWidth: true

					RowLayout {
						Layout.fillWidth: true

						RowLayout {
							Layout.fillWidth: true
							spacing: Kirigami.Units.mediumSpacing

							PlasmaComponents.ToolButton {
								text: i18n("Back to ChatGPT")
								visible: !gptWebView.url.toString().match(/chat\.openai\.com\/(|chat|auth)/);
								enabled: visible
								icon.name: "draw-arrow-back"
								display: PlasmaComponents.ToolButton.IconOnly
								PlasmaComponents.ToolTip.text: text
								PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
								PlasmaComponents.ToolTip.visible: hovered
								onClicked: gptWebView.url = "https://chat.openai.com/chat";
							}

							Kirigami.Heading {
								id: titleText
								Layout.alignment: Qt.AlignCenter
								Layout.fillWidth: true
								verticalAlignment: Text.AlignVCenter
								text: i18n("ChatGPT")
								color: theme.textColor
							}
						}

						PlasmaComponents.ToolButton {
							text: i18n("Debug")
							checkable: true
							checked: gptWebViewInspector.enabled
							visible: Qt.application.arguments[0] == "plasmoidviewer" || plasmoid.configuration.debugConsole
							enabled: visible
							icon.name: "format-text-code"
							display: PlasmaComponents.ToolButton.IconOnly
							PlasmaComponents.ToolTip.text: text
							PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
							PlasmaComponents.ToolTip.visible: hovered
							onToggled: {
								gptWebViewInspector.visible = !gptWebViewInspector.visible;
								gptWebViewInspector.enabled = visible || gptWebViewInspector.visible
							}
						}

						PlasmaComponents.ToolButton {
							id: proButton
							checkable: true
							checked: proLinkContainer.visible
							text: i18n("Im a Pro")
							visible: gptWebView.url.toString().match(/chat\.openai\.com\/auth/);
							icon.name: "x-office-contact"
							display: PlasmaComponents.ToolButton.IconOnly
							PlasmaComponents.ToolTip.text: text
							PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
							PlasmaComponents.ToolTip.visible: hovered
							onToggled: proLinkContainer.visible = !proLinkContainer.visible;
						}

						PlasmaComponents.ToolButton {
							id: refreshButton
							text: i18n("Reload")
							icon.name: "view-refresh"
							display: PlasmaComponents.ToolButton.IconOnly
							PlasmaComponents.ToolTip.text: text
							PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
							PlasmaComponents.ToolTip.visible: hovered
							onClicked: gptWebView.reload();
						}

						PlasmaComponents.ToolButton {
							id: pinButton
							checkable: true
							checked: plasmoid.configuration.pin
							icon.name: "window-pin"
							text: i18n("Keep Open")
							display: PlasmaComponents.ToolButton.IconOnly
							PlasmaComponents.ToolTip.text: text
							PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
							PlasmaComponents.ToolTip.visible: hovered
							onToggled: plasmoid.configuration.pin = checked
						}
					}

					RowLayout {
						id: proLinkContainer
						Layout.fillWidth: true
						visible: false;

						PlasmaComponents.TextField {
							id: proLinkField

							enabled: proLinkContainer.visible
							Layout.fillWidth: true

							placeholderText: i18n("Paste the accesss link that was send to your email.")
							text: ""
						}

						PlasmaComponents.Button {
							enabled: proLinkContainer.visible
							icon.name: "go-next"
							onClicked:  {
								gptWebView.url = proLinkField.text;
								proLinkContainer.visible= false;
							}
						}
					}
				}
			}

			//-------------------- Connections  -----------------------

			Binding {
				target: plasmoid
				property: "hideOnWindowDeactivate"
				value: !plasmoid.configuration.pin
			}
		}

		FocusScope {
			Layout.fillHeight: true
			Layout.fillWidth: true

			WebEngineView {
				anchors.fill: parent

				id: gptWebView
				focus: true
				url: "https://chat.openai.com/chat"

				profile: WebEngineProfile {
					id: chatGptProfile
					storageName: "chat-gpt"
					offTheRecord: false
					httpCacheType: WebEngineProfile.DiskHttpCache
					persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
					userScripts: [
						WebEngineScript {
							injectionPoint: WebEngineScript.DocumentCreation
							name: "helperFunctions"
							worldId: WebEngineScript.MainWorld
							sourceUrl: "./js/helper_functions.js"
						}
					]
				}

				settings.javascriptCanAccessClipboard: plasmoid.configuration.allowClipboardAccess

				onLoadingChanged: {
					if(WebEngineView.LoadSucceededStatus === loadRequest.status) {
						root.reloadRetries = 0;
						let themeLightness = (isDark(theme.backgroundColor) ? 'dark' : 'light') ;

						gptWebView.runJavaScript("document.userScripts.setConfig("+JSON.stringify(plasmoid.configuration)+");");
						gptWebView.runJavaScript("document.userScripts.setSendOnEnter();");
						gptWebView.runJavaScript("document.userScripts.getTheme();",function(theme) {
							if( !plasmoid.expanded && plasmoid.configuration.matchTheme && (!theme ||  theme !== themeLightness)) {
								gptWebView.runJavaScript("document.userScripts.setTheme('"+themeLightness+"');");
								gptWebView.relreloadAndBypassCacheoad();
							} else if(plasmoid.configuration.matchTheme && theme !== themeLightness) {
								root.themeMismatch = true;
							}
						});
						gptWebView.runJavaScript("document.userScripts.setTheme('"+themeLightness+"');");
					} else if(
						WebEngineView.LoadFailedStatus === loadRequest.status &&
						!plasmoid.expanded &&
						Date.now() > root.nextReloadTime && root.reloadRetries < 10
					) {
						console.log("Failed  when loading  page, reloading as we are hidden..");
						gptWebView.reload();
						root.reloadRetries +=1;
						root.nextReloadTime = Math.min(Date.now() + 1000 * (2**root.reloadRetries) , plasmoid.configuration.maxReloadTime * 1000);
					}
				}

				onJavaScriptConsoleMessage: if(Qt.application.arguments[0] == "plasmoidviewer") {
					console.log("Chat-GPT: " + message);
				}

				onNavigationRequested: if(request.navigationType == WebEngineNavigationRequest.LinkClickedNavigation) {
					if(request.url.toString().match(/https?\:\/\/chat\.openai\.com/)) {
						gptWebView.url = request.url;
					} else {
						Qt.openUrlExternally(request.url);
						request.action = WebEngineNavigationRequest.IgnoreRequest;
					}
				}

				function isDark(color) {
					let luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
					return (luminance < 0.5);
				}
			}
		}
	}
}


