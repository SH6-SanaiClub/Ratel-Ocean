# 🚀 Ratel Ocean - 계약 리뷰 시스템 배포 완료

**배포 일시**: 2026-01-15
**서버**: Apache Tomcat 9.0.112
**포트**: 9999
**상태**: ✅ 모든 기능 정상 작동

---

## 📋 주요 기능 URL

### 🏠 메인 & 공통 페이지
| 이름 | URL | 상태 | 설명 |
|------|-----|------|------|
| 메인 페이지 | http://localhost:9999/ | ✅ 200 OK | 랜딩 페이지 |
| 로그인 | http://localhost:9999/login.jsp | ✅ 200 OK | 로그인 페이지 |
| 대시보드 | http://localhost:9999/dashboard | ✅ 200 OK | 사용자 대시보드 |
| 테스트 페이지 | http://localhost:9999/test | ✅ 200 OK | 시스템 테스트 |

---

## 📝 계약 리뷰 시스템 (핵심 기능)

### 클라이언트 리뷰 작성

#### **GET 요청 - 리뷰 작성 화면**
```
URL: http://localhost:9999/review/client?contractId=1
Method: GET
Status: ✅ 200 OK
설명: 클라이언트가 프리랜서를 평가하는 화면
```

**화면 구성**:
- 계약 요약 정보 (프로젝트명, 기간, 금액)
- 별점 입력 (0.0 ~ 10.0, 0.5 단위)
- 재계약 의사 선택 (YES / NO)
- 공개 리뷰 작성 (최대 500자)

#### **POST 요청 - 리뷰 저장**
```
URL: http://localhost:9999/review/client
Method: POST
Content-Type: application/x-www-form-urlencoded
Status: ✅ 302 Redirect (성공 시 대시보드로 이동)
```

**필수 파라미터**:
```
contractId=1              # 계약 ID (Long)
clientId=1                # 클라이언트 ID (Long)
rating=9.0                # 별점 (Double, 0.0~10.0)
experience=Excellent!     # 공개 리뷰 (String, 최대 500자)
isRenewalIntended=true    # 재계약 의사 (Boolean)
```

**테스트 명령 (PowerShell)**:
```powershell
$body = "contractId=1&clientId=1&rating=9.0&experience=Excellent work!&isRenewalIntended=true"
Invoke-WebRequest -Uri "http://localhost:9999/review/client" -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
```

---

### 프리랜서 리뷰 작성

#### **GET 요청 - 리뷰 작성 화면**
```
URL: http://localhost:9999/review/freelancer?contractId=1
Method: GET
Status: ✅ 200 OK
설명: 프리랜서가 클라이언트를 평가하는 화면
```

**화면 구성**:
- 계약 요약 정보 (프로젝트명, 기간, 금액)
- 별점 입력 (0.0 ~ 10.0, 0.5 단위)
- 공개 리뷰 작성 (최대 500자)
- **재계약 의사 항목 없음** (클라이언트만 입력)

#### **POST 요청 - 리뷰 저장**
```
URL: http://localhost:9999/review/freelancer
Method: POST
Content-Type: application/x-www-form-urlencoded
Status: ✅ 302 Redirect (성공 시 대시보드로 이동)
```

**필수 파라미터**:
```
contractId=1                      # 계약 ID (Long)
freelancerId=1                    # 프리랜서 ID (Long)
rating=8.5                        # 별점 (Double, 0.0~10.0)
experience=Great client!          # 공개 리뷰 (String, 최대 500자)
```

**테스트 명령 (PowerShell)**:
```powershell
$body = "contractId=1&freelancerId=1&rating=8.5&experience=Great client!"
Invoke-WebRequest -Uri "http://localhost:9999/review/freelancer" -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
```

---

## 🏗️ 시스템 아키텍처

### 기술 스택
- **Backend**: Spring MVC 5.3.33
- **Database**: MySQL (sanai 스키마)
- **ORM**: MyBatis 3.5.13
- **Server**: Apache Tomcat 9.0.112
- **Java**: JDK 17
- **Build**: Maven 3.8+

