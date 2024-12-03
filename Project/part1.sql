-- CREATE DATABASE "securityOrganisation"
--     WITH
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     STRATEGY = WAL_LOG -- стандартный метод, используемый в субд для обеспечения целостности и долговечности данных.
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1
--     IS_TEMPLATE = False;
--
-- COMMENT ON DATABASE "securityOrganisation"
--     IS 'Database for final project on private security organisation , SPBU first semester, 2024';

-- помните, что типы перечислений(ENUM) чувствительны к регистру символов.
CREATE TYPE base_status AS ENUM ('OPEN', 'CLOSED');
CREATE TABLE base
(
    base_id  SERIAL PRIMARY KEY,
    location TEXT NOT NULL,
    status   base_status NOT NULL
);

-- Meal, Ready-to-Eat (MRE) : Блюдо, готовое к употреблению (MRE)
-- это автономный индивидуальный военный рацион Соединенных Штатов, используемый Вооруженными силами Соединенных Штатов и Министерством обороны.
CREATE TABLE mre
(
    mre_id         SERIAL PRIMARY KEY,
    breakfast      TEXT     NOT NULL,
    lunch          TEXT     NOT NULL,
    dinner         TEXT     NOT NULL,
    food_additives TEXT,
    kkal           SMALLINT NOT NULL CHECK (kkal >= 3000 AND kkal <= 5000),
    proteins       SMALLINT NOT NULL CHECK (proteins >= 50 AND proteins <= 200),
    fats           SMALLINT NOT NULL CHECK (fats >= 44 AND fats <= 100 ),
    carbohydrate   SMALLINT NOT NULL CHECK (carbohydrate >= 250 AND carbohydrate <= 400)
);

CREATE TABLE equipment
(
    equip_id      SERIAL PRIMARY KEY,
    camouflage    TEXT,
    communication TEXT,
    intelligence  TEXT,
    medical       TEXT,
    mre_id        INTEGER NOT NULL REFERENCES mre ON DELETE RESTRICT, --foreign key
    extra         TEXT
);

CREATE TYPE force AS ENUM ('GF', 'NAVY', 'AF');

--numeric(10,2):Точность (10): указывает общее количество значащих цифр, которые могут быть сохранены в этом столбце. В этом случае зарплата может содержать до 10 цифр.
--Шкала (2): Указывает количество цифр, которые могут быть сохранены справа от десятичной точки. Здесь это означает, что для обозначения дробной части (центов) можно использовать 2 цифры.

CREATE TABLE position
(
    pos_id   SERIAL PRIMARY KEY,
    name     VARCHAR(255)           NOT NULL,
    salary_rub   NUMERIC(10, 2) NOT NULL CHECK (salary_rub >= 50000),
    rank     VARCHAR(100),
    equip_id INTEGER        REFERENCES equipment ON DELETE SET NULL, --foreign key
    forces   force
);

CREATE TABLE employee
(
    emp_id        SERIAL PRIMARY KEY,
    name          VARCHAR(255)    NOT NULL,
    surname       VARCHAR(255)    NOT NULL,
    date_of_birth DATE    NOT NULL CHECK (DATE_PART('year', AGE(date_of_birth)) >= 18),
    CHECK (DATE_PART('year', AGE(date_of_birth)) <= 60),   -- Maximum age 60
    education     TEXT,
    hiring_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    pos_id        INTEGER NOT NULL REFERENCES position ON DELETE RESTRICT, --foreign key
    is_married    BOOLEAN NOT NULL,
    base_id       INTEGER REFERENCES base ON DELETE SET NULL
);

CREATE TYPE blood_type AS ENUM ('A', 'B', 'O','AB','AO','BO');
CREATE TABLE medical_card
(
    med_id    SERIAL PRIMARY KEY,
    emp_id    INTEGER  NOT NULL REFERENCES employee ON DELETE CASCADE, --foreign key
    height_cm SMALLINT NOT NULL CHECK (height_cm >= 150 AND height_cm <= 250),
    weight_kg SMALLINT NOT NULL CHECK (weight_kg >= 50 AND weight_kg <= 100),
    diseases  TEXT,
    blood     blood_type  NOT NULL, -- AA, AO, AB,
    gender    VARCHAR(1)  NOT NULL -- M OR F
);

CREATE TABLE weapon
(
    weapon_id        SERIAL PRIMARY KEY,
    name             VARCHAR(255) NOT NULL,
    type             VARCHAR(255) NOT NULL,
    caliber          REAL CHECK (caliber > 0),
    rate_of_fire     SMALLINT CHECK (rate_of_fire > 0),
    sighting_range_m SMALLINT CHECK (sighting_range_m > 0)
);

CREATE TYPE ex_status AS ENUM ('NOT_STARTED', 'STARTED', 'ON_GOING','PENDING','FINISHED');
CREATE TABLE campaign
(
    camp_id          SERIAL PRIMARY KEY,
    name             VARCHAR(255)           NOT NULL,
    customer         VARCHAR(255)           NOT NULL,
    earning          NUMERIC(11, 2) NOT NULL CHECK (earning >= 0),
    spending         NUMERIC(11, 2) NOT NULL CHECK (spending >= 0),
    execution_status ex_status
);

CREATE TABLE mission
(
    miss_id             SERIAL PRIMARY KEY,
    camp_id             INTEGER NOT NULL REFERENCES campaign ON DELETE CASCADE,
    start_date_and_time TIMESTAMP,
    end_date_and_time   TIMESTAMP,
    legal_status        BOOLEAN NOT NULL,
    departure_location  VARCHAR(255),
    arrival_location    VARCHAR(255),
    enemies             TEXT
);

CREATE TYPE trans_status AS ENUM ('VERIFIED', 'NEED_VERIFICATION', 'MAINTAINED','NOT_MAINTAINED','OUT_OF_USE');
CREATE TABLE transport
(
    trans_id SERIAL PRIMARY KEY,
    name     VARCHAR(100) NOT NULL,
    type     VARCHAR(100) NOT NULL,
    status   trans_status NOT NULL
);

CREATE TABLE equip_weapon
(
    equip_id  INTEGER NOT NULL REFERENCES equipment,
    weapon_id INTEGER NOT NULL REFERENCES weapon,
    PRIMARY KEY (equip_id, weapon_id)
);

CREATE TABLE missions_transport
(
    miss_id  INTEGER NOT NULL REFERENCES mission,
    trans_id INTEGER NOT NULL REFERENCES transport,
    PRIMARY KEY (miss_id, trans_id)
);

CREATE TABLE inspection
(
    emp_id       INTEGER NOT NULL REFERENCES employee,
    trans_id     INTEGER NOT NULL REFERENCES transport,
    service_date DATE    NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (trans_id, emp_id)
);

CREATE TABLE missions_emp
(
    miss_id INTEGER NOT NULL REFERENCES mission,
    emp_id  INTEGER NOT NULL REFERENCES employee,
    PRIMARY KEY (miss_id, emp_id)
);

