<%--
  Created by IntelliJ IDEA.
  User: kimyoungbeen
  Date: 2026. 1. 20.
  Time: 12:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>클라이언트 회원가입 - Ratel Ocean</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/select-role.css">
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <style>
    /* 단계 표시 */
    .step-indicator {
      display: flex;
      justify-content: center;
      align-items: center;
      margin: 2rem 0;
      gap: 1rem;
    }

    .step-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
    }

    .step-number {
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: #e0e0e0;
      color: #666;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      font-size: 14px;
    }

    .step-item.active .step-number {
      background: #1F7A8C;
      color: white;
    }

    .step-item.completed .step-number {
      background: #4caf50;
      color: white;
    }

    .step-arrow {
      color: #ccc;
      font-size: 20px;
    }

    /* 단계별 컨텐츠 */
    .step-content {
      display: none;
      animation: fadeIn 0.3s;
    }

    .step-content.active {
      display: block;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* 폼 스타일 */
    .form-group {
      margin-bottom: 1.5rem;
    }

    .form-label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 600;
      color: #2B2B2B;
    }

    .form-input {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
    }

    .form-input:focus {
      outline: none;
      border-color: #1F7A8C;
    }

    .input-row {
      display: flex;
      gap: 0.5rem;
    }

    .input-row .form-input {
      flex: 1;
    }

    .btn {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 4px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
    }

    .btn-primary {
      background: #1F7A8C;
      color: white;
    }

    .btn-primary:hover {
      background: #165d6b;
    }

    .btn-primary:disabled {
      background: #ccc;
      cursor: not-allowed;
    }

    .btn-secondary {
      background: #6F7272;
      color: white;
    }

    .btn-secondary:hover {
      background: #5a5c5c;
    }

    .btn-group {
      display: flex;
      gap: 1rem;
      justify-content: center;
      margin-top: 2rem;
    }

    .card {
      background: white;
      border-radius: 8px;
      padding: 2rem;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      max-width: 600px;
      margin: 0 auto;
    }

    .card h2 {
      color: #2B2B2B;
      margin-bottom: 1rem;
    }

    .subtitle {
      color: #6F7272;
      margin-bottom: 2rem;
    }

    /* 클라이언트 타입 선택 카드 */
    .client-type-cards {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .type-card {
      border: 2px solid #ddd;
      border-radius: 8px;
      padding: 1.5rem;
      cursor: pointer;
      transition: all 0.3s;
      text-align: center;
    }

    .type-card:hover {
      border-color: #1F7A8C;
      background: #f8f9fa;
    }

    .type-card.selected {
      border-color: #1F7A8C;
      background: #e8f4f5;
    }

    .type-card h3 {
      font-size: 1.25rem;
      margin-bottom: 0.5rem;
      color: #2B2B2B;
    }

    .type-card p {
      color: #6F7272;
      font-size: 0.9rem;
    }

    /* 메시지 */
    .message {
      padding: 1rem;
      border-radius: 4px;
      margin-bottom: 1rem;
    }

    .message.success {
      background: #d4edda;
      color: #155724;
      border: 1px solid #c3e6cb;
    }

    .message.error {
      background: #f8d7da;
      color: #721c24;
      border: 1px solid #f5c6cb;
    }

    .message.info {
      background: #d1ecf1;
      color: #0c5460;
      border: 1px solid #bee5eb;
    }

    small {
      display: block;
      margin-top: 0.25rem;
      font-size: 12px;
    }

    small.success {
      color: #4caf50;
    }

    small.error {
      color: #f44336;
    }

    .hidden {
      display: none;
    }

    /* 진위확인 결과 */
    .verification-result {
      padding: 1rem;
      border-radius: 4px;
      margin-top: 1rem;
    }

    .verification-result.success {
      background: #d4edda;
      border: 1px solid #c3e6cb;
      color: #155724;
    }

    .verification-result.error {
      background: #f8d7da;
      border: 1px solid #f5c6cb;
      color: #721c24;
    }

    /* ⭐ 추가: 필드 잠금 스타일 */
    .locked-field {
      background-color: #f0f0f0 !important;
      border: 2px solid #1F7A8C !important;
      color: #666 !important;
      cursor: not-allowed !important;
      font-weight: 500;
    }

    .lock-notice {
      margin-top: 12px;
      padding: 12px 16px;
      background: #e8f4f8;
      border-left: 4px solid #1F7A8C;
      border-radius: 4px;
      font-size: 14px;
      color: #0d5a6b;
      line-height: 1.5;
    }

    #checkBusinessBtn:disabled {
      background-color: #28a745;
      border-color: #28a745;
      color: white;
      cursor: not-allowed;
      opacity: 0.8;
    }
  </style>
