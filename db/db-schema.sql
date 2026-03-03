create table admins
(
    admin_id      bigint auto_increment
        primary key,
    login_id      varchar(50)                                             not null,
    email         varchar(100)                                            not null,
    password      varchar(255)                                            not null,
    refresh_token varchar(512)                                            null comment '리프레시 토큰',
    name          varchar(50)                                             not null,
    role          enum ('SUPER_ADMIN', 'ADMIN') default 'ADMIN'           not null,
    status        enum ('ACTIVE', 'INACTIVE')   default 'ACTIVE'          not null,
    created_at    datetime                      default CURRENT_TIMESTAMP not null,
    updated_at    datetime                      default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uk_admins_email
        unique (email),
    constraint uk_admins_login_id
        unique (login_id)
)
    comment '관리자 계정';

create table companies
(
    company_id        bigint auto_increment
        primary key,
    company_name      varchar(100)                                               not null,
    ceo_name          varchar(50)                                                not null,
    ceo_email         varchar(255)                                               null,
    business_number   varchar(50)                                                not null,
    opening_date      date                                                       not null comment '개업일자',
    business_verified tinyint(1) default 0                                       not null,
    industry          varchar(100)                                               null,
    address           varchar(300)                                               null,
    company_size      enum ('STARTUP', 'SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE') null,
    website_url       varchar(500)                                               null,
    created_at        datetime   default CURRENT_TIMESTAMP                       not null,
    constraint uk_companies_business_number
        unique (business_number)
)
    comment '회사(법인) 정보';

create table stacks
(
    stack_id   bigint auto_increment
        primary key,
    stack_name varchar(50)                                not null,
    category   enum ('SKILL', 'POSITION') default 'SKILL' not null,
    constraint uk_stacks_name
        unique (stack_name)
)
    comment '기술/포지션 마스터';

create index idx_stacks_category
    on stacks (category);

create table users
(
    user_id           bigint auto_increment comment '유저 PK'
        primary key,
    login_id          varchar(50)                                                        not null comment '로그인 ID (중복 불가)',
    email             varchar(100)                                                       not null comment '이메일 (중복 불가)',
    password          varchar(255)                                                       not null comment '암호화 비밀번호',
    refresh_token     varchar(512)                                                       null comment '리프레시 토큰',
    user_type         enum ('FREELANCER', 'CLIENT')                                      not null comment '유저 유형',
    name              varchar(50)                                                        not null comment '실명',
    phone             varchar(20)                                                        not null comment '전화번호',
    birth_date        date                                                               not null comment '생년월일',
    profile_image_url varchar(500)                                                       null comment '프로필 이미지 URL',
    status            enum ('ACTIVE', 'INACTIVE', 'SUSPENDED') default 'ACTIVE'          not null comment '계정 상태(소프트 딜리트)',
    created_at        datetime                                 default CURRENT_TIMESTAMP not null comment '가입일',
    updated_at        datetime                                 default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '수정일',
    constraint uk_users_email
        unique (email),
    constraint uk_users_login_id
        unique (login_id)
)
    comment '사용자(소프트 딜리트 기준)';

create table accounts
(
    account_id     bigint auto_increment
        primary key,
    user_id        bigint                             not null,
    bank_name      varchar(50)                        not null,
    account_holder varchar(50)                        not null,
    account_number varchar(50)                        not null,
    updated_at     datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_account_user
        foreign key (user_id) references users (user_id)
)
    comment '유저 계좌';

create index idx_accounts_user
    on accounts (user_id);

create table client_profiles
(
    client_id   bigint                                                        not null
        primary key,
    company_id  bigint                                                        null,
    client_type enum ('GENERAL', 'PERSONAL', 'CORPORATION') default 'GENERAL' not null,
    constraint fk_client_profile_company
        foreign key (company_id) references companies (company_id)
            on delete set null,
    constraint fk_client_profile_user
        foreign key (client_id) references users (user_id)
)
    comment '클라이언트 프로필';

