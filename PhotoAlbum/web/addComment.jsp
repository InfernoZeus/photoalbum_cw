<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%

//Basic error checking. If the required parameters don't exist, cancel processing
//and redirect the user to an error page. Otherwise a nasty Tomcat error message appears.
    if (!util.requireParams("commentText,photo_id", "1,0", request, response)) {
        dbConnector.closeConnection();
        return;
    }

//Remove nasty characters from the comment text to stop any mischief.
    String commentText = util.cleanString(request.getParameter("commentText"));
//Get the photo id, failing if it is not an integer.
    String photoId;
    if ((photoId = util.requireTxt(request.getParameter("photo_id"), request, response)) == null) {
        dbConnector.closeConnection();
        return;
    }

//Get the album id for this photo so it can be checked against the user's permissions.
    dbConnector.executeSQL("SELECT album_id FROM photos WHERE id = " + photoId);
    int albumId = Integer.parseInt(dbConnector.getRecord(0, 0).toString());

    if (login.getAlbumPermission(albumId) == null) {
        util.errorRedirect("You do not have the appropriate permissions to make a comment.", request, response);
    }

//Check against user permissions

//The basic URL to which the user will be redirected.
    String redirectUrl = "photo.jsp?photo_id=" + photoId;

    //Do the record insert.
    int result = dbConnector.updateSQL(
            "INSERT INTO comments(photo_id, user_id, comment) "
            + "VALUES('" + photoId + "', '" + login.getUserId() + "', '" + commentText + "')");

    if (result == 0) {
        //If the rows affected was 0, an error occured during the insert statement.
        redirectUrl += "&errorMsg=There%20was%20an%20error%20adding%20the%20comment!";
    }

//Send the user back to the photo page. If there was an error, it is appended to the query string
//of this redirect and displayed to the user on the photo page.
    response.sendRedirect(redirectUrl);

%>