</head>
<body>
<header class="site-header">
  <div class="container header-inner">
    <a class="logo" href="${pageContext.request.contextPath}/">
      <img src="${pageContext.request.contextPath}/resources/images/ratelogo.png" alt="Ratel Ocean 로고">
    </a>
  </div>
</header>

<main class="select-role">
  <div class="container">
    <h1 class="title">클라이언트 회원가입</h1>
    <p class="subtitle">환영합니다, <strong>${commonData.name}</strong>님! 추가 정보를 입력해주세요.</p>

    <!-- 단계 표시 -->
    <div class="step-indicator">
      <div class="step-item completed">
        <div class="step-number">✓</div>
        <span>기본정보</span>
      </div>
      <div class="step-arrow">→</div>
      <div class="step-item active" data-step="3">
        <div class="step-number">1</div>
        <span>클라이언트 유형</span>
      </div>
      <div class="step-arrow">→</div>
      <div class="step-item" data-step="4">
        <div class="step-number">2</div>
        <span>회사정보</span>
      </div>
      <div class="step-arrow">→</div>
      <div class="step-item" data-step="5">
        <div class="step-number">3</div>
        <span>완료</span>
      </div>
    </div>

    <!-- 메시지 영역 -->
    <div id="message-area"></div>

    <!-- Step 3: 클라이언트 타입 선택 -->
    <div id="step3" class="step-content active">
      <div class="card">
        <h2>클라이언트 유형 선택</h2>
        <p class="subtitle">어떤 유형의 클라이언트이신가요?</p>

        <div class="client-type-cards">
          <div class="type-card" data-type="PERSONAL">
            <h3>🧑 개인 클라이언트</h3>
            <p>사업자 번호가 없는 개인</p>
            <p style="font-size: 0.8rem; color: #999; margin-top: 0.5rem;">
              프리랜서 고용, 소규모 프로젝트 발주
            </p>
          </div>
          <div class="type-card" data-type="CORPORATION">
            <h3>🏢 법인 클라이언트</h3>
            <p>사업자 번호가 있는 개인사업자/법인</p>
            <p style="font-size: 0.8rem; color: #999; margin-top: 0.5rem;">
              대규모 프로젝트, 장기 계약
            </p>
          </div>
        </div>

        <div class="btn-group">
          <button type="button" class="btn btn-secondary" id="backToSignup">이전</button>
          <button type="button" class="btn btn-primary" id="nextToStep4" disabled>다음</button>
        </div>
      </div>
    </div>

    <!-- Step 4: 회사 정보 입력 (법인만) -->
    <div id="step4" class="step-content">
      <div class="card">
        <h2>회사 정보 입력</h2>
        <p class="subtitle">사업자 정보를 입력해주세요. 국세청 진위확인을 진행합니다.</p>

        <form id="companyInfoForm">
          <div class="form-group">
            <label class="form-label" for="companyName">회사명 *</label>
            <input type="text" id="companyName" name="companyName" class="form-input" placeholder="(주)라텔오션" required>
          </div>

          <div class="form-group">
            <label class="form-label" for="ceoName">대표자명 *</label>
            <input type="text" id="ceoName" name="ceoName" class="form-input" placeholder="홍길동" required>
            <small style="color: #666;">사업자등록증에 기재된 대표자명을 정확히 입력해주세요.</small>
          </div>

          <div class="form-group">
            <label class="form-label" for="businessNumber">사업자등록번호 *</label>
            <div class="input-row">
              <input type="text" id="businessNumber" name="businessNumber" class="form-input" placeholder="123-45-67890" required>
              <button type="button" id="checkBusinessBtn" class="btn btn-secondary">중복확인</button>
            </div>
            <small id="businessMsg"></small>
          </div>

          <div class="form-group">
            <label class="form-label" for="openingDate">개업일자 *</label>
            <input type="date" id="openingDate" name="openingDate" class="form-input" required>
            <small style="color: #666;">사업자등록증에 기재된 개업일자를 입력해주세요.</small>
          </div>

          <div class="form-group">
            <button type="button" id="verifyBusinessBtn" class="btn btn-primary" style="width: 100%;">
              🔍 사업자 진위확인
            </button>
            <div id="verificationResult" class="hidden"></div>
          </div>

          <hr style="margin: 2rem 0; border: none; border-top: 1px solid #ddd;">

          <h3 style="margin-bottom: 1rem; color: #2B2B2B;">추가 정보 (선택)</h3>

          <div class="form-group">
            <label class="form-label" for="industry">업종</label>
            <input type="text" id="industry" name="industry" class="form-input" placeholder="IT 소프트웨어 개발">
          </div>

          <div class="form-group">
            <label class="form-label" for="address">주소</label>
            <input type="text" id="address" name="address" class="form-input" placeholder="서울시 강남구...">
          </div>

          <div class="form-group">
            <label class="form-label" for="companySize">회사 규모</label>
            <select id="companySize" name="companySize" class="form-input">
              <option value="">선택하세요</option>
              <option value="STARTUP">스타트업 (10인 미만)</option>
              <option value="SMALL">소기업 (10-49인)</option>
              <option value="MEDIUM">중기업 (50-299인)</option>
              <option value="LARGE">대기업 (300인 이상)</option>
            </select>
          </div>

          <div class="form-group">
            <label class="form-label" for="websiteUrl">웹사이트</label>
            <input type="url" id="websiteUrl" name="websiteUrl" class="form-input" placeholder="https://example.com">
          </div>

          <div class="btn-group">
            <button type="button" class="btn btn-secondary" id="backToStep3">이전</button>
            <button type="button" class="btn btn-primary" id="completeCorporation" disabled>회원가입 완료</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Step 5: 완료 메시지 (개인 클라이언트용) -->
    <div id="step5" class="step-content">
      <div class="card" style="text-align: center;">
        <h2 style="color: #1F7A8C; font-size: 2rem; margin-bottom: 1rem;">🎉</h2>
        <h2>회원가입이 완료되었습니다!</h2>
        <p class="subtitle" style="margin-top: 1rem;">
          환영합니다! 이제 로그인하여 서비스를 이용하실 수 있습니다.
        </p>
        <div class="btn-group" style="margin-top: 2rem;">
          <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">로그인하러 가기</a>
        </div>
      </div>
    </div>
  </div>
