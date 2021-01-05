DROP TABLE PARTICIPATION;
DROP TABLE PRACTICE;
DROP TABLE EVALUATION;
DROP TABLE SKILLS;
DROP TABLE PAYMENT;
DROP TABLE PAYMENT_TYPE;
DROP TABLE ACCESSES;
DROP TABLE UPDATE_RIGHTS;
DROP TABLE USER_ACCOUNT;
DROP TABLE MANAGER;
DROP TABLE PLAYER;
DROP TABLE COACH;
DROP TABLE PARENT;
DROP TABLE PERSON;
DROP TABLE ADDRESS;
DROP TABLE PAYMENT_CHANGES;
--DROP TRIGGER Payment_Changes_trg;

-- TABLE CREATION
CREATE TABLE ADDRESS(
address_id DECIMAL(12) NOT NULL PRIMARY KEY,
street VARCHAR(255) NOT NULL,
city VARCHAR(255) NOT NULL,
state VARCHAR(2) NOT NULL,
zip VARCHAR(10) NOT NULL
);

CREATE TABLE PERSON(
person_id DECIMAL(12) NOT NULL PRIMARY KEY,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
address_id DECIMAL(12) NOT NULL,
is_player DECIMAL(1),
is_parent DECIMAL(1),
FOREIGN KEY (address_id) REFERENCES ADDRESS (address_id)
);

CREATE TABLE PARENT(
person_id DECIMAL(12) NOT NULL PRIMARY KEY,
phone_number VARCHAR(12) NOT NULL,
email VARCHAR(32) NOT NULL,
is_coach VARCHAR(1),
is_manager VARCHAR(1),
FOREIGN KEY (person_id) REFERENCES PERSON (person_id)
);

CREATE TABLE COACH(
person_id DECIMAL(12) NOT NULL PRIMARY KEY,
team VARCHAR(32),
c_field VARCHAR(32),
FOREIGN KEY (person_id) REFERENCES PERSON (person_id)
);

CREATE TABLE PLAYER(
person_id DECIMAL(12) NOT NULL PRIMARY KEY,
grade VARCHAR(12) NOT NULL,
parent_id DECIMAL(12) NOT NULL,
emergency_first VARCHAR(255) NOT NULL,
emergency_last VARCHAR(255) NOT NULL,
emergency_phone VARCHAR(12) NOT NULL,
coach_id DECIMAL(12) NOT NULL,
travel_team DECIMAL(12),
FOREIGN KEY(person_id) REFERENCES PERSON(person_id),
FOREIGN KEY (parent_id) REFERENCES PARENT(person_id),
FOREIGN KEY (coach_id) REFERENCES COACH(person_id)
);

CREATE TABLE MANAGER(
person_id DECIMAL(12) NOT NULL PRIMARY KEY,
FOREIGN KEY (person_id)REFERENCES PERSON (person_id)
);

CREATE TABLE USER_ACCOUNT(
account_id DECIMAL(12) NOT NULL PRIMARY KEY,
person_id DECIMAL(12) NOT NULL,
user_name VARCHAR(32) NOT NULL,
user_password VARCHAR(255) NOT NULL,
FOREIGN KEY (person_id) REFERENCES Person (person_id)
);

CREATE TABLE UPDATE_RIGHTS(
rights_id DECIMAL(12) NOT NULL PRIMARY KEY,
description VARCHAR(64)
);

CREATE TABLE ACCESSES(
access_id DECIMAL(12) NOT NULL PRIMARY KEY,
rights_id DECIMAL(12) NOT NULL,
account_id DECIMAL(12) NOT NULL,
FOREIGN KEY (rights_id) REFERENCES UPDATE_RIGHTS (rights_id),
FOREIGN KEY (account_id) REFERENCES USER_ACCOUNT (account_id)
);

CREATE TABLE PAYMENT_TYPE(
pmt_type_id DECIMAL(12) NOT NULL PRIMARY KEY,
pmt_description VARCHAR (32) NOT NULL
);

CREATE TABLE PAYMENT(
payment_id DECIMAL(12) NOT NULL PRIMARY KEY,
pmt_type DECIMAL(12) NOT NULL,
player_id DECIMAL(12) NOT NULL,
payment_date DATE NOT NULL,
payment_amount DECIMAL(6,2),
FOREIGN KEY (pmt_type) REFERENCES PAYMENT_TYPE (pmt_type_id),
FOREIGN KEY (player_id) REFERENCES PLAYER (person_id)
);

