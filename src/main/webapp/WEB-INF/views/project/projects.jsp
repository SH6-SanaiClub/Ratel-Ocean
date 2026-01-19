<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로젝트 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            padding-top: 20px;
        }
        .project-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            background-color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .project-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        .project-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            margin-right: 10px;
        }
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        .status-completed {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        .status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
        }
        .project-info {
            font-size: 14px;
            color: #666;
            margin-top: 10px;
        }
        .project-budget {
            font-size: 16px;
            font-weight: bold;
            color: #007bff;
            margin-top: 10px;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <h1>프로젝트 관리</h1>
                <p>진행 중인 프로젝트 목록입니다.</p>
                
                <div id="projectsList">
                    <!-- 프로젝트 목록이 여기에 표시됩니다 -->
                    <div class="alert alert-info">
                        프로젝트 데이터가 없습니다. 관리자에게 문의하세요.
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 향후 프로젝트 데이터를 API에서 로드할 예정
        document.addEventListener('DOMContentLoaded', function() {
            // TODO: API에서 프로젝트 목록 로드
            console.log('프로젝트 관리 페이지 로드됨');
        });
    </script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
