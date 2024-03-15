import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM


KCM.SimpleKCM {
    id:root

	property string cfg_downloadLocation: folderDialog.folder
	property bool cfg_sendOnEnter: sendOnEnter.checked
	property bool cfg_matchTheme: matchTheme.checked
	property bool cfg_allowClipboardAccess: allowClipboardAccess.checked

	Kirigami.FormLayout {
		id: page

		Layout.fillHeight:true

		QQC2.CheckBox {
			id: sendOnEnter
			text: i18n("Send On Enter")
		}
		QQC2.Label {
			opacity: 0.7
			text:i18n("When checked pressing Enter will send the query to ChatGPT.");
		}
		QQC2.Label {
			opacity: 0.7
			font.italic: true
			text:i18n("For now please reload the page with the 'Reload' Button after changing this configuration.");
		}

		QQC2.CheckBox {
			id: matchTheme
			text: i18n("Match OS theme")
		}

		QQC2.CheckBox {
			id: allowClipboardAccess
			text: i18n("Allow ChatGPT system clipboard access")
		}
		QQC2.Label {
			opacity: 0.7
			font.italic: true
			text:i18n("This is enabled by default to allow for quick code/recipe/etc but can be disabled if you are worried about ChatCGPT  examining your system clipboard");
		}

		QQC2.Button {
			id: downloadLocation
			text: i18n("Select Download Path : %1 ", folderDialog.folder )
			onClicked:{
				folderDialog.open();
			}
		}
		QQC2.Label {
			opacity: 0.7
			font.italic: true
			text:i18n("Select the directory to download files to.");
		}

		FolderDialog {
			id:folderDialog
		}
	}
}