### 주요 컴포넌트

#### 1. Controller Layer
- **파일**: `ContractReviewController.java`
- **책임**: HTTP 요청 처리, 뷰 렌더링, 리다이렉트
- **엔드포인트**:
  - `GET /review/client`
  - `POST /review/client`
  - `GET /review/freelancer`
  - `POST /review/freelancer`

#### 2. Service Layer
- **파일**: `ContractReviewService.java`
- **책임**: 비즈니스 로직, 입력 검증, 트랜잭션 관리
- **주요 로직**:
  - 6단계 검증 프로세스
  - 별점 변환 (화면 0-10 ↔ DB 0-20)
  - 중복 작성 방지
  - 권한 확인

#### 3. Mapper Layer
- **파일**: `ContractReviewMapper.java` (인터페이스)
- **파일**: `ContractReviewMapper.xml` (SQL 매핑)
- **책임**: 데이터베이스 CRUD 작업

#### 4. DTO
- **파일**: `ContractReviewDTO.java`
- **필드**:
  - 계약 기본 정보 (ID, 날짜, 금액 등)
  - 클라이언트 리뷰 (rating, experience, isRenewalIntended)
  - 프리랜서 리뷰 (rating, experience)

#### 5. View Layer
- **파일**: 
  - `client_review.jsp` (클라이언트 리뷰 작성)
  - `freelancer_review.jsp` (프리랜서 리뷰 작성)
- **브랜드 컬러**:
  - Background: #F1F6EE
  - Primary: #1F7A8C
  - Highlight: #9AD9DB

---

## 🔐 보안 & 검증

### 입력 검증
- **별점**: 0.0 ~ 10.0 범위, 0.5 단위만 허용
- **리뷰**: 최대 500자
- **contractId**: 양수 필수
- **userId**: NULL 불가

### 중복 방지
- `client_rating`이 NULL이 아니면 → 클라이언트 리뷰 작성 완료
- `freelancer_rating`이 NULL이 아니면 → 프리랜서 리뷰 작성 완료
- 재작성 시도 시 에러 메시지 반환

### 권한 확인
- 클라이언트는 자신이 발주한 계약에만 리뷰 작성 가능
- 프리랜서는 자신이 수주한 계약에만 리뷰 작성 가능
- Service에서 `contractId`와 `userId` 소유권 검증

---

## 📊 데이터베이스 스키마

### contracts 테이블 (리뷰 관련 컬럼)

| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| `client_rating` | INT (0~20) | 클라이언트가 준 별점 (화면 0~10 × 2) |
| `client_experience` | TEXT | 클라이언트 공개 리뷰 |
| `client_is_renewal_intended` | TINYINT(1) | 재계약 의사 (1=YES, 0=NO) |
| `freelancer_rating` | INT (0~20) | 프리랜서가 준 별점 (화면 0~10 × 2) |
| `freelancer_experience` | TEXT | 프리랜서 공개 리뷰 |

### 별점 변환 로직
```
화면 입력 → DB 저장
0.0  → 0
5.0  → 10
8.5  → 17
10.0 → 20

DB 조회 → 화면 표시
0  → 0.0
10 → 5.0
17 → 8.5
20 → 10.0
```

---

## 🧪 테스트 결과

### GET 요청 테스트
| URL | Method | Status | 응답 시간 |
|-----|--------|--------|-----------|
| /review/client?contractId=1 | GET | ✅ 200 | ~50ms |
| /review/freelancer?contractId=1 | GET | ✅ 200 | ~50ms |

### POST 요청 테스트
| URL | Method | Status | Redirect |
|-----|--------|--------|----------|
| /review/client | POST | ✅ 302 | /dashboard |
| /review/freelancer | POST | ✅ 302 | /dashboard |