CREATE TABLE SKILLS(
skill_id DECIMAL(12) NOT NULL PRIMARY KEY,
skill_description VARCHAR(32) NOT NULL
);

CREATE TABLE EVALUATION(
evaluation_id DECIMAL(12) NOT NULL PRIMARY KEY,
player_id DECIMAL(12) NOT NULL,
skill_id DECIMAL(12) NOT NULL,
evaluation_date DATE,
evaluation_score DECIMAL(1),
FOREIGN KEY(player_id) REFERENCES PLAYER (person_id),
FOREIGN KEY(skill_id) REFERENCES SKILLS(skill_id)
);


CREATE TABLE PRACTICE(
practice_id DECIMAL(12) NOT NULL PRIMARY KEY,
practice_date DATE NOT NULL
);

CREATE TABLE PARTICIPATION(
particip_id DECIMAL(12) NOT NULL PRIMARY KEY,
practice_id DECIMAL(12) NOT NULL,
player_id DECIMAL(12) NOT NULL,
FOREIGN KEY (player_id) REFERENCES PLAYER(person_id),
FOREIGN KEY (practice_id) REFERENCES PRACTICE(practice_id)
);

CREATE TABLE PAYMENT_CHANGES(
payment_changes_id DECIMAL(12) NOT NULL PRIMARY KEY,
old_value DECIMAL(6,2) NOT NULL,
new_value DECIMAL(6,2) NOT NULL,
payment_id DECIMAL(12) NOT NULL,
change_date DATE
);

CREATE INDEX person_first_idx
ON PERSON (first_name);

CREATE INDEX person_last_idx
ON PERSON (last_name);

CREATE INDEX emerg_phone_idx
ON PLAYER (emergency_phone);

CREATE INDEX parent_phone_idx
ON PARENT (phone_number);

CREATE INDEX email_idx
ON PARENT (email);

CREATE INDEX pmt_date_idx
ON PAYMENT (payment_date);

CREATE INDEX practice_date_idx
ON PRACTICE (practice_date);

CREATE INDEX person_address_idx
ON PERSON (address_id);

CREATE UNIQUE INDEX account_person_idx
ON USER_ACCOUNT (person_id);

CREATE INDEX access_rights_idx
ON ACCESSES (rights_id);

CREATE INDEX access_account_idx
ON ACCESSES (account_id);

CREATE INDEX player_parent_idx
ON PLAYER (parent_id);

CREATE INDEX player_coach_idx
ON PLAYER (coach_id);

CREATE INDEX payment_player_idx
ON PAYMENT (player_id);

CREATE INDEX payment_type_idx
ON PAYMENT (pmt_type);

CREATE INDEX eval_player_idx
ON EVALUATION (player_id);

CREATE INDEX eval_skill_idx
ON EVALUATION (skill_id);

CREATE INDEX partic_player_idx
ON PARTICIPATION (player_id);

CREATE INDEX partic_practice_idx
ON PARTICIPATION (practice_id);


-- stored procedure to create a coach
CREATE OR REPLACE PROCEDURE Create_Coach(
    first_name IN VARCHAR,
    last_name IN VARCHAR,
    address_id IN DECIMAL,
    street IN VARCHAR,
    city IN VARCHAR,
    state IN VARCHAR,
    zip IN VARCHAR,
    phone_number IN VARCHAR,
    email IN VARCHAR,
    is_coach IN DECIMAL,
    is_manager IN DECIMAL,
    is_player IN DECIMAL,
    is_parent IN DECIMAL,    
    account_id IN DECIMAL,
    user_name IN VARCHAR,
    user_password IN VARCHAR,
    person_id IN DECIMAL,
    team IN VARCHAR,
    c_field IN VARCHAR)
IS
BEGIN
    --Insert values into Address table
    INSERT INTO Address(address_id, street, city, state, zip)
    VALUES(address_id, street, city, state, zip);

    --Insert values into Person table
    INSERT INTO Person(person_id, first_name, last_name, address_id, is_player, is_parent)
    VALUES(person_id, first_name, last_name, address_id, is_player, is_parent);

    --Insert values into Account table
    INSERT INTO User_Account(account_id, person_id, user_name, user_password)
    VALUES(account_id, person_id, user_name, user_password);
    
    --Insert values into Parent table
    INSERT INTO Parent(person_id, phone_number, email, is_coach, is_manager)
    VALUES(person_id, phone_number, email, is_coach, is_manager);

    --Insert values into Coach table
    INSERT INTO Coach(person_id, team, c_field)
    VALUES(person_id, team, c_field);

