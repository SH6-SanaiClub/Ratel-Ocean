<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${project.title}</title>
    <style>
        body {
            margin: 0;
            font-family: Pretendard, Arial, sans-serif;
            background: #f8fafc;
            color: #111827;
        }

        .detail-wrap {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 16px;
        }

        .card {
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 10px 28px rgba(15, 23, 42, 0.08);
            padding: 32px;
        }

        .title {
            font-size: 30px;
            font-weight: 950;
            margin-bottom: 10px;
        }

        .meta {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            font-size: 13px;
            color: #6b7280;
            font-weight: 800;
            margin-bottom: 24px;
        }

        .section {
            margin-bottom: 28px;
        }

        .section h3 {
            font-size: 16px;
            font-weight: 900;
            margin-bottom: 10px;
        }

        .desc {
            line-height: 1.7;
            white-space: pre-line;
        }

        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        .info-box {
            background: #f9fafb;
            border-radius: 12px;
            padding: 14px;
            font-size: 14px;
            font-weight: 800;
        }

        .info-label {
            font-size: 12px;
            color: #6b7280;
            margin-bottom: 6px;
        }

        .actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 36px;
        }

        .btn {
            padding: 12px 18px;
            border-radius: 12px;
            font-weight: 900;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background: #5c3cce;
            color: #fff;
        }

        .btn-outline {
            background: #fff;
            border: 1px solid #d1d5db;
        }
    </style>
</head>
<body>
<div class="detail-wrap">
    <div class="card">
        <!-- 제목 -->
        <div class="title">${project.title}</div>
        <!-- 메타 -->
        <div class="meta">
            <span>등록일 ${project.createdAt}</span>
            <span>조회수 ${project.viewCount}</span>
            <span>지원자 ${project.applicantCount}명</span>
            <span>상태 ${project.projectStatus}</span>
        </div>
        <!-- 설명 -->
        <div class="section">
            <h3>프로젝트 설명</h3>
            <div class="desc">${project.description}</div>
        </div>
        <!-- 정보 -->
        <div class="section">
            <h3>프로젝트 정보</h3>
            <div class="info-grid">
                <div class="info-box">
                    <div class="info-label">예산</div>
                    <fmt:formatNumber value="${project.budget / 10000}"
                                      maxFractionDigits="0"/>만원
                </div>
                <div class="info-box">
                    <div class="info-label">예상 기간</div>
                    ${project.estDuration}
                </div>
                <div class="info-box">
                    <div class="info-label">시작 예정일</div>
                    ${project.startDate}
                </div>
                <div class="info-box">
                    <div class="info-label">마감일</div>
                    ${project.deadlineDate}
                </div>
                <div class="info-box">
                    <div class="info-label">커뮤니케이션</div>
                    ${project.communicateMethod}
                </div>
                <div class="info-box">
                    <div class="info-label">결제 방식</div>
                    ${project.paymentMethod}
                </div>
                <c:if test="${not empty project.changePolicy}">
                    <div class="info-box">
                        <div class="info-label">변경/수정 정책</div>
                            ${project.changePolicy}
                    </div>
                </c:if>
                <div class="info-box">
                    <div class="info-label">최대 수정 횟수</div>
                    ${project.maxRevisionCount}회
                </div>
            </div>
        </div>
        <!-- 버튼 -->
        <div class="actions">
            <a class="btn btn-outline"
               href="${pageContext.request.contextPath}/project/dashboard?page=${page}&size=${size}&onlyActive=${onlyActive}&keyword=${fn:escapeXml(keyword)}">
                목록으로
            </a>
            <button class="btn btn-primary">
                지원하기
            </button>
        </div>
    </div>
</div>
</body>
</html>