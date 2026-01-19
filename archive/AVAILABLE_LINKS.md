# 🌊 Ratel Ocean - 실행 가능한 모든 링크

**Tomcat 상태**: ✅ 재실행 완료 (포트: 9999)  
**컨텍스트**: ratelocean  
**기본 URL**: http://localhost:9999/ratelocean

---

## 🏠 홈 & 인증

| 설명 | 링크 | 방식 |
|------|------|------|
| 홈 페이지 | http://localhost:9999/ratelocean/ | GET |
| 역할 선택 | http://localhost:9999/ratelocean/join/select-role.do | GET/POST |
| 회원가입 | http://localhost:9999/ratelocean/join/signup | GET |
| 로그인 | http://localhost:9999/ratelocean/login | GET |

---

## 👤 대시보드

| 설명 | 링크 | 방식 | 비고 |
|------|------|------|------|
| 프리랜서 대시보드 | http://localhost:9999/ratelocean/dashboard | GET | ✨ 프리랜서 전용 |
| 클라이언트 대시보드 | http://localhost:9999/ratelocean/client-dashboard | GET | 🔨 클라이언트 전용 |

---

## 📝 프로젝트 & 계약

| 설명 | 링크 | 방식 | 비고 |
|------|------|------|------|
| 프로젝트 목록 | http://localhost:9999/ratelocean/projects | GET |  |
| 계약서 1단계 (PDF 업로드) | http://localhost:9999/ratelocean/client_contract_first | GET | 💼 프로젝트 정보 입력 |
| 계약서 1단계 제출 | http://localhost:9999/ratelocean/contract/first | POST | 📤 PDF 업로드 |
| 계약서 2단계 (AI 검토) | http://localhost:9999/ratelocean/contract/second | GET | 🤖 Select2 드롭다운 적용 |

---

## 🔍 기회큐 & 경력

| 설명 | 링크 | 방식 | 비고 |
|------|------|------|------|
| 기회큐 | http://localhost:9999/ratelocean/queue | GET |  |
| 경력 관리 | http://localhost:9999/ratelocean/career | GET |  |
| 마이페이지 | http://localhost:9999/ratelocean/mypage | GET |  |

---

## 💰 금융 & 지갑

| 설명 | 링크 | 방식 | 비고 |
|------|------|------|------|
| 계좌 등록 | http://localhost:9999/ratelocean/settings/accounts/register | GET |  |
| 금융 관리 | http://localhost:9999/ratelocean/settings/finance | GET |  |

---

## 📚 정보

| 설명 | 링크 | 방식 |
|------|------|------|
| 신뢰 가이드라인 | http://localhost:9999/ratelocean/trust-guideline | GET |

---

## 🔗 API (JSON)

모든 API는 SELECT2 라이브러리와 통합되어 있으며, DB의 `stacks` 테이블에서 데이터를 실시간으로 로드합니다.

### 개발 영역 (POSITION 카테고리)

**GET** `/api/stacks/positions`

```json
[
  {"id": 125, "name": "웹"},
  {"id": 126, "name": "모바일앱"},
  {"id": 127, "name": "데이터베이스"},
  {"id": 128, "name": "DevOps/인프라"},
  {"id": 129, "name": "게임/그래픽"},
  {"id": 130, "name": "AI/빅데이터"},
  {"id": 131, "name": "임베디드/하드웨어"},
  {"id": 132, "name": "기타"}
]
```

**링크**: http://localhost:9999/ratelocean/api/stacks/positions

---

### 기술 스택 (SKILL 카테고리)

**GET** `/api/stacks/skills` (124개 항목)

```json
[
  {"id": 1, "name": ".Net"},
  {"id": 2, "name": "Android"},
  {"id": 3, "name": "Android Studio"},
  ...
  {"id": 30, "name": "Flask"}
]
```

**링크**: http://localhost:9999/ratelocean/api/stacks/skills

**샘플**: Java, Spring, React, Node.js, Python, Go 등 132개 기술 포함

---

### 전체 스택 (통합)

**GET** `/api/stacks/all`

```json
{
  "positions": [...],
  "skills": [...]
}
```

**링크**: http://localhost:9999/ratelocean/api/stacks/all

---

## 🎨 주요 기능

### ✨ 계약 검토 페이지 (/contract/second)

- **Select2 라이브러리**: 검색 가능한 드롭다운
- **DB 실시간 연동**: stacks 테이블의 132개 기술
- **태그 형식 선택**: 선택된 항목이 예쁜 태그로 표시
- **동적 추가/제거**: 마일스톤 단계 추가 기능
- **검증**: 최소 1개 이상 항목 보유 필수

### 🤖 AI 기반 계약 생성

**흐름**:
1. Step 1: PDF 업로드 & 프로젝트 정보 입력
2. AI 분석 (Mock Data 제공)
3. Step 2: AI가 자동 생성한 계약 정보 검토 & 수정
4. Select2를 통한 기술 스택 선택

---

## 🗄️ DB 테이블 연동

| 테이블 | 레코드 수 | 사용 페이지 | 비고 |
|--------|----------|-----------|------|
| `stacks` | 132 | API, 계약 검토 | ✅ POSITION(8) + SKILL(124) |
| `projects` | 0 | 프로젝트 목록 | 📝 Mock data 제공 |
| `contracts` | 0 | 계약 검토 | 📝 Mock data 제공 |
| `users` | 0 | 인증 시스템 | 📝 향후 통합 예정 |
| `freelancer_profiles` | 0 | 프리랜서 대시보드 | 📝 향후 통합 예정 |
| `client_profiles` | 0 | 클라이언트 대시보드 | 📝 향후 통합 예정 |

---

## 🛠️ 최근 수정 사항

### ✅ 완료

1. **JSP contentType 충돌 해결**
   - 포함되는 JSP에서 contentType 제거
   - pageEncoding만 사용하도록 표준화
   - 7개 파일 수정 (sidebar.jsp, header.jsp 등)

2. **Select2 라이브러리 적용**
   - StackController API 구현
   - client_con_second.jsp 개선
   - 132개 기술 스택 DB 연동

3. **클라이언트 대시보드 추가**
   - DashboardController에 `/client-dashboard` 엔드포인트 추가
   - client_dashboard.jsp 연결

4. **Tomcat 재실행**
   - 모든 서비스 정상 작동 확인

---

## ⚡ 다음 할 일 (TODO)

- [ ] 사용자 인증 시스템 통합 (로그인/로그아웃)
- [ ] 세션 기반 대시보드 라우팅
- [ ] 계약 정보 DB 저장 기능
- [ ] 프로젝트 생성/수정 기능
- [ ] 파일 업로드 기능 (PDF 저장)
- [ ] 실제 AI 계약 분석 통합

---

**작성일**: 2026-01-14  
**Tomcat 포트**: 9999  
**데이터베이스**: MySQL 8.0 (192.168.0.56:3306)
