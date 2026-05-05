BEGIN EXECUTE IMMEDIATE 'DROP VIEW licenses_ov'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW locations_ov'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE licenses_obj_tab PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE locations_obj_tab PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE license_obj_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE location_obj_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Объектный тип для мест использования лицензий
CREATE OR REPLACE TYPE location_obj_t AS OBJECT (
    location_id NUMBER,
    room_number NVARCHAR2(50),
    planned_growth_seats NUMBER,

    CONSTRUCTOR FUNCTION location_obj_t(
        p_location_id NUMBER,
        p_room_number NVARCHAR2
    ) RETURN SELF AS RESULT,

    MAP MEMBER FUNCTION map_key RETURN NVARCHAR2,
    MEMBER FUNCTION projected_capacity RETURN NUMBER DETERMINISTIC,
    MEMBER PROCEDURE add_growth(p_extra_seats NUMBER)
);

CREATE OR REPLACE TYPE BODY location_obj_t AS
    CONSTRUCTOR FUNCTION location_obj_t(
        p_location_id NUMBER,
        p_room_number NVARCHAR2
    ) RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.location_id := p_location_id;
        SELF.room_number := p_room_number;
        SELF.planned_growth_seats := 0;
        RETURN;
    END;

    MAP MEMBER FUNCTION map_key RETURN NVARCHAR2
    IS
    BEGIN
        RETURN room_number;
    END;

    MEMBER FUNCTION projected_capacity RETURN NUMBER DETERMINISTIC
    IS
    BEGIN
        RETURN NVL(planned_growth_seats, 0);
    END;

    MEMBER PROCEDURE add_growth(p_extra_seats NUMBER)
    IS
    BEGIN
        SELF.planned_growth_seats := NVL(SELF.planned_growth_seats, 0) + NVL(p_extra_seats, 0);
    END;
END;

-- Объектный тип для лицензий
CREATE OR REPLACE TYPE license_obj_t AS OBJECT (
    license_id NUMBER,
    product_id NUMBER,
    purchase_date DATE,
    expiration_date DATE,
    unit_price  NUMBER(18,2),
    total_seats NUMBER,

    CONSTRUCTOR FUNCTION license_obj_t(
        p_license_id NUMBER,
        p_product_id NUMBER,
        p_purchase_date DATE,
        p_unit_price NUMBER,
        p_total_seats NUMBER
    ) RETURN SELF AS RESULT,

    MAP MEMBER FUNCTION map_total_cost RETURN NUMBER,
    MEMBER FUNCTION total_cost RETURN NUMBER DETERMINISTIC,
    MEMBER FUNCTION remaining_days RETURN NUMBER DETERMINISTIC,
    MEMBER PROCEDURE extend_months(p_months NUMBER)
);

CREATE OR REPLACE TYPE BODY license_obj_t AS
    CONSTRUCTOR FUNCTION license_obj_t(
        p_license_id    NUMBER,
        p_product_id    NUMBER,
        p_purchase_date DATE,
        p_unit_price    NUMBER,
        p_total_seats   NUMBER
    ) RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.license_id := p_license_id;
        SELF.product_id := p_product_id;
        SELF.purchase_date   := p_purchase_date;
        SELF.expiration_date := ADD_MONTHS(p_purchase_date, 12);
        SELF.unit_price      := p_unit_price;
        SELF.total_seats     := p_total_seats;
        RETURN;
    END;

    MAP MEMBER FUNCTION map_total_cost RETURN NUMBER
    IS
    BEGIN
        RETURN NVL(unit_price, 0) * NVL(total_seats, 0);
    END;

    MEMBER FUNCTION total_cost RETURN NUMBER DETERMINISTIC
    IS
    BEGIN
        RETURN NVL(unit_price, 0) * NVL(total_seats, 0);
    END;

    MEMBER FUNCTION remaining_days RETURN NUMBER DETERMINISTIC
    IS
    BEGIN
        IF expiration_date IS NULL THEN
            RETURN NULL;
        END IF;
        RETURN TRUNC(expiration_date) - TRUNC(SYSDATE);
    END;

    MEMBER PROCEDURE extend_months(p_months NUMBER)
    IS
    BEGIN
        IF SELF.expiration_date IS NULL THEN
            SELF.expiration_date := ADD_MONTHS(TRUNC(SYSDATE), NVL(p_months, 0));
        ELSE
            SELF.expiration_date := ADD_MONTHS(SELF.expiration_date, NVL(p_months, 0));
        END IF;
    END;
END;

-- 3. Копирование данных из реляционных таблиц в объектные
-- Объектные таблицы
CREATE TABLE locations_obj_tab OF location_obj_t (
    CONSTRAINT pk_locations_obj_tab PRIMARY KEY (location_id),
    CONSTRAINT nn_locations_obj_room CHECK (room_number IS NOT NULL)
);

CREATE TABLE licenses_obj_tab OF license_obj_t (
    CONSTRAINT pk_licenses_obj_tab PRIMARY KEY (license_id),
    CONSTRAINT nn_licenses_obj_purchase CHECK (purchase_date IS NOT NULL),
    CONSTRAINT nn_licenses_obj_price CHECK (unit_price IS NOT NULL),
    CONSTRAINT nn_licenses_obj_seats CHECK (total_seats IS NOT NULL)
);

