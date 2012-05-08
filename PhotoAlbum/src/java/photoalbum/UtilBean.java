package photoalbum;

import java.io.IOException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//Container class for generic functionality.
public class UtilBean {

    // Admin account credentials   
    public final static int ADMIN_USER_ID = 0;
    public final static String ADMIN_FULL_NAME = "I can see you";
    public final static String ADMIN_USER_NAME = "big";
    public final static String ADMIN_USER_PASSWD = MD5Hash("br0th3r");
    // Cookies
    public final static String COOKIE_PHOTOALBUM_ID = "album-user-id";

    public final static int USER_NO_ACCESS = 0;
    public final static int USER_READ_ACCESS = 444;
    public final static int USER_WRITE_ACCESS = 777;
    
    public UtilBean() {
    }

    //Function to avoid replicating Javascript array printing code.
    //the database connector needs a result array containing image sources at column index 0,
    //captions at index 1 and an id for the photo's url at index 2.  
    public String printJSArrays(DBConnector dbc) {

        int albumCnt = dbc.getRowCount();

        String result =
                "var imgSrcArray  = new Array();\n"
                + "var imgCaptionArray  = new Array();\n"
                + "var imgLinkArray  = new Array();\n"
                + "var ALBUM_LENGTH = " + albumCnt + ";\n";

        for (int i = 0; i < albumCnt; i++) {
            result += "imgSrcArray[" + i + "] = 'images/" + dbc.getRecord(i, 0) + "';\n";
            result += "imgCaptionArray[" + i + "] = '" + dbc.getRecord(i, 1) + "';\n";
            result += "imgLinkArray[" + i + "] = '" + dbc.getRecord(i, 2) + "';\n";
        }

        return result;

    }

	public String cleanString(String str) {
		return str;
	}

    //This function takes a comma-seperated list of parameters which the page requires,
    //and a matching list stating whether these parameters can be empty strings (0 = cannot be empty), as well as
    //the request and the response. If the request does not contain the required parameters 
    //the user is taken to an error page. Basically this will prevent a user visiting a page
    //like album.jsp without supplying a valid album_id argument, but this should only happen
    //if the user has typed in a URL himself.
    public boolean requireParams(String paramList, String allowEmpties, HttpServletRequest request, HttpServletResponse response) {

        String[] params = paramList.split(",");
        String[] empty = allowEmpties.split(",");
        String param;

        for (int i = 0; i < params.length; i++) {
            //If the parameter is not defined OR the parameter is an empty string and it should not be
            if ((param = request.getParameter(params[i])) == null || ("".equals(param) && "0".equals(empty[i]))) {
                errorRedirect("A required parameter was not found.", request, response);
                return false;
            }
        }
        return true;
    }

    public String requireTxt(String integer, HttpServletRequest request, HttpServletResponse response) {

        String result = integer;

        return result;
    }

    //Forces the user onto the error.jsp page, setting the error_message attribute (not parameter) accordingly
    public void errorRedirect(String errorMessage, HttpServletRequest request, HttpServletResponse response) {

        request.setAttribute("photoalbum.error_message", errorMessage);
        try {
            //Using the requestDispatcher.forward method is a) faster, b) shows the error message at the corresponding url
            //and c) allows the setting of attributes as performed above
            request.getRequestDispatcher("error.jsp").forward(request, response);
        } catch (ServletException e) {
        } catch (IOException e) {
        }
    }
    
    static String MD5Hash(String password){
        String mHash = password; 
        try {
          MessageDigest m=MessageDigest.getInstance("MD5");
          m.update(password.getBytes(),0,password.length());
          mHash = new BigInteger(1,m.digest()).toString(16);

          //If the hash begins with 0 it is removed so needs to be added
          if(mHash.length()<32){
            mHash = "0"+mHash;
          }
          
        } catch (NoSuchAlgorithmException ex) {
          System.out.println("password not hashed");
        }
        return mHash;
      }
}