create table freelancer_careers
(
    career_id     bigint auto_increment
        primary key,
    freelancer_id bigint                             not null,
    company_name  varchar(100)                       not null,
    role          varchar(100)                       not null,
    position      varchar(100)                       not null,
    start_date    date                               not null,
    end_date      date                               null,
    description   text                               null,
    created_at    datetime default CURRENT_TIMESTAMP not null,
    updated_at    datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_career_user
        foreign key (freelancer_id) references users (user_id)
)
    comment '프리랜서 회사 경력';

create index idx_career_freelancer
    on freelancer_careers (freelancer_id, start_date);

create table freelancer_portfolios
(
    portfolio_id  bigint auto_increment
        primary key,
    freelancer_id bigint                               not null,
    title         varchar(255)                         not null,
    description   text                                 null,
    portfolio_url varchar(2048)                        not null,
    file_size     bigint     default 0                 not null,
    is_public     tinyint(1) default 1                 not null,
    created_at    datetime   default CURRENT_TIMESTAMP not null,
    updated_at    datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_portfolio_user
        foreign key (freelancer_id) references users (user_id)
)
    comment '프리랜서 포트폴리오';

create index idx_portfolio_freelancer
    on freelancer_portfolios (freelancer_id, created_at);

create table freelancer_profiles
(
    freelancer_id       bigint               not null
        primary key,
    nickname            varchar(50)          not null,
    introduction        text                 null,
    github_url          varchar(500)         null,
    website_url         varchar(500)         null,
    school_name         varchar(100)         null,
    major               varchar(100)         null,
    degree              varchar(50)          null,
    grad_status         varchar(50)          null,
    is_profile_complete tinyint(1) default 0 not null,
    constraint uk_freelancer_nickname
        unique (nickname),
    constraint fk_freelancer_profile_user
        foreign key (freelancer_id) references users (user_id)
)
    comment '프리랜서 프로필';

create table freelancer_project_experiences
(
    experience_id bigint auto_increment
        primary key,
    freelancer_id bigint                             not null,
    title         varchar(200)                       not null,
    client_name   varchar(100)                       null,
    start_date    date                               not null,
    end_date      date                               null,
    role          varchar(100)                       not null,
    description   text                               null,
    created_at    datetime default CURRENT_TIMESTAMP not null,
    updated_at    datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint fk_exp_user
        foreign key (freelancer_id) references users (user_id)
)
    comment '프리랜서 외부 프로젝트 경험';

create index idx_exp_freelancer
    on freelancer_project_experiences (freelancer_id, start_date);

create table freelancer_skills
(
    freelancer_stack_id bigint auto_increment
        primary key,
    freelancer_id       bigint        not null,
    stack_id            bigint        not null,
    stack_level         int default 1 not null,
    stack_year          int default 0 not null,
    constraint uk_freelancer_stack
        unique (freelancer_id, stack_id),
    constraint fk_fs_stack
        foreign key (stack_id) references stacks (stack_id)
            on delete cascade,
    constraint fk_fs_user
        foreign key (freelancer_id) references users (user_id),
    constraint chk_stack_level
        check (`stack_level` between 1 and 5)
)
    comment '프리랜서 보유 기술';

create index idx_fs_freelancer
    on freelancer_skills (freelancer_id);

create index idx_fs_stack
    on freelancer_skills (stack_id);

create table freelancer_wallets
(
    wallet_id     bigint auto_increment
        primary key,
    freelancer_id bigint           not null,
    account_id    bigint           not null,
    balance       bigint default 0 not null,
    total_earned  bigint default 0 not null,
    wallet_pw     varchar(255)     not null,
    version       int    default 0 not null,
    constraint uk_wallet_freelancer
        unique (freelancer_id),
    constraint fk_wallet_account
        foreign key (account_id) references accounts (account_id),
    constraint fk_wallet_user
        foreign key (freelancer_id) references users (user_id)
)
    comment '프리랜서 지갑';

create index idx_wallet_account
    on freelancer_wallets (account_id);

