package photoalbum;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class Search extends HttpServlet {

    private String completeName(String sub) {
        DBConnector db = new DBConnector();
        db.executeSQL(
                "SELECT p.src, p.title, p.id "
                + "FROM photos p "
                + "JOIN albums a ON p.album_id = a.id "
                + "WHERE UPPER(p.description) LIKE UPPER('%" + sub + "%')"
                + "OR UPPER(p.title) LIKE UPPER('%" + sub + "%')");
        String searchresults = "";
        try {
            searchresults = (String) db.getRecord(1, 1);
        } catch (IndexOutOfBoundsException e) {
            searchresults = "Nothing found...";
        }
        return searchresults;
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String searchquery = request.getParameter("searchquery");

        String msg = "";
        if (action.equalsIgnoreCase("0")) {
            msg = completeName(searchquery);
        } else if (action.equalsIgnoreCase("1")) {
            msg = completeName(searchquery);
        }

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            out.println(msg);
        } finally {
            out.close();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}
