# sanai DB 스키마 레퍼런스

> **Database**: sanai  
> **Host**: 192.168.0.56:3306  
> **User**: remote_user  
> **총 테이블 수**: 26개  
> **마지막 업데이트**: 2026-01-14

---

## 📊 테이블 목록 및 개요

### 👤 **사용자 관리 (Users & Profiles)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `users` | 통합 사용자 (프리랜서/클라이언트/관리자) | user_id, login_id, email, user_type, status |
| `admins` | 관리자 계정 | admin_id, login_id, email, role, status |
| `freelancer_profiles` | 프리랜서 프로필 | user_id, nickname, introduction, github_url, is_profile_complete |
| `client_profiles` | 클라이언트 프로필 | client_id, company_id, client_type |
| `companies` | 기업 정보 | company_id, company_name, business_number, business_verified |

### 💼 **프로젝트 관리 (Projects)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `projects` | 프로젝트 | project_id, client_id, title, budget, project_status, deadline_date |
| `project_stacks` | 프로젝트 필요 스택 | project_stack_id, project_id, stack_id, stack_level |
| `project_applications` | 프로젝트 지원 내역 | application_id, project_id, freelancer_id, is_contracted |
| `project_bookmarks` | 프로젝트 북마크 | bookmark_id, project_id, user_id |
| `project_freelancer_stacks` | 지원자 스택 | project_freelancer_stack_id, application_id, stack_id |

### 📋 **계약 관리 (Contracts)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `contracts` | 계약 | contract_id, total_budget, contract_status, contract_start_date |
| `contract_milestones` | 계약 마일스톤 | milestone_id, contract_id, milestone_name, amount, status |
| `milestone_histories` | 마일스톤 변경 이력 | milestone_history_id, milestone_id, action_type, prev_value |

### 💰 **금융 관리 (Wallet)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `accounts` | 계좌 정보 | account_id, user_id, bank_name, account_number |
| `freelancer_wallets` | 프리랜서 지갑 | wallet_id, freelancer_id, balance, total_earned, wallet_pw |
| `wallet_histories` | 지갑 입출금 내역 | wallet_history_id, wallet_id, io_type, amount, balance |

### 💬 **채팅 (Chat)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `chat_rooms` | 채팅방 | room_id, freelancer_id, project_id, is_active |
| `messages` | 메시지 | message_id, room_id, sender_id, content, is_read |

### 🎯 **기회 큐 (Queue)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `queues` | 프리랜서 기회 큐 | queue_id, freelancer_id, queue_name, min_budget, max_budget |
| `queue_stacks` | 큐 관련 스택 | queue_stack_id, queue_id, stack_id |
| `queue_matchings` | 큐-프로젝트 매칭 | matching_id, queue_id, project_id, status |

### 🛠️ **프리랜서 경력 & 포트폴리오**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `freelancer_careers` | 경력 | career_id, freelancer_id, company_name, role, start_date |
| `freelancer_portfolios` | 포트폴리오 | portfolio_id, freelancer_id, title, portfolio_url, is_public |
| `freelancer_project_experiences` | 프로젝트 경험 | experience_id, freelancer_id, title, role, description |
| `freelancer_skills` | 프리랜서 보유 스킬 | freelancer_stack_id, freelancer_id, stack_id, stack_level |

### 🏷️ **기술 스택 (Stacks)**
| 테이블 | 설명 | 주요 컬럼 |
|--------|------|-----------|
| `stacks` | 기술 스택 마스터 | stack_id, stack_name, category |

---

## 📋 상세 테이블 스키마

### 1. `users` (사용자)
```sql
CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '유저 PK',
    login_id VARCHAR(255) UNIQUE NOT NULL COMMENT '로그인 ID',
    email VARCHAR(255) UNIQUE NOT NULL COMMENT '이메일',
    password VARCHAR(255) NOT NULL COMMENT '암호화 비밀번호',
    user_type ENUM('FREELANCER', 'CLIENT') NOT NULL COMMENT '유저 유형',
    name VARCHAR(255) NOT NULL COMMENT '실명',
    phone VARCHAR(255) NOT NULL COMMENT '전화번호',
    birth_date DATE NOT NULL COMMENT '생년월일',
    profile_image_url VARCHAR(255) COMMENT '프로필 이미지 URL',
    status ENUM('ACTIVE', 'INACTIVE', 'DELETED') NOT NULL COMMENT '계정 상태',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '가입일',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일'
);
```

### 2. `projects` (프로젝트)
```sql
CREATE TABLE projects (
    project_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    start_date DATE NOT NULL,
    deadline_date DATE NOT NULL,
    est_duration VARCHAR(255) NOT NULL,
    budget BIGINT NOT NULL,
    communicate_method VARCHAR(255) NOT NULL,
    payment_method VARCHAR(255) NOT NULL,
    change_policy TEXT,
    max_revision_count INT NOT NULL,
    project_status ENUM('RECRUITING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL,
    is_public TINYINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    view_count INT NOT NULL DEFAULT 0,
    applicant_count INT NOT NULL DEFAULT 0,
    FOREIGN KEY (client_id) REFERENCES users(user_id)
);
```

