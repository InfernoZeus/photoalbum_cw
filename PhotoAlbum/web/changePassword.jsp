<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%@ page import="javax.servlet.http.*" %>

<%

    boolean changePasswordSuccess = false;
    String changePasswordFailMessage = "";

//Process a login. "action" is the name of the submit button and "Login" is its value
//so this only runs when a user has submitted the form. This allows the page to both
//display the login form and process login requests.
    if ("ChangePassword".equals(request.getParameter("action"))) {

        //Basic error checking. If the required parameters don't exist, cancel processing
        //and redirect the user to an error page. Otherwise a nasty Tomcat error message appears.
        if (!util.requireParams("oldPassword,newPassword", "0,0", request, response)) {
            dbConnector.closeConnection();
            return;
        }

        String oldPassword = util.cleanString(request.getParameter("oldPassword"));
        String newPassword = util.cleanString(request.getParameter("newPassword"));



        if (login.changePassword(dbConnector, oldPassword, newPassword)) {
            changePasswordSuccess = true;
        } else {
            changePasswordFailMessage = "Password was NOT updated. Please try again.";
        }

    }


%>
<html>  
    <head>
        <title>Photo Album</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript">

            //Returning false prevents the form from being submitted.
            function checkPasswordForm(){
  
                var username = document.getElementById('oldPassword').value;
                var password = document.getElementById('newPassword').value;
   
            }

            //This function retrieved from http://www.nicknettleton.com/zine/javascript/trim-a-string-in-javascript
            //Trims whitespaces from a string, so username and password are valid as required in the spec
            function trim(str){
                return str.replace(/^\s+|\s+$/g, '');  
            }

            //If the login was successful, conditionally print this javascript, which runs automatically.
            //The window will close and the opener will reload, reflecting the user's succesful login.
            <% if (changePasswordSuccess) {%>
                alert("Password changed successfully!");
                window.close();  
            <% } //end if loginsuccess %>

    
        </script>
    </head>
    <body>  
        <%
            //Conditionally print the login failure message  
            if (!"".equals(changePasswordFailMessage)) {%>
        <p class="errorMsg"><%=changePasswordFailMessage%></p>
        <br/>
        <% } //end if %>


        <form action="changePassword.jsp" method="post" onsubmit="return(checkPasswordForm())">
            <span>Username: </span><br/><input type="text" name="username" id="username" readonly="true" value="<%=login.getUsername()%>" ><br/><br/>
                <span>Old Password: </span><br/><input type="password" name="oldPassword" id="oldPassword"><br/><br/>
                    <span>New Password: </span><br/><input type="password" name="newPassword" id="newPassword"><br/><br/>

                        <input type="submit" name="action" value="ChangePassword">
                            </form>
                            </body>
                            </html>
                            <% dbConnector.closeConnection();%>