create table projects
(
    project_id          bigint auto_increment
        primary key,
    client_id           bigint                                                            not null,
    title               varchar(255)                                                      not null,
    description         text                                                              not null,
    start_date          date                                                              not null,
    deadline_date       date                                                              not null,
    est_duration        varchar(50)                                                       not null,
    budget              bigint                                                            not null,
    communicate_method  varchar(50)                                                       not null,
    payment_method      varchar(50)                                                       not null,
    change_policy       text                                                              null,
    max_revision_count  int                                     default 0                 not null,
    project_status      enum ('READY', 'IN_PROGRESS', 'CLOSED') default 'READY'           not null,
    is_public           tinyint(1)                              default 1                 not null,
    created_at          datetime                                default CURRENT_TIMESTAMP not null,
    updated_at          datetime                                default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    view_count          int                                     default 0                 not null,
    applicant_count     int                                     default 0                 not null,
    plan_url            varchar(2048)                                                     null comment '기획서url',
    file_size           varchar(200)                                                      null comment '파일 크기 (최대 5GB)',
    budget_negotiable   tinyint(1)                              default 0                 not null comment '예산 조율 가능 여부',
    duration_negotiable tinyint(1)                              default 0                 not null comment '기간 조율 가능 여부',
    constraint fk_project_client
        foreign key (client_id) references users (user_id)
)
    comment '프로젝트 공고';

create table chat_rooms
(
    room_id           bigint auto_increment
        primary key,
    freelancer_id     bigint                               not null,
    project_id        bigint                               not null,
    is_active         tinyint(1) default 1                 not null,
    last_message_at   datetime                             null comment '마지막 메시지 시각',
    created_at        datetime   default CURRENT_TIMESTAMP not null,
    freelancer_exited tinyint(1) default 0                 null comment '프리랜서 퇴장 여부 (0:참여, 1:퇴장)',
    client_exited     tinyint(1) default 0                 null comment '클라이언트 퇴장 여부 (0:참여, 1:퇴장)',
    constraint fk_chatroom_freelancer
        foreign key (freelancer_id) references users (user_id),
    constraint fk_chatroom_project
        foreign key (project_id) references projects (project_id)
            on delete cascade
)
    comment '프로젝트 채팅방';

create index idx_rooms_project
    on chat_rooms (project_id, last_message_at);

create table messages
(
    message_id bigint auto_increment
        primary key,
    room_id    bigint                               not null,
    sender_id  bigint                               not null,
    content    text                                 not null,
    file_name  varchar(255)                         null,
    file_url   varchar(2048)                        null,
    file_size  bigint                               null,
    is_read    tinyint(1) default 0                 not null,
    is_deleted tinyint(1) default 0                 not null,
    deleted_at datetime                             null,
    created_at datetime   default CURRENT_TIMESTAMP not null,
    constraint fk_message_room
        foreign key (room_id) references chat_rooms (room_id)
            on delete cascade,
    constraint fk_message_sender
        foreign key (sender_id) references users (user_id)
)
    comment '채팅 메시지';

create index idx_message_room_date
    on messages (room_id, created_at);

create definer = root@localhost trigger trg_messages_ai
    after insert
    on messages
    for each row
BEGIN
    UPDATE chat_rooms
    SET last_message_at = NEW.created_at
    WHERE room_id = NEW.room_id;
END;

create table project_applications
(
    application_id     bigint auto_increment
        primary key,
    project_id         bigint                                not null,
    freelancer_id      bigint                                not null,
    application_status varchar(20) default 'PENDING'         not null comment '지원 상태 (PENDING, VIEWED, CHATTING, OFFERED, CONTRACTED, REJECTED, CANCELED)',
    applied_at         datetime    default CURRENT_TIMESTAMP not null,
    constraint uk_application_duplicate
        unique (project_id, freelancer_id),
    constraint fk_app_freelancer
        foreign key (freelancer_id) references users (user_id),
    constraint fk_app_project
        foreign key (project_id) references projects (project_id)
            on delete cascade
)
    comment '프로젝트 지원';

