-- =========================================================
-- MOGAK Initial Schema
-- Flyway: V1__init_schema.sql
-- Database: MariaDB
-- =========================================================


-- =========================================================
-- 1. USERS
-- =========================================================

CREATE TABLE users (
                       id                  BIGINT          NOT NULL AUTO_INCREMENT,
                       email               VARCHAR(255)    NULL,
                       nickname            VARCHAR(30)     NOT NULL,
                       profile_img_url     VARCHAR(500)    NULL,
                       role                VARCHAR(20)     NOT NULL,
                       status              VARCHAR(20)     NOT NULL,
                       created_at          DATETIME        NOT NULL,
                       updated_at          DATETIME        NOT NULL,
                       deleted_at          DATETIME        NULL,

                       CONSTRAINT pk_users
                           PRIMARY KEY (id),

                       CONSTRAINT uk_users_nickname
                           UNIQUE (nickname)
);


-- =========================================================
-- 2. SOCIAL ACCOUNTS
-- =========================================================

CREATE TABLE social_accounts (
                                 id                  BIGINT          NOT NULL AUTO_INCREMENT,
                                 user_id             BIGINT          NOT NULL,
                                 provider            VARCHAR(20)     NOT NULL,
                                 provider_user_id    VARCHAR(255)    NOT NULL,
                                 email               VARCHAR(255)    NULL,
                                 created_at          DATETIME        NOT NULL,
                                 updated_at          DATETIME        NOT NULL,

                                 CONSTRAINT pk_social_accounts
                                     PRIMARY KEY (id),

                                 CONSTRAINT uk_social_accounts_provider_user
                                     UNIQUE (provider, provider_user_id),

                                 CONSTRAINT fk_social_accounts_user
                                     FOREIGN KEY (user_id)
                                         REFERENCES users (id)
                                         ON DELETE CASCADE
);


CREATE INDEX idx_social_accounts_user_id
    ON social_accounts (user_id);


-- =========================================================
-- 3. CHARACTERS
-- =========================================================

CREATE TABLE characters (
                            id                  BIGINT          NOT NULL AUTO_INCREMENT,
                            user_id             BIGINT          NOT NULL,
                            created_at          DATETIME        NOT NULL,
                            updated_at          DATETIME        NOT NULL,

                            CONSTRAINT pk_characters
                                PRIMARY KEY (id),

                            CONSTRAINT uk_characters_user
                                UNIQUE (user_id),

                            CONSTRAINT fk_characters_user
                                FOREIGN KEY (user_id)
                                    REFERENCES users (id)
                                    ON DELETE CASCADE
);


-- =========================================================
-- 4. ITEMS
-- =========================================================

CREATE TABLE items (
                       id                  BIGINT          NOT NULL AUTO_INCREMENT,
                       name                VARCHAR(100)    NOT NULL,
                       category            VARCHAR(30)     NOT NULL,
                       image_url           VARCHAR(500)    NULL,
                       sprite_key          VARCHAR(100)    NOT NULL,
                       price               INT             NOT NULL,
                       is_active           BOOLEAN         NOT NULL,
                       created_at          DATETIME        NOT NULL,

                       CONSTRAINT pk_items
                           PRIMARY KEY (id),

                       CONSTRAINT chk_items_price
                           CHECK (price >= 0)
);


CREATE INDEX idx_items_category_active
    ON items (category, is_active);


-- =========================================================
-- 5. USER ITEMS
-- =========================================================

CREATE TABLE user_items (
                            id                  BIGINT          NOT NULL AUTO_INCREMENT,
                            item_id             BIGINT          NOT NULL,
                            user_id             BIGINT          NOT NULL,
                            acquired_at         DATETIME        NOT NULL,

                            CONSTRAINT pk_user_items
                                PRIMARY KEY (id),

                            CONSTRAINT uk_user_items_user_item
                                UNIQUE (user_id, item_id),

                            CONSTRAINT fk_user_items_user
                                FOREIGN KEY (user_id)
                                    REFERENCES users (id)
                                    ON DELETE CASCADE,

                            CONSTRAINT fk_user_items_item
                                FOREIGN KEY (item_id)
                                    REFERENCES items (id)
);


CREATE INDEX idx_user_items_item_id
    ON user_items (item_id);


-- =========================================================
-- 6. CHARACTER EQUIPMENT
-- =========================================================

