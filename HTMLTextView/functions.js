function showParagraph(displayLimit) {
	var target = document.getElementById('myDiv');
	var text = target.innerHTML;
	var paragraphs = text.split('\n');
	var displayText = "";
	for (var i = 0; i < displayLimit; i++) {
		if (paragraphs[i] != undefined) {
			displayText += paragraphs[i] + "\n";
		}
	}
	if (paragraphs.length > displayLimit) {
		displayText += "<span id='dots'>...</span><span id='more' style='display:none'>";
		for (var i = displayLimit; i < paragraphs.length; i++) {
			displayText += paragraphs[i] + "\n";
		}
		displayText += "</span><br>";
	}
	target.innerHTML = displayText;
};

function readMore() {
	var dots = document.getElementById("dots");
	var moreText = dots.nextSibling;
	if (dots.style.display === "none" || '') {
		console.log('hello') dots.style.display = "inline";
		moreText.style.display = "none";
	} else {
		dots.style.display = "none";
		moreText.style.display = "inline";
	}
};

function getLenghtText() {
	var target = document.getElementById('myDiv');
	var paragraphHTML = target.innerHTML.split('\n');
	console.log(paragraphHTML.length);
	window.webkit.messageHandlers.iosListener.postMessage("perrrrooooo");
};
