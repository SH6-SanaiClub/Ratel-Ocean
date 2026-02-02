<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="ro_hd_navItem">
  <a class="ro_hd_navLink" href="${pageContext.request.contextPath}/project/dashboard">프로젝트</a>
  <div class="ro_hd_dropdownBar">
    <div class="ro_hd_dropdownInner">
      <div class="ro_hd_ddCol">
        <p class="ro_hd_ddTitle">탐색</p>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/project/dashboard">프로젝트 찾기</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/project/dashboard?summary=today">새로운 공고</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/project/dashboard?summary=deadline7">마감 임박</a>
      </div>

    </div>
  </div>
</div>

<div class="ro_hd_navItem">
  <a class="ro_hd_navLink" href="${pageContext.request.contextPath}/freelancer/project/manage">내 프로젝트 관리</a>
  <div class="ro_hd_dropdownBar">
    <div class="ro_hd_dropdownInner">

      <div class="ro_hd_ddCol">
        <p class="ro_hd_ddTitle">프로젝트 관리</p>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/manage">프로젝트 일정 관리</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/detail">프로젝트 상세 관리</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/project/bookmark">북마크한 프로젝트</a>
      </div>
      <div class="ro_hd_ddCol">
        <p class="ro_hd_ddTitle">프로젝트 조회</p>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/manage?tab=inProgress">진행 중인 프로젝트</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/manage?tab=applied">지원한 프로젝트</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/manage?tab=completed">완료된 프로젝트</a>
      </div>
      <div class="ro_hd_ddCol">
        <p class="ro_hd_ddTitle">프로젝트 상세 관리</p>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/detail?tab=inProgress">마일스톤 관리</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/detail?tab=completed">사용 스킬 등록</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/project/detail?tab=reviews">리뷰 작성 및 조회</a>
      </div>

    </div>
  </div>
</div>

<div class="ro_hd_navItem">
  <a class="ro_hd_navLink" href="${pageContext.request.contextPath}/contract/list">내 계약 관리</a>
  <div class="ro_hd_dropdownBar">
    <div class="ro_hd_dropdownInner">
      <div class="ro_hd_ddCol">
        <p class="ro_hd_ddTitle">내 계약 관리</p>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/contract/list">내 계약 전체보기</a>
      </div>
    </div>
  </div>
</div>

<div class="ro_hd_navItem">
  <a class="ro_hd_navLink" href="${pageContext.request.contextPath}/profile/${userId}">내 프로필</a>
  <div class="ro_hd_dropdownBar">
    <div class="ro_hd_dropdownInner">
      <div class="ro_hd_ddCol">
        <p class="ro_hd_ddTitle">프로필</p>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/profile/${userId}">내 프로필 보기</a>
        <a class="ro_hd_ddLink" href="${pageContext.request.contextPath}/freelancer/profile/edit">내 프로필 수정</a>
      </div>
    </div>
  </div>
</div>
