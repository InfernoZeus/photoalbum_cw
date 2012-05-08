<jsp:useBean id="dbConnector" class="photoalbum.DBConnector" scope="request" />
<jsp:useBean id="util" class="photoalbum.UtilBean" scope="request" />
<jsp:useBean id="login" class="photoalbum.Login" scope="session" />
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %>
<%@ page import="java.util.*" %>
<%@ page import="net.sf.jmimemagic.Magic" %>
<%@ page import="net.sf.jmimemagic.MagicMatch" %>


<%

    String title = "";
    String description = "";
    String album_id = "";

    if (ServletFileUpload.isMultipartContent(request)) {
        ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
        List fileItemsList = servletFileUpload.parseRequest(request);

        String optionalFileName = "";
        FileItem fileItem = null;

        Iterator it = fileItemsList.iterator();
        while (it.hasNext()) {
            FileItem fileItemTemp = (FileItem) it.next();
            if (fileItemTemp.isFormField()) {
                if (fileItemTemp.getFieldName().equals("title")) {
                    title = fileItemTemp.getString();
                }
                if (fileItemTemp.getFieldName().equals("description")) {
                    description = fileItemTemp.getString();
                }
                if (fileItemTemp.getFieldName().equals("album_id")) {
                    album_id = fileItemTemp.getString();
                }
%>

<b>Name-value Pair Info:</b><br/>
Field name: <%= fileItemTemp.getFieldName()%><br/>
Field value: <%= fileItemTemp.getString()%><br/><br/>

<%
            if (fileItemTemp.getFieldName().equals("filename")) {
                optionalFileName = fileItemTemp.getString();
            }
        } else
            fileItem = fileItemTemp;
    }
        
   	int userAccessLevel = dbConnector.userPermission(Integer.valueOf(album_id),login.getUserId());
   	if (userAccessLevel!= util.USER_WRITE_ACCESS) {
       	util.errorRedirect("You do not have the appropriate permissions to upload to this photo album.", request, response);
       	dbConnector.closeConnection();
       	return;
   	}

    if (fileItem != null) {
        String fileName = fileItem.getName();
%>

<b>Uploaded File Info:</b><br/>
Content type: <%= fileItem.getContentType()%><br/>
Field name: <%= fileItem.getFieldName()%><br/>
File name: <%= fileName%><br/>
File size: <%= fileItem.getSize()%><br/><br/>

<%
    /*
     * Save the uploaded file if its size is greater than 0.
     */
    if (fileItem.getSize() > 0) {
        String contentType = fileItem.getContentType();
        if (optionalFileName.trim().equals("")) {
            fileName = FilenameUtils.getName(fileName).trim();
        } else {
            fileName = optionalFileName.trim();
        }


        ServletContext context = session.getServletContext();
        String contextPath = request.getContextPath();
        String realContextPath = context.getRealPath(contextPath);
        System.out.println("Context path: " + contextPath);
        System.out.println("Real context path: " + realContextPath);
        String dirName = realContextPath.substring(0,
                realContextPath.lastIndexOf(contextPath.substring(1))) + "images/";

        System.out.println("Checking: " + dirName + "tmp");
        File tmp = new File(dirName + "tmp");
        fileItem.write(tmp);

        Magic parser = new Magic();
        MagicMatch match = parser.getMagicMatch(tmp, false);
        String magictype = match.getMimeType();
        System.out.println(magictype);

        if ((contentType.equalsIgnoreCase("image/jpeg")
                || contentType.equalsIgnoreCase("image/gif")
                || contentType.equalsIgnoreCase("image/png"))
                && (magictype.equalsIgnoreCase("image/jpeg")
                || magictype.equalsIgnoreCase("image/gif")
                || magictype.equalsIgnoreCase("image/png"))
                && (fileName.toLowerCase().endsWith(".jpg")
                || fileName.toLowerCase().endsWith(".jpeg")
                || fileName.toLowerCase().endsWith(".gif")
                || fileName.toLowerCase().endsWith(".png"))) {

            String nowTimeStamp = new java.text.SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());

            try {
                File saveTo = new File(dirName + nowTimeStamp + fileName);
                tmp.renameTo(saveTo);

                int result = dbConnector.addPhoto(title, description, nowTimeStamp + fileName, album_id);

                if (result == 0) {
                    //If the rows affected was 0, an error occured during the insert statement.
                    response.sendRedirect("error.jsp");
                }
%>
<b>The uploaded file has been saved successfully.</b>

<%
    response.sendRedirect("album.jsp?album_id=" + album_id);
} catch (Exception e) {
    System.out.print("ERROR! ");
    e.printStackTrace();
%>

<b>An error occurred when we tried to save the uploaded file.</b>

<%
                    }
                } else {
                    try {
                        util.errorRedirect("Uploaded file should be an image of type jpg, gif or png.", request, response);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
        }
    }
%>