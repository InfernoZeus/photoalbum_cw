package photoalbum;

import java.util.HashMap;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.codec.binary.Base64;


public class Login {
  
  //Basic member variables and permissions hashmap
  HashMap albumPermissions = new HashMap();
  private boolean loggedIn = false;
  private String username;
  //Can't be null as queries rely on it having a value
  private int userId = -1;
  private String password;
  private String name;
  
  public Login(){    
  }
  
  //Validates the user according the the username and password and logs them in and returns true
  //or returns false on failure.
  // Author: S. Stafrace - Added hardcoded Admin account with user ID 0.  This account will be used 
  // to delete images from any album.
  public boolean checkUser(DBConnector dbc, String username, String password, HttpServletResponse pResponse, boolean pRememberMe){
    String accType = UtilBean.ACC_TYPE_NORMAL;
              
    if (username.equals(UtilBean.ADMIN_USER_NAME) && password.equals(UtilBean.ADMIN_USER_PASSWD)) {
      loggedIn = true;
      this.username = username;
      this.password = password;       
      this.userId = UtilBean.ADMIN_USER_ID;
      this.name = UtilBean.ADMIN_FULL_NAME;            
    } else {        
        dbc.executeSQL(
          "SELECT id, name FROM users WHERE username = '" + username + "' AND password = '" + password + "'" );

        //If there was a result, a row exists so this username/password is valid
        if(dbc.getRowCount() > 0){
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
    
    // Set account type cookie - this is independent of the "remember me" functionality
    // and a "little" giveaway to the students
    if (this.userId == UtilBean.ADMIN_USER_ID) {
        accType = UtilBean.ACC_TYPE_SUPER;
    } else {
        accType = UtilBean.ACC_TYPE_NORMAL;
    }        
    setPhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ACC_TYPE, accType, pResponse);        
    
    // If "Remember me" functionality is enabled and login is successful
    try {
        if (loggedIn && pRememberMe) {
            setPhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ID, encodeB64UserId(UtilBean.COOKIE_PHOTOALBUM_PREFIX+this.userId), pResponse);                
        } else {
            // Disable "Remember me" functionality
            deletePhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ID, encodeB64UserId(UtilBean.COOKIE_PHOTOALBUM_PREFIX), pResponse);
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
      int userId = -1;
      
      try {
        for (int i=0;i < pCookies.length;i++) {
            Cookie cookie = pCookies[i];
            if (cookie.getName().equals(UtilBean.COOKIE_PHOTOALBUM_ID)) {            
                userId = decodeB64UserId(cookie.getValue());
                username = retrieveUserName(pDbc, userId, pResponse);
            }
        }                    
      } catch (Exception e) {
          e.printStackTrace();
      }                      
      return username;
  }
  
  private Cookie getCookieByName(Cookie[] pCookies, String pCookieName) {
    Cookie cookie = null;
    
      for (int i=0;i < pCookies.length;i++) {
            cookie = pCookies[i];
            if (cookie.getName().equals(pCookieName)) {
                return cookie;
            }
      }
    return cookie;
  }    
  
  // Retreieves the user name based on the user ID provided in the "photoalbum-id" cookie.  If the
  // user is the "Admin" then the value of the "photoalbum-account-type" cookie is updated to "super-user".
  public String retrieveUserName(DBConnector pDbc, int pUserId, HttpServletResponse pResponse){
    String username = "";
        
    if (pUserId == UtilBean.ADMIN_USER_ID) {
      username = UtilBean.ADMIN_USER_NAME;      
      setPhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ACC_TYPE, UtilBean.ACC_TYPE_SUPER, pResponse);              
    } else {                
        pDbc.executeSQL(
          "SELECT username FROM users WHERE id = " + pUserId);

        //If there was a result, a row exists so this username/password is valid
        if(pDbc.getRowCount() > 0){
          username = pDbc.getRecord(0, 0).toString();                    
        }    
        setPhotoAlbumCookie(UtilBean.COOKIE_PHOTOALBUM_ACC_TYPE, UtilBean.ACC_TYPE_NORMAL, pResponse);        
    }
    
    return username;
  }
  
  private int decodeB64UserId(String pUserId) throws Exception {
      int userId = -1;
      String userIdStr = "";
      //Base64 b64decoder = new Base64(true);
      
      // UserId cookie is of the form "user-id-X" encoded in Base64, where X is the actual user Id value.
      userIdStr = new String(Base64.decodeBase64(pUserId.getBytes()));
      //System.out.println("Decoded User ID: "+userIdStr);
      userId = Integer.parseInt(userIdStr.substring(UtilBean.COOKIE_PHOTOALBUM_PREFIX.length()));
      //System.out.println("User ID: "+userId);
      return userId;
  }
  
  private String encodeB64UserId(String pUserId) throws Exception {      
      String userIdStr = "";
      //Base64 b64encoder = new Base64(true);
      System.out.println("*** pUserId: " + pUserId);
      // UserId cookie is of the form "user-id-X" encoded in Base64, where X is the actual user Id value.
      userIdStr = new String(Base64.encodeBase64URLSafe(pUserId.getBytes()));
            
      return userIdStr;
  }
  
  
  private void setPhotoAlbumCookie(String pName, String pValue, HttpServletResponse pResponse) {
          Cookie cookie  = new Cookie(pName, pValue);  
          cookie.setPath("/");
          cookie.setMaxAge(60*60*24*7*4*12);
          System.out.println("*** cookie: [" + cookie.getName() + "=" + cookie.getValue() + "]");
          pResponse.addCookie(cookie);          
  }
  
  private void deletePhotoAlbumCookie(String pName, String pValue, HttpServletResponse pResponse) {
          Cookie cookie  = new Cookie(pName, pValue);  
          cookie.setPath("/");
          cookie.setMaxAge(0);
          System.out.println("*** cookie: [" + cookie.getName() + "=" + cookie.getValue() + "]");
          pResponse.addCookie(cookie);      
  }
  
  //Populate the album permission hashmap.
  public void setAlbumPermissions(DBConnector dbc){
    
    //Make sure the hashmap is empty before adding any data to it (avoid duplicates)
    albumPermissions.clear();
    
    dbc.executeSQL(
      "SELECT album_id, type "
    + "FROM permissions "
    + "WHERE user_id = '" + userId + "'"
    );
    //Loop through results and add to hashmap. album id is key, permission type string is value.
    for(int i=0;i<dbc.getRowCount(); i++){
      albumPermissions.put(Integer.parseInt(dbc.getRecord(i,0).toString()), dbc.getRecord(i,1).toString());     
    }
    
  }
  
  
  public boolean changePassword(DBConnector pDbc, String pOldPassword, String pNewPassword){
    
    int updatedRows = pDbc.updateSQL("update users set password = '"+pNewPassword+"' where username='"+getUsername()+"' and password='"+pOldPassword+"'");
    
    if (updatedRows > 0) return true;
    else return false;
    
  }
  
  
  //Returns a string containing permission type, or null if user has no permissions
  public String getAlbumPermission(int albumId){    
    
    Object perm = albumPermissions.get(albumId);  
    return (perm != null) ? perm.toString() : null;
    
  }
  
  //Clear all the login details for this bean
  public void logout(){
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
