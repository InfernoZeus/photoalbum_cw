<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%

//addComment.jsp may return to this page with a message. If it exists, store it in a variable.
    String message = request.getParameter("message");
    if (message == null) {
        message = "";
    } else {
        message = util.cleanString(message);
    }

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title>Email us!</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
    </head>
    <body>
        <%@ include file="top.jsp" %>
        <%//Conditionally display the message from addContact.jsp
            if (!"".equals(message)) {
        %>
        <p class="errorMsg"><%=message%></p>
        <%
            }//end if message
%>
        <h1>PhotoAlbum</h1>
        <h2>Feedback, Bug submission and Support page...</h2>

        Customer satisfaction is number one priority! Please give us details about your query...<br/><br/><br/>
        <br/>
        <form action="addContact.jsp" method="post">
            Please select an Issue Type:<br/>
            <select name='issue_type'>
                <option name='Feedback' value='Feedback'> Feedback </option>
                <option name='Bug' value='Bug'> Bug </option>
                <option name='Support' value='Support'> Support </option>
            </select>
            <br/><br/>
            Please enter your Full Name:<br/>
            <input type="text" style="width:300px" name="name" value=""/>
            <br/><br/>
            Please enter a valid Email Address:<br/>
            <input type="text" style="width:300px" name="email" value=""/>
            <br/><br/>
            Type your message or a complete textual description of your issue:<br/>
            <textarea cols="30" rows="4" name="text" id="text"></textarea><br/><br/>
            <div class="center"><input type="submit" value="Submit Contact Form..."/></div>
        </form>
    </body>
</html>
<% dbConnector.closeConnection();%>