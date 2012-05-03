package photoalbum;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
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
  public DBConnector(){    
    connect("jdbc:mysql://localhost:3306/photo_album", "org.gjt.mm.mysql.Driver", "whccw", "cw-whc$2012");
  }
  
  //Method for connecting to the database using supplied arguments.
  public void connect(String pUrl, String pDriver, String pUsername, String pPassword){
    
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
  public boolean executeSQL(String pQry){    

    Statement stmt;
    ResultSet rs;    
    clearResults();
    
    try {
      //Create the statement object
      stmt = dbConnection.createStatement();
      //Run the statement provided as the function's argument, storing the results
      //in a result set object.
      rs = stmt.executeQuery(pQry);    
      rsmd = rs.getMetaData();   
      
      //The column count is known but the row count isn't, but we can increment it
      //from 0 during the loop.
      rowCount = 0;
      colCount = rsmd.getColumnCount();
      
      //Loop through the rows of the result set using the next() operation.
      while(rs.next()){  
        //Create a new array list to store the data for this row. Data is stored
        //generically as an Object.
        ArrayList<Object> row = new ArrayList<Object>();
        
        //Loop through the columns in this row.
        for(int i =1;i<=getColCount();i++){
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
  public int updateSQL(String pStmt){
    
    try{
      Statement stmt = dbConnection.createStatement();
      //Use the executeUpdate command to run this type of statement
      int rowsAffected = stmt.executeUpdate(pStmt);
      stmt.close();
      
      return rowsAffected;
      
    }catch (SQLException ex) {
      System.err.println(ex);
      return 0;
    } finally {
      try{
        dbConnection.close();
      }catch (SQLException ex) {
        System.err.println(ex);
      }
    }    
  }
  
  //Retrieve the data Object from the ArrayList at the given row and column index. 
  //Note this will be 0-based, not 1-based as the JDBC ResultSet is.
  public Object getRecord(int pRow, int pCol){    
    return resultSet.get(pRow).get(pCol);
  }
  
  //Get the header using the result set meta data.
  public String getHeader(int colIndex){
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

  public void setRowCount(int rowCount) {
    throw new RuntimeException("Illegal attempt to set readonly field.");
  }

  public int getColCount() {
    return colCount;
  }

  public void setColCount(int colCount) {
    throw new RuntimeException("Illegal attempt to set readonly field.");
  }
  
  //Clear all the result data in preparation for running a new query.
  public void clearResults(){
    colCount = 0;
    rowCount = 0;
    resultSet.clear();
  }
  
  //Closes the connection with the database. This is called at the bottom of every 
  //page which implements this bean.
  public boolean closeConnection(){
    try{
      dbConnection.close();
      return true;
    }catch (SQLException ex) {
      System.err.println(ex);
      return false;
    }   
  }  
  

}
