<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약 작성 테스트</title>
    <style>
        body {
            background: #f8f9fa;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding: 40px 0;
        }
        .container {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.08);
            max-width: 700px;
            width: 100%;
            padding: 40px 32px;
        }
        .section-title {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 24px;
            color: #333;
            text-align: center;
        }
        .info-box {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #667eea;
        }
        .info-label {
            font-size: 12px;
            color: #666;
            font-weight: 600;
            margin-bottom: 2px;
        }
        .info-value {
            font-size: 16px;
            color: #333;
            font-weight: 500;
        }
        .upload-section {
            margin-top: 32px;
        }
        .upload-box {
            border: 2px dashed #667eea;
            border-radius: 8px;
            padding: 32px 20px;
            text-align: center;
            background: #f5f7ff;
            cursor: pointer;
            margin-bottom: 16px;
        }
        .file-info {
            margin-top: 12px;
            padding: 10px;
            background: #e8f5e9;
            border-radius: 8px;
            border-left: 4px solid #4caf50;
            display: none;
        }
        .file-info.active { display: block; }
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 12px;
            border-left: 4px solid #c62828;
            display: none;
        }
        .error-message.active { display: block; }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            margin-top: 20px;
            width: 100%;
        }
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
<div class="container">
    <h2 class="section-title">계약 작성 테스트</h2>
    <form id="selectProjectForm" method="get" action="">
        <label for="projectId">프로젝트 선택:</label>
        <select name="projectId" id="projectId" onchange="this.form.submit()" style="margin-bottom: 24px; width: 100%; padding: 8px;">
            <option value="">-- 프로젝트를 선택하세요 --</option>
            <c:forEach var="project" items="${projectList}">
                <option value="${project.projectId}" <c:if test="${selectedProject != null && selectedProject.projectId == project.projectId}">selected</c:if>>
                    ${project.title} (${project.status})
                </option>
            </c:forEach>
        </select>
    </form>
    <c:if test="${selectedProject != null}">
        <div class="info-box">
            <div><span class="info-label">프로젝트명</span> <span class="info-value">${selectedProject.title}</span></div>
            <div><span class="info-label">설명</span> <span class="info-value">${selectedProject.description}</span></div>
            <div><span class="info-label">카테고리</span> <span class="info-value">${selectedProject.category}</span></div>
            <div><span class="info-label">상태</span> <span class="info-value">${selectedProject.status}</span></div>
            <div><span class="info-label">예산</span> <span class="info-value"><fmt:formatNumber value="${selectedProject.budget}" type="number" groupingUsed="true" /> 원 (${selectedProject.budgetType})</span></div>
            <div><span class="info-label">예상 시작일</span> <span class="info-value">${selectedProject.startDate}</span></div>
            <div><span class="info-label">예상 마감일</span> <span class="info-value">${selectedProject.endDate}</span></div>
            <div><span class="info-label">기술 스택</span> <span class="info-value">${selectedProject.techStack}</span></div>
            <div><span class="info-label">클라이언트</span> <span class="info-value">${selectedProject.clientName} (${selectedProject.clientEmail})</span></div>
        </div>
        <div class="upload-section">
            <form id="uploadForm" method="POST" action="${pageContext.request.contextPath}/contract/test/upload" enctype="multipart/form-data" onsubmit="return validateForm();">
                <input type="hidden" name="projectId" value="${selectedProject.projectId}" />
                <div class="upload-box" id="uploadBox" onclick="document.getElementById('pdfInput').click();">
                    <span>📁 PDF 파일을 클릭 또는 드래그하여 업로드</span>
                </div>
                <input type="file" id="pdfInput" name="pdf" accept=".pdf" onchange="handleFileSelect(event)" style="display:none;" />
                <div class="file-info" id="fileInfo">
                    <div id="fileName"></div>
                    <div id="fileSize"></div>
                </div>
                <div class="error-message" id="errorMsg"></div>
                <button type="submit" class="btn" id="submitBtn" disabled>AI 분석 시작</button>
            </form>
        </div>
    </c:if>
</div>
<script>
function handleFileSelect(event) {
    const file = event.target.files[0];
    const fileInfo = document.getElementById('fileInfo');
    const errorMsg = document.getElementById('errorMsg');
    const submitBtn = document.getElementById('submitBtn');
    if (!file) {
        fileInfo.classList.remove('active');
        submitBtn.disabled = true;
        return;
    }
    if (!file.name.toLowerCase().endsWith('.pdf')) {
        errorMsg.textContent = 'PDF 파일만 업로드 가능합니다.';
        errorMsg.classList.add('active');
        fileInfo.classList.remove('active');
        submitBtn.disabled = true;
        return;
    }
    const maxSize = 50 * 1024 * 1024;
    if (file.size > maxSize) {
        errorMsg.textContent = '파일 크기가 50MB를 초과합니다.';
        errorMsg.classList.add('active');
        fileInfo.classList.remove('active');
        submitBtn.disabled = true;
        return;
    }
    errorMsg.classList.remove('active');
    document.getElementById('fileName').textContent = '파일명: ' + file.name;
    document.getElementById('fileSize').textContent = '크기: ' + (file.size / 1024).toFixed(2) + ' KB';
    fileInfo.classList.add('active');
    submitBtn.disabled = false;
}
function validateForm() {
    const fileInput = document.getElementById('pdfInput');
    if (!fileInput.value) {
        alert('PDF 파일을 업로드하세요.');
        return false;
    }
    return true;
}
</script>
</body>
</html>
