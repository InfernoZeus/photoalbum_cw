<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>


<%
String errorMsg = "";
try {
    System.out.println("Parameters");
    System.out.println("----------");
    Enumeration e = request.getAttributeNames();
    while (e.hasMoreElements()) {
        System.out.println(e.nextElement());
    }
    errorMsg = request.getAttribute("photoalbum.error_message").toString();
} catch (Exception e) {
    e.printStackTrace();
}    

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Error</title>
        <link type="text/css" rel="stylesheet" href="style.css" />
    </head>
    <body>
        <div class="errorMsg">
            Sorry, an unexpected error occured. Please report this to the webmaster.<br/><br/>The reported error was:
            <ul>
                <li><%=errorMsg %></li>
            </ul>
        </div>

    </body>  
</html>
