# SANAI DATABASE 전체 스키마 문서

**생성일시**: 2026-01-16 11:04:14

## 🔎 이번 검토 메모 (2026-01-16 재검토)

- 데이터 출처: sanai_schema.txt (MySQL 8.0.44, INFORMATION_SCHEMA 기반)
- 점검 결과: 테이블 26개 / 레코드 153건 / 외래키 33개 / 트리거 6개 / ENUM 12개 값 확인
- 상태 ENUM 정합: projects.status = READY/IN_PROGRESS/CLOSED, contracts.status = SIGNED/TERMINATED/COMPLETED
- 삭제 방지 트리거: users 테이블 BEFORE DELETE 시 소프트 딜리트 안내 트리거 정상 동작
- wallet_histories BI/AI 트리거의 잔액·합산 로직과 오류 처리(잘못된 io_type, 음수 금액) 검증 완료

## 📊 데이터베이스 기본 정보

- **데이터베이스명**: sanai
- **MySQL 버전**: 8.0.44
- **문자셋**: utf8mb4

- **총 테이블 수**: 26개

- **총 레코드 수**: 153건

---

## 📑 목차

1. [테이블 목록 및 레코드 수](#테이블-목록-및-레코드-수)
2. [테이블별 상세 스키마](#테이블별-상세-스키마)
3. [외래키 제약조건](#외래키-제약조건)
4. [인덱스 정보](#인덱스-정보)
5. [트리거 정보](#트리거-정보)
6. [ENUM 타입 정보](#enum-타입-정보)
7. [데이터베이스 ERD 관계](#데이터베이스-erd-관계)

---

## 테이블 목록 및 레코드 수

| 번호 | 테이블명 | 레코드 수 | 설명 |
|------|----------|-----------|------|
| 1 | `accounts` | 0 | 은행 계좌 정보 |
| 2 | `admins` | 0 | 관리자 계정 |
| 3 | `chat_rooms` | 1 | 채팅방 |
| 4 | `client_profiles` | 0 | 클라이언트 프로필 |
| 5 | `companies` | 0 | 기업 정보 |
| 6 | `contract_milestones` | 0 | 계약 마일스톤 |
| 7 | `contracts` | 3 | 계약 정보 |
| 8 | `freelancer_careers` | 0 | 프리랜서 경력 |
| 9 | `freelancer_portfolios` | 0 | 프리랜서 포트폴리오 |
| 10 | `freelancer_profiles` | 0 | 프리랜서 프로필 |
| 11 | `freelancer_project_experiences` | 0 | 프리랜서 프로젝트 경험 |
| 12 | `freelancer_skills` | 0 | 프리랜서 기술 |
| 13 | `freelancer_wallets` | 0 | 프리랜서 지갑 |
| 14 | `messages` | 3 | 채팅 메시지 |
| 15 | `milestone_histories` | 0 | 마일스톤 변경 이력 |
| 16 | `project_applications` | 3 | 프로젝트 지원서 |
| 17 | `project_bookmarks` | 0 | 프로젝트 북마크 |
| 18 | `project_freelancer_stacks` | 0 | 지원서별 기술스택 |
| 19 | `project_stacks` | 0 | 프로젝트 요구 기술 |
| 20 | `projects` | 3 | 프로젝트 정보 |
| 21 | `queue_matchings` | 0 | 큐 매칭 정보 |
| 22 | `queue_stacks` | 0 | 큐 기술스택 |
| 23 | `queues` | 0 | 프리랜서 대기 큐 |
| 24 | `stacks` | 132 | 기술 스택 마스터 |
| 25 | `users` | 8 | 사용자 정보 |
| 26 | `wallet_histories` | 0 | 지갑 입출금 이력 |

---

## 테이블별 상세 스키마

### 📋 accounts

**설명**: 은행 계좌 정보

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `account_id` | bigint | NO | PRI |  | auto_increment |
| `user_id` | bigint | NO | MUL |  |  |
| `bank_name` | varchar(50) | NO |  |  |  |
| `account_holder` | varchar(50) | NO |  |  |  |
| `account_number` | varchar(50) | NO |  |  |  |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 admins

**설명**: 관리자 계정

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `admin_id` | bigint | NO | PRI |  | auto_increment |
| `login_id` | varchar(50) | NO | UNI |  |  |
| `email` | varchar(100) | NO | UNI |  |  |
| `password` | varchar(255) | NO |  |  |  |
| `refresh_token` | varchar(512) | YES |  |  |  |
| `name` | varchar(50) | NO |  |  |  |
| `role` | enum('SUPER_ADMIN','ADMIN') | NO |  | ADMIN |  |
| `status` | enum('ACTIVE','INACTIVE') | NO |  | ACTIVE |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 chat_rooms

**설명**: 채팅방

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `room_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `project_id` | bigint | NO | MUL |  |  |
| `is_active` | tinyint(1) | NO |  | 1 |  |
| `last_message_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 1건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 client_profiles

**설명**: 클라이언트 프로필

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `client_id` | bigint | NO | PRI |  |  |
| `company_id` | bigint | YES | MUL |  |  |
| `client_type` | enum('GENERAL','PERSONAL','CORPORATION') | NO |  | GENERAL |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 companies

**설명**: 기업 정보

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `company_id` | bigint | NO | PRI |  | auto_increment |
| `company_name` | varchar(100) | NO |  |  |  |
| `ceo_name` | varchar(50) | NO |  |  |  |
| `ceo_email` | varchar(255) | YES |  |  |  |
| `business_number` | varchar(50) | NO | UNI |  |  |
| `business_verified` | tinyint(1) | NO |  | 0 |  |
| `industry` | varchar(100) | YES |  |  |  |
| `address` | varchar(300) | YES |  |  |  |
| `company_size` | enum('STARTUP','SMALL','MEDIUM','LARGE','ENTERPRISE') | YES |  |  |  |
| `website_url` | varchar(500) | YES |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 contract_milestones

**설명**: 계약 마일스톤

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `milestone_id` | bigint | NO | PRI |  | auto_increment |
| `contract_id` | bigint | NO | MUL |  |  |
| `step_order` | int | NO |  |  |  |
| `milestone_name` | varchar(100) | NO |  |  |  |
| `work_scope` | text | YES |  |  |  |
| `amount` | bigint | NO |  |  |  |
| `due_date` | date | YES |  |  |  |
| `status` | enum('WAITING','DEPOSITED','REQUESTED','PAID','CANCELED') | NO |  | WAITING |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 contracts

**설명**: 계약 정보

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `contract_id` | bigint | NO | PRI |  |  |
| `total_budget` | bigint | NO |  |  |  |
| `payment_method` | varchar(50) | NO |  |  |  |
| `contract_start_date` | date | NO |  |  |  |
| `contract_end_date` | date | NO |  |  |  |
| `contract_status` | enum('SIGNED','TERMINATED','COMPLETED') | NO |  | SIGNED |  |
| `origin_contract_url` | varchar(2048) | YES |  |  |  |
| `platform_contract_url` | varchar(2048) | YES |  |  |  |
| `ai_report_url` | varchar(2048) | YES |  |  |  |
| `contracted_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `completed_at` | datetime | YES |  |  |  |
| `cancel_reason` | text | YES |  |  |  |
| `client_rating` | int | YES |  |  |  |
| `client_experience` | text | YES |  |  |  |
| `client_is_renewal_intended` | tinyint(1) | YES |  |  |  |
| `freelancer_rating` | int | YES |  |  |  |
| `freelancer_experience` | text | YES |  |  |  |

**통계**: 레코드 3건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 freelancer_careers

**설명**: 프리랜서 경력

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `career_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `company_name` | varchar(100) | NO |  |  |  |
| `role` | varchar(100) | NO |  |  |  |
| `position` | varchar(100) | NO |  |  |  |
| `start_date` | date | NO |  |  |  |
| `end_date` | date | YES |  |  |  |
| `description` | text | YES |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 freelancer_portfolios

**설명**: 프리랜서 포트폴리오

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `portfolio_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `title` | varchar(255) | NO |  |  |  |
| `description` | text | YES |  |  |  |
| `portfolio_url` | varchar(2048) | NO |  |  |  |
| `file_size` | bigint | NO |  | 0 |  |
| `is_public` | tinyint(1) | NO |  | 1 |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 freelancer_profiles

**설명**: 프리랜서 프로필

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `user_id` | bigint | NO | PRI |  |  |
| `nickname` | varchar(50) | NO | UNI |  |  |
| `introduction` | text | YES |  |  |  |
| `github_url` | varchar(500) | YES |  |  |  |
| `website_url` | varchar(500) | YES |  |  |  |
| `school_name` | varchar(100) | YES |  |  |  |
| `major` | varchar(100) | YES |  |  |  |
| `degree` | varchar(50) | YES |  |  |  |
| `grad_status` | varchar(50) | YES |  |  |  |
| `is_profile_complete` | tinyint(1) | NO |  | 0 |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 freelancer_project_experiences

**설명**: 프리랜서 프로젝트 경험

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `experience_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `title` | varchar(200) | NO |  |  |  |
| `client_name` | varchar(100) | YES |  |  |  |
| `start_date` | date | NO |  |  |  |
| `end_date` | date | YES |  |  |  |
| `role` | varchar(100) | NO |  |  |  |
| `description` | text | YES |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 freelancer_skills

**설명**: 프리랜서 기술

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `freelancer_stack_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `stack_id` | bigint | NO | MUL |  |  |
| `stack_level` | int | NO |  | 1 |  |
| `stack_year` | int | NO |  | 0 |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 freelancer_wallets

**설명**: 프리랜서 지갑

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `wallet_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | UNI |  |  |
| `account_id` | bigint | NO | MUL |  |  |
| `balance` | bigint | NO |  | 0 |  |
| `total_earned` | bigint | NO |  | 0 |  |
| `wallet_pw` | varchar(255) | NO |  |  |  |
| `version` | int | NO |  | 0 |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 messages

**설명**: 채팅 메시지

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `message_id` | bigint | NO | PRI |  | auto_increment |
| `room_id` | bigint | NO | MUL |  |  |
| `sender_id` | bigint | NO | MUL |  |  |
| `content` | text | NO |  |  |  |
| `file_name` | varchar(255) | YES |  |  |  |
| `file_url` | varchar(2048) | YES |  |  |  |
| `file_size` | bigint | YES |  |  |  |
| `is_read` | tinyint(1) | NO |  | 0 |  |
| `is_deleted` | tinyint(1) | NO |  | 0 |  |
| `deleted_at` | datetime | YES |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 3건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 milestone_histories

**설명**: 마일스톤 변경 이력

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `milestone_history_id` | bigint | NO | PRI |  | auto_increment |
| `milestone_id` | bigint | NO | MUL |  |  |
| `action_type` | varchar(50) | NO |  |  |  |
| `prev_value` | text | YES |  |  |  |
| `curr_value` | text | NO |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 project_applications

**설명**: 프로젝트 지원서

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `application_id` | bigint | NO | PRI |  | auto_increment |
| `project_id` | bigint | NO | MUL |  |  |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `is_contracted` | tinyint(1) | NO |  | 0 |  |
| `applied_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 3건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 project_bookmarks

**설명**: 프로젝트 북마크

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `bookmark_id` | bigint | NO | PRI |  | auto_increment |
| `project_id` | bigint | NO | MUL |  |  |
| `user_id` | bigint | NO | MUL |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 project_freelancer_stacks

**설명**: 지원서별 기술스택

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `project_freelancer_stack_id` | bigint | NO | PRI |  | auto_increment |
| `application_id` | bigint | NO | MUL |  |  |
| `stack_id` | bigint | NO | MUL |  |  |
| `is_primary` | tinyint(1) | NO |  | 0 |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 project_stacks

**설명**: 프로젝트 요구 기술

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `project_stack_id` | bigint | NO | PRI |  | auto_increment |
| `project_id` | bigint | NO | MUL |  |  |
| `stack_id` | bigint | NO | MUL |  |  |
| `stack_level` | int | YES |  |  |  |
| `stack_year` | int | NO |  | 0 |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 projects

**설명**: 프로젝트 정보

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `project_id` | bigint | NO | PRI |  | auto_increment |
| `client_id` | bigint | NO | MUL |  |  |
| `title` | varchar(255) | NO |  |  |  |
| `description` | text | NO |  |  |  |
| `start_date` | date | NO |  |  |  |
| `deadline_date` | date | NO |  |  |  |
| `est_duration` | varchar(50) | NO |  |  |  |
| `budget` | bigint | NO |  |  |  |
| `communicate_method` | varchar(50) | NO |  |  |  |
| `payment_method` | varchar(50) | NO |  |  |  |
| `change_policy` | text | YES |  |  |  |
| `max_revision_count` | int | NO |  | 0 |  |
| `project_status` | enum('READY','IN_PROGRESS','CLOSED') | NO | MUL | READY |  |
| `is_public` | tinyint(1) | NO |  | 1 |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |
| `view_count` | int | NO |  | 0 |  |
| `applicant_count` | int | NO |  | 0 |  |
| `plan_url` | varchar(2048) | YES |  |  |  |
| `file_size` | varchar(200) | YES |  |  |  |
| `budget_negotiable` | tinyint(1) | NO |  | 0 |  |
| `duration_negotiable` | tinyint(1) | NO |  | 0 |  |

**통계**: 레코드 3건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 queue_matchings

**설명**: 큐 매칭 정보

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `matching_id` | bigint | NO | PRI |  | auto_increment |
| `queue_id` | bigint | NO | MUL |  |  |
| `project_id` | bigint | NO | MUL |  |  |
| `status` | enum('PENDING','ACCEPTED','REJECTED','EXPIRED') | NO |  | PENDING |  |
| `matched_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 queue_stacks

**설명**: 큐 기술스택

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `queue_stack_id` | bigint | NO | PRI |  | auto_increment |
| `queue_id` | bigint | NO | MUL |  |  |
| `stack_id` | bigint | NO | MUL |  |  |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 queues

**설명**: 프리랜서 대기 큐

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `queue_id` | bigint | NO | PRI |  | auto_increment |
| `freelancer_id` | bigint | NO | MUL |  |  |
| `queue_name` | varchar(100) | NO |  |  |  |
| `min_budget` | int | NO |  |  |  |
| `max_budget` | int | NO |  |  |  |
| `expected_duration` | varchar(20) | NO |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 stacks

**설명**: 기술 스택 마스터

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `stack_id` | bigint | NO | PRI |  | auto_increment |
| `stack_name` | varchar(50) | NO | UNI |  |  |
| `category` | enum('SKILL','POSITION') | NO | MUL | SKILL |  |

**통계**: 레코드 132건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 users

**설명**: 사용자 정보

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `user_id` | bigint | NO | PRI |  | auto_increment |
| `login_id` | varchar(50) | NO | UNI |  |  |
| `email` | varchar(100) | NO | UNI |  |  |
| `password` | varchar(255) | NO |  |  |  |
| `refresh_token` | varchar(512) | YES |  |  |  |
| `user_type` | enum('FREELANCER','CLIENT') | NO |  |  |  |
| `name` | varchar(50) | NO |  |  |  |
| `phone` | varchar(20) | NO |  |  |  |
| `birth_date` | date | NO |  |  |  |
| `profile_image_url` | varchar(500) | YES |  |  |  |
| `status` | enum('ACTIVE','INACTIVE','SUSPENDED') | NO |  | ACTIVE |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
| `updated_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

**통계**: 레코드 8건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

### 📋 wallet_histories

**설명**: 지갑 입출금 이력

| 컬럼명 | 타입 | NULL | KEY | DEFAULT | EXTRA |
|--------|------|------|-----|---------|-------|
| `wallet_history_id` | bigint | NO | PRI |  | auto_increment |
| `wallet_id` | bigint | NO | MUL |  |  |
| `io_type` | enum('DEPOSIT','WITHDRAWAL','PAYMENT','REFUND') | NO |  |  |  |
| `amount` | bigint | NO |  |  |  |
| `balance` | bigint | NO |  |  |  |
| `summary` | varchar(255) | NO |  |  |  |
| `created_at` | datetime | NO |  | CURRENT_TIMESTAMP | DEFAULT_GENERATED |

**통계**: 레코드 0건 | 엔진: InnoDB | 콜레이션: utf8mb4_0900_ai_ci

---

## 외래키 제약조건

| 제약조건명 | 테이블 | 컬럼 | 참조 테이블 | 참조 컬럼 |
|-----------|--------|------|------------|----------|
| `fk_account_user` | `accounts` | `user_id` | `users` | `user_id` |
| `fk_chatroom_freelancer` | `chat_rooms` | `freelancer_id` | `users` | `user_id` |
| `fk_chatroom_project` | `chat_rooms` | `project_id` | `projects` | `project_id` |
| `fk_client_profile_company` | `client_profiles` | `company_id` | `companies` | `company_id` |
| `fk_client_profile_user` | `client_profiles` | `client_id` | `users` | `user_id` |
| `fk_milestone_contract` | `contract_milestones` | `contract_id` | `contracts` | `contract_id` |
| `fk_contract_application` | `contracts` | `contract_id` | `project_applications` | `application_id` |
| `fk_career_user` | `freelancer_careers` | `freelancer_id` | `users` | `user_id` |
| `fk_portfolio_user` | `freelancer_portfolios` | `freelancer_id` | `users` | `user_id` |
| `fk_freelancer_profile_user` | `freelancer_profiles` | `user_id` | `users` | `user_id` |
| `fk_exp_user` | `freelancer_project_experiences` | `freelancer_id` | `users` | `user_id` |
| `fk_fs_stack` | `freelancer_skills` | `stack_id` | `stacks` | `stack_id` |
| `fk_fs_user` | `freelancer_skills` | `freelancer_id` | `users` | `user_id` |
| `fk_wallet_account` | `freelancer_wallets` | `account_id` | `accounts` | `account_id` |
| `fk_wallet_user` | `freelancer_wallets` | `freelancer_id` | `users` | `user_id` |
| `fk_message_room` | `messages` | `room_id` | `chat_rooms` | `room_id` |
| `fk_message_sender` | `messages` | `sender_id` | `users` | `user_id` |
| `fk_mh_milestone` | `milestone_histories` | `milestone_id` | `contract_milestones` | `milestone_id` |
| `fk_app_freelancer` | `project_applications` | `freelancer_id` | `users` | `user_id` |
| `fk_app_project` | `project_applications` | `project_id` | `projects` | `project_id` |
| `fk_bookmark_project` | `project_bookmarks` | `project_id` | `projects` | `project_id` |
| `fk_bookmark_user` | `project_bookmarks` | `user_id` | `users` | `user_id` |
| `fk_pfstack_application` | `project_freelancer_stacks` | `application_id` | `project_applications` | `application_id` |
| `fk_pfstack_stack` | `project_freelancer_stacks` | `stack_id` | `stacks` | `stack_id` |
| `fk_pstack_project` | `project_stacks` | `project_id` | `projects` | `project_id` |
| `fk_pstack_stack` | `project_stacks` | `stack_id` | `stacks` | `stack_id` |
| `fk_project_client` | `projects` | `client_id` | `users` | `user_id` |
| `fk_matchings_project` | `queue_matchings` | `project_id` | `projects` | `project_id` |
| `fk_matchings_queue` | `queue_matchings` | `queue_id` | `queues` | `queue_id` |
| `fk_qstack_queue` | `queue_stacks` | `queue_id` | `queues` | `queue_id` |
| `fk_qstack_stack` | `queue_stacks` | `stack_id` | `stacks` | `stack_id` |
| `fk_queues_freelancer` | `queues` | `freelancer_id` | `users` | `user_id` |
| `fk_wallet_history_wallet` | `wallet_histories` | `wallet_id` | `freelancer_wallets` | `wallet_id` |

**총 33개의 외래키 제약조건**

---

## 인덱스 정보

### accounts

- 🔑 UNIQUE: `PRIMARY` (account_id)
- 📇 INDEX: `idx_accounts_user` (user_id)

### admins

- 🔑 UNIQUE: `PRIMARY` (admin_id)
- 🔑 UNIQUE: `uk_admins_login_id` (login_id)
- 🔑 UNIQUE: `uk_admins_email` (email)

### chat_rooms

- 🔑 UNIQUE: `PRIMARY` (room_id)
- 📇 INDEX: `idx_rooms_project` (project_id, last_message_at)
- 📇 INDEX: `fk_chatroom_freelancer` (freelancer_id)

### client_profiles

- 🔑 UNIQUE: `PRIMARY` (client_id)
- 📇 INDEX: `fk_client_profile_company` (company_id)

### companies

- 🔑 UNIQUE: `PRIMARY` (company_id)
- 🔑 UNIQUE: `uk_companies_business_number` (business_number)

### contract_milestones

- 🔑 UNIQUE: `PRIMARY` (milestone_id)
- 🔑 UNIQUE: `uk_contract_step` (contract_id, step_order)
- 📇 INDEX: `idx_milestone_contract` (contract_id, status)

### contracts

- 🔑 UNIQUE: `PRIMARY` (contract_id)

### freelancer_careers

- 🔑 UNIQUE: `PRIMARY` (career_id)
- 📇 INDEX: `idx_career_freelancer` (freelancer_id, start_date)

### freelancer_portfolios

- 🔑 UNIQUE: `PRIMARY` (portfolio_id)
- 📇 INDEX: `idx_portfolio_freelancer` (freelancer_id, created_at)

### freelancer_profiles

- 🔑 UNIQUE: `PRIMARY` (user_id)
- 🔑 UNIQUE: `uk_freelancer_nickname` (nickname)

### freelancer_project_experiences

- 🔑 UNIQUE: `PRIMARY` (experience_id)
- 📇 INDEX: `idx_exp_freelancer` (freelancer_id, start_date)

### freelancer_skills

- 🔑 UNIQUE: `PRIMARY` (freelancer_stack_id)
- 🔑 UNIQUE: `uk_freelancer_stack` (freelancer_id, stack_id)
- 📇 INDEX: `idx_fs_freelancer` (freelancer_id)
- 📇 INDEX: `idx_fs_stack` (stack_id)

### freelancer_wallets

- 🔑 UNIQUE: `PRIMARY` (wallet_id)
- 🔑 UNIQUE: `uk_wallet_freelancer` (freelancer_id)
- 📇 INDEX: `idx_wallet_account` (account_id)

### messages

- 🔑 UNIQUE: `PRIMARY` (message_id)
- 📇 INDEX: `idx_message_room_date` (room_id, created_at)
- 📇 INDEX: `fk_message_sender` (sender_id)

### milestone_histories

- 🔑 UNIQUE: `PRIMARY` (milestone_history_id)
- 📇 INDEX: `idx_mh_milestone` (milestone_id, created_at)

### project_applications

- 🔑 UNIQUE: `PRIMARY` (application_id)
- 🔑 UNIQUE: `uk_application_duplicate` (project_id, freelancer_id)
- 📇 INDEX: `idx_app_project` (project_id, applied_at)
- 📇 INDEX: `idx_app_freelancer` (freelancer_id, applied_at)

### project_bookmarks

- 🔑 UNIQUE: `PRIMARY` (bookmark_id)
- 🔑 UNIQUE: `uk_bookmark_unique` (project_id, user_id)
- 📇 INDEX: `idx_bookmark_user_time` (user_id, created_at)

### project_freelancer_stacks

- 🔑 UNIQUE: `PRIMARY` (project_freelancer_stack_id)
- 🔑 UNIQUE: `uk_application_stack` (application_id, stack_id)
- 📇 INDEX: `fk_pfstack_stack` (stack_id)

### project_stacks

- 🔑 UNIQUE: `PRIMARY` (project_stack_id)
- 🔑 UNIQUE: `uk_project_stack` (project_id, stack_id)
- 📇 INDEX: `idx_pstack_project` (project_id)
- 📇 INDEX: `idx_pstack_stack` (stack_id)

### projects

- 🔑 UNIQUE: `PRIMARY` (project_id)
- 📇 INDEX: `idx_projects_status_date` (project_status, created_at)
- 📇 INDEX: `idx_projects_client` (client_id)

### queue_matchings

- 🔑 UNIQUE: `PRIMARY` (matching_id)
- 🔑 UNIQUE: `uq_queue_project` (queue_id, project_id)
- 📇 INDEX: `idx_matchings_queue_time` (queue_id, matched_at)
- 📇 INDEX: `idx_matchings_project_status` (project_id, status)

### queue_stacks

- 🔑 UNIQUE: `PRIMARY` (queue_stack_id)
- 🔑 UNIQUE: `uk_queue_stack` (queue_id, stack_id)
- 📇 INDEX: `fk_qstack_stack` (stack_id)

### queues

- 🔑 UNIQUE: `PRIMARY` (queue_id)
- 🔑 UNIQUE: `uq_queue_name_per_freelancer` (freelancer_id, queue_name)
- 📇 INDEX: `idx_queues_freelancer_created` (freelancer_id, created_at)

### stacks

- 🔑 UNIQUE: `PRIMARY` (stack_id)
- 🔑 UNIQUE: `uk_stacks_name` (stack_name)
- 📇 INDEX: `idx_stacks_category` (category)

### users

- 🔑 UNIQUE: `PRIMARY` (user_id)
- 🔑 UNIQUE: `uk_users_login_id` (login_id)
- 🔑 UNIQUE: `uk_users_email` (email)

### wallet_histories

- 🔑 UNIQUE: `PRIMARY` (wallet_history_id)
- 📇 INDEX: `idx_history_wallet_time` (wallet_id, created_at)

---

## 트리거 정보

### ⚡ trg_messages_ai

- **테이블**: `messages`
- **이벤트**: AFTER INSERT
- **실행문**:

```sql
BEGIN
    UPDATE chat_rooms
       SET last_message_at = NEW.created_at
     WHERE room_id = NEW.room_id;
END
```

### ⚡ trg_project_applications_ai

- **테이블**: `project_applications`
- **이벤트**: AFTER INSERT
- **실행문**:

```sql
BEGIN
    UPDATE projects
       SET applicant_count = applicant_count + 1
     WHERE project_id = NEW.project_id;
END
```

### ⚡ trg_project_applications_ad

- **테이블**: `project_applications`
- **이벤트**: AFTER DELETE
- **실행문**:

```sql
BEGIN
    UPDATE projects
       SET applicant_count = GREATEST(applicant_count - 1, 0)
     WHERE project_id = OLD.project_id;
END
```

### ⚡ trg_users_block_delete

- **테이블**: `users`
- **이벤트**: BEFORE DELETE
- **실행문**:

```sql
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'users는 물리 삭제 불가. status로 소프트 딜리트 하세요.';
END
```

### ⚡ trg_wallet_histories_bi

- **테이블**: `wallet_histories`
- **이벤트**: BEFORE INSERT
- **실행문**:

```sql
BEGIN
    DECLARE v_balance BIGINT;

    -- (A) 현재 잔액 조회 + 지갑 행 잠금(FOR UPDATE)
    SELECT balance
      INTO v_balance
      FROM freelancer_wallets
     WHERE wallet_id = NEW.wallet_id
     FOR UPDATE;

    -- (B) 지갑 존재 여부 검증
    IF v_balance IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid wallet_id: wallet not found';
    END IF;

    -- (C) amount 양수 검증
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Amount must be positive';
    END IF;

    -- (D) 유형별 잔액 반영 + NEW.balance 스냅샷 계산
    IF NEW.io_type IN ('DEPOSIT','PAYMENT','REFUND') THEN
        SET NEW.balance = v_balance + NEW.amount;

    ELSEIF NEW.io_type = 'WITHDRAWAL' THEN
        IF v_balance < NEW.amount THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Insufficient balance';
        END IF;
        SET NEW.balance = v_balance - NEW.amount;

    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid io_type';
    END IF;
END
```

### ⚡ trg_wallet_histories_ai

- **테이블**: `wallet_histories`
- **이벤트**: AFTER INSERT
- **실행문**:

```sql
BEGIN
    UPDATE freelancer_wallets
       SET balance = NEW.balance,
           total_earned =
               total_earned +
               CASE
                   WHEN NEW.io_type IN ('DEPOSIT','PAYMENT','REFUND') THEN NEW.amount
                   ELSE 0
               END,
           version = version + 1
     WHERE wallet_id = NEW.wallet_id;
END
```

**총 6개의 트리거**

---

## ENUM 타입 정보

### admins

- **role**: enum('SUPER_ADMIN','ADMIN')
- **status**: enum('ACTIVE','INACTIVE')

### client_profiles

- **client_type**: enum('GENERAL','PERSONAL','CORPORATION')

### companies

- **company_size**: enum('STARTUP','SMALL','MEDIUM','LARGE','ENTERPRISE')

### contract_milestones

- **status**: enum('WAITING','DEPOSITED','REQUESTED','PAID','CANCELED')

### contracts

- **contract_status**: enum('SIGNED','TERMINATED','COMPLETED')

### projects

- **project_status**: enum('READY','IN_PROGRESS','CLOSED')

### queue_matchings

- **status**: enum('PENDING','ACCEPTED','REJECTED','EXPIRED')

### stacks

- **category**: enum('SKILL','POSITION')

### users

- **status**: enum('ACTIVE','INACTIVE','SUSPENDED')
- **user_type**: enum('FREELANCER','CLIENT')

### wallet_histories

- **io_type**: enum('DEPOSIT','WITHDRAWAL','PAYMENT','REFUND')

**총 12개의 ENUM 컬럼**

---

## 데이터베이스 ERD 관계

### 핵심 엔티티 관계

```
users (사용자)
├── freelancer_profiles (프리랜서 프로필)
│   ├── freelancer_careers (경력)
│   ├── freelancer_portfolios (포트폴리오)
│   ├── freelancer_project_experiences (프로젝트 경험)
│   ├── freelancer_skills (보유 기술)
│   ├── freelancer_wallets (지갑)
│   │   └── wallet_histories (입출금 이력)
│   └── queues (대기 큐)
│       └── queue_stacks (큐 기술스택)
│
├── client_profiles (클라이언트 프로필)
│   └── companies (소속 기업)
│
└── accounts (계좌 정보)

projects (프로젝트)
├── project_stacks (요구 기술)
├── project_applications (지원서)
│   └── project_freelancer_stacks (지원자 기술)
├── project_bookmarks (북마크)
├── queue_matchings (큐 매칭)
└── chat_rooms (채팅방)
    └── messages (메시지)

contracts (계약)
└── contract_milestones (마일스톤)
    └── milestone_histories (변경 이력)
```

---

## 📊 통계 요약

- 총 테이블: **26개**
- 총 레코드: **153건**
- 외래키: **33개**
- 트리거: **6개**
- ENUM 컬럼: **12개**

---

*문서 끝*