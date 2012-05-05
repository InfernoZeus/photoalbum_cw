var _playing = false, _slideshowPlaying = false;
var _currentImage = window.opener._currentImage;
var _slideInterval;
var _slideshowInterval;
var ALBUM_LENGTH = window.opener.ALBUM_LENGTH;


function onLoad(){
    var div = document.getElementById('div0')
    window.opener.changeImage(_currentImage, div, 750);  
}

function playSlideshow(){

    if(_currentImage == ALBUM_LENGTH - 1 || _playing) return false;
  
    if(_slideshowPlaying) {
        stopSlideshow();
        return false;
    }
  
    _slideshowPlaying = true;
    document.getElementById('play').src='stop.gif';
    _slideshowInterval = setInterval("nextSlide()", 2000);
}

function nextSlide(){

    if(_currentImage == ALBUM_LENGTH - 1){
        stopSlideshow();
        return false;
    }  
    nextPage();
}

function stopSlideshow(){

    _slideshowPlaying = false;
    clearInterval(_slideshowInterval);
    document.getElementById('play').src='play.gif';
}


//The following page change functions are duplicated from script.js
//They have to be seperate as the windows should not interfere.
//However they do reference the image array from the main window as required in the spec.


function nextPage(){

    if(_currentImage == ALBUM_LENGTH - 1  || _playing) 
        return false;
  
    var slideDiv0 = document.getElementById('div0');
    var slideDiv1 = document.getElementById('div1'); 

    window.opener.changeImage(++_currentImage, slideDiv1, 750);
    startSlide(slideDiv0,"up");
}

function lastPage(){
  
    stopSlideshow();

    if(_currentImage == ALBUM_LENGTH - 1  || _playing) 
        return false;

    var slideDiv0 = document.getElementById('div0');
    var slideDiv1 = document.getElementById('div1'); 

    _currentImage = ALBUM_LENGTH - 1;
    window.opener.changeImage(_currentImage, slideDiv1, 750);  
    startSlide(slideDiv0,"up");  
}

function prevPage(){

    stopSlideshow();

    if(_currentImage == 0 || _playing) 
        return false;

    var slideDiv0 = document.getElementById('div0');
    var slideDiv1 = document.getElementById('div1'); 

    window.opener.changeImage(--_currentImage, slideDiv0, 750);  
    window.opener.changeImage(_currentImage + 1, slideDiv1, 750);  

    slideDiv0.style.marginTop = '-750px';
    startSlide(slideDiv0,"down");

}

function firstPage(){

    stopSlideshow();
  
    if(_currentImage == 0 || _playing) 
        return false;
    
    var slideDiv0 = document.getElementById('div0');
    var slideDiv1 = document.getElementById('div1'); 

    window.opener.changeImage(_currentImage, slideDiv1, 750);
    _currentImage = 0;  
    window.opener.changeImage(_currentImage, slideDiv0, 750);  

    slideDiv0.style.marginTop = '-750px';
    startSlide(slideDiv0,"down");  
}

function startSlide(pSlideDiv, pDirection){
  
    var increment = (pDirection=="up") ? 50: -50;
    if(!window.opener._playAnimations) increment *= 15;
    _playing = true;
    _slideInterval = setInterval(function() {
        slideDiv(pSlideDiv,increment)
        },15);

}


function slideDiv(pDiv, pDistance){
  
    var over = false;
    var gridMargin = window.opener.extractPixelValue(pDiv.style.marginTop) - pDistance;  
    pDiv.style.marginTop = gridMargin + 'px';  
  
    if(gridMargin == -750) {
        //Upward slide is over
        pDiv.style.marginTop = "0px";    
        clearInterval(_slideInterval);
        over = true;
    } else if(gridMargin == 0){
        //Downward slide is over    
        clearInterval(_slideInterval);
        over = true;
    }

    if(over){
        window.opener.changeImage(_currentImage, pDiv, 750);
    }
  
    if(over) _playing = false;

}