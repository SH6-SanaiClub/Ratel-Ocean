<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div class="nav-item">
  <a class="nav-link" href="${pageContext.request.contextPath}/project/dashboard">프로젝트</a>
  <div class="dropdown-bar">
    <div class="dropdown-inner">
      <div class="dd-col">
        <p class="dd-title">탐색</p>
        <a class="dd-link" href="${pageContext.request.contextPath}/project/dashboard">프로젝트 찾기</a>
        <a class="dd-link" href="${pageContext.request.contextPath}/project/create">새 프로젝트 등록</a>
        <a class="dd-link" href="${pageContext.request.contextPath}/project/bookmark">북마크한 프로젝트</a>
      </div>

    </div>
  </div>
</div>

<div class="nav-item">
  <a class="nav-link" href="${pageContext.request.contextPath}/client/manage">내 프로젝트 관리</a>
</div>

<div class="nav-item">
  <a class="nav-link" href="${pageContext.request.contextPath}/client/contracts">내 계약 관리</a>
  <div class="dropdown-bar">
    <div class="dropdown-inner">
      <div class="dd-col">
        <p class="dd-title">내 계약 관리</p>
        <a class="dd-link" href="${pageContext.request.contextPath}/client/contract/management">내 계약 전체보기</a>
      </div>
    </div>
  </div>
</div>