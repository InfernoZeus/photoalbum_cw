package photoalbum;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;

public class Login {

	private static Map<String, String> rememberMeCookieHashToUsername = new HashMap<String, String>();
	private static Map<String, String> usernameToRememberMeCookieHash = new HashMap<String, String>();
    //Basic member variables and permissions hashmap
    HashMap albumPermissions = new HashMap();
    private boolean loggedIn = false;
    private String username;
    //Can't be null as queries rely on it having a value
    private int userId = -1;
    private String password;
    private String name;

    public Login() {
    }

    //Validates the user according the the username and password and logs them in and returns true
    //or returns false on failure.
    // Author: S. Stafrace - Added hardcoded Admin account with user ID 0.  This account will be used 
    // to delete images from any album.
    public boolean checkUser(DBConnector dbc, String username, String password, HttpServletResponse pResponse, boolean pRememberMe) {
        password = UtilBean.MD5Hash(password);

        if (username.equals(UtilBean.ADMIN_USER_NAME) && password.equals(UtilBean.ADMIN_USER_PASSWD)) {
            loggedIn = true;
            this.username = username;
            this.password = password;
            this.userId = UtilBean.ADMIN_USER_ID;
            this.name = UtilBean.ADMIN_FULL_NAME;
        } else {
            dbc.checkUsernamePassword(username, password);

            //If there was a result, a row exists so this username/password is valid
            if (dbc.getRowCount() > 0) {
                loggedIn = true;
                this.username = username;
                this.password = password;
                this.userId = Integer.parseInt(dbc.getRecord(0, 0).toString());
                this.name = dbc.getRecord(0, 1).toString();
                setAlbumPermissions(dbc);

            } else {
                loggedIn = false;
            }
        }

        // If "Remember me" functionality is enabled and login is successful
        try {
            if (loggedIn && pRememberMe) {
            	String hashedUsername = UtilBean.MD5Hash(this.username+Math.random());
            	rememberMeCookieHashToUsername.put(hashedUsername, username);
            	usernameToRememberMeCookieHash.put(username, hashedUsername);
                setPhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ID, hashedUsername, pResponse);
            } else {
                // Disable "Remember me" functionality
            	String hashedUsername = usernameToRememberMeCookieHash.get(username);
            	if (hashedUsername != null) {
            		rememberMeCookieHashToUsername.remove(hashedUsername);
            		usernameToRememberMeCookieHash.remove(username);
            	}
                deletePhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ID, "", pResponse);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return loggedIn;
    }

    // Displays the apropriate username if the "remember me" functionality
    // was selected.  There are two cookies used: photoalbum-id and photoalbum-account-type
    public String rememberMeUsername(Cookie[] pCookies, DBConnector pDbc, HttpServletResponse pResponse) {
        String username = "";

        try {
            for (int i = 0; i < pCookies.length; i++) {
                Cookie cookie = pCookies[i];
                if (cookie.getName().equals(UtilBean.COOKIE_PHOTOALBUM_ID)) {
                	username = rememberMeCookieHashToUsername.get(cookie.getValue());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return username;
    }
    
    private void setPhotoAlbumCookie(String pName, String pValue, HttpServletResponse pResponse) {
        Cookie cookie = new Cookie(pName, pValue);
        cookie.setPath("/");
        cookie.setMaxAge(60 * 60 * 24 * 7 * 4 * 12);
        System.out.println("*** cookie: [" + cookie.getName() + "=" + cookie.getValue() + "]");
        pResponse.addCookie(cookie);
    }

    private void deletePhotoAlbumCookie(String pName, String pValue, HttpServletResponse pResponse) {
        Cookie cookie = new Cookie(pName, pValue);
        cookie.setPath("/");
        cookie.setMaxAge(0);
        System.out.println("*** cookie: [" + cookie.getName() + "=" + cookie.getValue() + "]");
        pResponse.addCookie(cookie);
    }

    //Populate the album permission hashmap.
    public void setAlbumPermissions(DBConnector dbc) {

        //Make sure the hashmap is empty before adding any data to it (avoid duplicates)
        albumPermissions.clear();

        dbc.getAlbumPermissions(userId);
        //Loop through results and add to hashmap. album id is key, permission type string is value.
        for (int i = 0; i < dbc.getRowCount(); i++) {
            albumPermissions.put(Integer.parseInt(dbc.getRecord(i, 0).toString()), dbc.getRecord(i, 1).toString());
        }

    }

    public boolean changePassword(DBConnector pDbc, String pOldPassword, String pNewPassword) {
    	String hashedNewPassword = UtilBean.MD5Hash(pNewPassword);
    	String hashedOldPassword = UtilBean.MD5Hash(pOldPassword);
        int updatedRows = pDbc.changeUsersPassword(getUsername(), hashedOldPassword, hashedNewPassword);

        if (updatedRows > 0) {
            return true;
        } else {
            return false;
        }

    }

    //Returns a string containing permission type, or null if user has no permissions
    public String getAlbumPermission(int albumId) {

        Object perm = albumPermissions.get(albumId);
        return (perm != null) ? perm.toString() : null;

    }

    //Clear all the login details for this bean
    public void logout() {
        loggedIn = false;
        username = "";
        password = "";
        name = "";
        userId = -1;
        albumPermissions.clear();
    }

    public String getName() {
        return name;
    }

    public boolean isLoggedIn() {
        return loggedIn;
    }

    public String getUsername() {
        return username;
    }

    //Returns 0 when not logged in
    public int getUserId() {
        return userId;
    }
}
