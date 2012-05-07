<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%

//Select the "first" image, album name and ID for each public album
//This is then passed to the util bean which prints the Javascript arrays.
//NB for convenience this function also displays private albums to a logged in user,
//this was not asked for in the spec but I think it makes
    dbConnector.getIndexCoverInfo(login.getUserId());

%>
<html>  
    <head>
        <title>Photo Album</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript">

            //The Javascript from cw1 was slightly modified to support this coursework. 
            //Set up the "click mode" (i.e. single or double clicks) and the URL to append the image or album id to.
            var CLICK_MODE = "SINGLE";
            var CLICK_LOCATION = "album.jsp?album_id=";

            //Call the util bean function to print the appropriate JS arrays (for image source etc).
            <%=util.printJSArrays(dbConnector)%>

        </script>
        <script type="text/javascript" src="script.js"></script>

    </head>
    <body onload="onLoad()">
        <!--Include generic functionality for the box at the top of the page-->
        <%@ include file="top.jsp" %>
        <h1>Select an album...</h1>
        <!--Include generic html for the 3*3 photo grid.-->
        <%@ include file="photoGrid.jsp" %>
    </body>
</html>
<% dbConnector.closeConnection();%>