INSERT INTO locations_obj_tab
SELECT location_obj_t(
           l.location_id,
           l.room_number,
           l.planned_growth_seats
       )
FROM Locations l;

INSERT INTO licenses_obj_tab
SELECT license_obj_t(
           l.license_id,
           l.product_id,
           l.purchase_date,
           l.expiration_date,
           l.unit_price,
           l.total_seats
       )
FROM Licenses l;
COMMIT;

SELECT l.license_id, l.expiration_date, l.total_cost() AS total_cost
FROM licenses_obj_tab l;

SELECT loc.location_id, loc.room_number, loc.projected_capacity() AS projected_capacity
FROM locations_obj_tab loc;


-- 4. Объектные представления 
CREATE OR REPLACE VIEW locations_ov OF location_obj_t
WITH OBJECT IDENTIFIER (location_id) AS
SELECT location_obj_t(
           l.location_id,
           l.room_number,
           l.planned_growth_seats
       )
FROM Locations l;

CREATE OR REPLACE VIEW licenses_ov OF license_obj_t
WITH OBJECT IDENTIFIER (license_id) AS
SELECT license_obj_t(
           l.license_id,
           l.product_id,
           l.purchase_date,
           l.expiration_date,
           l.unit_price,
           l.total_seats
       )
FROM Licenses l;

--Фукнций и методы объектного представления locations
SELECT
    l.location_id,
    l.room_number,
    l.planned_growth_seats,
    l.projected_capacity() AS projected_capacity
FROM locations_ov l;

SELECT
    l.location_id,
    l.room_number,
    l.planned_growth_seats
FROM locations_ov l
ORDER BY VALUE(l);

DECLARE
    v_location location_obj_t;
BEGIN
    SELECT VALUE(l)
    INTO v_location
    FROM locations_ov l
    WHERE l.location_id = 1;

    DBMS_OUTPUT.PUT_LINE('До изменения: ' || v_location.planned_growth_seats);

    v_location.add_growth(2);

    DBMS_OUTPUT.PUT_LINE('После изменения: ' || v_location.planned_growth_seats);
END;

--Конструктор
DECLARE
    v_location location_obj_t;
BEGIN
    v_location := location_obj_t(
        100,
        '505'
    );

    DBMS_OUTPUT.PUT_LINE('ID аудитории: ' || v_location.location_id);
    DBMS_OUTPUT.PUT_LINE('Номер аудитории: ' || v_location.room_number);
    DBMS_OUTPUT.PUT_LINE('Планируемый рост мест: ' || v_location.planned_growth_seats);
END;

--Фукнций и методы объектного представления licenses
SELECT
    l.license_id,
    l.expiration_date,
    l.remaining_days() AS remaining_days
FROM licenses_ov l;

SELECT
    l.license_id,
    l.product_id,
    l.total_cost() AS total_cost
FROM licenses_ov l
ORDER BY VALUE(l);

DECLARE
    v_license license_obj_t;
BEGIN
    SELECT VALUE(l)
    INTO v_license
    FROM licenses_ov l
    WHERE l.license_id = 1;

    DBMS_OUTPUT.PUT_LINE('До продления: ' || TO_CHAR(v_license.expiration_date, 'DD.MM.YYYY'));

    v_license.extend_months(3);

    DBMS_OUTPUT.PUT_LINE('После продления: ' || TO_CHAR(v_license.expiration_date, 'DD.MM.YYYY'));
END;
/

--Конструктор license
DECLARE
    v_license license_obj_t;
BEGIN
    v_license := license_obj_t(
        100,
        2,
        DATE '2026-04-28',
        5000,
        10
    );

    DBMS_OUTPUT.PUT_LINE('ID лицензии: ' || v_license.license_id);
    DBMS_OUTPUT.PUT_LINE('Дата покупки: ' || TO_CHAR(v_license.purchase_date, 'DD.MM.YYYY'));
    DBMS_OUTPUT.PUT_LINE('Дата окончания: ' || TO_CHAR(v_license.expiration_date, 'DD.MM.YYYY'));
    DBMS_OUTPUT.PUT_LINE('Общая стоимость: ' || v_license.total_cost());
END;
/



-- 5. Индексы в объектных таблицах
-- Индекс по атрибуту объектной таблицы
CREATE INDEX idx_licenses_obj_product
ON licenses_obj_tab(product_id);

CREATE INDEX idx_locations_obj_capacity
ON locations_obj_tab l (l.projected_capacity());

EXPLAIN PLAN FOR
SELECT *
FROM licenses_obj_tab l
WHERE l.product_id = 2;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT *
FROM locations_obj_tab l
WHERE l.projected_capacity() > 10;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Индекс по методу объектной таблицы
CREATE INDEX idx_licenses_obj_total_cost
    ON licenses_obj_tab x (x.total_cost());

CREATE INDEX idx_locations_obj_room
    ON locations_obj_tab (room_number);
    
EXPLAIN PLAN FOR
SELECT *
FROM licenses_obj_tab l
WHERE l.total_cost() >= 100000;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT *
FROM locations_obj_tab l
WHERE l.room_number = '101';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

