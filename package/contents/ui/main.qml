/*
*    SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>
*    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

import QtWebEngine

PlasmoidItem {
	id: root
	property bool themeMismatch: false;
	property int nextReloadTime: 0;
	property int reloadRetries: 0;
	property int maxReloadRetiries: 25;
	property bool loadedsuccessfully:false;

	compactRepresentation: CompactRepresentation {}

	fullRepresentation: ColumnLayout {
		anchors.fill: parent

		Layout.minimumWidth: 256 * 1
		Layout.minimumHeight:  512 * 1
		Layout.preferredWidth: 520 * 1
		Layout.preferredHeight: 840 * 1

		//-----------------------------  Helpers --------------------------------------------
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

		Timer {
			id: reloadTimer

			interval: 1000
			running:  !plasmoid.expand
			onTriggered: if(	!loadedsuccessfully &&
								!plasmoid.expanded &&
								Date.now() > root.nextReloadTime &&
								root.reloadRetries < root.maxReloadRetiries ){
					console.log("Failed to load ChatGPT page, reloading as we are hidden..");
					root.reloadRetries +=1;
					root.nextReloadTime = Math.min(Date.now() + 1000 * (2**root.reloadRetries) , plasmoid.configuration.maxReloadTime * 1000);
					gptWebView.reload();
			}
		}

		//-------------------------------------- Connections  &&  handlers ------------------------------------


		Keys.onPressed: {
			if (event.key === Qt.Key_F5 && gptWebView) {
				gptWebView.reload();
			}
			// Prevent the event from propagating further
			event.accepted = true;
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

		FileDialog {
			id:fileDialog
		}

		ColumnLayout {
			spacing: Kirigami.Units.mediumSpacing

			Kirigami.Heading {
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
							checked: gptWebViewInspector && gptWebViewInspector.enabled
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

		//-------------------------  Actual ChatGPT View --------------------------

		WebEngineView {
			// anchors.fill: parent
			Layout.fillHeight: true
			Layout.fillWidth: true

			id: gptWebView
			focus: true
			url: "https://chat.openai.com/chat"

			profile: WebEngineProfile {
				id: chatGptProfile
				storageName: "chat-gpt"
				offTheRecord: false
				httpCacheType: WebEngineProfile.DiskHttpCache
				persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
				downloadPath: (plasmoid.configuration.downloadLocation ?
									Qt.resolveUrl(plasmoid.configuration.downloadLocation) :
									chatGptProfile.downloadPath) + "/"

				onDownloadFinished: {
					console.log("onDownloadFinished : " +download.downloadDirectory + download.downloadFileName);
				}
				onDownloadRequested : {
					console.log("onDownloadRequested : " + download.downloadFileName);
					if( plasmoid.configuration.downloadLocation ) {
						download.downloadDirectory = chatGptProfile.downloadPath;
						download.accept();
						console.log("onDownloadRequested : downloaded to "+download.downloadDirectory);
						console.log("onDownloadRequested : downloaded to "+plasmoid.configuration.downloadLocation );
					} else {
						console.log("onDownloadRequested : please configure a download location");
					}
				}
			}

			settings.javascriptCanAccessClipboard: plasmoid.configuration.allowClipboardAccess

			Component.onCompleted: {
				var helperScript = {
					name: "helperFunctions",
					injectionPoint: WebEngineScript.DocumentCreation,
					sourceUrl: Qt.resolvedUrl("./js/helper_functions.js"),
					worldId: WebEngineScript.MainWorld
				}

				userScripts.collection = [ helperScript ]
			}

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
				}


				loadedsuccessfully = 	( loadRequest.status == WebEngineLoadRequest.LoadSucceededStatus && (gptWebView.loadProgress == 100 || gptWebView.loadProgress == 0))
									&&
										( !gptWebView.loading )

			}

			onFileDialogRequested: {
				console.log("onFileDialogRequested");
				//console.log(JSON.stringify(request));
				fileDialog.title = "Choose File";
				fileDialog.accept.connect(function (request){
					request.dialogAccept(fileDialog.selectedFiles);
				});
				fileDialog.reject.connect(function(request) {
					request.dialogReject()
				});
				fileDialog.open();
				request.accepted = true
			}

			onJavaScriptDialogRequested : {
				console.log("onJavaScriptDialogRequested");
			}

			onNewWindowRequested : {
				console.log("onNewViewRequested");
				if(request.requestedUrl.toString().match(/https?\:\/\/chat\.openai\.com/)) {
					gptWebView.url = request.requestedUrl;
					console.log(request.url);
				} else {
					Qt.openUrlExternally(request.url);
					request.action = WebEngineNavigationRequest.IgnoreRequest;
				}
			}

			onJavaScriptConsoleMessage: if( Qt.application.arguments[0].match(/plasmoidviewer/) ) {
				console.log("Chat-GPT: " + message);
			}

			onNavigationRequested: {
				if(request.navigationType == WebEngineNavigationRequest.LinkClickedNavigation) {
					if(request.url.toString().match(/https?\:\/\/chat\.openai\.com/)) {
						gptWebView.url = request.url;
						console.log(request.url);
					} else {
						Qt.openUrlExternally(request.url);
						request.action = WebEngineNavigationRequest.IgnoreRequest;
					}
				}
			}

			function isDark(color) {
				let luminance = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
				return (luminance < 0.5);
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
	}
}


