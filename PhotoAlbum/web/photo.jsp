<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%@ page import="java.io.File" %>

<%

//Basic error checking. If the required parameters don't exist, cancel processing
//and redirect the user to an error page. Otherwise a nasty Tomcat error message appears.
    if (!util.requireParams("photo_id", "0", request, response)) {
        dbConnector.closeConnection();
        return;
    }

//Get the ID of the photo from the querystring, checking for errors as we do on album.jsp
    String photoId;
    if ((photoId = util.requireTxt(request.getParameter("photo_id"), request, response)) == null) {
        System.out.println("-----------Photo not found: " + photoId);
        dbConnector.closeConnection();
        return;
    }

//Check the photo actually exists.
    dbConnector.executeSQL("SELECT 1 FROM photos WHERE id = " + photoId);
    if (dbConnector.getRowCount() == 0) {
        util.errorRedirect("The specified photo could not be found.", request, response);
        dbConnector.closeConnection();
        return;
    }

//All error checks have now been performed


//addComment.jsp may return to this page with an error message. If it exists, store it in a variable.
    String errorMsg = request.getParameter("errorMsg");
    if (errorMsg == null) {
        errorMsg = "";
    } else {
        errorMsg = util.cleanString(errorMsg);
    }

//Select the photo's basic information and store in variables below.
    dbConnector.executeSQL(
            "SELECT p.src, p.title, p.description, a.title, a.id "
            + "FROM photos p "
            + "JOIN albums a ON p.album_id = a.id "
            + "WHERE p.id = " + photoId);

    String photoSrc = dbConnector.getRecord(0, 0).toString();
    String photoTitle = dbConnector.getRecord(0, 1).toString();
    String photoDesc = dbConnector.getRecord(0, 2).toString();
    String albumTitle = dbConnector.getRecord(0, 3).toString();
    int albumId = Integer.parseInt(dbConnector.getRecord(0, 4).toString());

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title>View Photo: <%=photoTitle%></title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript">
            function onLoad(){
                var div = document.getElementById('div0');
                var img = document.getElementById('viewImage0');
  
                var resize = window.opener.calculateDimensions(img,600);
                img.width = resize[0];
                img.height = resize[1];    
                window.opener.fixPadding(img,600);   
            }

            <%
                // Execute only if the "Delete Image" button has been clicked
                if ("DELETE IMAGE".equals(request.getParameter("delete")) && login.getUserId() == util.ADMIN_USER_ID) {
                    int photosDeleted = dbConnector.updateSQL("DELETE FROM photos WHERE id = " + photoId);
                    if (photosDeleted == 1) {
                        String realContextPath = getServletContext().getRealPath("/");
                        System.out.println("Real context: " + realContextPath);
                        String dirName = realContextPath + "/images/";
                        File file = new File(dirName + photoSrc);
                        System.out.println("TEST FILE: " + file.getAbsolutePath());
                        if (file.delete()) {
            %>    
                window.opener.document.location.reload();
                window.close(); 
            <% } else {
                            util.errorRedirect("An error occurred whilst deleteing the image from the file system", request, response);
                        }
                    } else {
                        util.errorRedirect("An error occurred whilst deleteing the image from the database", request, response);
                    }
                }
            %>
      
        </script>
    </head>
    <body onload="onLoad()">

        <%//Conditionally display the error message from addComment.jsp 
            if (!"".equals(errorMsg)) {
        %>
        <p class="errorMsg"><%=errorMsg%></p>
        <%
            }//end if errorMsg
        %>
        <h1><%=photoTitle%></h1>
        <h2><%=photoDesc%></h2>    
        <div id="mainArea" class="popup" style="width:600px; height: 600px;">
            <div id="div0" class="popupDiv">
                <img id="viewImage0" src="images/<%=photoSrc%>" />          
            </div>
        </div>
        <%
            //Select all the comments for this photo
            dbConnector.executeSQL(
                    "SELECT c.comment, u.name "
                    + "FROM comments c "
                    + "JOIN users u ON c.user_id = u.id "
                    + "WHERE c.photo_id = " + photoId);

            if (login.getUserId() == util.ADMIN_USER_ID) {
        %>
        <form action="photo.jsp" method="post">
            <!--hidden field contains the id of the photo receiving a comment -->
            <input type="hidden" name="photo_id" value="<%=photoId%>"/>        
            <div class="center" style="padding:10px;"><input type="submit" name="delete" value="DELETE IMAGE"/></div>
        </form>
        <div id="commentArea">        
            <%
                }
                if (dbConnector.getRowCount() == 0) {
            %>
            <p>No comments</p>
            <%            } else {
            %>
            <ul id="comments">
                <%//Loop through query results and display every comment selected 
                    for (int i = 0; i < dbConnector.getRowCount(); i++) {%>
                <li><p><b><%=dbConnector.getRecord(i, 1)%></b>: <%=dbConnector.getRecord(i, 0)%></p></li>     
                <% } //end for %>
            </ul>
            <%
                } //end if 

                //Check user has permissions to comment on this album (by having permissions user is implicitly logged in)
                //and if they do, display the comment box.
                if (login.getAlbumPermission(albumId) != null) {
            %>
            <form action="addComment.jsp" method="post">
                <!--hidden field contains the id of the photo receiving a comment -->
                <input type="hidden" name="photo_id" value="<%=photoId%>"/>
                <textarea cols="50" rows="7" name="commentText" id="commentTextarea"></textarea>
                <div class="center"><input type="submit" value="Post Comment"/></div>
            </form>
            <% } //end if album permissions %>
        </div>
    </body>
</html>
<% dbConnector.closeConnection();%>