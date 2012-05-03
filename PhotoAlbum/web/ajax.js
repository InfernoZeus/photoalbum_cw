var xmlHttp;
var displayElement;

function getMessage(action, searchquery) {
  xmlHttp=getXMLHttpRequest();
  if (xmlHttp==null) return;
  var url="Search?action=" + action + "&searchquery=" + searchquery;
  url += "&sid=" + Math.random(); // prevent caching!!!
  xmlHttp.onreadystatechange=stateChange;
  xmlHttp.open("GET",url,true);
  xmlHttp.send(null);
}

function getXMLHttpRequest() {
  var xmlHttp = null;
  try { // IE7+, Firefox, Opera 8.0+, Safari, Chrome
    xmlHttp=new XMLHttpRequest();
  }
  catch (e) {
    try { // IE6+
      xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
    }
    catch (e) {
      try { // IE5+
        xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
      catch (e) { // No support
        alert("Your browser does not support AJAX!");
        return null;
      }
    }
  }
  return xmlHttp;
}

function stateChange()
{
  if(xmlHttp.readyState==4)
  {
    displayElement.innerHTML=xmlHttp.responseText;
  }
}

function setHint(e) {
  if (e.value.length==0)  {
    document.getElementById("termhint").innerHTML="";
    return;
  }
  displayElement = document.getElementById("termhint");
  getMessage(0, e.value);
}

function setCountry(e) {
  if (e.value.length==0)  {
    return;
  }
  displayElement = document.getElementById("country");
  getMessage(1, e.value);
}