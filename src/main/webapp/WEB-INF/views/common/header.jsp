<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:choose>
  <c:when test="${sessionScope.userType eq 'CLIENT'}">
    <jsp:include page="/WEB-INF/views/common/client_header.jsp" />
  </c:when>
  <c:otherwise>
    <jsp:include page="/WEB-INF/views/common/freelancer_header.jsp" />
  </c:otherwise>
</c:choose>
