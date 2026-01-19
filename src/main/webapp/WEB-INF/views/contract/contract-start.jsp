<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>계약 시작 - 라테오션</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            width: 100%;
            overflow: hidden;
        }
        
        /* ═══════════════════════════════════════════════════════════════ */
        /* 헤더 영역 */
        /* ═══════════════════════════════════════════════════════════════ */
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .header p {
            font-size: 14px;
            opacity: 0.9;
            line-height: 1.5;
        }
        
        /* ═══════════════════════════════════════════════════════════════ */
        /* 콘텐츠 영역 */
        /* ═══════════════════════════════════════════════════════════════ */
        
        .content {
            padding: 40px 30px;
        }
        
        /* 섹션 제목 */
        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        /* 정보 표시 */
        .info-box {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #667eea;
        }
        
        .info-item {
            margin-bottom: 15px;
        }
        
        .info-item:last-child {
            margin-bottom: 0;
        }
        
        .info-label {
            display: block;
            font-size: 12px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 5px;
            letter-spacing: 0.5px;
        }
        
        .info-value {
            display: block;
            font-size: 16px;
            color: #333;
            font-weight: 500;
        }
        
        /* 프리랜서 정보 */
        .freelancer-info {
            background: #fffbf0;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid #ff9800;
        }
        
        .freelancer-info .info-label {
            color: #e67e22;
        }
        
        /* PDF 업로드 섹션 */
        .upload-section {
            margin-top: 40px;
            padding-top: 40px;
            border-top: 1px solid #e0e0e0;
        }
        
        .upload-box {
            border: 2px dashed #667eea;
            border-radius: 8px;
            padding: 40px 30px;
            text-align: center;
            background: #f5f7ff;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }
        
        .upload-box:hover {
            border-color: #764ba2;
            background: #f0f3ff;
        }
        
        .upload-box.dragover {
            border-color: #764ba2;
            background: #e8eeff;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .upload-icon {
            font-size: 48px;
            margin-bottom: 15px;
            display: block;
        }
        
        .upload-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        .upload-description {
            font-size: 13px;
            color: #666;
            margin-bottom: 15px;
        }
        
        .upload-hint {
            font-size: 12px;
            color: #999;
            margin-top: 10px;
        }
        
        #pdfInput {
            display: none;
        }
        
        /* 선택된 파일 표시 */
        .file-info {
            margin-top: 20px;
            padding: 15px;
            background: #e8f5e9;
            border-radius: 8px;
            border-left: 4px solid #4caf50;
            display: none;
        }
        
        .file-info.active {
            display: block;
        }
        
        .file-name {
            font-weight: 600;
            color: #2e7d32;
            margin-bottom: 5px;
        }
        
        .file-size {
            font-size: 12px;
            color: #558b2f;
        }
        
        /* 버튼 */
        .button-group {
            margin-top: 40px;
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .btn-secondary {
            background: #f0f0f0;
            color: #333;
        }
        
        .btn-secondary:hover {
            background: #e0e0e0;
        }
        
        /* 에러 메시지 */
        .error-message {
            background: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #c62828;
            display: none;
        }
        
        .error-message.active {
            display: block;
        }
        
        /* 로딩 상태 */
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
            color: #667eea;
            font-weight: 600;
        }
        
        .loading.active {
            display: block;
        }
        
        .spinner {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 10px;
            vertical-align: middle;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* 반응형 디자인 */
        @media (max-width: 600px) {
            .header {
                padding: 30px 20px;
            }
            
            .header h1 {
                font-size: 22px;
            }
            
            .content {
                padding: 25px 20px;
            }
            
            .button-group {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
    <div class="container">
        <!-- 헤더 -->
        <div class="header">
            <h1>📋 계약 작성</h1>
            <p>1️⃣ Step 1: 프로젝트 공지 확인 및 계약서 PDF 업로드</p>
        </div>
        
        <!-- 메인 콘텐츠 -->
        <div class="content">
            
            <!-- 에러 메시지 -->
            <c:if test="${not empty error}">
                <div class="error-message active">
                    <strong>❌ 오류:</strong> ${error}
                </div>
            </c:if>
            
            <!-- 프로젝트 정보 섹션 -->
            <div>
                <h2 class="section-title">📌 프로젝트 정보</h2>
                
                <div class="info-box">
                    <div class="info-item">
                        <span class="info-label">프로젝트명</span>
                        <span class="info-value">${projectInfo.title}</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="info-label">프로젝트 설명</span>
                        <span class="info-value">${projectInfo.description}</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="info-label">예산</span>
                        <span class="info-value">
                            <fmt:formatNumber value="${projectInfo.budget}" type="number" groupingUsed="true" /> 원
                        </span>
                    </div>
                    
                    <div class="info-item">
                        <span class="info-label">생성일</span>
                        <span class="info-value">
                            ${projectInfo.createdAt.toString().substring(0, 16).replace('T', ' ')}
                        </span>
                    </div>
                </div>
            </div>
            
            <!-- 프리랜서 정보 섹션 -->
            <div>
                <h2 class="section-title">👤 프리랜서 정보</h2>
                
                <div class="freelancer-info">
                    <div class="info-item">
                        <span class="info-label">이름</span>
                        <span class="info-value">${freelancerName}</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="info-label">이메일</span>
                        <span class="info-value">${freelancerEmail}</span>
                    </div>
                    
                    <div class="info-item">
                        <span class="info-label">경력</span>
                        <span class="info-value">${freelancerExperience} 년</span>
                    </div>
                </div>
            </div>
            
            <!-- PDF 업로드 섹션 -->
            <div class="upload-section">
                <h2 class="section-title">📄 계약서 PDF 업로드</h2>
                
                <form id="uploadForm" method="POST" action="${pageContext.request.contextPath}/contract/analyze" 
                      enctype="multipart/form-data" onsubmit="return validateForm();">
                    
                    <!-- 숨겨진 필드 -->
                    <input type="hidden" name="projectId" value="${projectInfo.projectId}" />
                    <input type="hidden" name="freelancerId" value="${freelancerId}" />
                    
                    <!-- PDF 업로드 박스 -->
                    <div class="upload-box" id="uploadBox" ondrop="handleDrop(event)" 
                         ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" 
                         onclick="document.getElementById('pdfInput').click();">
                        <span class="upload-icon">📁</span>
                        <div class="upload-title">PDF 파일을 여기에 드래그하거나 클릭하세요</div>
                        <div class="upload-description">또는 컴퓨터에서 선택</div>
                        <div class="upload-hint">
                            지원 형식: PDF (.pdf) | 최대 크기: 50MB
                        </div>
                    </div>
                    
                    <!-- 파일 입력 (숨김) -->
                    <input type="file" id="pdfInput" name="pdf" accept=".pdf" 
                           onchange="handleFileSelect(event)" />
                    
                    <!-- 선택된 파일 정보 -->
                    <div class="file-info" id="fileInfo">
                        <div class="file-name" id="fileName"></div>
                        <div class="file-size" id="fileSize"></div>
                    </div>
                    
                    <!-- 로딩 상태 -->
                    <div class="loading" id="loading">
                        <span class="spinner"></span> 분석 중...
                    </div>
                    
                    <!-- 버튼 그룹 -->
                    <div class="button-group">
                        <button type="submit" class="btn btn-primary" id="submitBtn" disabled>
                            ▶️ 다음 단계 (AI 분석)
                        </button>
                        <a href="javascript:history.back()" class="btn btn-secondary">
                            ◀️ 이전 단계
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- JavaScript -->
    <script>
        /**
         * [함수명] handleFileSelect
         * [목적] 파일 선택 input의 change 이벤트 핸들러
         * [로직]
         * 1. 선택된 파일 확인
         * 2. PDF 확장자 검증
         * 3. 파일 크기 검증 (50MB)
         * 4. 파일 정보 표시
         * 5. 제출 버튼 활성화
         */
        function handleFileSelect(event) {
            const file = event.target.files[0];
            const fileInfo = document.getElementById('fileInfo');
            const errorMsg = document.querySelector('.error-message');
            
            if (!file) {
                fileInfo.classList.remove('active');
                document.getElementById('submitBtn').disabled = true;
                return;
            }
            
            // PDF 확장자 검증
            if (!file.name.toLowerCase().endsWith('.pdf')) {
                errorMsg.textContent = '❌ 오류: PDF 파일만 업로드 가능합니다.';
                errorMsg.classList.add('active');
                fileInfo.classList.remove('active');
                document.getElementById('submitBtn').disabled = true;
                return;
            }
            
            // 파일 크기 검증 (50MB)
            const maxSize = 50 * 1024 * 1024;
            if (file.size > maxSize) {
                errorMsg.textContent = '❌ 오류: 파일 크기가 50MB를 초과합니다.';
                errorMsg.classList.add('active');
                fileInfo.classList.remove('active');
                document.getElementById('submitBtn').disabled = true;
                return;
            }
            
            // 에러 메시지 숨기기
            errorMsg.classList.remove('active');
            
            // 파일 정보 표시
            document.getElementById('fileName').textContent = '✓ 파일명: ' + file.name;
            document.getElementById('fileSize').textContent = '크기: ' + 
                (file.size / 1024).toFixed(2) + ' KB';
            fileInfo.classList.add('active');
            
            // 제출 버튼 활성화
            document.getElementById('submitBtn').disabled = false;
        }
        
        /**
         * [함수명] handleDragOver
         * [목적] 드래그 오버 이벤트 처리 (시각 피드백)
         */
        function handleDragOver(event) {
            event.preventDefault();
            event.stopPropagation();
            document.getElementById('uploadBox').classList.add('dragover');
        }
        
        /**
         * [함수명] handleDragLeave
         * [목적] 드래그 떠난 이벤트 처리
         */
        function handleDragLeave(event) {
            event.preventDefault();
            event.stopPropagation();
            document.getElementById('uploadBox').classList.remove('dragover');
        }
        
        /**
         * [함수명] handleDrop
         * [목적] 드래그-드롭 이벤트 처리
         */
        function handleDrop(event) {
            event.preventDefault();
            event.stopPropagation();
            document.getElementById('uploadBox').classList.remove('dragover');
            
            const files = event.dataTransfer.files;
            if (files.length > 0) {
                document.getElementById('pdfInput').files = files;
                handleFileSelect({ target: { files: files } });
            }
        }
        
        /**
         * [함수명] validateForm
         * [목적] 폼 제출 전 유효성 검증
         */
        function validateForm() {
            const pdfInput = document.getElementById('pdfInput');
            const errorMsg = document.querySelector('.error-message');
            
            if (!pdfInput.files || !pdfInput.files[0]) {
                errorMsg.textContent = '❌ 오류: PDF 파일을 선택해주세요.';
                errorMsg.classList.add('active');
                return false;
            }
            
            // 로딩 상태 표시
            document.getElementById('loading').classList.add('active');
            document.getElementById('submitBtn').disabled = true;
            
            return true;
        }
    </script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
