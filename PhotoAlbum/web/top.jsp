<script type="text/javascript" src="ajax.js"></script>
<%
//This page is used as an include on the top of every page.

//Makes the search result page a little nicer by displaying the search text
//in the search box
            String sq = request.getParameter("searchquery");
            if (sq != null) {
                sq = util.cleanString(sq);
            } else {
                sq = "";
            }
%>
<div id="rightCorner">  
    <p class="topP">
        <a href="index.jsp">Home</a> | <a href="#" onclick="window.open('contact.jsp', 'helpWin', 'width=620, height=600'); return false;">Contact!</a> |
        <a href="#" onclick="window.open('help.htm', 'helpWin', 'width=620, height=600'); return false;">Help</a> |
        Search: 
    </p>
    <form action="search.jsp" method="get">
        <input type="text" style="width:100px" id="searchquery" name="searchquery" onkeyup="setHint(this)" value="<%=sq%>"/>
        <input type="submit" value="Go">
    </form>
    <div id="termhint" onclick="document.getElementById('searchquery').value=this.innerHTML">...type to see most probable search result, then click it...</div>
    <p class="botP" id="loginText">
        <% if (login.isLoggedIn()) {%>
        Logged in as <i><%=login.getName()%></i>. <a href="javascript:showChangePasswordPage()">Change Password</a> - <a href="logout.jsp" onclick="return confirm('Are you sure?')">Log Out</a>                    
        <% } else {%>
        You are not logged in. <a href="javascript:showLoginPage()">Log In</a>
        <% }%>
        <br/>
    </p>
</div>
