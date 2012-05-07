<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%

//Basic error checking. If the required parameters don't exist, cancel processing
//and redirect the user to an error page. Otherwise a nasty error message appears.
    if (!util.requireParams("issue_type,name,email,text", "1,0", request, response)) {
        dbConnector.closeConnection();
        return;
    }

//Remove nasty characters from the contact text only, to stop any mischief.
    String issue_type = util.cleanString(request.getParameter("issue_type"));
    String name = util.cleanString(request.getParameter("name"));
    String email = util.cleanString(request.getParameter("email"));
    String text = util.cleanString(request.getParameter("text"));

//The basic URL to which the user will be redirected.
    String redirectUrl = "contact.jsp";

    //Do the record insert.
    int result = dbConnector.addContact(issue_type, name, email, text);

    if (result == 0) {
        //If the rows affected was 0, an error occured during the insert statement.
        redirectUrl += "?message=There%20was%20an%20error%20submitting%20your%20Form!";
    } else {
        redirectUrl += "?message=Your%20message%20was%20received%20successfully!%20Thank%20you!";
    }

//Send the user back to the contact page. If there was a message, it is appended to the query string
//of this redirect and displayed to the user.
    response.sendRedirect(redirectUrl);

%>