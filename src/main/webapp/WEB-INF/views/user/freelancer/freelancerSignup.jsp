<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RatelOcean | 프리랜서 프로필</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        :root { --brand-main: #2C1A52; --brand-accent: #00F0FF; --brand-purple: #8A2BE2; --bg-light: #F8F9FD; --text-dark: #2D2D2D; --border-color: #E2E8F0; }
        body {
            margin: 0;
            padding: 20px;
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container { width: 100%; max-width: 580px; background: #FFFFFF; border-radius: 20px; padding: 50px 45px; box-shadow: 0 10px 30px rgba(44, 26, 82, 0.08); border: 1px solid var(--border-color); }
        .header { text-align: center; margin-bottom: 35px; }
        .header h1 { font-size: 1.6rem; font-weight: 700; color: var(--brand-main); margin: 0; }
        .form-body { display: flex; flex-direction: column; gap: 24px; }
        .input-group { display: flex; flex-direction: column; }
        .label-text { font-size: 0.95rem; font-weight: 600; color: var(--text-dark); margin-bottom: 8px; display: flex; align-items: center; gap: 8px; }
        .label-text i { color: var(--brand-purple); }
        input[type="text"], input[type="url"], textarea, select { padding: 14px 16px; border: 1.5px solid var(--border-color); border-radius: 10px; font-size: 0.95rem; color: var(--text-dark); transition: all 0.2s ease; background: #FFFFFF; }
        input:focus, textarea:focus, select:focus { outline: none; border-color: var(--brand-purple); box-shadow: 0 0 0 3px rgba(138, 43, 226, 0.1); }
        textarea { resize: vertical; min-height: 100px; font-family: inherit; }
        .grid-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .btn-group { display: flex; gap: 12px; margin-top: 10px; }
        .btn { flex: 1; padding: 18px; border-radius: 12px; font-size: 1.05rem; font-weight: 700; cursor: pointer; transition: all 0.3s ease; display: flex; justify-content: center; align-items: center; gap: 8px; border: none; }
        .btn-secondary { background: #6c757d; color: #FFFFFF; }
        .btn-secondary:hover { background: #5a6268; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(108, 117, 125, 0.3); }
        .btn-primary { background: linear-gradient(135deg, var(--brand-main) 0%, var(--brand-purple) 100%); color: #FFFFFF; border: none; padding: 18px; border-radius: 12px; font-size: 1.05rem; font-weight: 700; cursor: pointer; transition: all 0.3s ease; display: flex; justify-content: center; align-items: center; gap: 8px; }
        .btn-primary:hover { background: var(--brand-purple); transform: translateY(-2px); box-shadow: 0 5px 15px rgba(44, 26, 82, 0.2); }
        .btn-primary:disabled { background: #ccc; cursor: not-allowed; transform: none; }
        select { appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='%232C1A52' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 12px center; background-size: 16px; }
    </style>
</head>
<body>

<div class="container">
    <header class="header">
        <h1>전문가 프로필 등록</h1>
    </header>

    <form id="freelancerForm" class="form-body">
        <div class="input-group">
            <label class="label-text"><i class="fas fa-id-badge"></i> 활동 닉네임</label>
            <input type="text" name="nickname" placeholder="플랫폼에서 사용하실 닉네임을 입력하세요" required>
        </div>

        <div class="input-group">
            <label class="label-text"><i class="fas fa-user-edit"></i> 전문 분야 및 소개</label>
            <textarea name="introduction" placeholder="본인의 전문 스택 및 프로젝트 강점을 200자 내외로 요약해 주세요." required></textarea>
        </div>

        <div class="input-group">
            <label class="label-text"><i class="fas fa-graduation-cap"></i> 최종 학력</label>
            <div class="grid-row" style="margin-bottom: 10px;">
                <input type="text" name="schoolName" placeholder="학교명 (예: OO대학교)">
                <input type="text" name="major" placeholder="전공명 (예: 컴퓨터공학)">
            </div>
            <div class="grid-row">
                <select name="degree">
                    <option value="" disabled selected>학위 선택</option>
                    <option value="ASSOCIATE">전문학사</option>
                    <option value="BACHELOR">학사</option>
                    <option value="MASTER">석사</option>
                    <option value="DOCTOR">박사</option>
                </select>
                <select name="gradStatus">
                    <option value="" disabled selected>졸업 상태</option>
                    <option value="GRADUATED">졸업</option>
                    <option value="ATTENDING">재학</option>
                    <option value="DROPOUT">중퇴</option>
                    <option value="LEAVE_OF_ABSENCE">휴학</option>
                </select>
            </div>
        </div>

        <div class="input-group">
            <label class="label-text"><i class="fas fa-link"></i> 소셜 및 포트폴리오</label>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <input type="url" name="githubUrl" placeholder="GitHub 주소 (https://...)">
                <input type="url" name="websiteUrl" placeholder="포트폴리오 주소 (https://...)">
            </div>
        </div>

        <!-- 이전/다음 버튼 -->
        <div class="btn-group">
            <button type="button" id="prevBtn" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> 이전
            </button>
            <button type="button" id="submitBtn" class="btn btn-primary">
                프로필 저장 후 다음 단계 <i class="fas fa-arrow-right"></i>
            </button>
        </div>
    </form>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';

    $(document).ready(function() {
        $('#freelancerForm').on('submit', function(e) {
            e.preventDefault();
        });

        $('#submitBtn').click(function() {
            const nickname = $('input[name="nickname"]').val();
            const introduction = $('textarea[name="introduction"]').val();

            if (!nickname || !introduction) {
                alert('닉네임과 전문 분야 소개는 필수 항목입니다.');
                return;
            }

            $(this).prop('disabled', true).text('처리 중...');

            $.ajax({
                url: contextPath + '/join/freelancer/signup',
                method: 'POST',
                data: $('#freelancerForm').serialize(),
                success: function(response) {
                    if (response.success && response.redirect) {
                        window.location.href = contextPath + response.redirect;
                    } else {
                        alert(response.message || '오류가 발생했습니다.');
                        $('#submitBtn').prop('disabled', false).html('프로필 저장 후 다음 단계 <i class="fas fa-arrow-right"></i>');
                    }
                },
                error: function() {
                    alert('서버 연결에 실패했습니다.');
                    $('#submitBtn').prop('disabled', false).html('프로필 저장 후 다음 단계 <i class="fas fa-arrow-right"></i>');
                }
            });
        });
    });

    $(document).ready(function() {
        // 이전 버튼
        $('#prevBtn').click(function() {
            window.history.back();
        });

        // 기존 submitBtn 코드...
        $('#submitBtn').click(function() {
            // ... 기존 코드 유지
            $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 처리 중...');
            // ...
        });
    });
</script>

</body>
</html>