CREATE TABLE character_equipment (
                                     id                  BIGINT          NOT NULL AUTO_INCREMENT,
                                     character_id        BIGINT          NOT NULL,
                                     item_id             BIGINT          NOT NULL,
                                     slot                VARCHAR(30)     NOT NULL,
                                     equipped_at         DATETIME        NOT NULL,

                                     CONSTRAINT pk_character_equipment
                                         PRIMARY KEY (id),

                                     CONSTRAINT uk_character_equipment_character_slot
                                         UNIQUE (character_id, slot),

                                     CONSTRAINT fk_character_equipment_character
                                         FOREIGN KEY (character_id)
                                             REFERENCES characters (id)
                                             ON DELETE CASCADE,

                                     CONSTRAINT fk_character_equipment_item
                                         FOREIGN KEY (item_id)
                                             REFERENCES items (id)
);


CREATE INDEX idx_character_equipment_item_id
    ON character_equipment (item_id);


-- =========================================================
-- 7. SUBJECTS
-- =========================================================

CREATE TABLE subjects (
                          id                  BIGINT          NOT NULL AUTO_INCREMENT,
                          user_id             BIGINT          NOT NULL,
                          name                VARCHAR(50)     NOT NULL,
                          color               VARCHAR(20)     NULL,
                          is_active           BOOLEAN         NOT NULL,
                          created_at          DATETIME        NOT NULL,
                          updated_at          DATETIME        NOT NULL,

                          CONSTRAINT pk_subjects
                              PRIMARY KEY (id),

                          CONSTRAINT fk_subjects_user
                              FOREIGN KEY (user_id)
                                  REFERENCES users (id)
                                  ON DELETE CASCADE
);


CREATE INDEX idx_subjects_user_active
    ON subjects (user_id, is_active);


-- =========================================================
-- 8. STUDY GROUPS
-- =========================================================

CREATE TABLE study_groups (
                              id                  BIGINT          NOT NULL AUTO_INCREMENT,
                              owner_id            BIGINT          NOT NULL,
                              name                VARCHAR(100)    NOT NULL,
                              description         VARCHAR(500)    NULL,
                              visibility          VARCHAR(20)     NOT NULL,
                              max_members         INT             NOT NULL,
                              created_at          DATETIME        NOT NULL,
                              updated_at          DATETIME        NOT NULL,

                              CONSTRAINT pk_study_groups
                                  PRIMARY KEY (id),

                              CONSTRAINT fk_study_groups_owner
                                  FOREIGN KEY (owner_id)
                                      REFERENCES users (id),

                              CONSTRAINT chk_study_groups_max_members
                                  CHECK (max_members > 0)
);


CREATE INDEX idx_study_groups_owner_id
    ON study_groups (owner_id);

CREATE INDEX idx_study_groups_visibility
    ON study_groups (visibility);


-- =========================================================
-- 9. STUDY GROUP MEMBERS
-- =========================================================

CREATE TABLE study_group_members (
                                     id                  BIGINT          NOT NULL AUTO_INCREMENT,
                                     study_group_id      BIGINT          NOT NULL,
                                     user_id             BIGINT          NOT NULL,
                                     status              VARCHAR(20)     NOT NULL,
                                     joined_at           DATETIME        NULL,

                                     CONSTRAINT pk_study_group_members
                                         PRIMARY KEY (id),

                                     CONSTRAINT uk_study_group_members_group_user
                                         UNIQUE (study_group_id, user_id),

                                     CONSTRAINT fk_study_group_members_group
                                         FOREIGN KEY (study_group_id)
                                             REFERENCES study_groups (id)
                                             ON DELETE CASCADE,

                                     CONSTRAINT fk_study_group_members_user
                                         FOREIGN KEY (user_id)
                                             REFERENCES users (id)
                                             ON DELETE CASCADE
);


CREATE INDEX idx_study_group_members_user_id
    ON study_group_members (user_id);

CREATE INDEX idx_study_group_members_group_status
    ON study_group_members (study_group_id, status);


-- =========================================================
-- 10. STUDY ROOMS
-- =========================================================