END;
/

-- stored procedure to create a payment
CREATE OR REPLACE PROCEDURE Payment_sp(
payment_id_par IN DECIMAL,
pmt_type_par IN DECIMAL,
player_id_par IN DECIMAL,
payment_date_par DATE,
payment_amount_par IN DECIMAL)
IS
BEGIN
    INSERT INTO Payment(payment_id, pmt_type, player_id, payment_date, payment_amount)
    VALUES (payment_id_par, pmt_type_par, player_id_par, payment_date_par, payment_amount_par);
END;
/

-- stored procedure to create skills
CREATE OR REPLACE PROCEDURE Skills_sp(
skill_id_par IN DECIMAL,
skill_description_par IN VARCHAR)
IS
BEGIN
    INSERT INTO Skills(skill_id, skill_description)
    VALUES (skill_id_par, skill_description_par);
END;
/

-- stored procedure to create a parent
CREATE OR REPLACE PROCEDURE Create_Parent(
    first_name IN VARCHAR,
    last_name IN VARCHAR,
    address_id IN DECIMAL,
    street IN VARCHAR,
    city IN VARCHAR,
    state IN VARCHAR,
    zip IN VARCHAR,
    phone_number IN VARCHAR,
    email IN VARCHAR,
    is_player IN DECIMAL,
    is_parent IN DECIMAL,
    is_coach IN DECIMAL,
    is_manager IN DECIMAL,
    account_id IN DECIMAL,
    user_name IN VARCHAR,
    user_password IN VARCHAR,
    person_id IN DECIMAL)
IS
BEGIN
    --Insert values into Address table
    INSERT INTO Address(address_id, street, city, state, zip)
    VALUES(address_id, street, city, state, zip);
    
    --Insert values into Person table
    INSERT INTO Person(person_id, first_name, last_name, address_id, is_player, is_parent)
    VALUES(person_id, first_name, last_name, address_id, is_player, is_parent);
    
    --Insert values into User_Account table
    INSERT INTO User_Account(account_id, person_id, user_name, user_password)
    VALUES(account_id, person_id, user_name, user_password);
    
    --Insert values into Parent table
    INSERT INTO Parent(person_id, phone_number, email, is_coach, is_manager)
    VALUES(person_id, phone_number, email, is_coach, is_manager);
END;
/

-- stored procedure to create a player
CREATE OR REPLACE PROCEDURE Create_Player(
    first_name IN VARCHAR,
    last_name IN VARCHAR,
    address_id IN DECIMAL,
    is_player IN DECIMAL,
    is_parent IN DECIMAL,
    parent_id IN DECIMAL,
    grade IN VARCHAR,
    emergency_first IN VARCHAR,
    emergency_last IN VARCHAR,
    emergency_phone IN VARCHAR,
    coach_id IN DECIMAL,
    travel_team IN DECIMAL,
    person_id IN DECIMAL)
IS
BEGIN    
    --Insert values into Person table
    INSERT INTO Person(person_id, first_name, last_name, address_id, is_player, is_parent)
    VALUES(person_id, first_name, last_name, address_id, is_player, is_parent);
    
    --Insert values into Player table
    INSERT INTO Player(person_id, grade, parent_id, emergency_first, emergency_last, emergency_phone, coach_id, travel_team)
    VALUES(person_id, grade, parent_id, emergency_first, emergency_last, emergency_phone, coach_id, travel_team);
END;
/


-- Populating Tables

BEGIN
    CREATE_COACH(
    'Jon',
    'Smith',
    101,
    '324 Plain st.',
    'Mansfield',
    'MA',
    '02048',
    '508-345-3423',
    'jsmith_coach@company.com',
    1,
    0,
    0,
    1,
    201,
    'jsmith',
    'my_best_password',
    301,
    'Manchaster United',
    'Hutchinson-1');
END;
/


