<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<%
login.logout();
//sendRedirect preferred over jsp:forward because it correctly changes user's URL
//Send them to index.jsp so, for instance, if they were viewing a private album
//they don't receive an error message.
response.sendRedirect("index.jsp");
%>
