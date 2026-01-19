<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>파일 업로드 테스트</title>
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
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            max-width: 600px;
            width: 100%;
        }

        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }

        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .upload-area {
            border: 3px dashed #667eea;
            border-radius: 15px;
            padding: 40px;
            text-align: center;
            background: #f8f9ff;
            margin-bottom: 20px;
            transition: all 0.3s;
            cursor: pointer;
        }

        .upload-area:hover {
            border-color: #764ba2;
            background: #f0f2ff;
        }

        .upload-area.dragover {
            border-color: #764ba2;
            background: #e8ebff;
            transform: scale(1.02);
        }

        .upload-icon {
            font-size: 60px;
            margin-bottom: 15px;
        }

        .upload-text {
            color: #667eea;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .upload-hint {
            color: #999;
            font-size: 14px;
        }

        input[type="file"] {
            display: none;
        }

        .file-info {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
            display: none;
        }

        .file-info.show {
            display: block;
        }

        .file-name {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .file-size {
            color: #666;
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            color: #333;
            font-weight: 600;
            margin-bottom: 8px;
        }

        textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            font-family: inherit;
            resize: vertical;
            min-height: 80px;
        }

        textarea:focus {
            outline: none;
            border-color: #667eea;
        }

        .btn {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: 10px;
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
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn-secondary:hover {
            background: #f8f9ff;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .result-info {
            background: #e8f5e9;
            border-radius: 10px;
            padding: 15px;
            margin-top: 20px;
        }

        .result-info strong {
            display: block;
            color: #2e7d32;
            margin-bottom: 5px;
        }

        .result-info p {
            color: #388e3c;
            font-size: 14px;
            margin: 5px 0;
            word-break: break-all;
        }

        .links {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .links a {
            flex: 1;
            text-align: center;
            padding: 12px;
            background: #f8f9fa;
            color: #667eea;
            text-decoration: none;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .links a:hover {
            background: #667eea;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📤 파일 업로드 테스트</h1>
        <p class="subtitle">다른 PC에서도 이 페이지에 접속해서 파일을 업로드해보세요!</p>

        <c:if test="${not empty success}">
            <div class="alert alert-success">
                ✅ ${success}
            </div>
            <div class="result-info">
                <strong>📁 업로드 정보:</strong>
                <p><strong>파일명:</strong> ${filename}</p>
                <p><strong>파일 크기:</strong> ${filesize}</p>
                <p><strong>저장 경로:</strong> ${filepath}</p>
                <c:if test="${not empty description}">
                    <p><strong>설명:</strong> ${description}</p>
                </c:if>
            </div>
        </c:if>

        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ❌ ${error}
            </div>
        </c:if>

        <form method="post" enctype="multipart/form-data" id="uploadForm">
            <div class="upload-area" id="uploadArea">
                <div class="upload-icon">📁</div>
                <div class="upload-text">클릭하거나 파일을 드래그하세요</div>
                <div class="upload-hint">모든 파일 형식 지원 (PDF, PNG, JPG, ZIP 등)</div>
                <input type="file" name="file" id="fileInput" required>
            </div>

            <div class="file-info" id="fileInfo">
                <div class="file-name" id="fileName"></div>
                <div class="file-size" id="fileSize"></div>
            </div>

            <div class="form-group">
                <label for="description">📝 파일 설명 (선택사항)</label>
                <textarea name="description" id="description" placeholder="이 파일에 대한 간단한 설명을 입력하세요..."></textarea>
            </div>

            <button type="submit" class="btn btn-primary" id="submitBtn" disabled>
                업로드하기
            </button>
        </form>

        <div class="links">
            <a href="${pageContext.request.contextPath}/test/files">📂 업로드된 파일 보기</a>
            <a href="${pageContext.request.contextPath}/">🏠 홈으로</a>
        </div>
    </div>

    <script>
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const fileInfo = document.getElementById('fileInfo');
        const fileName = document.getElementById('fileName');
        const fileSize = document.getElementById('fileSize');
        const submitBtn = document.getElementById('submitBtn');

        // 업로드 영역 클릭 시 파일 선택
        uploadArea.addEventListener('click', () => {
            fileInput.click();
        });

        // 파일 선택 시
        fileInput.addEventListener('change', (e) => {
            handleFile(e.target.files[0]);
        });

        // 드래그 앤 드롭
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                fileInput.files = files;
                handleFile(files[0]);
            }
        });

        function handleFile(file) {
            if (!file) return;

            fileName.textContent = '📄 ' + file.name;
            fileSize.textContent = '크기: ' + formatFileSize(file.size);
            fileInfo.classList.add('show');
            submitBtn.disabled = false;
        }

        function formatFileSize(bytes) {
            if (bytes < 1024) return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(2) + ' KB';
            if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
            return (bytes / (1024 * 1024 * 1024)).toFixed(2) + ' GB';
        }

        // 폼 제출 시 로딩 표시
        document.getElementById('uploadForm').addEventListener('submit', (e) => {
            submitBtn.innerHTML = '⏳ 업로드 중...';
            submitBtn.disabled = true;
        });
    </script>
</body>
</html>
