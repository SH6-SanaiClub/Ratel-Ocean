<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>마이페이지 | Ratel Ocean</title>

  <!-- 아이콘 -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/freelancerMypage.css">

</head>
<body>

<div class="mp-container">

  <!-- 상단 헤더 카드 -->
  <div class="header-card">
    <div class="profile-frame">
      <!-- 실제 이미지 -->
      <img id="headerProfileImg"
           src="${not empty profile.profileImageUrl ? pageContext.request.contextPath.concat(profile.profileImageUrl) : ''}"
           style="${not empty profile.profileImageUrl ? '' : 'display:none;'}"
           onerror="this.style.display='none'">

      <!-- 기본 아이콘 -->
      <i class="fa-solid fa-user"></i>
    </div>

    <div class="header-content">
      <div class="header-top-row">
        <span class="client-id">${profile.loginId}</span>

      </div>
    </div>

    <div>
      <button type="button" class="btn-header-action" onclick="showEdit()">내 프로필 수정</button>
    </div>
  </div>

  <!-- 본문: 좌측 사이드바 + 우측 콘텐츠 -->
  <div class="body-wrapper">

    <!-- 좌측 사이드바 -->
    <div class="sidebar">

      <div class="sidebar-group">
        <div class="sidebar-label">지갑 관리</div>
        <ul class="sidebar-menu">
          <li onclick="switchTab('dashboard', this)" class="active">내 지갑</li>
          <li onclick="switchTab('received', this)">거래 내역</li>
        </ul>
      </div>

      <div class="sidebar-group">
        <div class="sidebar-label">계정 설정</div>
        <ul class="sidebar-menu">
          <!-- 기본 탭 active -->
          <li onclick="switchTab('edit', this)" id="menu-edit" >내 정보 수정</li>
        </ul>
      </div>
    </div>

    <!-- 우측 메인 콘텐츠 -->
    <div class="main-content">

      <!-- 내 정보 수정 -->
      <div id="view-edit" class="view-section active">
        <div class="dash-card">
          <h3 class="form-section-title">내 정보 수정</h3>

          <!-- 프리랜서 업데이트 엔드포인트로 변경 -->
          <form action="${pageContext.request.contextPath}/freelancer/mypage/update"
                method="post"
                enctype="multipart/form-data">

            <div class="form-row">
              <label>아이디 (수정 불가)</label>
              <input type="text" class="form-input" value="${profile.loginId}" readonly>
            </div>

            <div class="form-row">
              <label>이름</label>
              <input type="text" name="name" class="form-input" value="${profile.name}" readonly>
            </div>

            <div class="form-row">
              <label>연락처</label>
              <input type="text" name="phone" class="form-input" value="${profile.phone}">
            </div>

            <button type="submit" class="btn-submit">정보 수정 저장</button>
          </form>

          <!-- 비밀번호 변경 -->
          <div style="margin-top:40px; padding-top:30px; border-top:1px solid #eee;">
            <h3 class="form-section-title" style="font-size:18px; border:none; margin-bottom:15px;">비밀번호 변경</h3>

            <div class="form-row">
              <input type="password" id="currentPw" class="form-input" placeholder="현재 비밀번호">
            </div>
            <div class="form-row">
              <input type="password" id="newPw" class="form-input" placeholder="새 비밀번호">
            </div>
            <div class="form-row">
              <input type="password" id="newPwChk" class="form-input" placeholder="새 비밀번호 확인">
            </div>

            <button type="button" class="btn-submit" style="background:#555;" onclick="changePw()">비밀번호 변경</button>
          </div>

        </div>
      </div>

    </div><!-- /.main-content -->

  </div><!-- /.body-wrapper -->

</div><!-- /.mp-container -->

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
  const contextPath = "${pageContext.request.contextPath}";
  const msg = "${msg}";
</script>


<script src="${pageContext.request.contextPath}/resources/js/freelancerMypage.js"></script>

</body>
</html>