BEGIN
    CREATE_Player(
    'Connor',
    'Smith',
    101,
    1,
    0,
    301,
    '2',
    'Marcia',
    'Smith',
    '617-347-2387',
    301,
    0,
    302);
END;
/

BEGIN
    CREATE_COACH(
    'Aaron',
    'Wells',
    102,
    '5894 Fruit st.',
    'Mansfield',
    'MA',
    '02048',
    '508-745-3498',
    'awells_coach@company.com',
    1,
    0,
    0,
    1,
    202,
    'awells',
    'awells_password',
    303,
    'FC Barcelona',
    'Hutchinson-2');
END;
/

BEGIN
    CREATE_Player(
    'Ethan',
    'Wells',
    102,
    1,
    0,
    303,
    '2',
    'Abby',
    'Wells',
    '617-785-4832',
    303,
    0,
    304);
END;
/

BEGIN
    CREATE_COACH(
    'Ruslan',
    'Asmaev',
    103,
    '107 Pebble road',
    'Mansfield',
    'MA',
    '02048',
    '508-809-6543',
    'rasmaev_coach@company.com',
    1,
    0,
    0,
    1,
    203,
    'rasmaev',
    'rasmaev_password',
    305,
    'FC Bayern Munich',
    'Hutchinson-3');
END;
/

BEGIN
    CREATE_Player(
    'Anatoli',
    'Asmaev',
    103,
    1,
    0,
    305,
    '3',
    'Azida',
    'Asmaev',
    '617-879-0905',
    305,
    1,
    306);
END;
/

BEGIN
    CREATE_COACH(
    'Andrey',
    'Belyaev',
    104,
    '2005 Timber road',
    'Mansfield',
    'MA',
    '02048',
    '508-908-9058',
    'abelyaev_coach@company.com',
    1,
    0,
    0,
    1,
    204,
    'abelyaev',
    'abelyaev_password',
    307,
    'Juventus FC',
    'Hutchinson-4');
END;
/

BEGIN
    CREATE_Player(
    'Alex',
    'Belyaev',
    104,
    1,
    0,
    307,
    '3',
    'Tatiana',
    'Belyaev',
    '617-890-0845',
    307,
    1,
    308);
END;
/

BEGIN
    CREATE_COACH(
    'Audrey',
    'Fields',
    105,
    '207 Amber street',
    'Mansfield',
    'MA',
    '02048',
    '508-880-7765',
    'afields_coach@company.com',
    1,
    0,
    0,
    1,
    205,
    'afields',
    'afields_password',
    309,
    'Chelsea FC',
    'Hutchinson-5');
END;
/

BEGIN
    CREATE_Player(
    'Emma',
    'Fields',
    105,
    1,
    0,
    309,
    '4',
    'Brian',
    'Fields',
    '617-791-1298',
    309,
    1,
    310);
END;
/

BEGIN
    CREATE_COACH(
    'Ryan',
    'Wishnevsky',
    106,
    '989 Greenfields ave',
    'Mansfield',
    'MA',
    '02048',
    '508-209-4466',
    'rwish_coach@company.com',
    1,
    0,
    0,
    1,
    206,
    'rwish',
    'rwish_password',
    311,
    'Real Madrid',
    'Hutchinson-6');
END;
/

BEGIN
    CREATE_Player(
    'Jenna',
    'Wishnevsky',
    106,
    1,
    0,
    311,
    '5',
    'Laura',
    'Wishnevsky',
    '617-677-4323',
    311,
    0,
    312);
END;
/

BEGIN
    CREATE_Player(
    'Paul',
    'Wishnevsky',
    106,
    1,
    0,
    311,
    '4',
    'Laura',
    'Wishnevsky',
    '617-677-4323',
    311,
    0,
    313);
END;
/

BEGIN
    CREATE_PARENT(
    'Hanna',
    'Meyer',
    107,
    '1012 North Main st.',
    'Mansfield',
    'MA',
    '02048',
    '508-678-0103',
    'hmeyer@company.com',
    0,
    1,
    0,
    0,
    207,
    'hmeyer',
    'hmeyer_password',
    314);
END;
/

BEGIN
    CREATE_Player(
    'Thomas',
    'Meyer',
    107,
    1,
    0,
    311,
    '3',
    'John',
    'Meyer',
    '617-345-0907',
    305,
    0,
    315);
END;
/

