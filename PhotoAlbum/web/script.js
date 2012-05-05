/*************************
* Core functionality code
* =======================
*
* Only one image array is used because the images are dynamically resized in the browser
* when needed. The code contains extra animation functionality beyond the spec, but this
* has been isolated in the bottom part of this code.
*
**************************/

var images = new Array();
var _currentImage, _currentPage = 0;

//Bugfix: only load thumbnails when all images are loaded into memory
//otherwise images won't show in firefox when not in cache
var imgLdCt = ALBUM_LENGTH;
function imgLd(){
    if(--imgLdCt == 0) loadThumbnails(0,document.getElementById('grid0'));
}

//Called when page body loads
function onLoad(){
  
    //Initialise image array
    for(i=0;i<ALBUM_LENGTH;i++){
        images[i] = new Image();
        images[i].src = imgSrcArray[i];
        images[i].onload = function(){
            //Only resize when image has downloaded
            var resize = calculateDimensions(this,170);    
            this.width = resize[0];
            this.height = resize[1];
            imgLd();
        };
        images[i].onerror = function(){ //avoid missing image blanks whole page
            this.width = 170;
            this.height = 170;
            imgLd();
        }
    }
  
    //Clone grid and zoom objects
    document.getElementById('mainArea').appendChild((document.getElementById('grid0').cloneNode(true)));
    document.getElementById('mainArea').appendChild((document.getElementById('zoom0').cloneNode(true)));
    //Change IDs to avoid conflicts
    document.getElementById('mainArea').getElementsByTagName('div')[11].id = 'grid1';
    document.getElementById('mainArea').getElementsByTagName('div')[21].id = 'zoom1';
  
    document.getElementById('zoom1').style.height="610px";
    document.getElementById('zoom1').style.width="610px";
}

//Returns an array with correctly scaled width and height for pTargetImage fitting into pTargetSize
function calculateDimensions(pTargetImg, pTargetSize){
  
    var curHeight = pTargetImg.height;
    var curWidth = pTargetImg.width;  
    var ratio = ((curHeight > curWidth) ? curHeight : curWidth) / pTargetSize;
  
    return[curWidth / ratio, curHeight / ratio];  
}

//Vertically centre pImg: an absolutely horrible hack, but the easiest way to do it
function fixPadding(pImg, pContainerHeight){
    pImg.style.marginTop = ((pContainerHeight - pImg.height) / 2) + 'px';
}

//load thumbnails into grid
function loadThumbnails(pPageNum, pIntoGrid){

    var thumb = pIntoGrid.getElementsByTagName('img');
    for(i=0;i<9;i++){   
        if((pPageNum * 9) + i < ALBUM_LENGTH){      
            loadImage(i + pPageNum * 9,thumb[i],180);
            thumb[i].style.display = "block";
            //Set caption
            pIntoGrid.getElementsByTagName('span')[i].innerHTML = imgCaptionArray[i + pPageNum * 9];
        } else {
            thumb[i].style.display = "none";
            //Remove caption
            pIntoGrid.getElementsByTagName('span')[i].innerHTML = '';
        }
    }
}

//load image pImgId into pIntoImg
function loadImage(pImgId, pIntoImg, pContainerHeight){
    pIntoImg.src = images[pImgId].src;
    pIntoImg.width = images[pImgId].width;
    pIntoImg.height = images[pImgId].height;
    fixPadding(pIntoImg,pContainerHeight);  
}


function singleClick(pImgId){
    var link = imgLinkArray[pImgId + (_currentPage * 9)];  
    if(link == null) return false;
  
    if(CLICK_MODE == 'SINGLE') {   
        location.href = CLICK_LOCATION + link;    
    } else {
        return false;
    }
}

function doubleClick(pImgId){
  
    var link = imgLinkArray[pImgId + (_currentPage * 9)];  
    if(link == null) return false;
  
    if(CLICK_MODE == 'DOUBLE'){
        var newWin = window.open(CLICK_LOCATION + link, "albumPopup", "height=820, width=820, status=1, scrollbars=yes");
    } else {
        return false;
    }
  
}