CREATE TABLE study_rooms (
                             id                  BIGINT          NOT NULL AUTO_INCREMENT,
                             owner_id            BIGINT          NULL,
                             name                VARCHAR(100)    NOT NULL,
                             description         VARCHAR(500)    NULL,
                             room_type           VARCHAR(20)     NOT NULL,
                             access_code         VARCHAR(100)    NULL,
                             map_key             VARCHAR(100)    NOT NULL,
                             thumbnail_url       VARCHAR(500)    NULL,
                             capacity            INT             NOT NULL,
                             status              VARCHAR(20)     NOT NULL,
                             created_at          DATETIME        NOT NULL,

                             CONSTRAINT pk_study_rooms
                                 PRIMARY KEY (id),

                             CONSTRAINT uk_study_rooms_access_code
                                 UNIQUE (access_code),

                             CONSTRAINT fk_study_rooms_owner
                                 FOREIGN KEY (owner_id)
                                     REFERENCES users (id)
                                     ON DELETE CASCADE,

                             CONSTRAINT chk_study_rooms_type
                                 CHECK (
                                     room_type IN (
                                                   'PERSONAL',
                                                   'PRIVATE',
                                                   'PUBLIC',
                                                   'GROUP'
                                         )
                                     ),

                             CONSTRAINT chk_study_rooms_capacity
                                 CHECK (capacity > 0),

                             CONSTRAINT chk_study_rooms_personal_capacity
                                 CHECK (
                                     room_type <> 'PERSONAL'
                                         OR capacity = 1
                                     ),

                             CONSTRAINT chk_study_rooms_access_code
                                 CHECK (
                                     (room_type = 'PRIVATE' AND access_code IS NOT NULL)
                                         OR
                                     (room_type <> 'PRIVATE' AND access_code IS NULL)
                                     )
);


CREATE INDEX idx_study_rooms_owner_id
    ON study_rooms (owner_id);

CREATE INDEX idx_study_rooms_type_status
    ON study_rooms (room_type, status);


-- =========================================================
-- 11. SEATS
-- =========================================================

CREATE TABLE seats (
                       id                  BIGINT          NOT NULL AUTO_INCREMENT,
                       room_id             BIGINT          NOT NULL,
                       seat_code           VARCHAR(30)     NOT NULL,
                       position_x          INT             NOT NULL,
                       position_y          INT             NOT NULL,
                       direction           VARCHAR(10)     NOT NULL,
                       is_active           BOOLEAN         NOT NULL,

                       CONSTRAINT pk_seats
                           PRIMARY KEY (id),

                       CONSTRAINT uk_seats_room_code
                           UNIQUE (room_id, seat_code),

                       CONSTRAINT fk_seats_room
                           FOREIGN KEY (room_id)
                               REFERENCES study_rooms (id)
                               ON DELETE CASCADE
);


CREATE INDEX idx_seats_room_active
    ON seats (room_id, is_active);


-- =========================================================
-- 12. STUDY GROUP ROOMS
-- =========================================================

CREATE TABLE study_group_rooms (
                                   id                  BIGINT          NOT NULL AUTO_INCREMENT,
                                   study_group_id      BIGINT          NOT NULL,
                                   study_room_id       BIGINT          NOT NULL,
                                   level               INT             NOT NULL,
                                   total_exp           BIGINT          NOT NULL,

                                   CONSTRAINT pk_study_group_rooms
                                       PRIMARY KEY (id),

                                   CONSTRAINT uk_study_group_rooms_group
                                       UNIQUE (study_group_id),

                                   CONSTRAINT uk_study_group_rooms_room
                                       UNIQUE (study_room_id),

                                   CONSTRAINT fk_study_group_rooms_group
                                       FOREIGN KEY (study_group_id)
                                           REFERENCES study_groups (id)
                                           ON DELETE CASCADE,

                                   CONSTRAINT fk_study_group_rooms_room
                                       FOREIGN KEY (study_room_id)
                                           REFERENCES study_rooms (id)
                                           ON DELETE CASCADE,

                                   CONSTRAINT chk_study_group_rooms_level
                                       CHECK (level >= 1),

                                   CONSTRAINT chk_study_group_rooms_total_exp
                                       CHECK (total_exp >= 0)
);


-- =========================================================
-- 13. STUDY SESSIONS
-- =========================================================

CREATE TABLE study_sessions (
                                id                  BIGINT          NOT NULL AUTO_INCREMENT,
                                user_id             BIGINT          NOT NULL,
                                subject_id          BIGINT          NOT NULL,
                                room_id             BIGINT          NULL,
                                started_at          DATETIME        NOT NULL,
                                ended_at            DATETIME        NULL,
                                study_seconds       INT             NOT NULL,
                                break_seconds       INT             NOT NULL,
                                status              VARCHAR(20)     NOT NULL,
                                created_at          DATETIME        NOT NULL,

                                CONSTRAINT pk_study_sessions
                                    PRIMARY KEY (id),

                                CONSTRAINT fk_study_sessions_user
                                    FOREIGN KEY (user_id)
                                        REFERENCES users (id)
                                        ON DELETE CASCADE,

                                CONSTRAINT fk_study_sessions_subject
                                    FOREIGN KEY (subject_id)
                                        REFERENCES subjects (id),

                                CONSTRAINT fk_study_sessions_room
                                    FOREIGN KEY (room_id)
                                        REFERENCES study_rooms (id)
                                        ON DELETE SET NULL,

                                CONSTRAINT chk_study_sessions_study_seconds
                                    CHECK (study_seconds >= 0),

                                CONSTRAINT chk_study_sessions_break_seconds
                                    CHECK (break_seconds >= 0),

                                CONSTRAINT chk_study_sessions_time
                                    CHECK (
                                        ended_at IS NULL
                                            OR ended_at >= started_at
                                        )
);