--INSERT values into Skills
INSERT INTO SKILLS(skill_id, skill_description)
VALUES (601, 'short passing');

INSERT INTO SKILLS(skill_id, skill_description)
VALUES (602, 'long passing');

INSERT INTO SKILLS(skill_id, skill_description)
VALUES (603, 'speed');

INSERT INTO SKILLS(skill_id, skill_description)
VALUES (604, 'shooting');

INSERT INTO SKILLS(skill_id, skill_description)
VALUES (605, 'team player');

--INSERT values into Evaluation
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(701, 302, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(702, 302, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(703, 302, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(704, 302, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(705, 302, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);



INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(706, 313, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(707, 313, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(708, 313, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(709, 313, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(710, 313, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(711, 312, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(712, 312, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(713, 312, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(714, 312, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(715, 312, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(716, 310, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(717, 310, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(718, 310, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(719, 310, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(720, 310, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(721, 308, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(722, 308, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(723, 308, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(724, 308, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(725, 308, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(726, 306, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(727, 306, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(728, 306, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(729, 306, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(730, 306, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);


--Wells
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(731, 304, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(732, 304, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(733, 304, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(734, 304, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(735, 304, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

--Meyer
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(856, 315, 601, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(857, 315, 602, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(858, 315, 603, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(859, 315, 604, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(860, 315, 605, TO_DATE('02/09/2020', 'DD/MM/YYYY'), 3);



--Week Two:
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(736, 302, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(737, 302, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(738, 302, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(739, 302, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(740, 302, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);



INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(741, 313, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(742, 313, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(743, 313, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(744, 313, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(745, 313, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(746, 312, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(747, 312, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(748, 312, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(749, 312, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(750, 312, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(751, 310, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(752, 310, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(753, 310, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(754, 310, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(755, 310, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(756, 308, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(757, 308, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(758, 308, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(759, 308, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(760, 308, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(761, 306, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(762, 306, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(763, 306, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(764, 306, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(765, 306, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);


--Wells
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(766, 304, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(767, 304, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(768, 304, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(769, 304, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(770, 304, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

--Meyer
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(771, 315, 601, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(772, 315, 602, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(773, 315, 603, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(774, 315, 604, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(775, 315, 605, TO_DATE('09/09/2020', 'DD/MM/YYYY'), 3);

--Week Three
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(776, 302, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(777, 302, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(778, 302, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(779, 302, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(780, 302, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);



INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(781, 313, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(782, 313, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(783, 313, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(784, 313, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(785, 313, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(786, 312, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(787, 312, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(788, 312, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(789, 312, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(790, 312, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(791, 310, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(792, 310, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(793, 310, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(794, 310, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(795, 310, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(796, 308, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(797, 308, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(798, 308, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(799, 308, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(800, 308, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(801, 306, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(802, 306, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(803, 306, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(804, 306, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(805, 306, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);


--Wells
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(806, 304, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(807, 304, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(808, 304, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(809, 304, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(810, 304, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

--Meyer
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(811, 315, 601, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(812, 315, 602, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(813, 315, 603, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(814, 315, 604, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(815, 315, 605, TO_DATE('16/09/2020', 'DD/MM/YYYY'), 3);


--Week Four:

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(816, 302, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(817, 302, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(818, 302, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(819, 302, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(820, 302, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);



INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(821, 313, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(822, 313, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(823, 313, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(824, 313, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(825, 313, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(826, 312, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(827, 312, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(828, 312, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(829, 312, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(830, 312, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(831, 310, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(832, 310, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(833, 310, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(834, 310, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(835, 310, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(836, 308, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(837, 308, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(838, 308, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(839, 308, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(840, 308, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);


INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(841, 306, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(842, 306, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(843, 306, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(844, 306, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(845, 306, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);


--Wells
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(846, 304, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(847, 304, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(848, 304, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(849, 304, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(850, 304, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

--Meyer
INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(851, 315, 601, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(852, 315, 602, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 2);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(853, 315, 603, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 4);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(854, 315, 604, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 5);

INSERT INTO EVALUATION(evaluation_id, player_id, skill_id, evaluation_date, evaluation_score)
VALUES(855, 315, 605, TO_DATE('23/09/2020', 'DD/MM/YYYY'), 3);



-- INSERT values into Payment_Type
INSERT INTO PAYMENT_TYPE(pmt_type_id, pmt_description)
VALUES(401, 'Annual Fee');

INSERT INTO PAYMENT_TYPE(pmt_type_id, pmt_description)
VALUES(402, 'Uniform');


-- INSERT Values into Payment using stored procedure
BEGIN
    PAYMENT_SP(
    501, 401, 302, TO_DATE('12/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/
    
BEGIN
    PAYMENT_SP(
    502, 401, 304, TO_DATE('10/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

BEGIN
    PAYMENT_SP(
    503, 401, 306, TO_DATE('10/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

BEGIN
    PAYMENT_SP(
    504, 401, 308, TO_DATE('10/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

BEGIN
    PAYMENT_SP(
    505, 401, 313, TO_DATE('12/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

BEGIN
    PAYMENT_SP(
    506, 401, 312, TO_DATE('12/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

BEGIN
    PAYMENT_SP(
    507, 401, 310, TO_DATE('12/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

BEGIN
    PAYMENT_SP(
    508, 401, 313, TO_DATE('12/09/2020', 'DD/MM/YYYY'), 120.00);
END;
/

CREATE OR REPLACE TRIGGER Payment_Changes_trg
BEFORE UPDATE OR INSERT ON Payment
FOR EACH ROW

DECLARE
    old_payment_value DECIMAL(6,2); -- car to contain old payment amount
BEGIN
    -- select the old payment amount from the table Payment
    SELECT payment_amount
    INTO old_payment_value
    FROM Payment
    --condions: same player and same type
    WHERE payment_id = (
            SELECT MAX(payment_id)
            FROM Payment
            WHERE :NEW.player_id = player_id AND :NEW.pmt_type = pmt_type);
    
    IF :NEW.payment_amount <> old_payment_value THEN
        INSERT INTO Payment_Changes(payment_changes_id, old_value, new_value, payment_id, change_date)
        VALUES(NVL((SELECT MAX(payment_changes_id) + 1 FROM Payment_Changes), 1), old_payment_value, 
        :NEW.payment_amount, :NEW.payment_id, trunc(sysdate));
    END IF;
END;
/

-- CHECK the trigger for creating a history table for Payment
BEGIN
    PAYMENT_SP(
    509, 401, 304, TO_DATE('18/09/2020', 'DD/MM/YYYY'), 130.00);
END;
/

BEGIN
    PAYMENT_SP(
    510, 401, 308, TO_DATE('18/09/2020', 'DD/MM/YYYY'), 130.00);
END;
/

BEGIN
    PAYMENT_SP(
    511, 401, 310, TO_DATE('20/09/2020', 'DD/MM/YYYY'), 130.00);
END;
/

BEGIN
    PAYMENT_SP(
    512, 401, 312, TO_DATE('20/09/2020', 'DD/MM/YYYY'), 130.00);
END;
/

BEGIN
    PAYMENT_SP(
    513, 401, 313, TO_DATE('20/09/2020', 'DD/MM/YYYY'), 130.00);
END;
/

--Business Questions and Corresponding Queries

--1. Find the number of players by grade sorted in descending order
SELECT grade, COUNT(person_id) Players
FROM Player
GROUP BY grade
ORDER BY grade DESC;

--2. Find the names of players whose average score is at least 4. Also list skills and average score per skill per player.
SELECT first_name ||' '|| last_name Name, skill_description, AVG(evaluation_score) AS Ave_Score
FROM Evaluation
JOIN Skills ON Skills.skill_id = evaluation.skill_id
JOIN Player ON player.person_id = evaluation.player_id
JOIN Person ON person.person_id = player.person_id
WHERE player_id IN (
        SELECT player_id
        FROM Evaluation
        GROUP BY player_id
        HAVING AVG(evaluation_score) > 3)
GROUP BY skill_description, first_name ||' '|| last_name
ORDER BY AVG(evaluation_score) DESC;

--3. Finding those players who were enrolled last year and now
SELECT person_id, first_name || ' ' || last_name As Name
FROM Person
WHERE person_id IN(
    SELECT person.person_id
    FROM Person
    JOIN Player ON player.person_id = person.person_id
    JOIN Payment ON payment.player_id = person.person_id
    JOIN payment_changes ON payment.payment_id = payment_changes.payment_id
    WHERE old_value = 120 AND new_value = 130);


