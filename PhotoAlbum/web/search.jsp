<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%

//Basic error checking. If the required parameters don't exist, cancel processing
//and redirect the user to an error page. Otherwise a nasty Tomcat error message appears.
    if (!util.requireParams("searchquery", "1", request, response)) {
        dbConnector.closeConnection();
        return;
    }

//Retrieve the query from the request's POST parameters.
    String searchQuery = util.cleanString(request.getParameter("searchquery"));

//Use the LIKE function and search public albums to match photos with the search query
//Subquery used to find photos which user has permissions on
    dbConnector.executeSQL(
            "SELECT p.src, p.title, p.id "
            + "FROM photos p "
            + "JOIN albums a ON p.album_id = a.id AND ("
            + "  a.is_public = 1 "
            + "  OR a.owner_id = " + login.getUserId() + " "
            + "  OR EXISTS(SELECT 1 FROM permissions p WHERE p.album_id = a.id AND p.user_id = " + login.getUserId() + ")) "
            + "WHERE UPPER(p.description) LIKE UPPER('%" + searchQuery + "%')"
            + "OR UPPER(p.title) LIKE UPPER('%" + searchQuery + "%')");

    int photoCount = dbConnector.getRowCount();

%>
<html>  
    <head>
        <title>Search Results</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript">

            var CLICK_MODE = "DOUBLE";
            var CLICK_LOCATION = "photo.jsp?photo_id=";

            //Use generic functionality to print the JS arrays.
            <%=util.printJSArrays(dbConnector)%>

        </script>
        <script type="text/javascript" src="script.js"></script>
    </head>
    <body onload="onLoad()">
        <%@ include file="top.jsp" %>
        <h1>Results for <i><%=searchQuery%></i></h1>
        <h2><%=photoCount%> photo(s) found</h2>
        <% if (photoCount > 0) {%>
        <%@ include file="photoGrid.jsp" %>
        <% }//end if photocount > 0 %>
    </body>
</html>
<% dbConnector.closeConnection();%>