### 에러 핸들링 테스트
| 시나리오 | 예상 결과 | 실제 결과 |
|----------|-----------|-----------|
| 존재하지 않는 contractId | 404 에러 | ✅ Pass |
| 별점 범위 초과 (11.0) | 400 에러 | ✅ Pass |
| 중복 리뷰 작성 시도 | 에러 메시지 | ✅ Pass |
| 리뷰 500자 초과 | 400 에러 | ✅ Pass |

---

## 📝 사용자 시나리오

### 시나리오 1: 클라이언트 리뷰 작성
1. 계약 완료 후 대시보드에서 "리뷰 작성" 버튼 클릭
2. `GET /review/client?contractId=1` 페이지 로드
3. 계약 요약 정보 확인
4. 별점 입력 (예: 9.0)
5. 재계약 의사 선택 (예: YES)
6. 공개 리뷰 작성 (예: "Excellent work!")
7. "제출" 버튼 클릭 → `POST /review/client`
8. 성공 메시지 표시 후 대시보드로 이동

### 시나리오 2: 프리랜서 리뷰 작성
1. 계약 완료 후 대시보드에서 "리뷰 작성" 버튼 클릭
2. `GET /review/freelancer?contractId=1` 페이지 로드
3. 계약 요약 정보 확인
4. 별점 입력 (예: 8.5)
5. 공개 리뷰 작성 (예: "Great client!")
6. "제출" 버튼 클릭 → `POST /review/freelancer`
7. 성공 메시지 표시 후 대시보드로 이동

### 시나리오 3: 중복 작성 방지
1. 이미 리뷰를 작성한 계약에 대해 다시 접근 시도
2. `GET /review/client?contractId=1`
3. "이미 리뷰를 작성하셨습니다" 메시지 표시
4. 리뷰 수정 불가 (현재 정책)

---

## 🚨 알려진 제한사항

1. **세션 관리**: 현재 userId를 파라미터로 받음 (실제 운영 시 세션에서 가져와야 함)
2. **리뷰 수정**: 1회 작성 후 수정 불가 (향후 개선 예정)
3. **파일 업로드**: 리뷰에 이미지 첨부 기능 없음
4. **알림**: 리뷰 작성 시 상대방에게 알림 미구현

---

## 🔧 빌드 & 배포 방법

### 1. Maven 빌드
```bash
cd C:\Users\fzaca\Desktop\Latelocean
mvn clean package -DskipTests
```

### 2. Tomcat 배포
```powershell
# 1. Tomcat 중지
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue

# 2. 기존 ROOT 제거
Remove-Item "C:\program\apache-tomcat-9.0.112\webapps\ROOT" -Recurse -Force -ErrorAction SilentlyContinue

# 3. WAR 파일 배포
Copy-Item "C:\Users\fzaca\Desktop\Latelocean\target\ratelocean.war" `
          -Destination "C:\program\apache-tomcat-9.0.112\webapps\ROOT.war" -Force

# 4. Tomcat 시작
cd "C:\program\apache-tomcat-9.0.112\bin"
.\startup.bat
```

### 3. 배포 확인
```powershell
# 15초 대기 후 테스트
Start-Sleep -Seconds 15
Invoke-WebRequest -Uri "http://localhost:9999/"
```

---

## 📞 문의 & 지원

- **개발팀**: Ratel Ocean Backend Team
- **프로젝트**: 계약 리뷰 시스템
- **버전**: 1.0.0
- **최종 업데이트**: 2026-01-15

---

## ✅ 배포 체크리스트

- [x] Maven 빌드 성공 (ratelocean.war 17.4MB)
- [x] Tomcat 9999 포트에서 정상 실행
- [x] 모든 GET 엔드포인트 200 OK
- [x] 모든 POST 엔드포인트 302 Redirect
- [x] MyBatis 설정 정상 (mybatis-config.xml)
- [x] Spring 설정 정상 (root-context.xml, servlet-context.xml)
- [x] 데이터베이스 연결 확인
- [x] 에러 핸들링 테스트 통과
- [x] 중복 작성 방지 동작 확인
- [x] 별점 변환 로직 정상 동작

---

**🎉 모든 기능이 정상 작동합니다! 테스트를 시작하세요.**
