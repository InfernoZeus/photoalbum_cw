package photoalbum;

import java.sql.*;
import java.util.ArrayList;

public class DBConnector {

    //Basic member variables
    private String dbUrl;
    private String dbDriver;
    private String dbUsername;
    private String dbPassword;
    //Member variables to store the results of the latest query
    //ResultSets are represented as a 2D ArrayList of objects
    private ArrayList<ArrayList> resultSet = new ArrayList<ArrayList>();
    private int rowCount, colCount;
    ResultSetMetaData rsmd;
    Connection dbConnection;

    //Form a connection when the bean is instantiated. Obviously in a real system this would
    //be more clever, and probably use a connection pool or maintain a persistent connection etc.
    public DBConnector() {
        connect("jdbc:mysql://localhost:3306/photo_album", "org.gjt.mm.mysql.Driver", "whccw", "cw-whc$2012");
    }

    //Method for connecting to the database using supplied arguments.
    private void connect(String pUrl, String pDriver, String pUsername, String pPassword) {

        dbUrl = pUrl;
        dbDriver = pDriver;
        dbUsername = pUsername;
        dbPassword = pPassword;

        try {
            //Register the JDBC MySQL driver
            Class.forName(dbDriver);
            //Establish a connection
            dbConnection = DriverManager.getConnection(pUrl, pUsername, pPassword);
        } catch (ClassNotFoundException ex) {
            System.err.println(ex);
            throw new RuntimeException(ex);
        } catch (SQLException ex) {
            System.err.println(ex);
        }

    }

    //Executes SELECT statements
    private boolean executeSQL(PreparedStatement stmt) {

        ResultSet rs;
        clearResults();

        try {
            //Run the statement provided as the function's argument, storing the results
            //in a result set object.
            rs = stmt.executeQuery();
            rsmd = rs.getMetaData();

            //The column count is known but the row count isn't, but we can increment it
            //from 0 during the loop.
            rowCount = 0;
            colCount = rsmd.getColumnCount();

            //Loop through the rows of the result set using the next() operation.
            while (rs.next()) {
                //Create a new array list to store the data for this row. Data is stored
                //generically as an Object.
                ArrayList<Object> row = new ArrayList<Object>();

                //Loop through the columns in this row.
                for (int i = 1; i <= getColCount(); i++) {
                    //Add each column's data to the row.
                    row.add(rs.getObject(i));
                }

                //Finally, add the row to the resultSet ArrayList.
                resultSet.add(row);
                rowCount++;
            }

            rs.close();
            stmt.close();

        } catch (SQLException ex) {
            System.err.println(ex);
            return false;
        }
        return true;

    }

    //Run a SQL query which modifies data (i.e. INSERT, UPDATE, DELETE)
    private int updateSQL(PreparedStatement stmt) {

        try {
            //Use the executeUpdate command to run this type of statement
            int rowsAffected = stmt.executeUpdate();
            stmt.close();

            return rowsAffected;

        } catch (SQLException ex) {
            System.err.println(ex);
            return 0;
        } finally {
            try {
                dbConnection.close();
            } catch (SQLException ex) {
                System.err.println(ex);
            }
        }
    }

    //Retrieve the data Object from the ArrayList at the given row and column index. 
    //Note this will be 0-based, not 1-based as the JDBC ResultSet is.
    public Object getRecord(int pRow, int pCol) {
        return resultSet.get(pRow).get(pCol);
    }

    //Get the header using the result set meta data.
    public String getHeader(int colIndex) {
        try {
            return rsmd.getColumnName(colIndex);
        } catch (SQLException ex) {
            System.err.println(ex);
            return "";
        }
    }

    public int getRowCount() {
        return rowCount;
    }

    public int getColCount() {
        return colCount;
    }

    //Clear all the result data in preparation for running a new query.
    private void clearResults() {
        colCount = 0;
        rowCount = 0;
        resultSet.clear();
    }

    //Closes the connection with the database. This is called at the bottom of every 
    //page which implements this bean.
    public boolean closeConnection() {
        try {
        	if (dbConnection != null)
        		dbConnection.close();
            return true;
        } catch (SQLException ex) {
            System.err.println(ex);
            return false;
        }
    }

