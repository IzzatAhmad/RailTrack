<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.railtrack.system.dao.MenuItemDAO, com.railtrack.system.model.MenuItem, java.util.List" %>
<%
    MenuItemDAO dao = new MenuItemDAO();
    List<MenuItem> items = dao.findAll();
    request.setAttribute("menuItems", items);
    request.setAttribute("userRole", "COORDINATOR");
%>
<jsp:include page="/views/coordinator/menu_management.jsp" />
