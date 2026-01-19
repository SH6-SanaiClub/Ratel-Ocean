// ═══════════════════════════════════════════════════════════════════════
// 기술 스택 모달 - JavaScript
// ═══════════════════════════════════════════════════════════════════════

(function() {
    // 전역 변수
    window.techStackModal = {
        allPositions: [],
        allSkills: [],
        selectedPositionIds: [],
        selectedSkillIds: [],
        currentTechFilter: 'all',
        callback: null
    };
    
    // ═══════════════════════════════════════════════════════════════════════
    // 모달 열기
    // ═══════════════════════════════════════════════════════════════════════
    
    window.openTechStackModal = function(callback, preselectedAreas, preselectedStacks) {
        techStackModal.callback = callback;
        techStackModal.selectedPositionIds = [];
        techStackModal.selectedSkillIds = [];
        
        // 기존 선택값 복원
        if (preselectedAreas && preselectedAreas.length > 0) {
            techStackModal.selectedPositionIds = preselectedAreas.map(a => String(a.id || a));
        }
        if (preselectedStacks && preselectedStacks.length > 0) {
            techStackModal.selectedSkillIds = preselectedStacks.map(s => String(s.id || s));
        }
        
        $('#techStackModalOverlay').addClass('active');
        $('body').css('overflow', 'hidden');
        
        // 데이터 로드
        if (techStackModal.allPositions.length === 0) {
            loadModalPositions();
        } else {
            renderModalPositionGrid();
            updateModalSelectedPositionTags();
        }
        
        if (techStackModal.allSkills.length === 0) {
            loadModalSkills();
        } else {
            renderModalTechItems();
            updateModalSelectedTags();
        }
    };
    
    // ═══════════════════════════════════════════════════════════════════════
    // 모달 닫기
    // ═══════════════════════════════════════════════════════════════════════
    
    window.closeTechStackModal = function() {
        $('#techStackModalOverlay').removeClass('active');
        $('body').css('overflow', '');
        
        // 검색 초기화
        $('#modalTechSearch').val('');
        techStackModal.currentTechFilter = 'all';
        $('.alphabet-btn').removeClass('active');
        $('.alphabet-btn.all').addClass('active');
    };
    
    // ═══════════════════════════════════════════════════════════════════════
    // 선택 확정
    // ═══════════════════════════════════════════════════════════════════════
    
    window.confirmTechStackSelection = function() {
        // 개발 영역과 기술 스택 둘 다 선택 안 했으면 경고
        if (techStackModal.selectedPositionIds.length === 0 && techStackModal.selectedSkillIds.length === 0) {
            alert('개발 영역 또는 기술 스택을 최소 1개 이상 선택해주세요.');
            return;
        }
        
        // 선택된 개발 영역 데이터 (선택 안 했을 수도 있음 - 독립적 관리)
        const selectedAreas = techStackModal.allPositions.filter(p => 
            techStackModal.selectedPositionIds.includes(String(p.id))
        );
        
        // 선택된 기술 스택 데이터 (선택 안 했을 수도 있음 - 독립적 관리)
        const selectedStacks = techStackModal.allSkills.filter(s => 
            techStackModal.selectedSkillIds.includes(String(s.id))
        );
        
        // 콜백 호출
        if (techStackModal.callback) {
            techStackModal.callback(selectedAreas, selectedStacks);
        }
        
        closeTechStackModal();
    };
    
    // ═══════════════════════════════════════════════════════════════════════
    // 개발 영역 로드
    // ═══════════════════════════════════════════════════════════════════════
    
    function loadModalPositions() {
        $.ajax({
            url: '/ratelocean/api/stacks/positions',
            method: 'GET',
            dataType: 'json',
            success: function(positions) {
                techStackModal.allPositions = positions;
                techStackModal.allPositions.sort((a, b) => {
                    if (a.name === '기타') return 1;
                    if (b.name === '기타') return -1;
                    return a.name.localeCompare(b.name);
                });
                renderModalPositionGrid();
                updateModalSelectedPositionTags();
            },
            error: function() {
                console.error('개발 영역 데이터를 불러오는데 실패했습니다.');
                alert('개발 영역 데이터를 불러올 수 없습니다. 네트워크를 확인해주세요.');
            }
        });
    }
    
    function renderModalPositionGrid() {
        const grid = $('#modalPositionGrid');
        grid.empty();
        
        techStackModal.allPositions.forEach(pos => {
            const btn = $('<button>')
                .attr('type', 'button')
                .addClass('position-btn')
                .attr('data-id', String(pos.id))
                .attr('data-name', pos.name)
                .text(pos.name);
            
            // 기존 선택 복원
            if (techStackModal.selectedPositionIds.includes(String(pos.id))) {
                btn.addClass('selected');
            }
            
            grid.append(btn);
        });
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 기술 스택 로드
    // ═══════════════════════════════════════════════════════════════════════
    
    function loadModalSkills() {
        console.log('📡 기술 스택 데이터 로드 시작...');
        $.ajax({
            url: '/ratelocean/api/stacks/skills',
            method: 'GET',
            dataType: 'json',
            success: function(skills) {
                console.log('✅ 기술 스택 데이터 로드 완료. 개수:', skills.length);
                techStackModal.allSkills = skills;
                techStackModal.allSkills.sort((a, b) => a.name.localeCompare(b.name));
                console.log('📊 정렬 완료. 첫 5개:', techStackModal.allSkills.slice(0, 5).map(s => s.name));
                renderModalTechItems();
                updateModalSelectedTags();
                console.log('🎨 렌더링 완료');
            },
            error: function(xhr, status, error) {
                console.error('❌ 기술 스택 데이터 로드 실패:', error);
                console.error('상태 코드:', xhr.status);
                console.error('응답:', xhr.responseText);
                alert('기술 스택 데이터를 불러올 수 없습니다. 네트워크를 확인해주세요.');
            }
        });
    }
    
    function renderModalTechItems() {
        console.log('🎨 기술 스택 렌더링 시작...');
        const grid = $('#modalTechItemsGrid');
        grid.empty();
        
        // 모든 기술 스택 표시 (개발 영역과 독립적으로)
        const allSkills = techStackModal.allSkills;
        
        console.log('📦 allSkills 데이터:', allSkills);
        console.log('📊 allSkills 길이:', allSkills ? allSkills.length : 0);
        
        if (!allSkills || allSkills.length === 0) {
            console.warn('⚠️ 기술 스택 데이터가 없습니다!');
            grid.html('<div style="grid-column: 1/-1; padding: 2rem; text-align: center; color: #999;">기술 스택 데이터를 불러올 수 없습니다</div>');
            return;
        }
        
        console.log('✅ 기술 스택 렌더링 중... 개수:', allSkills.length);
        
        allSkills.forEach(skill => {
            const isSelected = techStackModal.selectedSkillIds.includes(String(skill.id));
            const item = $('<div>')
                .addClass('tech-item')
                .attr('data-id', String(skill.id))
                .attr('data-name', skill.name.toLowerCase())
                .text(skill.name);
            
            if (isSelected) {
                item.addClass('selected');
            }
            
            grid.append(item);
        });
        
        console.log('✅ DOM에 추가 완료. 필터 적용 중...');
        applyModalTechFilter();
        console.log('✅ 기술 스택 렌더링 완료!');
    }

    function updateModalSelectedPositionTags() {
        const tagsArea = $('#modalSelectedPositionTags');
        tagsArea.empty();
        
        if (techStackModal.selectedPositionIds.length === 0) {
            tagsArea.html('<span style="color: #999;">선택된 개발 영역이 없습니다</span>');
            return;
        }
        
        techStackModal.selectedPositionIds.forEach(id => {
            const position = techStackModal.allPositions.find(p => String(p.id) === String(id));
            if (position) {
                const tag = $('<div>')
                    .addClass('tech-tag')
                    .attr('data-id', String(id));
                
                const nameSpan = $('<span>').text(position.name);
                const removeBtn = $('<span>')
                    .addClass('tech-tag-remove')
                    .html('×')
                    .on('click', function() {
                        removeModalPosition(id);
                    });
                
                tag.append(nameSpan).append(removeBtn);
                tagsArea.append(tag);
            }
        });
    }

    function removeModalPosition(id) {
        const idStr = String(id);
        const index = techStackModal.selectedPositionIds.indexOf(idStr);
        if (index > -1) {
            techStackModal.selectedPositionIds.splice(index, 1);
            document.querySelector(`[data-id="${idStr}"].position-btn`)?.classList.remove('selected');
            updateModalSelectedPositionTags();
            // 개발 영역과 기술 스택이 독립적이므로 기술 재렌더링 불필요
        }
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 영역별 기술 매핑 (Position → Skills)
    // ═══════════════════════════════════════════════════════════════════════
    
    function getSkillsByPositions(positionIds) {
        if (!positionIds || positionIds.length === 0) {
            return [];
        }
        
        // 영역별 기술 매핑 (수동 정의)
        const positionSkillMap = {
            '125': [ // 웹 (백엔드)
                '.Net', 'ASP.NET', 'ASP.NET Core', 'Django', 'FastAPI', 'FastAPI (Python)', 
                'Flask', 'Go', 'Java', 'Java Spring', 'Kotlin', 'Laravel', 'Node.js', 
                'PHP', 'Python', 'Ruby on Rails', 'Rust', 'Scala', 'Spring', 
                'Spring Boot', 'TypeScript', 'Express', 'NestJS'
            ],
            '126': [ // 웹 (프론트엔드)
                'Angular', 'CSS', 'HTML', 'HTML/CSS', 'JavaScript', 'jQuery', 
                'Next.js', 'React', 'React Native', 'Svelte', 'TypeScript', 'Vue', 
                'Vue.js', 'Bootstrap', 'Tailwind CSS', 'SASS/SCSS'
            ],
            '127': [ // 모바일
                'Android', 'Flutter', 'iOS', 'Kotlin', 'React Native', 
                'Swift', 'Xamarin', 'Objective-C'
            ],
            '128': [ // 데이터분석
                'Excel', 'Hadoop', 'Hive', 'Jupyter', 'Machine Learning', 
                'Pandas', 'Power BI', 'Python', 'R', 'SAS', 'SQL', 'Tableau'
            ],
            '129': [ // 데이터엔지니어
                'Apache Kafka', 'Apache Spark', 'AWS', 'BigQuery', 'Databricks', 
                'Dataflow', 'Delta Lake', 'DuckDB', 'Flink', 'GCP', 'Hadoop', 
                'Hive', 'PySpark', 'Python', 'Scala', 'Spark SQL', 'dbt'
            ],
            '130': [ // 데이터베이스
                'BigQuery', 'Cassandra', 'DynamoDB', 'Elasticsearch', 'Firebase', 
                'MariaDB', 'MongoDB', 'MySQL', 'Oracle', 'PostgreSQL', 
                'Redis', 'SQL', 'SQL Server', 'SQLite'
            ],
            '131': [ // 데브옵스/인프라
                'AWS', 'Azure', 'CI/CD', 'Docker', 'GCP', 'Git', 'GitHub', 
                'GitLab', 'Kubernetes', 'Linux', 'Terraform', 'Jenkins', 
                'Ansible', 'Prometheus', 'ELK Stack'
            ],
            '132': [ // AI/머신러닝
                'AI', 'ChatGPT', 'Computer Vision', 'Deep Learning', 'Generative AI', 
                'GPT', 'Hugging Face', 'LangChain', 'LLM', 'Machine Learning', 
                'Neural Networks', 'NLP', 'OpenAI', 'PyTorch', 'Scikit-learn', 
                'Tensorflow', 'TensorFlow'
            ]
        };
        
        // 선택된 영역들의 기술 합치기
        const selectedSkillNames = new Set();
        positionIds.forEach(posId => {
            const skills = positionSkillMap[String(posId)] || [];
            skills.forEach(skillName => selectedSkillNames.add(skillName));
        });
        
        // allSkills에서 필터링
        return techStackModal.allSkills.filter(skill =>
            selectedSkillNames.has(skill.name)
        );
    }
    
    function updateModalSelectedTags() {
        const tagsArea = $('#modalSelectedTechTags');
        tagsArea.empty();
        
        if (techStackModal.selectedSkillIds.length === 0) {
            tagsArea.html('<span style="color: #999;">선택된 기술 스택이 없습니다</span>');
            return;
        }
        
        techStackModal.selectedSkillIds.forEach(id => {
            const skill = techStackModal.allSkills.find(s => String(s.id) === String(id));
            if (skill) {
                const tag = $('<div>')
                    .addClass('tech-tag')
                    .attr('data-id', String(id));
                
                const nameSpan = $('<span>').text(skill.name);
                const removeBtn = $('<span>')
                    .addClass('tech-tag-remove')
                    .html('×')
                    .on('click', function() {
                        removeModalSkill(id);
                    });
                
                tag.append(nameSpan).append(removeBtn);
                tagsArea.append(tag);
            }
        });
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 필터 적용
    // ═══════════════════════════════════════════════════════════════════════
    
    function applyModalTechFilter() {
        const filter = techStackModal.currentTechFilter;
        const searchText = $('#modalTechSearch').val().toLowerCase();
        
        $('.tech-item').each(function() {
            const name = $(this).data('name');
            const firstChar = name.charAt(0).toUpperCase();
            
            // 검색어 필터
            if (searchText && !name.includes(searchText)) {
                $(this).addClass('hidden');
                return;
            }
            
            // 알파벳 필터
            if (filter === 'all' || filter === '') {
                $(this).removeClass('hidden');
                return;
            }
            
            let inRange = false;
            if (filter === 'A-C' && firstChar >= 'A' && firstChar <= 'C') inRange = true;
            else if (filter === 'D-F' && firstChar >= 'D' && firstChar <= 'F') inRange = true;
            else if (filter === 'G-I' && firstChar >= 'G' && firstChar <= 'I') inRange = true;
            else if (filter === 'J-L' && firstChar >= 'J' && firstChar <= 'L') inRange = true;
            else if (filter === 'M-O' && firstChar >= 'M' && firstChar <= 'O') inRange = true;
            else if (filter === 'P-R' && firstChar >= 'P' && firstChar <= 'R') inRange = true;
            else if (filter === 'S-U' && firstChar >= 'S' && firstChar <= 'U') inRange = true;
            else if (filter === 'V-Z' && firstChar >= 'V' && firstChar <= 'Z') inRange = true;
            
            if (inRange) {
                $(this).removeClass('hidden');
            } else {
                $(this).addClass('hidden');
            }
        });
    }
    
    function removeModalSkill(id) {
        const idStr = String(id);
        const index = techStackModal.selectedSkillIds.indexOf(idStr);
        if (index > -1) {
            techStackModal.selectedSkillIds.splice(index, 1);
        }
        renderModalTechItems();
        updateModalSelectedTags();
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // 이벤트 리스너
    // ═══════════════════════════════════════════════════════════════════════
    
    $(document).ready(function() {
        // 개발 영역 버튼 클릭
        $(document).on('click', '#modalPositionGrid .position-btn', function() {
            const id = String($(this).data('id'));
            const index = techStackModal.selectedPositionIds.indexOf(id);
            
            if (index > -1) {
                techStackModal.selectedPositionIds.splice(index, 1);
                $(this).removeClass('selected');
            } else {
                techStackModal.selectedPositionIds.push(id);
                $(this).addClass('selected');
            }
            
            // 영역 선택 변경 시 기술 목록 다시 렌더링
            updateModalSelectedPositionTags();
            renderModalTechItems();
            updateModalSelectedTags();
        });
        
        // 기술 스택 아이템 클릭
        $(document).on('click', '#modalTechItemsGrid .tech-item', function() {
            const id = String($(this).data('id'));
            const index = techStackModal.selectedSkillIds.indexOf(id);
            
            if (index > -1) {
                techStackModal.selectedSkillIds.splice(index, 1);
            } else {
                techStackModal.selectedSkillIds.push(id);
            }
            
            renderModalTechItems();
            updateModalSelectedTags();
        });
        
        // 알파벳 필터 버튼
        $(document).on('click', '.tech-stack-modal .alphabet-btn', function() {
            $('.tech-stack-modal .alphabet-btn').removeClass('active');
            $(this).addClass('active');
            techStackModal.currentTechFilter = $(this).data('filter');
            applyModalTechFilter();
        });
        
        // 검색
        $(document).on('input', '#modalTechSearch', function() {
            applyModalTechFilter();
        });
        
        // 오버레이 클릭 시 닫기
        $(document).on('click', '#techStackModalOverlay', function(e) {
            if (e.target.id === 'techStackModalOverlay') {
                closeTechStackModal();
            }
        });
        
        // ESC 키로 닫기
        $(document).on('keydown', function(e) {
            if (e.key === 'Escape' && $('#techStackModalOverlay').hasClass('active')) {
                closeTechStackModal();
            }
        });
    });
})();