create table contracts
(
    contract_id                bigint                                                                                  not null
        primary key,
    total_budget               bigint                                                                                  not null,
    payment_method             varchar(50)                                                                             not null,
    contract_start_date        date                                                                                    not null,
    contract_end_date          date                                                                                    not null,
    contract_status            enum ('WAITING', 'SIGNED', 'PAID', 'TERMINATED', 'COMPLETED') default 'WAITING'         null,
    origin_contract_url        varchar(2048)                                                                           null,
    platform_contract_url      varchar(2048)                                                                           null,
    ai_report_url              varchar(2048)                                                                           null,
    contracted_at              datetime                                                      default CURRENT_TIMESTAMP not null,
    completed_at               datetime                                                                                null,
    cancel_reason              text                                                                                    null,
    client_rating              int                                                                                     null,
    client_experience          text                                                                                    null,
    client_is_renewal_intended tinyint(1)                                                                              null,
    freelancer_rating          int                                                                                     null,
    freelancer_experience      text                                                                                    null,
    constraint fk_contract_application
        foreign key (contract_id) references project_applications (application_id)
            on delete cascade,
    constraint chk_client_rating
        check ((`client_rating` is null) or (`client_rating` between 1 and 5)),
    constraint chk_contract_date
        check (`contract_end_date` >= `contract_start_date`),
    constraint chk_freelancer_rating
        check ((`freelancer_rating` is null) or (`freelancer_rating` between 1 and 5))
)
    comment '계약(지원과 1:1)';

create table contract_milestones
(
    milestone_id   bigint auto_increment
        primary key,
    contract_id    bigint                                                                           not null,
    step_order     int                                                                              not null,
    milestone_name varchar(100)                                                                     not null,
    work_scope     text                                                                             null,
    amount         bigint                                                                           not null,
    due_date       date                                                                             null,
    status         enum ('WAITING', 'DEPOSITED', 'REQUESTED', 'PAID', 'CANCELED') default 'WAITING' not null,
    constraint uk_contract_step
        unique (contract_id, step_order),
    constraint fk_milestone_contract
        foreign key (contract_id) references contracts (contract_id)
            on delete cascade,
    constraint chk_milestone_amount
        check (`amount` >= 0)
)
    comment '계약 마일스톤';

create index idx_milestone_contract
    on contract_milestones (contract_id, status);

create index idx_milestone_status
    on contract_milestones (contract_id, status, step_order);

create table milestone_histories
(
    milestone_history_id bigint auto_increment
        primary key,
    milestone_id         bigint                             not null,
    action_type          varchar(50)                        not null,
    prev_value           text                               null,
    curr_value           text                               not null,
    created_at           datetime default CURRENT_TIMESTAMP not null,
    constraint fk_mh_milestone
        foreign key (milestone_id) references contract_milestones (milestone_id)
            on delete cascade
)
    comment '마일스톤 변경 이력';

create index idx_mh_milestone
    on milestone_histories (milestone_id, created_at);

create table payments
(
    payment_id     bigint auto_increment comment '결제 ID'
        primary key,
    contract_id    bigint                                                                   not null comment '계약 ID',
    imp_uid        varchar(100)                                                             null comment '포트원 결제 고유번호',
    merchant_uid   varchar(100)                                                             null comment '가맹점 주문번호 (contract_{contractId}_{timestamp})',
    amount         bigint                                                                   not null comment '결제 금액',
    payment_method varchar(50)                                                              null comment '결제 수단 (card, trans, vbank 등)',
    payment_status enum ('PENDING', 'PAID', 'FAILED', 'CANCELED') default 'PENDING'         null comment '결제 상태',
    paid_at        datetime                                                                 null comment '결제 완료 시각',
    failed_reason  varchar(500)                                                             null comment '결제 실패 사유',
    buyer_name     varchar(50)                                                              null comment '구매자 이름',
    buyer_email    varchar(100)                                                             null comment '구매자 이메일',
    buyer_tel      varchar(20)                                                              null comment '구매자 연락처',
    pg_provider    varchar(50)                                                              null comment 'PG사 (html5_inicis, nice 등)',
    pg_tid         varchar(100)                                                             null comment 'PG사 거래 고유번호',
    card_name      varchar(50)                                                              null comment '카드사 이름',
    card_number    varchar(50)                                                              null comment '카드번호 (마스킹)',
    receipt_url    varchar(500)                                                             null comment '영수증 URL',
    created_at     datetime                                       default CURRENT_TIMESTAMP not null comment '생성일시',
    updated_at     datetime                                       default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '수정일시',
    constraint imp_uid
        unique (imp_uid),
    constraint merchant_uid
        unique (merchant_uid),
    constraint fk_payment_contract
        foreign key (contract_id) references contracts (contract_id)
)
    comment '결제 내역';

