<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>프리랜서 프로필 등록 - Ratel Ocean</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 0; padding: 0; background-color: #F1F6EE; }
        .container { max-width: 1000px; margin: 0 auto; padding: 2rem; }
        .card { background-color: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 2.5rem; margin-bottom: 2rem; }
        .title { font-size: 2rem; font-weight: 700; color: #2B2B2B; margin-bottom: 0.5rem; }
        .subtitle { font-size: 1rem; color: #6F7272; margin-bottom: 2rem; }
        .section-title { font-size: 1.3rem; font-weight: 600; color: #2B2B2B; margin: 2.5rem 0 1rem; padding-bottom: 0.5rem; border-bottom: 2px solid #A9D9DB; }
        .section-desc { font-size: 0.9rem; color: #6F7272; margin-top: 0.5rem; margin-bottom: 1.5rem; }
        .field { margin-bottom: 1.5rem; }
        .label { display: block; font-weight: 500; color: #2B2B2B; margin-bottom: 0.5rem; font-size: 0.95rem; }
        .label-small { font-size: 0.85rem; color: #6F7272; }
        .input, select, textarea { width: 100%; padding: 0.75rem; border: 1px solid #d0d0d0; border-radius: 6px; font-size: 1rem; box-sizing: border-box; font-family: inherit; }
        .input:focus, select:focus, textarea:focus { outline: none; border-color: #1F7A8C; }
        textarea { min-height: 100px; resize: vertical; }
        .grid { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); }
        .btn { padding: 0.75rem 2rem; border: none; border-radius: 6px; font-size: 1rem; font-weight: 500; cursor: pointer; }
        .btn-primary { background-color: #1F7A8C; color: white; }
        .btn-primary:hover { background-color: #165f6d; }
        .btn-outline { background-color: white; border: 1px solid #1F7A8C; color: #1F7A8C; }
        .btn-outline:hover { background-color: #f0f9fa; }
        .btn-small { padding: 0.5rem 1rem; font-size: 0.9rem; }
        .required { color: #ef4444; }
        .repeater-item { background-color: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 1.5rem; margin-bottom: 1rem; position: relative; }
        .repeater-item-title { font-weight: 600; color: #2B2B2B; margin-bottom: 1rem; }
        .remove-btn { position: absolute; top: 1rem; right: 1rem; background-color: #ef4444; color: white; padding: 0.4rem 0.8rem; border: none; border-radius: 4px; cursor: pointer; font-size: 0.85rem; }
        .remove-btn:hover { background-color: #dc2626; }
        .add-more { text-align: center; margin-top: 1rem; }
        .actions { display: flex; justify-content: space-between; gap: 1rem; margin-top: 3rem; }
        .info-box { background-color: #e0f2f7; border-left: 4px solid #1F7A8C; padding: 1rem; margin-bottom: 1.5rem; border-radius: 4px; }
        .info-box p { margin: 0; color: #2B2B2B; font-size: 0.9rem; }
        
        /* 기술 스택 태그 스타일 */
        .skill-tag-wrapper { display: flex; flex-wrap: wrap; gap: 0.75rem; }
        .skill-tag { background: linear-gradient(135deg, #e8f4f5 0%, #d4eef0 100%); border: 1.5px solid #94D9DB; color: #1F7A8C; padding: 8px 12px; border-radius: 20px; font-weight: 500; font-size: 0.9rem; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 1px 3px rgba(31, 122, 140, 0.1); }
        .skill-tag-name { font-weight: 600; }
        .skill-tag-details { display: flex; gap: 8px; font-size: 0.85rem; opacity: 0.9; }
        .skill-tag-remove { color: #1F7A8C; font-weight: 700; font-size: 1.1rem; cursor: pointer; width: 20px; height: 20px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s ease; margin-left: 4px; }
        .skill-tag-remove:hover { background-color: #ff6b6b; color: white; transform: scale(1.15); }
        .skill-detail-form { background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 1rem; margin-top: 0.5rem; }
        .skill-detail-grid { display: grid; grid-template-columns: 1fr 1fr 1fr auto; gap: 0.75rem; align-items: end; }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/views/common/freelancer_header.jsp" %>

    <div class="container">
        <div class="card">
            <h1 class="title">프리랜서 프로필 등록</h1>
            <p class="subtitle">프로필을 완성하고 프로젝트에 지원하세요.</p>

            <div class="info-box">
                <p>✏️ 이 정보는 클라이언트가 프리랜서를 선택할 때 중요한 판단 기준이 됩니다. 자세하고 정확하게 입력해주세요.</p>
            </div>

            <form id="profile-form" method="post" action="${pageContext.request.contextPath}/freelancer/complete-profile.do" onsubmit="return handleProfileSubmit(event)">
                
                <!-- 기본 프로필 -->
                <h3 class="section-title">기본 프로필</h3>
                <p class="section-desc">클라이언트에게 보여질 기본 정보를 입력하세요.</p>
                
                <div class="field">
                    <label class="label">닉네임 <span class="required">*</span></label>
                    <input type="text" name="nickname" class="input" placeholder="프로필에 표시될 닉네임" required />
                </div>

                <div class="field">
                    <label class="label">자기소개 <span class="required">*</span></label>
                    <textarea name="introduction" class="input" placeholder="본인의 전문성, 경험, 강점 등을 자유롭게 작성해주세요." required></textarea>
                </div>

                <!-- 프로필 이미지 업로드 -->
                <div class="field">
                    <label class="label">프로필 이미지</label>
                    <input type="file" name="profile_image" class="input" accept="image/jpeg,image/png,image/jpg" />
                    <p style="font-size: 0.85rem; color: #666; margin-top: 0.5rem;">JPG, PNG 파일만 가능 (최대 5MB)</p>
                </div>

                <div class="grid">
                    <div class="field">
                        <label class="label">GitHub URL</label>
                        <input type="url" name="github_url" class="input" placeholder="https://github.com/username" />
                    </div>

                    <div class="field">
                        <label class="label">개인 웹사이트 / 포트폴리오 URL</label>
                        <input type="url" name="website_url" class="input" placeholder="https://yourwebsite.com" />
                    </div>
                </div>

                <!-- 학력 정보 -->
                <h3 class="section-title">학력 정보</h3>
                <p class="section-desc">최종 학력 또는 주요 학력을 입력하세요.</p>

                <div class="grid">
                    <div class="field">
                        <label class="label">학교명</label>
                        <input type="text" name="school_name" class="input" placeholder="예: 서울대학교" />
                    </div>

                    <div class="field">
                        <label class="label">전공</label>
                        <input type="text" name="major" class="input" placeholder="예: 컴퓨터공학" />
                    </div>

                    <div class="field">
                        <label class="label">학위</label>
                        <select name="degree" class="input">
                            <option value="">선택</option>
                            <option value="고졸">고졸</option>
                            <option value="전문학사">전문학사</option>
                            <option value="학사">학사</option>
                            <option value="석사">석사</option>
                            <option value="박사">박사</option>
                        </select>
                    </div>

                    <div class="field">
                        <label class="label">졸업 상태</label>
                        <select name="grad_status" class="input">
                            <option value="">선택</option>
                            <option value="졸업">졸업</option>
                            <option value="재학">재학</option>
                            <option value="휴학">휴학</option>
                            <option value="중퇴">중퇴</option>
                        </select>
                    </div>
                </div>

                <!-- 기술 스택 (DB: freelancer_skills 테이블에 저장)
                     - stack_id: stacks 테이블 참조 (모달에서 선택)
                     - stack_level: 1-5 레벨 (사용자 직접 입력)
                     - stack_year: 경력년수 (사용자 직접 입력)
                -->
                <h3 class="section-title">기술 스택 <span class="required">*</span></h3>
                <p class="section-desc">보유한 기술을 선택하고 레벨과 경력을 입력하세요. (최소 1개 이상)</p>

                <!-- 레벨 정의 안내 -->
                <div style="margin-bottom: 1.5rem; padding: 1rem; background: #e8f4f5; border-left: 4px solid #1F7A8C; border-radius: 4px;">
                    <p style="margin: 0 0 0.5rem 0; font-weight: 600; color: #1F7A8C;">📊 레벨 정의</p>
                    <div style="font-size: 0.85rem; color: #333; line-height: 1.6;">
                        <p style="margin: 0.3rem 0;"><strong>Lv.1:</strong> 기본 개념 이해 - 기본 개념과 용어를 이해하고 있으며, 문서나 예제를 참고하여 간단한 사용이 가능</p>
                        <p style="margin: 0.3rem 0;"><strong>Lv.2:</strong> 기본 기능 활용 가능 - 기본 기능을 활용하여 단순한 작업을 수행할 수 있으며, 참고 자료를 통해 기능 구현 가능</p>
                        <p style="margin: 0.3rem 0;"><strong>Lv.3:</strong> 실무 활용 가능 - 실제 프로젝트에서 독립적으로 기능을 구현할 수 있으며, 일반적인 문제를 스스로 해결 가능</p>
                        <p style="margin: 0.3rem 0;"><strong>Lv.4:</strong> 설계 및 개선 가능 - 구조 설계, 성능 개선, 문제 해결을 주도할 수 있으며, 품질과 효율을 고려한 구현 가능</p>
                        <p style="margin: 0.3rem 0;"><strong>Lv.5:</strong> 전문가 수준 - 기술 전반에 대한 깊은 이해를 바탕으로 복잡한 문제 해결 및 기술 선택과 표준 수립 주도 가능</p>
                    </div>
                </div>

                <!-- 개발 영역 섹션 -->
                <h4 style="font-size: 1rem; font-weight: 600; color: #2B2B2B; margin-top: 1.5rem; margin-bottom: 0.75rem;">개발 영역 <span class="required">*</span></h4>
                <p style="font-size: 0.85rem; color: #666; margin-bottom: 1rem;">선택된 개발 영역별로 레벨과 경력을 입력하세요.</p>

                <div id="selected-areas-display" style="min-height: 50px; padding: 0.75rem; border: 2px dashed #ddd; border-radius: 8px; background-color: #f9fafb; margin-bottom: 1rem;">
                    <p style="text-align: center; color: #999; font-style: italic; margin: 0;">개발 영역이 선택되지 않았습니다.</p>
                </div>

                <div id="areas-container"></div>

                <!-- 기술 스택 섹션 -->
                <h4 style="font-size: 1rem; font-weight: 600; color: #2B2B2B; margin-top: 1.5rem; margin-bottom: 0.75rem;">기술 스택 <span class="required">*</span></h4>
                <p style="font-size: 0.85rem; color: #666; margin-bottom: 1rem;">선택된 기술별로 레벨과 경력을 입력하세요.</p>

                <div id="selected-skills-display" style="min-height: 50px; padding: 0.75rem; border: 2px dashed #ddd; border-radius: 8px; background-color: #f9fafb; margin-bottom: 1rem;">
                    <p style="text-align: center; color: #999; font-style: italic; margin: 0;">기술 스택이 선택되지 않았습니다. 아래 버튼을 클릭하여 추가하세요.</p>
                </div>

                <div id="skills-container"></div>
                
                <div class="add-more">
                    <button type="button" class="btn btn-primary" onclick="testModalOpen()" style="width: 100%;">
                        🔍 기술 스택 선택
                    </button>
                </div>

                <!-- 경력 사항 -->
                <h3 class="section-title">경력 사항</h3>
                <p class="section-desc">회사 또는 조직에서의 근무 경력을 입력하세요. (여러 개 추가 가능)</p>

                <div id="careers-container"></div>
                <div class="add-more">
                    <button type="button" class="btn btn-outline" onclick="addCareer()">+ 경력 추가</button>
                </div>

                <!-- 프로젝트 경험 -->
                <h3 class="section-title">프로젝트 경험</h3>
                <p class="section-desc">프리랜서 또는 개인 프로젝트 경험을 입력하세요. (여러 개 추가 가능)</p>

                <div id="experiences-container"></div>
                <div class="add-more">
                    <button type="button" class="btn btn-outline" onclick="addExperience()">+ 프로젝트 경험 추가</button>
                </div>

                <!-- 포트폴리오 -->
                <h3 class="section-title">포트폴리오</h3>
                <p class="section-desc">작업물, 결과물 링크를 추가하세요. (여러 개 추가 가능)</p>

                <div id="portfolios-container"></div>
                <div class="add-more">
                    <button type="button" class="btn btn-outline" onclick="addPortfolio()">+ 포트폴리오 추가</button>
                </div>

                <!-- 계좌 정보 -->
                <h3 class="section-title">계좌 정보 <span class="required">*</span></h3>
                <p class="section-desc">프로젝트 완료 후 수익금을 받을 계좌를 등록하세요.</p>

                <div class="grid">
                    <div class="field">
                        <label class="label">은행명 <span class="required">*</span></label>
                        <select name="bank_name" class="input" required>
                            <option value="">선택</option>
                            <option value="KB국민은행">KB국민은행</option>
                            <option value="신한은행">신한은행</option>
                            <option value="우리은행">우리은행</option>
                            <option value="하나은행">하나은행</option>
                            <option value="NH농협은행">NH농협은행</option>
                            <option value="IBK기업은행">IBK기업은행</option>
                            <option value="카카오뱅크">카카오뱅크</option>
                            <option value="토스뱅크">토스뱅크</option>
                            <option value="케이뱅크">케이뱅크</option>
                        </select>
                    </div>

                    <div class="field">
                        <label class="label">계좌번호 <span class="required">*</span> <span class="label-small">(숫자만)</span></label>
                        <input type="text" name="account_number" class="input" placeholder="12345678901234" required />
                    </div>

                    <div class="field">
                        <label class="label">예금주 <span class="required">*</span></label>
                        <input type="text" name="account_holder" class="input" placeholder="홍길동" required />
                    </div>
                </div>

                <div class="actions">
                    <button type="button" class="btn btn-outline" onclick="window.history.back()">이전으로</button>
                    <button type="submit" id="submit-btn" class="btn btn-primary" disabled style="opacity: 0.5; cursor: not-allowed;">프로필 완성하기</button>
                </div>
            </form>
        </div>
        
        <!-- 기술 스택 모달 - 공통 컴포넌트 -->
        <%@ include file="/WEB-INF/views/common/tech-stack-modal.jsp" %>
    </div>

    <script>
        let careerIndex = 0;
        let experienceIndex = 0;
        let portfolioIndex = 0;
        let skillIndex = 0;
        let selectedAreas = [];    // { id, name, level, years } - 개발 영역
        let selectedSkills = [];   // { id, name, level, years } - 기술 스택

        // ═══════════════════════════════════════════════════════════════════
        // 제출 버튼 활성화/비활성화 함수
        // ═══════════════════════════════════════════════════════════════════
        
        function checkFormValidity() {
            const submitBtn = document.getElementById('submit-btn');
            
            // 필수 필드 체크
            const nickname = document.querySelector('input[name="nickname"]')?.value.trim() || '';
            const introduction = document.querySelector('textarea[name="introduction"]')?.value.trim() || '';
            const bankName = document.querySelector('select[name="bank_name"]')?.value || '';
            const accountNumber = document.querySelector('input[name="account_number"]')?.value.trim() || '';
            const accountHolder = document.querySelector('input[name="account_holder"]')?.value.trim() || '';
            
            // 개발 영역이 선택되고 모든 필드가 입력되었는지 확인
            let areasValid = selectedAreas.length > 0;
            if (areasValid) {
                for (let i = 0; i < selectedAreas.length; i++) {
                    const area = selectedAreas[i];
                    if (!area.stackLevel || area.stackLevel === null || area.stackLevel === '' || 
                        area.stackYear === null || area.stackYear === undefined || area.stackYear === '') {
                        areasValid = false;
                        break;
                    }
                }
            }
            
            // 기술 스택이 선택되고 모든 필드가 입력되었는지 확인
            let skillsValid = selectedSkills.length > 0;
            if (skillsValid) {
                for (let i = 0; i < selectedSkills.length; i++) {
                    const skill = selectedSkills[i];
                    if (!skill.stackLevel || skill.stackLevel === null || skill.stackLevel === '' || 
                        skill.stackYear === null || skill.stackYear === undefined || skill.stackYear === '') {
                        skillsValid = false;
                        break;
                    }
                }
            }
            
            // 모든 필수 조건 확인
            const isValid = nickname.length >= 2 &&
                           introduction.length >= 10 &&
                           areasValid &&
                           skillsValid &&
                           bankName !== '' &&
                           accountNumber.length >= 10 &&
                           accountHolder.length > 0;
            
            if (isValid) {
                submitBtn.disabled = false;
                submitBtn.style.opacity = '1';
                submitBtn.style.cursor = 'pointer';
            } else {
                submitBtn.disabled = true;
                submitBtn.style.opacity = '0.5';
                submitBtn.style.cursor = 'not-allowed';
            }
        }
        
        // ═══════════════════════════════════════════════════════════════════
        // 기술 스택 모달 콜백 함수 - 최우선 정의
        // ═══════════════════════════════════════════════════════════════════
        
        /**
         * tech-stack-modal.js에서 호출하는 콜백 함수
         * @param {Array} selectedPositions - 선택된 개발 영역 [{id, name}, ...]
         * @param {Array} selectedStacks - 선택된 기술 스택 [{id, name}, ...]
         * 
         * 개발 영역과 기술 스택을 각각 별도로 관리:
         * - selectedAreas: 개발 영역 (웹, 모바일 등)에 대한 레벨/경력
         * - selectedSkills: 기술 스택 (Java, React 등)에 대한 레벨/경력
         */
        function handleTechStackSelection(selectedPositions, selectedStacks) {
            console.log('✅ 선택된 개발 영역:', selectedPositions);
            console.log('✅ 선택된 기술 스택:', selectedStacks);
            console.log('📝 첫 번째 영역 상세:', selectedPositions[0]);
            console.log('📝 첫 번째 기술 상세:', selectedStacks[0]);
            
            // 개발 영역 처리 (레벨과 경력은 사용자가 직접 입력)
            selectedAreas = selectedPositions.map(area => ({
                stackId: area.id,
                stackName: area.name,
                stackLevel: null,   // 사용자가 직접 입력
                stackYear: null     // 사용자가 직접 입력
            }));
            
            // 기술 스택 처리 (레벨과 경력은 사용자가 직접 입력)
            selectedSkills = selectedStacks.map(stack => ({
                stackId: stack.id,
                stackName: stack.name,
                stackLevel: null,   // 사용자가 직접 입력
                stackYear: null     // 사용자가 직접 입력
            }));
            
            console.log('📦 선택된 개발 영역:', selectedAreas);
            console.log('📦 선택된 기술 스택:', selectedSkills);
            
            renderSelectedAreas();
            renderSelectedSkills();
            
            // 제출 버튼 활성화 체크
            checkFormValidity();
        }

        /**
         * 모달 테스트 함수 - 상단에 선언해 초기 로드 시점에 즉시 전역으로 노출
         */
        function testModalOpen() {
            console.log('🧪 테스트 모달 열기 함수 호출됨');
            console.log('openTechStackModal 함수 존재:', typeof openTechStackModal);

            if (typeof openTechStackModal === 'function') {
                openTechStackModal(handleTechStackSelection);
            } else {
                alert('❌ 모달 함수를 찾을 수 없습니다. 페이지를 새로고침해주세요.');
                console.error('openTechStackModal 미정의');
            }
        }

        /**
         * 모달 디버그 함수 - 상단에 선언해 전역 노출 보장
         */
        function checkModalDebug() {
            console.log('🔍 모달 디버그 정보:');
            console.log('- openTechStackModal:', typeof openTechStackModal);
            console.log('- techStackModal:', window.techStackModal);
            console.log('- jQuery:', typeof $);
            console.log('- 모달 오버레이:', $('#techStackModalOverlay').length);
            console.log('- 모달 컨테이너:', $('#techStackModal').length);

            const status = {
                'openTechStackModal 함수': typeof openTechStackModal === 'function' ? '✅' : '❌',
                'techStackModal 객체': typeof window.techStackModal === 'object' ? '✅' : '❌',
                'jQuery': typeof $ === 'function' ? '✅' : '❌',
                '모달 HTML 존재': $('#techStackModalOverlay').length > 0 ? '✅' : '❌'
            };

            console.table(status);
            alert('디버그 정보를 콘솔에서 확인하세요. (F12 → Console)');
        }

        /**
         * 폼 제출 핸들러
         */
        function handleProfileSubmit(event) {
            event.preventDefault();
            
            console.log('📝 폼 제출 시작');
            console.log('선택된 스킬:', selectedSkills);
            
            // 폼 유효성 검사
            if (!validateForm()) {
                console.error('❌ 폼 검증 실패');
                return false;
            }
            
            console.log('✅ 폼 검증 성공 - 제출 진행');
            event.target.submit();
        }

        /**
         * 선택된 개발 영역 렌더링
         */
        function renderSelectedAreas() {
            console.log('🔄 renderSelectedAreas 호출됨');
            console.log('selectedAreas 내용:', JSON.stringify(selectedAreas));
            
            const displayArea = document.getElementById('selected-areas-display');
            const container = document.getElementById('areas-container');
            
            if (selectedAreas.length === 0) {
                displayArea.innerHTML = '<p style="text-align: center; color: #999; font-style: italic; margin: 0;">개발 영역이 선택되지 않았습니다.</p>';
                container.innerHTML = '';
                return;
            }
            
            // 태그 형태로 표시
            let displayHtml = '<div class="skill-tag-wrapper">';
            selectedAreas.forEach((area, idx) => {
                const areaName = area.stackName || '(이름없음)';
                const areaLevel = area.stackLevel ? 'Lv.' + area.stackLevel : '-';
                const areaYear = area.stackYear ? area.stackYear + '년' : '-';
                const tagHtml = '<div class="skill-tag">' +
                    '<span class="skill-tag-name">' + areaName + '</span>' +
                    '<span class="skill-tag-details">' +
                        '<span>' + areaLevel + '</span>' +
                        '<span>•</span>' +
                        '<span>' + areaYear + '</span>' +
                    '</span>' +
                    '<span class="skill-tag-remove" onclick="removeArea(' + idx + ')">×</span>' +
                    '</div>';
                console.log('🏷️ 생성된 HTML (영역 ' + idx + '):', tagHtml);
                displayHtml += tagHtml;
            });
            displayHtml += '</div>';
            console.log('📄 최종 displayHtml:', displayHtml);
            displayArea.innerHTML = displayHtml;
            
            // 상세 입력 폼 생성
            container.innerHTML = '';
            selectedAreas.forEach((area, idx) => {
                const areaName = area.stackName || '(이름없음)';
                const areaNameValue = area.stackName || '';
                const areaYear = area.stackYear || '';
                const lv1 = area.stackLevel == 1 ? 'selected' : '';
                const lv2 = area.stackLevel == 2 ? 'selected' : '';
                const lv3 = area.stackLevel == 3 ? 'selected' : '';
                const lv4 = area.stackLevel == 4 ? 'selected' : '';
                const lv5 = area.stackLevel == 5 ? 'selected' : '';
                const html = '<div class="skill-detail-form" id="area-detail-' + idx + '">' +
                    '<div style="margin-bottom: 1rem; padding: 0.75rem; background: #f0f9fa; border-left: 3px solid #94D9DB; border-radius: 4px;">' +
                        '<div style="font-weight: 600; color: #1F7A8C; font-size: 1rem;">' + areaName + '</div>' +
                    '</div>' +
                    '<input type="hidden" name="areas[' + idx + '].stack_name" value="' + areaNameValue + '" />' +
                    '<div class="skill-detail-grid">' +
                        '<div class="field" style="margin: 0;">' +
                            '<label class="label">레벨 (1-5) <span class="required">*</span></label>' +
                            '<select name="areas[' + idx + '].stack_level" class="input" required onchange="updateAreaLevel(' + idx + ', this.value)">' +
                                '<option value="">선택</option>' +
                                '<option value="1" ' + lv1 + '>1 - 기본 개념 이해</option>' +
                                '<option value="2" ' + lv2 + '>2 - 기본 기능 활용 가능</option>' +
                                '<option value="3" ' + lv3 + '>3 - 실무 활용 가능</option>' +
                                '<option value="4" ' + lv4 + '>4 - 설계 및 개선 가능</option>' +
                                '<option value="5" ' + lv5 + '>5 - 전문가 수준</option>' +
                            '</select>' +
                        '</div>' +
                        '<div class="field" style="margin: 0;">' +
                            '<label class="label">경력 (년) <span class="required">*</span></label>' +
                            '<input type="number" name="areas[' + idx + '].stack_year" class="input" min="0" step="1" placeholder="0" value="' + areaYear + '" required onchange="updateAreaYears(' + idx + ', this.value)" />' +
                        '</div>' +
                        '<button type="button" class="btn btn-outline btn-small" onclick="removeArea(' + idx + ')" style="height: fit-content;">삭제</button>' +
                    '</div>' +
                    '</div>';
                container.insertAdjacentHTML('beforeend', html);
            });
        }

        /**
         * 선택된 기술 스택 렌더링
         */
        function renderSelectedSkills() {
            console.log('🔄 renderSelectedSkills 호출됨');
            console.log('selectedSkills 내용:', JSON.stringify(selectedSkills));
            
            const displayArea = document.getElementById('selected-skills-display');
            const container = document.getElementById('skills-container');
            
            if (selectedSkills.length === 0) {
                displayArea.innerHTML = '<p style="text-align: center; color: #999; font-style: italic; margin: 0;">기술 스택이 선택되지 않았습니다. 아래 버튼을 클릭하여 추가하세요.</p>';
                container.innerHTML = '';
                return;
            }
            
            // 태그 형태로 표시
            let displayHtml = '<div class="skill-tag-wrapper">';
            selectedSkills.forEach((skill, idx) => {
                const skillName = skill.stackName || '(이름없음)';
                const skillLevel = skill.stackLevel ? 'Lv.' + skill.stackLevel : '-';
                const skillYear = skill.stackYear ? skill.stackYear + '년' : '-';
                const tagHtml = '<div class="skill-tag">' +
                    '<span class="skill-tag-name">' + skillName + '</span>' +
                    '<span class="skill-tag-details">' +
                        '<span>' + skillLevel + '</span>' +
                        '<span>•</span>' +
                        '<span>' + skillYear + '</span>' +
                    '</span>' +
                    '<span class="skill-tag-remove" onclick="removeSkill(' + idx + ')">×</span>' +
                    '</div>';
                console.log('🏷️ 생성된 HTML (스킬 ' + idx + '):', tagHtml);
                displayHtml += tagHtml;
            });
            displayHtml += '</div>';
            console.log('📄 최종 displayHtml (skills):', displayHtml);
            displayArea.innerHTML = displayHtml;
            
            // 상세 입력 폼 생성
            container.innerHTML = '';
            selectedSkills.forEach((skill, idx) => {
                const skillName = skill.stackName || '(이름없음)';
                const skillNameValue = skill.stackName || '';
                const skillYear = skill.stackYear || '';
                const lv1 = skill.stackLevel == 1 ? 'selected' : '';
                const lv2 = skill.stackLevel == 2 ? 'selected' : '';
                const lv3 = skill.stackLevel == 3 ? 'selected' : '';
                const lv4 = skill.stackLevel == 4 ? 'selected' : '';
                const lv5 = skill.stackLevel == 5 ? 'selected' : '';
                const html = '<div class="skill-detail-form" id="skill-detail-' + idx + '">' +
                    '<div style="margin-bottom: 1rem; padding: 0.75rem; background: #f0f9fa; border-left: 3px solid #94D9DB; border-radius: 4px;">' +
                        '<div style="font-weight: 600; color: #1F7A8C; font-size: 1rem;">' + skillName + '</div>' +
                    '</div>' +
                    '<input type="hidden" name="skills[' + idx + '].stack_name" value="' + skillNameValue + '" />' +
                    '<div class="skill-detail-grid">' +
                        '<div class="field" style="margin: 0;">' +
                            '<label class="label">레벨 (1-5) <span class="required">*</span></label>' +
                            '<select name="skills[' + idx + '].stack_level" class="input" required onchange="updateSkillLevel(' + idx + ', this.value)">' +
                                '<option value="">선택</option>' +
                                '<option value="1" ' + lv1 + '>1 - 기본 개념 이해</option>' +
                                '<option value="2" ' + lv2 + '>2 - 기본 기능 활용 가능</option>' +
                                '<option value="3" ' + lv3 + '>3 - 실무 활용 가능</option>' +
                                '<option value="4" ' + lv4 + '>4 - 설계 및 개선 가능</option>' +
                                '<option value="5" ' + lv5 + '>5 - 전문가 수준</option>' +
                            '</select>' +
                        '</div>' +
                        '<div class="field" style="margin: 0;">' +
                            '<label class="label">경력 (년) <span class="required">*</span></label>' +
                            '<input type="number" name="skills[' + idx + '].stack_year" class="input" min="0" step="1" placeholder="0" value="' + skillYear + '" required onchange="updateSkillYears(' + idx + ', this.value)" />' +
                        '</div>' +
                        '<button type="button" class="btn btn-outline btn-small" onclick="removeSkill(' + idx + ')" style="height: fit-content;">삭제</button>' +
                    '</div>' +
                    '</div>';
                container.insertAdjacentHTML('beforeend', html);
            });
        }

        // ═══════════════════════════════════════════════════════════════════
        // 개발 영역 업데이트 함수
        // ═══════════════════════════════════════════════════════════════════
        function updateAreaLevel(idx, level) {
            if (selectedAreas[idx]) {
                selectedAreas[idx].stackLevel = parseInt(level);
                renderSelectedAreas();
                checkFormValidity();  // 실시간 제출 버튼 활성화 체크
            }
        }

        function updateAreaYears(idx, years) {
            if (selectedAreas[idx]) {
                selectedAreas[idx].stackYear = parseFloat(years);
                renderSelectedAreas();
                checkFormValidity();  // 실시간 제출 버튼 활성화 체크
            }
        }

        function removeArea(idx) {
            selectedAreas.splice(idx, 1);
            renderSelectedAreas();
            checkFormValidity();  // 실시간 제출 버튼 활성화 체크
        }

        // ═══════════════════════════════════════════════════════════════════
        // 기술 스택 업데이트 함수
        // ═══════════════════════════════════════════════════════════════════
        function updateSkillLevel(idx, level) {
            if (selectedSkills[idx]) {
                selectedSkills[idx].stackLevel = parseInt(level);
                renderSelectedSkills();
                checkFormValidity();  // 실시간 제출 버튼 활성화 체크
            }
        }

        function updateSkillYears(idx, years) {
            if (selectedSkills[idx]) {
                selectedSkills[idx].stackYear = parseFloat(years);
                renderSelectedSkills();
                checkFormValidity();  // 실시간 제출 버튼 활성화 체크
            }
        }

        function removeSkill(idx) {
            selectedSkills.splice(idx, 1);
            renderSelectedSkills();
            checkFormValidity();  // 실시간 제출 버튼 활성화 체크
        }

        // ═══════════════════════════════════════════════════════════════════
        // ═══════════════════════════════════════════════════════════════════
        // 폼 검증
        // ═══════════════════════════════════════════════════════════════════
        function validateForm() {
            // 개발 영역 필수 검증
            if (selectedAreas.length === 0) {
                alert('⚠️ 개발 영역을 최소 1개 이상 선택해주세요.');
                document.getElementById('selected-areas-display').scrollIntoView({ behavior: 'smooth' });
                return false;
            }

            // 기술 스택 필수 검증
            if (selectedSkills.length === 0) {
                alert('⚠️ 기술 스택을 최소 1개 이상 선택해주세요.');
                document.getElementById('selected-skills-display').scrollIntoView({ behavior: 'smooth' });
                return false;
            }

            // 필수 필드 검증
            const nickname = document.querySelector('input[name="nickname"]').value.trim();
            const introduction = document.querySelector('textarea[name="introduction"]').value.trim();
            const bankName = document.querySelector('select[name="bank_name"]').value;
            const accountNumber = document.querySelector('input[name="account_number"]').value.trim();
            const accountHolder = document.querySelector('input[name="account_holder"]').value.trim();

            if (!nickname) {
                alert('⚠️ 닉네임을 입력해주세요.');
                return false;
            }
            
            if (nickname.length < 2) {
                alert('⚠️ 닉네임은 2자 이상이어야 합니다.');
                return false;
            }

            if (!introduction) {
                alert('⚠️ 자기소개를 입력해주세요.');
                return false;
            }
            
            if (introduction.length < 10) {
                alert('⚠️ 자기소개는 10자 이상이어야 합니다.');
                return false;
            }

            if (!bankName || bankName === '') {
                alert('⚠️ 은행명을 선택해주세요.');
                return false;
            }

            if (!accountNumber) {
                alert('⚠️ 계좌번호를 입력해주세요.');
                return false;
            }
            
            if (!/^\d{10,}$/.test(accountNumber)) {
                alert('⚠️ 유효한 계좌번호를 입력해주세요. (최소 10자 이상의 숫자)');
                return false;
            }

            if (!accountHolder) {
                alert('⚠️ 예금주를 입력해주세요.');
                return false;
            }
            
            if (accountHolder.length < 2) {
                alert('⚠️ 예금주는 2자 이상이어야 합니다.');
                return false;
            }

            // 모든 개발 영역의 숙련도가 설정되었는지 확인 (배열 데이터 직접 검증)
            for (let i = 0; i < selectedAreas.length; i++) {
                const area = selectedAreas[i];
                const areaName = area.stackName || area.name || '개발 영역';
                
                console.log(`검증 중 - 개발 영역 ${i}:`, area);
                
                if (!area.stackLevel || area.stackLevel === null) {
                    alert(`⚠️ ${areaName}의 숙련도를 선택해주세요.`);
                    return false;
                }
                
                if (area.stackYear === null || area.stackYear === undefined || area.stackYear < 0) {
                    alert(`⚠️ ${areaName}의 경력을 입력해주세요.`);
                    return false;
                }
            }

            // 모든 기술 스택의 숙련도가 설정되었는지 확인 (배열 데이터 직접 검증)
            for (let i = 0; i < selectedSkills.length; i++) {
                const skill = selectedSkills[i];
                const skillName = skill.stackName || skill.name || '기술 스택';
                
                console.log(`검증 중 - 기술 스택 ${i}:`, skill);
                
                if (!skill.stackLevel || skill.stackLevel === null) {
                    alert(`⚠️ ${skillName}의 숙련도를 선택해주세요.`);
                    return false;
                }
                
                if (skill.stackYear === null || skill.stackYear === undefined || skill.stackYear < 0) {
                    alert(`⚠️ ${skillName}의 경력을 입력해주세요.`);
                    return false;
                }
            }

            // 최종 로그
            console.log('✅ 폼 검증 완료');
            console.log('프로필 데이터:', {
                nickname,
                introduction: introduction.substring(0, 50) + '...',
                bankName,
                accountNumber: '****' + accountNumber.slice(-4),
                accountHolder,
                skillsCount: selectedSkills.length
            });
            
            return true;
        }

        // ═══════════════════════════════════════════════════════════════════
        // 기존 함수들 (경력, 프로젝트, 포트폴리오)
        // ═══════════════════════════════════════════════════════════════════

        function addCareer() {
            const container = document.getElementById('careers-container');
            const html = `
                <div class="repeater-item" id="career-${careerIndex}">
                    <button type="button" class="remove-btn" onclick="removeItem('career-${careerIndex}')">삭제</button>
                    <div class="repeater-item-title">경력 ${careerIndex + 1}</div>
                    <div class="grid">
                        <div class="field">
                            <label class="label">회사명 <span class="required">*</span></label>
                            <input type="text" name="careers[${careerIndex}].company_name" class="input" required />
                        </div>
                        <div class="field">
                            <label class="label">역할/직책 <span class="required">*</span></label>
                            <input type="text" name="careers[${careerIndex}].role" class="input" placeholder="예: 백엔드 개발자" required />
                        </div>
                        <div class="field">
                            <label class="label">포지션 <span class="required">*</span></label>
                            <input type="text" name="careers[${careerIndex}].position" class="input" placeholder="예: 시니어 개발자" required />
                        </div>
                        <div class="field">
                            <label class="label">시작일 <span class="required">*</span></label>
                            <input type="date" name="careers[${careerIndex}].start_date" class="input" required />
                        </div>
                        <div class="field">
                            <label class="label">종료일 <span class="label-small">(현재 재직중이면 비워두세요)</span></label>
                            <input type="date" name="careers[${careerIndex}].end_date" class="input" />
                        </div>
                    </div>
                    <div class="field">
                        <label class="label">업무 내용</label>
                        <textarea name="careers[${careerIndex}].description" class="input" placeholder="주요 업무와 성과를 기술하세요"></textarea>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
            careerIndex++;
        }

        function addExperience() {
            const container = document.getElementById('experiences-container');
            const html = `
                <div class="repeater-item" id="experience-${experienceIndex}">
                    <button type="button" class="remove-btn" onclick="removeItem('experience-${experienceIndex}')">삭제</button>
                    <div class="repeater-item-title">프로젝트 ${experienceIndex + 1}</div>
                    <div class="grid">
                        <div class="field">
                            <label class="label">프로젝트명 <span class="required">*</span></label>
                            <input type="text" name="experiences[${experienceIndex}].title" class="input" required />
                        </div>
                        <div class="field">
                            <label class="label">클라이언트명</label>
                            <input type="text" name="experiences[${experienceIndex}].client_name" class="input" />
                        </div>
                        <div class="field">
                            <label class="label">역할 <span class="required">*</span></label>
                            <input type="text" name="experiences[${experienceIndex}].role" class="input" placeholder="예: 풀스택 개발" required />
                        </div>
                        <div class="field">
                            <label class="label">시작일 <span class="required">*</span></label>
                            <input type="date" name="experiences[${experienceIndex}].start_date" class="input" required />
                        </div>
                        <div class="field">
                            <label class="label">종료일</label>
                            <input type="date" name="experiences[${experienceIndex}].end_date" class="input" />
                        </div>
                    </div>
                    <div class="field">
                        <label class="label">프로젝트 설명</label>
                        <textarea name="experiences[${experienceIndex}].description" class="input" placeholder="프로젝트 내용, 사용 기술, 성과 등을 작성하세요"></textarea>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
            experienceIndex++;
        }

        function addPortfolio() {
            const container = document.getElementById('portfolios-container');
            const html = `
                <div class="repeater-item" id="portfolio-${portfolioIndex}">
                    <button type="button" class="remove-btn" onclick="removeItem('portfolio-${portfolioIndex}')">삭제</button>
                    <div class="repeater-item-title">포트폴리오 ${portfolioIndex + 1}</div>
                    <div class="grid">
                        <div class="field">
                            <label class="label">제목 <span class="required">*</span></label>
                            <input type="text" name="portfolios[${portfolioIndex}].title" class="input" required />
                        </div>
                        <div class="field">
                            <label class="label">URL <span class="required">*</span></label>
                            <input type="url" name="portfolios[${portfolioIndex}].portfolio_url" class="input" placeholder="https://..." required />
                        </div>
                    </div>
                    <div class="field">
                        <label class="label">설명</label>
                        <textarea name="portfolios[${portfolioIndex}].description" class="input"></textarea>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
            portfolioIndex++;
        }

        function addSkill() {
            const container = document.getElementById('skills-container');
            const html = `
                <div class="repeater-item" id="skill-${skillIndex}">
                    <button type="button" class="remove-btn" onclick="removeItem('skill-${skillIndex}')">삭제</button>
                    <div class="repeater-item-title">기술 ${skillIndex + 1}</div>
                    <div class="grid">
                        <div class="field">
                            <label class="label">기술명 <span class="required">*</span></label>
                            <input type="text" name="skills[${skillIndex}].stack_name" class="input" placeholder="예: Java, React, AWS" required />
                        </div>
                        <div class="field">
                            <label class="label">숙련도 (1-5) <span class="required">*</span></label>
                            <select name="skills[${skillIndex}].stack_level" class="input" required>
                                <option value="">선택</option>
                                <option value="1">1 - 초급</option>
                                <option value="2">2 - 초중급</option>
                                <option value="3">3 - 중급</option>
                                <option value="4">4 - 중상급</option>
                                <option value="5">5 - 전문가</option>
                            </select>
                        </div>
                        <div class="field">
                            <label class="label">경력 (년) <span class="required">*</span></label>
                            <input type="number" name="skills[${skillIndex}].stack_year" class="input" min="0" step="1" placeholder="0" required />
                        </div>
                    </div>
                </div>
            `;
            container.insertAdjacentHTML('beforeend', html);
            skillIndex++;
        }

        function removeItem(id) {
            document.getElementById(id).remove();
        }

        // ═══════════════════════════════════════════════════════════════════
        // 기술 스택 렌더링 함수
        // ═══════════════════════════════════════════════════════════════════
        
        // 페이지 로드 시 초기화
        window.addEventListener('DOMContentLoaded', function() {
            console.log('🔍 페이지 로드됨');
            console.log('openTechStackModal 함수:', typeof openTechStackModal);
            console.log('handleTechStackSelection 함수:', typeof handleTechStackSelection);
            
            // 실시간 필드 검증을 위한 이벤트 리스너 추가
            const fieldsToWatch = [
                'input[name="nickname"]',
                'textarea[name="introduction"]',
                'select[name="bank_name"]',
                'input[name="account_number"]',
                'input[name="account_holder"]'
            ];
            
            fieldsToWatch.forEach(selector => {
                const element = document.querySelector(selector);
                if (element) {
                    element.addEventListener('input', checkFormValidity);
                    element.addEventListener('change', checkFormValidity);
                }
            });
            
            // 초기 검증
            checkFormValidity();
        });
        
    </script>
    
    <!-- 기술 스택 모달 JavaScript - 캐시 버스팅 추가 -->
    <script src="${pageContext.request.contextPath}/resources/js/tech-stack-modal.js?v=<%= System.currentTimeMillis() %>"></script>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

</body>
</html>
