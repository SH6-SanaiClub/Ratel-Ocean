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
        :root{
            --primary:#173160;
            --text:#0f172a;
            --bg:#f6f6f8;

            --line: rgba(59,111,220,.22);
            --tint: rgba(59,111,220,.10);

            --neutral-bg:#e5e7eb;
            --neutral-text:#111827;
            --neutral-line:#cbd5e1;

            --danger:#e11d48;
            --ok:#16a34a;
        }

        body{
            margin:0;
            padding:120px 20px 20px;
            font-family:'Noto Sans KR', sans-serif;
            background:
                    radial-gradient(1200px 600px at 20% 10%, rgba(59,111,220,.08), transparent 55%),
                    radial-gradient(900px 500px at 80% 0%, rgba(23,49,96,.10), transparent 60%),
                    var(--primary);
            min-height:100vh;
            display:flex;
            justify-content:center;
            align-items:center;
            color:var(--text);
            letter-spacing:-0.02em;
        }

        .container{
            width:100%;
            max-width:580px;
            background:#ffffff;
            border-radius:24px;
            padding:48px 42px;
            border:1px solid rgba(15,23,42,.08);
            box-shadow:0 20px 40px rgba(15,23,42,.06);
        }

        .header{
            text-align:center;
            margin-bottom:28px;
        }

        .header h1{
            font-size:1.6rem;
            font-weight:900;
            color:var(--text);
            margin:0;
        }

        .sub{
            margin-top:10px;
            color:rgba(15,23,42,.60);
            font-size:.95rem;
            line-height:1.45;
        }

        .form-body{
            display:flex;
            flex-direction:column;
            gap:22px;
        }

        .input-group{
            display:flex;
            flex-direction:column;
        }

        .label-text{
            font-size:.92rem;
            font-weight:900;
            color:rgba(15,23,42,.78);
            margin-bottom:8px;
            display:flex;
            align-items:center;
            gap:8px;
        }

        .label-text i{
            color: rgba(59,111,220,1);
        }

        input[type="text"],
        input[type="url"],
        textarea,
        select{
            padding:14px 16px;
            border:1.5px solid var(--neutral-line);
            border-radius:12px;
            font-size:.95rem;
            color:var(--text);
            transition:border-color .2s ease, box-shadow .2s ease, background-color .2s ease;
            background: rgba(255,255,255,.72);
            font-family:inherit;
        }

        input::placeholder,
        textarea::placeholder{
            color: rgba(15,23,42,.45);
        }

        input:focus,
        textarea:focus,
        select:focus{
            outline:none;
            border-color: var(--line);
            box-shadow: 0 0 0 3px var(--tint);
            background:#fff;
        }

        textarea{
            resize: vertical;
            min-height:110px;
        }

        .grid-row{
            display:grid;
            grid-template-columns: 1fr 1fr;
            gap:12px;
        }

        select{
            appearance:none;
            background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='%23173160' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat:no-repeat;
            background-position:right 12px center;
            background-size:16px;
            cursor:pointer;
        }

        .btn-group{
            display:flex;
            gap:12px;
            margin-top:6px;
        }

        .btn{
            flex:1;
            padding:16px 18px;
            border-radius:16px;
            font-size:1.02rem;
            font-weight:900;
            cursor:pointer;
            transition: transform .15s ease, filter .15s ease, background-color .15s ease, border-color .15s ease;
            display:flex;
            justify-content:center;
            align-items:center;
            gap:10px;
            border:none;
        }

        .btn-secondary{
            background:#fff;
            color:var(--text);
            border:2px solid var(--neutral-line);
        }

        .btn-secondary:hover{
            background: rgba(15,23,42,.03);
            border-color: rgba(15,23,42,.18);
        }

        .btn-secondary:active{
            transform: scale(.99);
        }

        .btn-primary{
            background: var(--primary);
            color:#fff;
            box-shadow:0 16px 30px rgba(15,23,42,.10);
        }

        .btn-primary:hover{
            transform: translateY(-1px);
            filter: brightness(1.02);
        }

        .btn-primary:active{
            transform: scale(.99);
        }

        .btn-primary:disabled{
            background: var(--neutral-bg);
            color: var(--neutral-text);
            cursor:not-allowed;
            border:1px solid var(--neutral-line);
            box-shadow:none;
            filter:none;
            transform:none;
        }

        @media (max-width: 768px){
            body{ padding:120px 16px 20px; }
            .container{ padding:34px 22px; border-radius:22px; }
            .grid-row{ grid-template-columns: 1fr; }
            .btn-group{ flex-direction:column; }
        }
    </style>
</head>
<body>

<div class="container">
    <header class="header">
        <h1>전문가 프로필 등록</h1>
        <div class="sub">프로젝트 매칭에 활용될 정보입니다. 핵심 강점 위주로 작성해 주세요.</div>
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
            <div style="display:flex; flex-direction:column; gap:10px;">
                <input type="url" name="githubUrl" placeholder="GitHub 주소 (https://...)">
                <input type="url" name="websiteUrl" placeholder="포트폴리오 주소 (https://...)">
            </div>
        </div>

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

        $('#prevBtn').click(function() {
            window.history.back();
        });

        $('#submitBtn').click(function() {
            const nickname = $('input[name="nickname"]').val();
            const introduction = $('textarea[name="introduction"]').val();

            if (!nickname || !introduction) {
                alert('닉네임과 전문 분야 소개는 필수 항목입니다.');
                return;
            }

            $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> 처리 중...');

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
</script>

</body>
</html>