create index idx_payment_contract
    on payments (contract_id);

create index idx_payment_imp_uid
    on payments (imp_uid);

create index idx_payment_merchant_uid
    on payments (merchant_uid);

create index idx_payment_status
    on payments (payment_status, created_at);

create index idx_app_freelancer
    on project_applications (freelancer_id, applied_at);

create index idx_app_project
    on project_applications (project_id, applied_at);

create index idx_app_status
    on project_applications (application_status, applied_at);

create definer = root@localhost trigger trg_project_applications_ad
    after delete
    on project_applications
    for each row
BEGIN
    UPDATE projects
    SET applicant_count = GREATEST(applicant_count - 1, 0)
    WHERE project_id = OLD.project_id;
END;

create definer = root@localhost trigger trg_project_applications_ai
    after insert
    on project_applications
    for each row
BEGIN
    UPDATE projects
    SET applicant_count = applicant_count + 1
    WHERE project_id = NEW.project_id;
END;

create table project_bookmarks
(
    bookmark_id bigint auto_increment
        primary key,
    project_id  bigint                             not null,
    user_id     bigint                             not null,
    created_at  datetime default CURRENT_TIMESTAMP not null,
    constraint uk_bookmark_unique
        unique (project_id, user_id),
    constraint fk_bookmark_project
        foreign key (project_id) references projects (project_id)
            on delete cascade,
    constraint fk_bookmark_user
        foreign key (user_id) references users (user_id)
)
    comment '프로젝트 북마크';

create index idx_bookmark_user_time
    on project_bookmarks (user_id, created_at);

create table project_freelancer_stacks
(
    project_freelancer_stack_id bigint auto_increment
        primary key,
    application_id              bigint               not null,
    stack_id                    bigint               not null,
    is_primary                  tinyint(1) default 0 not null,
    constraint uk_application_stack
        unique (application_id, stack_id),
    constraint fk_pfstack_application
        foreign key (application_id) references project_applications (application_id)
            on delete cascade,
    constraint fk_pfstack_stack
        foreign key (stack_id) references stacks (stack_id)
            on delete cascade
)
    comment '지원 시 선택한 스택';

create table project_stacks
(
    project_stack_id bigint auto_increment
        primary key,
    project_id       bigint        not null,
    stack_id         bigint        not null,
    stack_level      int           null,
    stack_year       int default 0 not null,
    constraint uk_project_stack
        unique (project_id, stack_id),
    constraint fk_pstack_project
        foreign key (project_id) references projects (project_id)
            on delete cascade,
    constraint fk_pstack_stack
        foreign key (stack_id) references stacks (stack_id)
            on delete cascade,
    constraint chk_project_stack_level
        check ((`stack_level` is null) or (`stack_level` between 1 and 5))
)
    comment '프로젝트 요구 스택';

create index idx_pstack_project
    on project_stacks (project_id);

create index idx_pstack_stack
    on project_stacks (stack_id);

create index idx_projects_client
    on projects (client_id);

create index idx_projects_status_date
    on projects (project_status, created_at);

create table queues
(
    queue_id          bigint auto_increment
        primary key,
    freelancer_id     bigint                             not null,
    queue_name        varchar(100)                       not null,
    min_budget        int                                not null,
    max_budget        int                                not null,
    expected_duration varchar(20)                        not null,
    created_at        datetime default CURRENT_TIMESTAMP not null,
    constraint uq_queue_name_per_freelancer
        unique (freelancer_id, queue_name),
    constraint fk_queues_freelancer
        foreign key (freelancer_id) references users (user_id),
    constraint ck_queue_budget
        check ((`min_budget` >= 0) and (`max_budget` >= `min_budget`))
)
    comment '프리랜서 기회 큐';