function firstPage(){
  
    //Validation, cannot go below page/image 0
    if((viewMode == "grid" && _currentPage == 0) 
        || (viewMode == "zoom" && _currentImage == 0) 
        || _playing) return false;
  
    var slideDiv0 = document.getElementById(viewMode + '0');
    var slideDiv1 = document.getElementById(viewMode + '1'); 

    if(viewMode=="grid"){        
        loadThumbnails(_currentPage, slideDiv1);
        loadThumbnails(0, slideDiv0);   
        _currentPage = 0;    
    } else {
        changeImage(_currentImage, slideDiv1);
        changeCurrentImage(0 - _currentImage);
        changeImage(0, slideDiv0);
    }    

    slideDiv0.style.marginTop = '-600px';
    startSlide(slideDiv0,"down");  
}

function prevPage(){

    //Validation, cannot go below page/image 0
    if((viewMode == "grid" && _currentPage == 0) 
        || (viewMode == "zoom" && _currentImage == 0) 
        || _playing) return false;

    var slideDiv0 = document.getElementById(viewMode + '0');
    var slideDiv1 = document.getElementById(viewMode + '1');   

    if(viewMode=="grid"){        
        changeCurrentPage(-1);
        loadThumbnails(_currentPage+1, slideDiv1);
        loadThumbnails(_currentPage, slideDiv0);
    } else {
        changeImage(_currentImage, slideDiv1);
        prevImage(slideDiv0);
    }  

    slideDiv0.style.marginTop = '-600px';
    startSlide(slideDiv0,"down");
}

function nextPage(){

    //Validation; cannot proceed belong album length
    if((viewMode == "grid" && _currentPage == Math.floor(ALBUM_LENGTH / 9)) 
        || (viewMode == "zoom" && _currentImage == ALBUM_LENGTH - 1) 
        || _playing) return false;
  
    var slideDiv0 = document.getElementById(viewMode + '0');
    var slideDiv1 = document.getElementById(viewMode + '1'); 

    if(viewMode=="grid"){
        changeCurrentPage(1);
        loadThumbnails(_currentPage, slideDiv1);
    }else{
        nextImage(slideDiv1);
    }

    startSlide(slideDiv0,"up");
}

function lastPage(){
  
    //Validation; cannot go to last page if already there
    if((viewMode == "grid" && _currentPage == Math.floor(ALBUM_LENGTH / 9)) 
        || (viewMode == "zoom" && _currentImage == ALBUM_LENGTH - 1) 
        || _playing) return false;

    var slideDiv0 = document.getElementById(viewMode + '0');
    var slideDiv1 = document.getElementById(viewMode + '1'); 

    if(viewMode=="grid"){        
        loadThumbnails(_currentPage, slideDiv0);
        loadThumbnails(Math.floor(ALBUM_LENGTH / 9), slideDiv1);   
        _currentPage = Math.floor(ALBUM_LENGTH / 9);
    } else {
        changeImage(_currentImage, slideDiv0);
        changeCurrentImage(ALBUM_LENGTH - 1 - _currentImage);
        changeImage(ALBUM_LENGTH - 1, slideDiv1);
    }    

    startSlide(slideDiv0,"up");  
}

//Change image id and load into image holder
function nextImage(pIntoDiv){
    changeCurrentImage(1);
    changeImage(_currentImage,pIntoDiv);  
}

//As above reversed
function prevImage(pIntoDiv){
    changeCurrentImage(-1);
    changeImage(_currentImage,pIntoDiv);
}

//Sets first the image of pIntoDiv to image of pImgId
function changeImage(pImgId, pIntoDiv, pTargetSize){

    if(pTargetSize==null) pTargetSize = 600;
  
    //DOM functions are unable to step by name, and there is more than
    //one Div so the images cannout share an ID, so this is the easiest way to do it
    var imgObj = pIntoDiv.getElementsByTagName('img')[0];
    loadImage(pImgId, imgObj, pTargetSize);
    var resize = calculateDimensions(images[pImgId],pTargetSize - 10);
    imgObj.width = resize[0];
    imgObj.height = resize[1];    
    fixPadding(imgObj,pTargetSize);   
}

