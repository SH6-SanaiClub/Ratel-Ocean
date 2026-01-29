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
<jsp:include page="/WEB-INF/views/common/headerBase.jsp" />
<div class="mp-container">

    <div class="header-card">
        <div class="profile-frame">
            <%-- 1. 실제 이미지 (있으면 보이고, 없거나 에러나면 숨김) --%>
            <img id="headerProfileImg"
                 src="${not empty profile.profileImageUrl ? pageContext.request.contextPath.concat(profile.profileImageUrl) : ''}"
                 style="${not empty profile.profileImageUrl ? '' : 'display:none;'}"
                 onerror="this.style.display='none'">

            <%-- 2. 기본 아이콘 (항상 뒤에 깔려있음) --%>
            <i class="fa-solid fa-user"></i>
        </div>

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
                    <li onclick="switchTab('dashboard', this)" class="active">작성한 평가</li>
                    <li onclick="switchTab('received', this)">받은 평가</li>
                </ul>
            </div>
            <div class="sidebar-group">
                <div class="sidebar-label">계정 설정</div>
                <ul class="sidebar-menu">
                    <li onclick="switchTab('edit', this)" id="menu-edit">내 정보 수정</li>
                    <li onclick="checkCompanyAccess(this)" id="menu-company">회사 정보 수정</li>
                </ul>
            </div>
        </div>

        <div class="main-content">

            <%-- 1. 내 평가 (작성한 리뷰) 화면 --%>
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
                    <div class="dash-title">나의 평가 (작성한 리뷰)</div>

                    <c:choose>
                        <c:when test="${not empty profile.stats.reviewList}">
                            <c:forEach var="review" items="${profile.stats.reviewList}">
                                <div class="review-card">
                                    <div class="rc-header">
                                        <div class="rc-title">${review.projectTitle}</div>
                                        <div class="rc-date">계약일: ${review.contractedAt}</div>
                                    </div>
                                    <div class="rc-info-grid">
                                        <div class="rc-info-item">
                                            <span class="label">프로젝트 기간</span>
                                            <span class="value">${review.startDate} ~ ${review.endDate}</span>
                                        </div>
                                        <div class="rc-info-item">
                                            <span class="label">총 예산</span>
                                            <span class="value">₩ <fmt:formatNumber value="${review.budget}" type="number"/></span>
                                        </div>
                                        <div class="rc-info-item">
                                            <span class="label">담당 프리랜서</span>
                                            <span class="value" style="font-weight:700;">${review.freelancerName}</span>
                                        </div>
                                        <div class="rc-info-item">
                                            <span class="label">재계약 의사</span>
                                            <c:choose>
                                                <c:when test="${review.recontractIntended}">
                                                    <span class="value" style="color:#2E7D32; font-weight:700;">
                                                        <i class="fa-solid fa-circle-check"></i> 있음
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="value" style="color:#999;">없음</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <div class="rc-content-area">
                                        <div style="margin-bottom:8px; color:#fdd835; font-size:14px;">
                                            <c:forEach begin="1" end="${review.rating}">★</c:forEach>
                                            <span style="color:#333; font-weight:700; font-size:13px; margin-left:5px;">
                                                ${review.rating}.0
                                            </span>
                                        </div>
                                        <div class="rc-text">${review.content}</div>
                                    </div>
                                    <c:if test="${review.recontractIntended}">
                                        <div style="margin-top:15px; text-align:right;">
                                            <button type="button" class="btn-profile-link"
                                                    onclick="window.open('${pageContext.request.contextPath}/profile/${review.freelancerId}', '_blank')">
                                                <i class="fa-solid fa-user-tag"></i> 프리랜서 프로필 상세보기
                                            </button>
                                        </div>
                                    </c:if>
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

            <%-- 2. 프리랜서의 평가 (받은 리뷰) 화면 --%>
                <div id="view-received" class="view-section">

                    <div class="dash-card">
                        <div class="dash-title">받은 평균 평점</div>
                        <div class="stats-row">
                            <div class="stat-box">
                                <h4>평균 평점</h4>
                                <div class="stat-value">
                                    <i class="fa-solid fa-star" style="color:#fdd835;"></i>
                                    <fmt:formatNumber value="${profile.stats.avgRating}" pattern="0.0"/>
                                </div>
                            </div>
                            <div class="stat-box">
                                <h4>받은 리뷰 수</h4>
                                <div class="stat-value">
                                    ${empty profile.stats.receivedReviewList ? 0 : profile.stats.receivedReviewList.size()} 건
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="dash-card">
                        <div class="dash-title">프리랜서의 평가 (받은 리뷰)</div>

                        <c:choose>
                            <c:when test="${not empty profile.stats.receivedReviewList}">
                                <c:forEach var="review" items="${profile.stats.receivedReviewList}">

                                    <div class="review-card">
                                        <div class="rc-header">
                                            <div class="rc-title">${review.projectTitle}</div>
                                            <div class="rc-date">계약일: ${review.contractedAt}</div>
                                        </div>

                                        <div class="rc-info-grid">
                                            <div class="rc-info-item">
                                                <span class="label">프로젝트 기간</span>
                                                <span class="value">${review.startDate} ~ ${review.endDate}</span>
                                            </div>
                                            <div class="rc-info-item">
                                                <span class="label">총 예산</span>
                                                <span class="value">₩ <fmt:formatNumber value="${review.budget}" type="number"/></span>
                                            </div>
                                            <div class="rc-info-item">
                                                <span class="label">작성자 (프리랜서)</span>
                                                <span class="value" style="font-weight:700;">${review.freelancerName}</span>
                                            </div>
                                        </div>

                                        <div class="rc-content-area">
                                            <div style="margin-bottom:8px; color:#fdd835; font-size:14px;">
                                                <c:forEach begin="1" end="${review.rating}">★</c:forEach>
                                                <span style="color:#333; font-weight:700; font-size:13px; margin-left:5px;">
                                                ${review.rating}.0
                                            </span>
                                            </div>
                                            <div class="rc-text">${review.content}</div>
                                        </div>

                                        <div style="margin-top:15px; text-align:right;">
                                            <button type="button" class="btn-profile-link"
                                                    onclick="window.open('${pageContext.request.contextPath}/profile/${review.freelancerId}', '_blank')">
                                                <i class="fa-solid fa-user-tag"></i> 작성자 프로필 보기
                                            </button>
                                        </div>

                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div style="text-align:center; padding:50px; color:#999; background:#f9f9f9; border-radius:4px;">
                                    아직 받은 평가가 없습니다.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            <div id="view-edit" class="view-section">
                <div class="dash-card">
                    <h3 class="form-section-title">내 정보 수정</h3>
                    <form action="${pageContext.request.contextPath}/client/mypage/update" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="clientType" value="${profile.clientType}">
                        <input type="hidden" name="companyId" value="${profile.companyId}">

                        <div style="display:flex; align-items:center; gap:20px; margin-bottom:30px;">

                            <%-- [수정] 미리보기 영역 --%>
                            <div class="profile-frame preview-size">
                                <img id="previewImg"
                                     src="${not empty profile.profileImageUrl ? pageContext.request.contextPath.concat(profile.profileImageUrl) : ''}"
                                     style="${not empty profile.profileImageUrl ? '' : 'display:none;'}"
                                     onerror="this.style.display='none'">
                                <i class="fa-solid fa-user"></i>
                            </div>

                            <div>
                                <label for="profileFile" style="cursor:pointer; background:#fff; border:1px solid #ccc; padding:6px 12px; border-radius:4px; font-size:13px; font-weight:600;">
                                    이미지 변경
                                </label>
                                <%-- 파일 입력 (기존 유지) --%>
                                <input type="file" id="profileFile" name="profileFile" style="display:none;" accept="image/*" onchange="readURL(this)">
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

            <div id="view-company" class="view-section">
                <div class="dash-card">
                    <h3 class="form-section-title">🏢 회사(사업자) 정보 관리</h3>

                    <form action="${pageContext.request.contextPath}/client/mypage/company-update" method="post">
                        <input type="hidden" name="companyId" value="${profile.companyId}">

                        <div class="form-row">
                            <label>회사명 (상호)</label>
                            <input type="text" name="companyName" class="form-input" value="${profile.companyName}" required>
                        </div>

                        <div style="display:flex; gap:20px;">
                            <div class="form-row" style="flex:1;">
                                <label>대표자명</label>
                                <input type="text" name="ceoName" class="form-input" value="${profile.ceoName}">
                            </div>
                            <div class="form-row" style="flex:1;">
                                <label>대표자 이메일</label>
                                <input type="email" name="ceoEmail" class="form-input" value="${profile.ceoEmail}">
                            </div>
                        </div>

                        <div style="display:flex; gap:20px;">
                            <div class="form-row" style="flex:1;">
                                <label>사업자 등록번호</label>
                                <input type="text" name="businessNumber" class="form-input" value="${profile.businessNumber}">
                            </div>
                            <div class="form-row" style="flex:1;">
                                <label>개업일자</label>
                                <input type="date" name="openingDate" class="form-input" value="${profile.openingDate}">
                            </div>
                        </div>

                        <div class="form-row">
                            <label>업종</label>
                            <input type="text" name="industry" class="form-input" value="${profile.industry}">
                        </div>

                        <div class="form-row">
                            <label>회사 규모</label>
                            <select name="companySize" class="form-input">
                                <option value="STARTUP" ${profile.companySize eq 'STARTUP' ? 'selected' : ''}>스타트업</option>
                                <option value="SMALL" ${profile.companySize eq 'SMALL' ? 'selected' : ''}>중소기업</option>
                                <option value="MEDIUM" ${profile.companySize eq 'MEDIUM' ? 'selected' : ''}>중견기업</option>
                                <option value="LARGE" ${profile.companySize eq 'LARGE' ? 'selected' : ''}>대기업</option>
                                <option value="ENTERPRISE" ${profile.companySize eq 'ENTERPRISE' ? 'selected' : ''}>글로벌 기업</option>
                            </select>
                        </div>

                        <div class="form-row">
                            <label>소재지 (사업장 주소)</label>
                            <input type="text" name="address" class="form-input" value="${profile.address}">
                        </div>

                        <div class="form-row">
                            <label>웹사이트 URL</label>
                            <input type="url" name="websiteUrl" class="form-input" value="${profile.websiteUrl}">
                        </div>

                        <button type="submit" class="btn-submit" style="background:#1F7A8C;">회사 정보 저장</button>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    const contextPath = "${pageContext.request.contextPath}";
    const msg = "${msg}";
    const clientType = "${profile.clientType}";
</script>
<script src="${pageContext.request.contextPath}/resources/js/clientMypage.js"></script>

</body>
</html>