document.userScripts={saveData:{},config:{}};

document.userScripts.getMainInput = function() {
		return document.querySelector('textarea.m-0');
}

document.userScripts.getSendButton = function() {
		return document.querySelector('textarea.m-0 + button.p-1');
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
			if(	e.keyCode == 13  && 
				!e.shiftKey && !e.ctrlKey && 
				document.userScripts.config.sendOnEnter) {
					document.userScripts.getSendButton().click();
					return false;
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