//Changes page and ensures no overflows occur, adjusting currentPage if they do.
function changeCurrentPage(pAmount){

    if(_currentPage + pAmount < 0){
        _currentPage = 0;
    } else if((_currentPage + pAmount) * 9 > ALBUM_LENGTH){
        _currentPage = Math.floor(ALBUM_LENGTH / 9);
    } else {
        _currentPage += pAmount;
    }  

}

function showLoginPage(){
    var newWin = window.open("login.jsp", "albumLoginPopup", "height=300, width=300, status=1");
}

function showChangePasswordPage(){
    var newWin = window.open("changePassword.jsp", "albumChangePasswordPopup", "height=300, width=300, status=1");
}

// 09/03/2011 - Code enhancements to make the web application more challenging
// Author: Stefan Stafrace

function confirmImages() {
    var ext = document.uploadFm.file.value;
    ext = ext.substring(ext.length-3,ext.length);
    ext = ext.toLowerCase();
    if(ext == 'jpg' || ext == 'gif' || ext == 'png' ) {
        return true; 
    }
    else {
        alert('You selected a .'+ext+
            ' file; please select a .jpg or .gif or .png file instead!');
        return false; 
    }    
}








/*************************
* Animation Code 
* =============
*
* Explanation:
* 
* Sliding makes use of two divs, i.e. grid0 and grid1, one above the other within the clipping div (mainArea).
* To slide up, the margin of the top div is reduced, and the div below it also rises accordingly. To slide down,
* the margin of the top div is set to -600 and then increased, pushing the bottom div down. The images on each
* div are adjusted to maintain the illusion of a seemless slide. The user only ever interacts with the topmost div.
*
* Zooming is achieved by overlaying a 'zooming' div on the thumbnail using absolute positioning and loading the 
* relevant image in. The size is gradually increased. When the animation completes, the zooming div is positioned
* statically so it can be subjected to slides. The opposite occurs for zooming out.
*
**************************/

var viewMode = "grid";
var _slideInterval;
var _playing = false;
var _playAnimations = true;



function startSlide(pSlideDiv, pDirection){
  
    var increment = (pDirection=="up") ? 30 : -30;
    if(!_playAnimations) increment *= 20;
  
    //Use anonymous function to pass arguments to slideDiv in IE
    //ref: http://www.claws-and-paws.com/node/1252
    _playing = true;
    _slideInterval = setInterval(function() {
        slideDiv(pSlideDiv,increment)
        }, 20);
}

//Called on interval _slideInterval
function slideDiv(pDiv, pDistance){
  
    var over = false;
    var gridMargin = extractPixelValue(pDiv.style.marginTop) - pDistance;  
    //if(gridMargin < -600) gridMargin = 600;
    pDiv.style.marginTop = gridMargin + 'px';  
  
    if(gridMargin == -600) {
        //Upward slide is over
        pDiv.style.marginTop = "0px";    
        clearInterval(_slideInterval);
        over = true;
    } else if(gridMargin == 0){
        //Downward slide is over    
        clearInterval(_slideInterval);
        over = true;
    }
  
    if(over && viewMode=="grid"){
        loadThumbnails(_currentPage, pDiv);    
    } else if(over && viewMode=="zoom"){
        changeImage(_currentImage, pDiv);
    }
  
    if(over) _playing = false;

}

//Utility function, returns numeric part of pixel values i.e. '128px' > 128
function extractPixelValue(pValue){
    return pValue.substring(0,pValue.indexOf('p'));
}

//This function was retrieved from http://www.quirksmode.org/js/findpos.html on 23/09/2008
//It uses the offsetParent property of an object to loop through the display hierarchy and retrieve the absolute position of any element
function findPos(obj) {
    curleft = 0;
    curtop = 0;
    if (obj.offsetParent) {
        do {
            curleft += obj.offsetLeft;
            curtop += obj.offsetTop;
        } while (obj = obj.offsetParent);
        return [curleft, curtop];
    }
}