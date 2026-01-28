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
      <button type="button"
              class="btn-header-action"
              onclick="location.href='${pageContext.request.contextPath}/freelancer/profile/edit'">
        내 프로필 수정
      </button>
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

      <!-- 내 지갑 (기본 활성) -->
      <div id="view-dashboard" class="view-section active">
        <div class="dash-card">
          <h3 class="form-section-title">내 지갑</h3>

          <div style="display:flex; gap:20px; flex-wrap:wrap;">
            <div style="flex:1; min-width:260px; border:1px solid #eee; border-radius:4px; padding:20px;">
              <div style="font-weight:700; margin-bottom:8px;">보유 금액</div>
              <div style="font-size:28px; font-weight:800;">
                <c:choose>
                  <c:when test="${not empty wallet}">
                    <fmt:formatNumber value="${wallet.balance}" type="number"/> 원
                  </c:when>
                  <c:otherwise>0 원</c:otherwise>
                </c:choose>
              </div>
            </div>

            <div style="flex:1; min-width:260px; border:1px solid #eee; border-radius:4px; padding:20px;">
              <div style="font-weight:700; margin-bottom:8px;">총 수익</div>
              <div style="font-size:28px; font-weight:800;">
                <c:choose>
                  <c:when test="${not empty wallet}">
                    <fmt:formatNumber value="${wallet.totalEarned}" type="number"/> 원
                  </c:when>
                  <c:otherwise>0 원</c:otherwise>
                </c:choose>
              </div>

            </div>
          </div>

          <div style="margin-top:18px; color:#888; font-size:12px;">
            ※ 출금 기능 구현 예정
          </div>
        </div>
      </div>

      <!-- 거래 내역 -->
      <div id="view-received" class="view-section">
        <div class="dash-card">
          <h3 class="form-section-title">거래 내역</h3>

          <div id="historyList"></div>

          <button type="button" id="btnMoreHistory" class="btn-submit"
                  style="margin-top:15px; background:#555;"
                  onclick="loadMoreHistory()">
            더보기
          </button>
        </div>
      </div>

      <!-- 내 정보 수정 -->
      <div id="view-edit" class="view-section">
        <div class="dash-card">
          <h3 class="form-section-title">내 정보 수정</h3>

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

    </div>
    <!-- /.main-content -->

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
