<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<%@ page import="javax.servlet.http.*" %>

<%

    boolean loginSuccess = false;
    String loginFailMessage = "";
    String rmUsername = "";

//Process a login. "action" is the name of the submit button and "Login" is its value
//so this only runs when a user has submitted the form. This allows the page to both
//display the login form and process login requests.
    if ("Login".equals(request.getParameter("action"))) {

        //Basic error checking. If the required parameters don't exist, cancel processing
        //and redirect the user to an error page. Otherwise a nasty Tomcat error message appears.
        if (!util.requireParams("username,password", "0,0", request, response)) {
            dbConnector.closeConnection();
            return;
        }

        String username = util.cleanString(request.getParameter("username"));
        String password = util.cleanString(request.getParameter("password"));
        String chkBox = request.getParameter("logChkBx");

        boolean rememberMe = false;
        if (chkBox != null) {
            if (chkBox.equalsIgnoreCase("on")) {
                rememberMe = true;
            }
        }


        if (login.checkUser(dbConnector, username, password, response, rememberMe)) {
            loginSuccess = true;
        } else {
            loginFailMessage = "You entered the wrong username or password. Please try again.";
        }

    } else {
        // Remember me functionality
        Cookie[] cookies = request.getCookies();
        rmUsername = login.rememberMeUsername(cookies, dbConnector, response);
    }


%>
<html>  
    <head>
        <title>Photo Album</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
        <script type="text/javascript">
            //Returning false prevents the form from being submitted.
            function checkLoginForm(){
  
                var username = document.getElementById('username').value;
                var password = document.getElementById('password').value;
   
            }

            //This function retrieved from http://www.nicknettleton.com/zine/javascript/trim-a-string-in-javascript
            //Trims whitespaces from a string, so username and password are valid as required in the spec
            function trim(str){
                return str.replace(/^\s+|\s+$/g, '');  
            }

            //If the login was successful, conditionally print this javascript, which runs automatically.
            //The window will close and the opener will reload, reflecting the user's succesful login.
            <% if (loginSuccess) {%>
                window.opener.document.location.reload();
                window.close();  
            <% } //end if loginsuccess %>

    
                function displayUsername() {    
                    var tUserName = '<%=rmUsername%>';
                    document.getElementById('username').value = tUserName;
                    if (tUserName.length > 0) {
                        document.getElementById('logChkBx').checked = true;
                    }    
                }
    
        </script>
    </head>
    <body onload="displayUsername()" >  
        <%
            //Conditionally print the login failure message  
            if (!"".equals(loginFailMessage)) {%>
        <p class="errorMsg"><%=loginFailMessage%></p>
        <br/>
        <% } //end if %>


        <form action="login.jsp" method="post" onsubmit="return(checkLoginForm())">
            <span>Username: </span> <input type="text" name="username" id="username" ><br/>
                <span>Password: </span> <input type="password" name="password" id="password"><br/><br/>
                    <span>Remember me? </span> <input type="checkbox" name="logChkBx" id="logChkBx" /><br/><br/>
                    <input type="submit" name="action" value="Login">
                        </form>
                        </body>
                        </html>
                        <% dbConnector.closeConnection();%>