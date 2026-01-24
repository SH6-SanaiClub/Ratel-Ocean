<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>프로젝트 관리 | Ratel Ocean</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/project/manage.css">
</head>
<body>

<div class="container section">

    <div class="page-header">
        <h2 class="page-title">내 프로젝트 및 지원자 관리</h2>
    </div>

    <div class="manage-grid-layout">

        <div class="card">
            <div class="panel-header-text">프로젝트 목록</div>
            <div class="scroll-container">

                <div class="list-group-title">모집 중</div>
                <c:forEach var="p" items="${recruitingProjects}">
                    <div class="custom-list-item" onclick="loadApplicants(${p.projectId}, this)">
                        <span class="item-header">
                            <span class="item-main-text">
                                <span class="status-indicator status-recruiting"></span>${p.title}
                            </span>
                        </span>
                        <span class="item-sub-text">지원자 ${p.applicantCount}명 · D-${p.dDay}</span>
                    </div>
                </c:forEach>

                <div class="list-group-title">진행 및 완료</div>
                <c:forEach var="p" items="${ongoingProjects}">
                    <div class="custom-list-item" onclick="loadApplicants(${p.projectId}, this)">
                        <span class="item-header">
                            <span class="item-main-text">
                                <span class="status-indicator status-ongoing"></span>${p.title}
                            </span>
                        </span>
                        <span class="item-sub-text">진행중</span>
                    </div>
                </c:forEach>
                <c:forEach var="p" items="${completedProjects}">
                    <div class="custom-list-item" onclick="loadApplicants(${p.projectId}, this)">
                        <span class="item-header">
                            <span class="item-main-text">
                                <span class="status-indicator status-completed"></span>${p.title}
                            </span>
                        </span>
                        <span class="item-sub-text">완료됨</span>
                    </div>
                </c:forEach>
            </div>
        </div>

        <div class="card">
            <div class="panel-header-column">

                <div id="projectControlBar" style="display:none;">
                    <span id="selectedProjectTitle" class="selected-project-title"></span>
                    <div class="btn-group">
                        <button class="btn-mini" onclick="goToProjectDetail()">
                            <i class="fa-solid fa-arrow-up-right-from-square"></i> 바로가기
                        </button>

                        <button class="btn-mini" onclick="goEditProject()">
                            <i class="fa-solid fa-pen"></i> 수정
                        </button>
                        <button class="btn-mini btn-danger" onclick="deleteProject()">
                            <i class="fa-regular fa-trash-can"></i> 삭제
                        </button>
                    </div>
                </div>

                <div class="applicant-list-label">
                    <span>지원자 목록</span>
                    <span id="applicantCountBadge" class="badge badge-secondary" style="display:none;">0</span>
                </div>
            </div>

            <div id="applicantListArea" class="scroll-container">
                <div class="empty-state">
                    <i class="fa-regular fa-folder-open"></i>
                    <p>프로젝트를 선택해주세요.</p>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="panel-header-text">상세 프로필</div>
            <div id="applicantDetailArea" class="scroll-container">
                <div class="empty-state">
                    <i class="fa-regular fa-user"></i>
                    <p>지원자를 선택하면<br>상세 정보가 표시됩니다.</p>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    const contextPath = "${pageContext.request.contextPath}";

    $(document).ready(function() {
        const msg = "${msg}";
        if (msg && msg.trim() !== "") {
            alert(msg);
        }
    });
</script>

<script src="${pageContext.request.contextPath}/resources/js/project/manage.js"></script>
</body>
</html>