### 3. `contracts` (계약)
```sql
CREATE TABLE contracts (
    contract_id BIGINT PRIMARY KEY,
    total_budget BIGINT NOT NULL,
    payment_method VARCHAR(255) NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    contract_status ENUM('PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED') NOT NULL,
    origin_contract_url VARCHAR(255),
    platform_contract_url VARCHAR(255),
    ai_report_url VARCHAR(255),
    contracted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    cancel_reason TEXT,
    client_rating INT,
    client_experience TEXT,
    client_is_renewal_intended TINYINT,
    freelancer_rating INT,
    freelancer_experience TEXT
);
```

### 4. `freelancer_wallets` (지갑)
```sql
CREATE TABLE freelancer_wallets (
    wallet_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    freelancer_id BIGINT UNIQUE NOT NULL,
    account_id BIGINT NOT NULL,
    balance BIGINT NOT NULL DEFAULT 0,
    total_earned BIGINT NOT NULL DEFAULT 0,
    wallet_pw VARCHAR(255) NOT NULL,
    version INT NOT NULL DEFAULT 0,
    FOREIGN KEY (freelancer_id) REFERENCES users(user_id),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
```

### 5. `stacks` (기술 스택)
```sql
CREATE TABLE stacks (
    stack_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    stack_name VARCHAR(255) UNIQUE NOT NULL,
    category ENUM('LANGUAGE', 'FRAMEWORK', 'DATABASE', 'TOOL', 'ETC') NOT NULL
);
```

---

## 🔗 주요 관계 (Foreign Keys)

### 사용자 → 프로필
- `freelancer_profiles.user_id` → `users.user_id`
- `client_profiles.client_id` → `users.user_id`

### 프로젝트 관계
- `projects.client_id` → `users.user_id`
- `project_applications.project_id` → `projects.project_id`
- `project_applications.freelancer_id` → `users.user_id`

### 계약 관계
- `contract_milestones.contract_id` → `contracts.contract_id`
- `contracts.contract_id` = `project_applications.application_id` (추정)

### 지갑 관계
- `freelancer_wallets.freelancer_id` → `users.user_id`
- `freelancer_wallets.account_id` → `accounts.account_id`
- `wallet_histories.wallet_id` → `freelancer_wallets.wallet_id`

### 채팅 관계
- `chat_rooms.freelancer_id` → `users.user_id`
- `chat_rooms.project_id` → `projects.project_id`
- `messages.room_id` → `chat_rooms.room_id`
- `messages.sender_id` → `users.user_id`

---

## 📊 ENUM 타입 정리

### `users.user_type`
- `FREELANCER`: 프리랜서
- `CLIENT`: 클라이언트

### `users.status`
- `ACTIVE`: 활성 계정
- `INACTIVE`: 비활성 계정
- `DELETED`: 삭제된 계정

### `projects.project_status`
- `RECRUITING`: 모집 중
- `IN_PROGRESS`: 진행 중
- `COMPLETED`: 완료
- `CANCELLED`: 취소

### `contracts.contract_status`
- `PENDING`: 대기
- `ACTIVE`: 진행 중
- `COMPLETED`: 완료
- `CANCELLED`: 취소

### `contract_milestones.status`
- (DB에서 확인 필요)

### `wallet_histories.io_type`
- `DEPOSIT`: 입금
- `WITHDRAW`: 출금

### `stacks.category`
- `LANGUAGE`: 프로그래밍 언어
- `FRAMEWORK`: 프레임워크
- `DATABASE`: 데이터베이스
- `TOOL`: 도구
- `ETC`: 기타

---

## 💡 개발 팁

### 1. MyBatis Mapper 네이밍 규칙
```
테이블명 → Mapper 위치
users → src/main/resources/mybatis/mappers/user/UserMapper.xml
projects → src/main/resources/mybatis/mappers/project/ProjectMapper.xml
contracts → src/main/resources/mybatis/mappers/contract/ContractMapper.xml
```

### 2. VO/DTO 클래스 생성
```java
// users 테이블 → User.java
public class User {
    private Long userId;
    private String loginId;
    private String email;
    private String password;
    private UserType userType;
    private String name;
    private String phone;
    private LocalDate birthDate;
    private String profileImageUrl;
    private UserStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

### 3. 자주 사용할 쿼리 예시

**사용자 조회**
```xml
<select id="selectUserById" parameterType="long" resultType="User">
    SELECT * FROM users WHERE user_id = #{userId}
</select>
```

**프로젝트 목록 조회**
```xml
<select id="selectProjectsByStatus" parameterType="string" resultType="Project">
    SELECT * FROM projects WHERE project_status = #{status} ORDER BY created_at DESC
</select>
```

**지갑 잔액 조회**
```xml
<select id="selectWalletBalance" parameterType="long" resultType="long">
    SELECT balance FROM freelancer_wallets WHERE freelancer_id = #{freelancerId}
</select>
```

---

## 🔄 실시간 조회 명령어

### 테이블 목록
```bash
mysql -h 192.168.0.56 -u remote_user -p0000 -D sanai -e "SHOW TABLES;"
```

### 특정 테이블 구조
```bash
mysql -h 192.168.0.56 -u remote_user -p0000 -D sanai -e "DESCRIBE users;"
```

### 데이터 샘플 조회
```bash
mysql -h 192.168.0.56 -u remote_user -p0000 -D sanai -e "SELECT * FROM users LIMIT 5;"
```

---

**마지막 업데이트**: 2026-01-14  
**생성 방법**: INFORMATION_SCHEMA.COLUMNS 조회
