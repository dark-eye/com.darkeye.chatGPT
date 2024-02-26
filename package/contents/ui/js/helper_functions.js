document.userScripts={saveData:{},config:{}};

document.userScripts.getMainInput = function() {
		return document.querySelector('textarea#prompt-textarea');
}

document.userScripts.getSendButton = function() {
		console.log(document.querySelector('button[data-testid=send-button]'));
		return document.querySelector('button[data-testid=send-button]');
}

document.userScripts.getStopButton = function() {
		return document.querySelector('button[aria-label=Stop generating]');
}


document.userScripts.setInputFocus = function () {
	let inputElement = document.userScripts.getMainInput();
	if(inputElement) {
		inputElement.focus();
	}
	console.log('setInputFocus');
}


document.userScripts.setSendOnEnter = function () {

	let inputElement =  document.userScripts.getMainInput();
	if(inputElement && !document.userScripts.saveData.oldOnPress) {
		document.userScripts.saveData.oldOnPress = inputElement.onkeypress;
		inputElement.onkeypress = function(e) {
			// console.log('keypress : ' + e.keyCode);
			if(document.userScripts.config.sendOnEnter) {
				if(	!e.shiftKey && !e.ctrlKey )
					switch(e.keyCode) {
						case 13 : {
								document.userScripts.getSendButton().click();
								return false;
						}
						break;
					}
			}
		}
	}

	console.log('setSendOnEnter');
}

document.userScripts.setTheme = function (theme) {
	if( document.userScripts.config && document.userScripts.config.matchTheme && theme ) {
		localStorage.setItem('theme', theme);
		console.log('setTheme');
	}
}

document.userScripts.getTheme = function () {	
	return localStorage.getItem('theme');
}

document.userScripts.removeSendOnEnter = function () {
	let inputElement =  document.userScripts.getMainInput();
	if(inputElement) {
		inputElement.onkeypress = document.userScripts.saveData.oldOnPress;
		document.userScripts.saveData.oldOnPress = null;
	}
	console.log('removeSendOnEnter');
}

document.userScripts.setConfig = function (configuration) {
	document.userScripts.config = configuration;
	console.log('setConfig : ' + JSON.stringify(configuration));
}

console.log('Helper Functions loaded');
