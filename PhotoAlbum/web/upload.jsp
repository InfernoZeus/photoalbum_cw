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
    dbConnector.executeSQL("SELECT 1 FROM albums a " + "WHERE id = " + albumId);
    if (dbConnector.getRowCount() == 0) {
        util.errorRedirect("The specified album could not be found.", request, response);
        dbConnector.closeConnection();
        return;
    }

//All error checking has now been performed.

//Select the general information about the album, including count of viewers
    dbConnector.executeSQL(
            "SELECT a.title, a.description, "
            + "(SELECT COUNT(*) FROM permissions p WHERE p.album_id = a.id ) "
            + "FROM albums a "
            + "WHERE a.id = " + albumId);

    String albumTitle = dbConnector.getRecord(0, 0).toString();
    String albumDesc = dbConnector.getRecord(0, 1).toString();
    String userCount = dbConnector.getRecord(0, 2).toString();


    dbConnector.executeSQL(
            "SELECT p.src, p.title, p.id "
            + "FROM photos p "
            + "WHERE p.album_id = " + albumId);

    int photoCount = dbConnector.getRowCount();

%>
<html>
    <head>
        <title>Photo Album : <%= albumTitle%> : Upload</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript" src="script.js"></script>
    </head>
    <body onload="onLoad()">
        <%@ include file="top.jsp" %>
        <h1><%=albumTitle%></h1>
        <h2>Upload New Image</h2>
        <div align="center"><p>Add a new image to your album by using the form below.  Please make sure that you choose a jpeg, gif or png file!</p><br/>
            <form name="uploadFm" enctype="multipart/form-data" action="uploadfile.jsp" method="POST" onsubmit="return confirmImages()">
                Title: <input type="text" name="title"/><br/>
                Description: <input type="description" name="description"/><br/>
                File: <input type="file" name="file" accept="image/jpeg,image/gif,image/png"/><br/>
                <input type="hidden" name="album_id" id="album_id" value="<%=request.getParameter("album_id")%>"/>
                <input type="submit" />
            </form>
        </div>
    </body>
</html>
<% dbConnector.closeConnection();%>