CREATE INDEX idx_study_sessions_user_started
    ON study_sessions (user_id, started_at);

CREATE INDEX idx_study_sessions_subject_id
    ON study_sessions (subject_id);

CREATE INDEX idx_study_sessions_room_id
    ON study_sessions (room_id);

CREATE INDEX idx_study_sessions_user_status
    ON study_sessions (user_id, status);


-- =========================================================
-- 14. FRIENDSHIPS
-- =========================================================

CREATE TABLE friendships (
                             id                  BIGINT          NOT NULL AUTO_INCREMENT,
                             requester_id        BIGINT          NOT NULL,
                             receiver_id         BIGINT          NOT NULL,
                             status              VARCHAR(20)     NOT NULL,
                             created_at          DATETIME        NOT NULL,
                             updated_at          DATETIME        NOT NULL,

                             CONSTRAINT pk_friendships
                                 PRIMARY KEY (id),

                             CONSTRAINT uk_friendships_requester_receiver
                                 UNIQUE (requester_id, receiver_id),

                             CONSTRAINT fk_friendships_requester
                                 FOREIGN KEY (requester_id)
                                     REFERENCES users (id)
                                     ON DELETE CASCADE,

                             CONSTRAINT fk_friendships_receiver
                                 FOREIGN KEY (receiver_id)
                                     REFERENCES users (id)
                                     ON DELETE CASCADE,

                             CONSTRAINT chk_friendships_not_self
                                 CHECK (requester_id <> receiver_id)
);


CREATE INDEX idx_friendships_receiver_status
    ON friendships (receiver_id, status);

CREATE INDEX idx_friendships_requester_status
    ON friendships (requester_id, status);


-- =========================================================
-- 15. NOTIFICATIONS
-- =========================================================

CREATE TABLE notification (
                              id                  BIGINT          NOT NULL AUTO_INCREMENT,
                              user_id             BIGINT          NOT NULL,
                              type                VARCHAR(30)     NOT NULL,
                              reference_id        BIGINT          NULL,
                              message             VARCHAR(255)    NOT NULL,
                              is_read             BOOLEAN         NOT NULL,
                              created_at          DATETIME        NOT NULL,

                              CONSTRAINT pk_notification
                                  PRIMARY KEY (id),

                              CONSTRAINT fk_notification_user
                                  FOREIGN KEY (user_id)
                                      REFERENCES users (id)
                                      ON DELETE CASCADE
);


CREATE INDEX idx_notification_user_read_created
    ON notification (user_id, is_read, created_at);


-- =========================================================
-- 16. USER WALLETS
-- =========================================================

CREATE TABLE user_wallets (
                              user_id             BIGINT          NOT NULL,
                              balance             BIGINT          NOT NULL,
                              updated_at          DATETIME        NOT NULL,

                              CONSTRAINT pk_user_wallets
                                  PRIMARY KEY (user_id),

                              CONSTRAINT fk_user_wallets_user
                                  FOREIGN KEY (user_id)
                                      REFERENCES users (id)
                                      ON DELETE CASCADE,

                              CONSTRAINT chk_user_wallets_balance
                                  CHECK (balance >= 0)
);


-- =========================================================
-- 17. POINT TRANSACTIONS
-- =========================================================

CREATE TABLE point_transactions (
                                    id                  BIGINT          NOT NULL AUTO_INCREMENT,
                                    user_id             BIGINT          NOT NULL,
                                    type                VARCHAR(30)     NOT NULL,
                                    amount              INT             NOT NULL,
                                    balance_after       BIGINT          NOT NULL,
                                    reference_id        BIGINT          NULL,
                                    created_at          DATETIME        NOT NULL,

                                    CONSTRAINT pk_point_transactions
                                        PRIMARY KEY (id),

                                    CONSTRAINT fk_point_transactions_user
                                        FOREIGN KEY (user_id)
                                            REFERENCES users (id)
                                            ON DELETE CASCADE,

                                    CONSTRAINT chk_point_transactions_amount
                                        CHECK (amount <> 0),

                                    CONSTRAINT chk_point_transactions_balance
                                        CHECK (balance_after >= 0)
);


CREATE INDEX idx_point_transactions_user_created
    ON point_transactions (user_id, created_at);