create table queue_matchings
(
    matching_id bigint auto_increment
        primary key,
    queue_id    bigint                                                                        not null,
    project_id  bigint                                                                        not null,
    status      enum ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED') default 'PENDING'         not null,
    matched_at  datetime                                            default CURRENT_TIMESTAMP not null,
    constraint uq_queue_project
        unique (queue_id, project_id),
    constraint fk_matchings_project
        foreign key (project_id) references projects (project_id)
            on delete cascade,
    constraint fk_matchings_queue
        foreign key (queue_id) references queues (queue_id)
            on delete cascade
)
    comment '큐-프로젝트 매칭';

create index idx_matchings_project_status
    on queue_matchings (project_id, status);

create index idx_matchings_queue_time
    on queue_matchings (queue_id, matched_at);

create table queue_stacks
(
    queue_stack_id bigint auto_increment
        primary key,
    queue_id       bigint not null,
    stack_id       bigint not null,
    constraint uk_queue_stack
        unique (queue_id, stack_id),
    constraint fk_qstack_queue
        foreign key (queue_id) references queues (queue_id)
            on delete cascade,
    constraint fk_qstack_stack
        foreign key (stack_id) references stacks (stack_id)
            on delete cascade
)
    comment '큐 선호 스택';

create index idx_queues_freelancer_created
    on queues (freelancer_id, created_at);

create table refunds
(
    refund_id      bigint auto_increment comment '환불 ID'
        primary key,
    payment_id     bigint                                                                            not null comment '원본 결제 ID',
    contract_id    bigint                                                                            not null comment '계약 ID',
    refund_amount  bigint                                                                            not null comment '환불 금액',
    reason         varchar(500)                                                                      null comment '환불 사유',
    requested_by   bigint                                                                            not null comment '환불 요청자 user_id',
    refund_status  enum ('REQUESTED', 'PROCESSING', 'COMPLETED', 'FAILED') default 'REQUESTED'       null comment '환불 상태',
    imp_refund_uid varchar(100)                                                                      null comment '포트원 환불 고유번호',
    refunded_at    datetime                                                                          null comment '환불 완료 시각',
    failed_reason  varchar(500)                                                                      null comment '환불 실패 사유',
    created_at     datetime                                                default CURRENT_TIMESTAMP not null comment '생성일시',
    updated_at     datetime                                                default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '수정일시',
    constraint fk_refund_contract
        foreign key (contract_id) references contracts (contract_id),
    constraint fk_refund_payment
        foreign key (payment_id) references payments (payment_id),
    constraint fk_refund_user
        foreign key (requested_by) references users (user_id),
    constraint chk_refund_amount
        check (`refund_amount` > 0)
)
    comment '환불 내역';

create index idx_refund_contract
    on refunds (contract_id);

create index idx_refund_payment
    on refunds (payment_id);

create index idx_refund_status
    on refunds (refund_status, created_at);

create definer = root@localhost trigger trg_users_block_delete
    before delete
    on users
    for each row
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'users는 물리 삭제 불가. status로 소프트 딜리트 하세요.';
END;

create table wallet_histories
(
    wallet_history_id bigint auto_increment
        primary key,
    wallet_id         bigint                                              not null,
    io_type           enum ('DEPOSIT', 'WITHDRAWAL', 'PAYMENT', 'REFUND') not null,
    amount            bigint                                              not null,
    balance           bigint                                              not null,
    summary           varchar(255)                                        not null,
    created_at        datetime default CURRENT_TIMESTAMP                  not null,
    constraint fk_wallet_history_wallet
        foreign key (wallet_id) references freelancer_wallets (wallet_id)
            on delete cascade,
    constraint chk_wallet_amount_positive
        check (`amount` > 0)
)
    comment '지갑 거래 내역';

create index idx_history_wallet_time
    on wallet_histories (wallet_id, created_at);

create definer = root@localhost trigger trg_wallet_histories_ai
    after insert
    on wallet_histories
    for each row
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
END;

create definer = root@localhost trigger trg_wallet_histories_bi
    before insert
    on wallet_histories
    for each row
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
END;