    void checkUsernamePassword(String username, String password) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT id, name FROM users WHERE username = ? AND password = ?");
            stmt.setString(1, username);
            stmt.setString(2, password);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }

    void retrieveUserName(int pUserId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT username FROM users WHERE id = ?");
            stmt.setInt(1, pUserId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }

    void getAlbumPermissions(int userId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT album_id, type FROM permissions WHERE user_id = ?");
            stmt.setInt(1, userId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }

    int changeUsersPassword(String username, String pOldPassword, String pNewPassword) {
    	if (dbConnection == null)
    		return 0;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("UPDATE users SET password = ? WHERE username = ? AND password = ?");
            stmt.setString(1, pNewPassword);
            stmt.setString(2, username);
            stmt.setString(3, pOldPassword);
            return updateSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
            return 0;
        }
    }

    void search(String searchString) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT p.src, p.title, p.id FROM photos p JOIN albums a ON p.album_id = a.id WHERE UPPER(p.description) LIKE UPPER('%' ? '%') OR UPPER(p.title) LIKE UPPER('%' ? '%')");
            stmt.setString(1, searchString);
            stmt.setString(2, searchString);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }
    
    public void searchWithPermissionCheck(String searchString, int userId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT p.src, p.title, p.id FROM photos p JOIN albums a ON p.album_id = a.id AND (a.is_public = 1 OR a.owner_id = ? OR EXISTS(SELECT 1 FROM permissions p WHERE p.album_id = a.id AND p.user_id = ?)) WHERE UPPER(p.description) LIKE UPPER('%' ? '%') OR UPPER(p.title) LIKE UPPER('%' ? '%')");
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setString(3, searchString);
            stmt.setString(4, searchString);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }

    public void getAlbumIdFromPhotoId(String photoId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT album_id FROM photos WHERE id = ?");
            stmt.setString(1, photoId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }

    public int addComment(String photoId, int userId, String commentText) {
    	if (dbConnection == null)
    		return 0;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("INSERT INTO comments(photo_id, user_id, comment) VALUES(?, ?, ?)");
            stmt.setString(1, photoId);
            stmt.setInt(2, userId);
            stmt.setString(3, commentText);
            return updateSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
            return 0;
        }
    }

    public int addContact(String issueType, String name, String email, String text) {
    	if (dbConnection == null)
    		return 0;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("INSERT INTO contact(issue_type,name,email,text) VALUES(?, ?, ?, ?)");
            stmt.setString(1, issueType);
            stmt.setString(2, name);
            stmt.setString(3, email);
            stmt.setString(4, text);
            return updateSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
            return 0;
        }
    }
    
    public boolean hasAlbum(String albumId) {
    	if (dbConnection == null)
    		return false;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT 1 FROM albums a WHERE id = ?");
            stmt.setString(1, albumId);	
            executeSQL(stmt);
            return (getRowCount() != 0);
        } catch (SQLException ex) {
            System.err.println(ex);
            return false;
        }
    }
    
    public void getAlbumInfo(String albumId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT a.title, a.description, (SELECT COUNT(*) FROM permissions p WHERE p.album_id = a.id ) FROM albums a WHERE a.id = ?");
            stmt.setString(1, albumId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }
    
    public void getPhotosInAlbum(String albumId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT p.src, p.title, p.id FROM photos p WHERE p.album_id = ?");
            stmt.setString(1, albumId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }
    
    public void getIndexCoverInfo(int userId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT p.src, a.title, p.album_id FROM photos p JOIN albums a ON p.album_id  = a.id AND (a.is_public = 1 OR a.owner_id = ? OR EXISTS(SELECT 1 FROM permissions pr WHERE pr.album_id = a.id AND pr.user_id = ?)) WHERE (p.id = (SELECT p2.id FROM photos p2 WHERE p2.album_id = p.album_id ORDER BY p2.id LIMIT 1))");
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }
    
    public boolean hasPhoto(String photoId) {
    	if (dbConnection == null)
    		return false;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT 1 FROM photos WHERE id = ?");
            stmt.setString(1, photoId);
            executeSQL(stmt);
            return (getRowCount() != 0);
        } catch (SQLException ex) {
            System.err.println(ex);
            return false;
        }
    }
    
    public void getPhotoInfo(String photoId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT p.src, p.title, p.description, a.title, a.id FROM photos p JOIN albums a ON p.album_id = a.id WHERE p.id = ?");
            stmt.setString(1, photoId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }
    
    public int deletePhoto(String photoId) {
    	if (dbConnection == null)
    		return 0;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("DELETE FROM photos WHERE id = ?");
            stmt.setString(1, photoId);
            return updateSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
            return 0;
        }
    }
    
    public void getCommentsForPhoto(String photoId) {
    	if (dbConnection == null)
    		return;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("SELECT c.comment, u.name FROM comments c JOIN users u ON c.user_id = u.id WHERE c.photo_id = ?");
            stmt.setString(1, photoId);
            executeSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
        }
    }
    
    public int addPhoto(String title, String description, String srcName, String albumId) {
    	if (dbConnection == null)
    		return 0;
        try {
            PreparedStatement stmt = dbConnection.prepareStatement("INSERT INTO photos(title, description, src, album_id) " + "VALUES(?, ?, ?, ?)");
            stmt.setString(1, title);
            stmt.setString(2, description);
            stmt.setString(3, srcName);
            stmt.setString(4, albumId);
            return updateSQL(stmt);
        } catch (SQLException ex) {
            System.err.println(ex);
            return 0;
        }
    }
}