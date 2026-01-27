<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div>
  <label for="freelancerId">프리랜서 선택:</label>
  <select name="freelancerId" id="freelancerId">
    <option value="">-- 선택 --</option>
    <c:forEach var="f" items="${freelancerList}">
      <option value="${f.id}">${f.name}</option>
    </c:forEach>
  </select>
</div>