</main>

<footer class="site-footer" style="margin-top: 3rem; padding: 2rem 0; background: #f8f9fa; text-align: center; color: #666;">
  © 2026 Ratel Ocean. All rights reserved.
</footer>

<script>
  const contextPath = '${pageContext.request.contextPath}';
  let currentStep = 3;  // Step 3부터 시작
  let selectedClientType = null;
  let isBusinessNumberChecked = false;
  let isBusinessVerified = false;

  $(document).ready(function() {
    // ═══════════════════════════════════════════════════════════════
    // Step 3: 클라이언트 타입 선택
    // ═══════════════════════════════════════════════════════════════

    // 클라이언트 타입 카드 선택
    $('.type-card').click(function() {
      $('.type-card').removeClass('selected');
      $(this).addClass('selected');
      selectedClientType = $(this).data('type');
      $('#nextToStep4').prop('disabled', false);
      console.log('클라이언트 타입 선택:', selectedClientType);
    });

    // 이전 버튼 (Step 3 → /join/signup)
    $('#backToSignup').click(function() {
      if (confirm('이전 단계로 돌아가시겠습니까? 입력하신 정보는 유지됩니다.')) {
        window.location.href = contextPath + '/join/signup';
      }
    });

    // 다음 버튼 (Step 3 → Step 4 or Step 5)
    $('#nextToStep4').click(function() {
      // 클라이언트 타입 저장
      $.ajax({
        url: contextPath + '/join/client/save-client-type',
        method: 'POST',
        data: { clientType: selectedClientType },
        success: function(response) {
          if (response.success) {
            console.log('클라이언트 타입 저장 성공:', selectedClientType);

            // 개인이면 바로 회원가입 완료
            if (selectedClientType === 'PERSONAL') {
              completePersonal();
            }
            // 법인이면 Step 4로
            else if (selectedClientType === 'CORPORATION') {
              goToStep(4);
            }
          } else {
            alert(response.message || '오류가 발생했습니다.');
          }
        },
        error: function(xhr) {
          console.error('클라이언트 타입 저장 실패:', xhr);
          alert('오류가 발생했습니다. 다시 시도해주세요.');
        }
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // Step 4: 회사 정보 입력
    // ═══════════════════════════════════════════════════════════════

    // 사업자번호 중복 확인
    $('#checkBusinessBtn').click(function() {
      const businessNumber = $('#businessNumber').val().trim();
      if (!businessNumber) {
        alert('사업자번호를 입력해주세요.');
        return;
      }

      $.ajax({
        url: contextPath + '/join/client/check-business-number',
        method: 'GET',
        data: { businessNumber: businessNumber },
        success: function(response) {
          const msg = $('#businessMsg');
          if (response.isDuplicate) {
            msg.text('이미 등록된 사업자번호입니다.').removeClass('success').addClass('error');
            isBusinessNumberChecked = false;
          } else {
            msg.text('사용 가능한 사업자번호입니다.').removeClass('error').addClass('success');
            isBusinessNumberChecked = true;
            checkCompletionReady();
          }
        },
        error: function(xhr) {
          console.error('사업자번호 중복 확인 실패:', xhr);
          alert('중복 확인 중 오류가 발생했습니다.');
        }
      });
    });

    // ⭐ 사업자 진위확인 (필드 잠금 기능 추가)
    $('#verifyBusinessBtn').click(function() {
      // ⭐ 재인증 확인
      if (isBusinessVerified && $(this).hasClass('btn-secondary')) {
        if (confirm('진위확인을 다시 진행하시겠습니까?\n정보를 수정한 후 다시 인증해야 합니다.')) {
          unlockVerifiedFields();
          $('#verificationResult').addClass('hidden').html('');
          alert('필드가 잠금 해제되었습니다. 정보를 수정한 후 다시 진위확인을 진행해주세요.');
        }
        return;
      }

      const businessNumber = $('#businessNumber').val().trim();
      const ceoName = $('#ceoName').val().trim();
      const openingDate = $('#openingDate').val();

      if (!businessNumber || !ceoName || !openingDate) {
        alert('사업자번호, 대표자명, 개업일자를 모두 입력해주세요.');
        return;
      }

      if (!isBusinessNumberChecked) {
        alert('사업자번호 중복 확인을 먼저 진행해주세요.');
        return;
      }

      $(this).prop('disabled', true).text('인증 중...');

      $.ajax({
        url: contextPath + '/join/client/verify-business',
        method: 'POST',
        data: {
          businessNumber: businessNumber,
          ceoName: ceoName,
          openingDate: openingDate
        },
        success: function(response) {
          const resultDiv = $('#verificationResult');
          resultDiv.removeClass('hidden');

          if (response.verified) {
            resultDiv.html('✅ ' + response.message)
                    .removeClass('error').addClass('success');
            isBusinessVerified = true;
            // ⭐ 필드 잠금
            lockVerifiedFields();
            checkCompletionReady();
          } else {
            resultDiv.html('❌ ' + response.message)
                    .removeClass('success').addClass('error');
            isBusinessVerified = false;
            // ⭐ 잠금 해제
            unlockVerifiedFields();
          }
        },
        error: function(xhr) {
          console.error('사업자 진위확인 실패:', xhr);
          $('#verificationResult')
                  .removeClass('hidden success').addClass('error')
                  .text('❌ 인증 중 오류가 발생했습니다.');
          isBusinessVerified = false;
          unlockVerifiedFields();
        },
        complete: function() {
          $('#verifyBusinessBtn').prop('disabled', false).text('🔍 사업자 진위확인');
        }
      });
    });

    // 이전 버튼 (Step 4 → Step 3)
    $('#backToStep3').click(function() {
      goToStep(3);
    });

    // 회원가입 완료 (법인)
    $('#completeCorporation').click(function() {
      if (!isBusinessNumberChecked) {
        alert('사업자번호 중복 확인을 먼저 진행해주세요.');
        return;
      }

      if (!isBusinessVerified) {
        alert('사업자 진위확인을 먼저 진행해주세요.');
        return;
      }

      const formData = $('#companyInfoForm').serialize();

      $.ajax({
        url: contextPath + '/join/client/complete-corporation',
        method: 'POST',
        data: formData,
        success: function(response) {
          if (response.success) {
            alert('회원가입이 완료되었습니다!');
            window.location.href = contextPath + response.redirectUrl;
          } else {
            alert(response.message || '회원가입 중 오류가 발생했습니다.');
          }
        },
        error: function(xhr) {
          console.error('법인 회원가입 실패:', xhr);
          alert('회원가입 중 오류가 발생했습니다.');
        }
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // ⭐ 추가: 필드 잠금/해제 함수
    // ═══════════════════════════════════════════════════════════════

    function lockVerifiedFields() {
      // 1. 필수 필드 readonly
      $('#businessNumber').prop('readonly', true).addClass('locked-field');
      $('#ceoName').prop('readonly', true).addClass('locked-field');
      $('#openingDate').prop('readonly', true).addClass('locked-field');

      // 2. 중복확인 버튼 비활성화
      $('#checkBusinessBtn').prop('disabled', true).text('확인완료');

      // 3. 진위확인 버튼 → 재인증 버튼으로 변경
      $('#verifyBusinessBtn')
              .removeClass('btn-primary')
              .addClass('btn-secondary')
              .html('🔄 다시 인증하기');

      // 4. 안내 메시지 추가
      if ($('#lockNotice').length === 0) {
        $('#verificationResult').after(
                '<div id="lockNotice" class="lock-notice">' +
                '🔒 진위확인이 완료된 정보는 수정할 수 없습니다. ' +
                '정보를 변경하려면 다시 "사업자 진위확인"을 클릭하세요.' +
                '</div>'
        );
      }

      console.log('✅ 진위확인 완료: 필드 잠금');
    }

    function unlockVerifiedFields() {
      // 1. readonly 해제
      $('#businessNumber').prop('readonly', false).removeClass('locked-field');
      $('#ceoName').prop('readonly', false).removeClass('locked-field');
      $('#openingDate').prop('readonly', false).removeClass('locked-field');

      // 2. 중복확인 버튼 활성화
      $('#checkBusinessBtn').prop('disabled', false).text('중복확인');

      // 3. 진위확인 버튼 복구
      $('#verifyBusinessBtn')
              .removeClass('btn-secondary')
              .addClass('btn-primary')
              .html('🔍 사업자 진위확인');

      // 4. 안내 메시지 제거
      $('#lockNotice').remove();

      // 5. 상태 초기화
      isBusinessNumberChecked = false;
      isBusinessVerified = false;
      $('#businessMsg').text('');
      $('#completeCorporation').prop('disabled', true);

      console.log('🔓 필드 잠금 해제');
    }

    // ═══════════════════════════════════════════════════════════════
    // 공통 함수
    // ═══════════════════════════════════════════════════════════════

    // 단계 이동
    function goToStep(step) {
      $('.step-content').removeClass('active');
      $('#step' + step).addClass('active');

      $('.step-item').removeClass('active completed');
      $('.step-item').each(function() {
        const stepNum = parseInt($(this).data('step'));
        if (stepNum < step) {
          $(this).addClass('completed');
        } else if (stepNum === step) {
          $(this).addClass('active');
        }
      });

      currentStep = step;
      console.log('현재 단계:', currentStep);
    }

    // 개인 클라이언트 회원가입 완료
    function completePersonal() {
      $.ajax({
        url: contextPath + '/join/client/complete-personal',
        method: 'POST',
        success: function(response) {
          if (response.success) {
            alert('회원가입이 완료되었습니다!');
            window.location.href = contextPath + response.redirectUrl;
          } else {
            alert(response.message || '회원가입 중 오류가 발생했습니다.');
          }
        },
        error: function(xhr) {
          console.error('개인 회원가입 실패:', xhr);
          alert('회원가입 중 오류가 발생했습니다.');
        }
      });
    }

    // 완료 버튼 활성화 체크
    function checkCompletionReady() {
      if (isBusinessNumberChecked && isBusinessVerified) {
        $('#completeCorporation').prop('disabled', false);
      } else {
        $('#completeCorporation').prop('disabled', true);
      }
    }
  });
</script>
</body>
</html>
