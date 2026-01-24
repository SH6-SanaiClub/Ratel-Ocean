<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 | Ratel Ocean</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/clientMypage.css">
</head>
<body>

<div class="mp-container">

    <div class="header-card">
        <img src="${pageContext.request.contextPath}${not empty profile.profileImageUrl ? profile.profileImageUrl : '/resources/img/default_profile.png'}"
             class="header-img" id="headerProfileImg">

        <div class="header-content">
            <div class="header-top-row">
                <span class="client-id">${profile.loginId}</span>

                <c:choose>
                    <c:when test="${profile.userStatus eq 'ACTIVE'}">
                        <span class="status-badge status-active"><i class="fa-solid fa-check"></i> 활동 가능</span>
                    </c:when>
                    <c:otherwise>
                        <span class="status-badge status-inactive"><i class="fa-solid fa-ban"></i> 비활성</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="header-company">
                ${not empty profile.companyName ? profile.companyName : '개인 클라이언트'}
            </div>

            <div class="header-tags">
                <span class="tag-item">
                    <i class="fa-regular fa-user"></i>
                    ${profile.clientType eq 'CORPORATION' ? '법인' : '개인'}
                </span>
                <span class="tag-item">
                    <i class="fa-solid fa-location-dot"></i>
                    ${not empty profile.address ? profile.address : '주소 미입력'}
                </span>
            </div>
        </div>

        <div>
            <button type="button" class="btn-header-action" onclick="showEdit()">내 프로필 수정</button>
        </div>
    </div>

    <div class="body-wrapper">

        <div class="sidebar">
            <div class="sidebar-group">
                <div class="sidebar-label">평가 관리</div>
                <ul class="sidebar-menu">
                    <li onclick="switchTab('dashboard', this)" class="active">내 평가</li>
                    <li onclick="alert('준비 중인 기능입니다.')">프리랜서의 평가</li>
                </ul>
            </div>
            <div class="sidebar-group">
                <div class="sidebar-label">계정 설정</div>
                <ul class="sidebar-menu">
                    <li onclick="switchTab('edit', this)" id="menu-edit">내 정보 수정</li>
                </ul>
            </div>
        </div>

        <div class="main-content">

            <div id="view-dashboard" class="view-section active">

                <div class="dash-card">
                    <div class="dash-title">외주 평균 평점</div>

                    <div class="stats-row">
                        <div class="stat-box">
                            <h4>평균 평점</h4>
                            <div class="stat-value">
                                <i class="fa-solid fa-star" style="color:#fdd835;"></i>
                                <fmt:formatNumber value="${profile.stats.avgRating}" pattern="0.0"/>
                            </div>
                        </div>
                        <div class="stat-box">
                            <h4>완료한 계약</h4>
                            <div class="stat-value">${profile.stats.contractCount} 건</div>
                        </div>
                    </div>

                </div>

                <div class="dash-card">
                    <div class="dash-title">나의 평가</div>

                    <c:choose>
                        <c:when test="${not empty profile.stats.reviewList}">
                            <c:forEach var="review" items="${profile.stats.reviewList}">
                                <div class="review-item">
                                    <div class="review-header">
                                        <span class="review-writer">
                                            <i class="fa-regular fa-user"></i> ${review.freelancerName}
                                        </span>
                                        <span class="review-date">${review.contractedAt}</span>
                                    </div>
                                    <div style="margin-bottom:8px; color:#fdd835; font-size:12px;">
                                        <c:forEach begin="1" end="${review.rating}">★</c:forEach>
                                    </div>
                                    <div class="review-content">${review.content}</div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div style="text-align:center; padding:50px; color:#999; background:#f9f9f9; border-radius:4px;">
                                아직 등록된 평가가 없습니다.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div id="view-edit" class="view-section">
                <div class="dash-card">
                    <h3 class="form-section-title">내 정보 수정</h3>

                    <form action="${pageContext.request.contextPath}/client/mypage/update" method="post"
                          enctype="multipart/form-data">
                        <input type="hidden" name="clientType" value="${profile.clientType}">
                        <input type="hidden" name="companyId" value="${profile.companyId}">

                        <div style="display:flex; align-items:center; gap:20px; margin-bottom:30px;">
                            <img src="${pageContext.request.contextPath}${not empty profile.profileImageUrl ? profile.profileImageUrl : '/resources/img/default_profile.png'}"
                                 id="previewImg"
                                 style="width:80px; height:80px; border-radius:50%; object-fit:cover; border:1px solid #ddd;">
                            <div>
                                <label for="profileFile"
                                       style="cursor:pointer; background:#fff; border:1px solid #ccc; padding:6px 12px; border-radius:4px; font-size:13px; font-weight:600;">
                                    이미지 변경
                                </label>
                                <input type="file" id="profileFile" name="profileFile" style="display:none;"
                                       accept="image/*" onchange="readURL(this)">
                                <div style="font-size:12px; color:#888; margin-top:5px;">5MB 이하의 이미지 파일</div>
                            </div>
                        </div>

                        <div class="form-row">
                            <label>아이디 (수정 불가)</label>
                            <input type="text" class="form-input" value="${profile.loginId}" readonly>
                        </div>
                        <div class="form-row">
                            <label>담당자명 / 이름</label>
                            <input type="text" name="name" class="form-input" value="${profile.name}" required>
                        </div>
                        <div class="form-row">
                            <label>연락처</label>
                            <input type="text" name="phone" class="form-input" value="${profile.phone}">
                        </div>

                        <c:if test="${profile.clientType eq 'CORPORATION'}">
                            <div class="corp-area">
                                <h4 style="margin-top:0; margin-bottom:15px; font-size:14px; color:#1F7A8C;">🏢 법인 정보</h4>
                                <div class="form-row">
                                    <label>회사명</label>
                                    <input type="text" name="companyName" class="form-input" value="${profile.companyName}">
                                </div>
                                <div class="form-row">
                                    <label>대표자명</label>
                                    <input type="text" name="ceoName" class="form-input" value="${profile.ceoName}">
                                </div>
                                <div class="form-row">
                                    <label>사업자 등록번호</label>
                                    <input type="text" name="businessNumber" class="form-input" value="${profile.businessNumber}">
                                </div>
                                <div class="form-row">
                                    <label>주소</label>
                                    <input type="text" name="address" class="form-input" value="${profile.address}">
                                </div>
                                <div class="form-row">
                                    <label>웹사이트 URL</label>
                                    <input type="text" name="websiteUrl" class="form-input" value="${profile.websiteUrl}">
                                </div>
                            </div>
                        </c:if>

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
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const contextPath = "${pageContext.request.contextPath}";
    const msg = "${msg}";
</script>
<script src="${pageContext.request.contextPath}/resources/js/clientMypage.js"></script>

</body>
</html>