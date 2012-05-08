<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%

//Basic error checking. If the required parameters don't exist, cancel processing
//and redirect the user to an error page. Otherwise a nasty Tomcat error message appears.
    if (!util.requireParams("album_id", "0", request, response)) {
        dbConnector.closeConnection();
        return;
    }


    String albumId = request.getParameter("album_id");

//Now check the album exists and is viewable.
    if (!dbConnector.hasAlbum(albumId)) {
        util.errorRedirect("The specified album could not be found.", request, response);
        dbConnector.closeConnection();
        return;
    }

    //check user has permission
    if (dbConnector.userPermission(Integer.valueOf(albumId),login.getUserId()) == util.USER_NO_ACCESS) {
        util.errorRedirect("You do not have access to view this album.", request, response);
        dbConnector.closeConnection();
        return;
    }

//All error checking has now been performed.

//Select the general information about the album, including count of viewers
    dbConnector.getAlbumInfo(albumId);

    String albumTitle = dbConnector.getRecord(0, 0).toString();
    String albumDesc = dbConnector.getRecord(0, 1).toString();
    String userCount = dbConnector.getRecord(0, 2).toString();


    dbConnector.getPhotosInAlbum(albumId);

    int photoCount = dbConnector.getRowCount();

%>
<html>  
    <head>
        <title>Photo Album : <%= albumTitle%></title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript">

            var CLICK_MODE = "DOUBLE";
            var CLICK_LOCATION = "photo.jsp?photo_id=";

            <%=util.printJSArrays(dbConnector)%>

        </script>
        <script type="text/javascript" src="script.js"></script>
    </head>
    <body onload="onLoad()">
        <%@ include file="top.jsp" %>
        <h1><%=albumTitle%></h1>
        <h2><%=albumDesc%></h2>
        <div align="center"><p>This album contains <b><%=photoCount%></b> photo(s), and <b><%=userCount%></b> user(s) can comment on it. Double click an image to see its comments.</p></div><br/>
        <hr/>
        <div align="center"><p><a href="upload.jsp?album_id=<%= albumId%>">Add new image</a></p></div><br/>
        <%@ include file="photoGrid.jsp" %>

    </body>
</html>
<% dbConnector.closeConnection();%>