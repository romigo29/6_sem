BEGIN EXECUTE IMMEDIATE 'DROP TABLE licenses_locations_coll_tab PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE license_with_locations_nt FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE license_with_locations_obj_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE location_obj_nt FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE license_bulk_demo PURGE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- 2a.Коллекция K2 
CREATE OR REPLACE TYPE location_obj_nt AS TABLE OF location_obj_t;

-- Объект K1: лицензия + вложенная коллекция K2
CREATE OR REPLACE TYPE license_with_locations_obj_t AS OBJECT (
    license_data license_obj_t,
    locations_k2 location_obj_nt
);

CREATE OR REPLACE TYPE license_with_locations_nt AS TABLE OF license_with_locations_obj_t;

CREATE TABLE licenses_locations_coll_tab OF license_with_locations_obj_t
NESTED TABLE locations_k2 STORE AS locations_k2_store;

INSERT INTO licenses_locations_coll_tab
SELECT license_with_locations_obj_t(
           VALUE(l),
           CAST(
               MULTISET(
                   SELECT DISTINCT VALUE(loc)
                   FROM locations_obj_tab loc
                   JOIN Devices d
                       ON d.Location_ID = loc.location_id
                   JOIN Installations i
                       ON i.Device_ID = d.Device_ID
                   WHERE i.License_ID = l.license_id
               ) AS location_obj_nt
           )
       )
FROM licenses_obj_tab l;
COMMIT;


SELECT
    t.license_data.license_id AS license_id,
    t.license_data.product_id AS product_id,
    CARDINALITY(t.locations_k2) AS locations_count
FROM licenses_locations_coll_tab t
ORDER BY t.license_data.license_id;

--2b. Выяснить, является ли членом коллекции К1 какой-то произвольный элемент;
DECLARE
    k1 license_with_locations_nt;
    v_license_id NUMBER := 1;
    v_found NUMBER := 0;
BEGIN
    SELECT VALUE(t)
    BULK COLLECT INTO k1
    FROM licenses_locations_coll_tab t;

    FOR i IN 1 .. k1.COUNT LOOP
        IF k1(i).license_data.license_id = v_license_id THEN
            v_found := 1;
            EXIT;
        END IF;
    END LOOP;

    IF v_found = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Лицензия ID = ' || v_license_id || ' является элементом коллекции K1');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Лицензия ID = ' || v_license_id || ' не является элементом коллекции K1');
    END IF;
END;
/
--2c. Найти пустые коллекции К1;
SELECT
    t.license_data.license_id AS license_id,
    t.license_data.product_id AS product_id,
    CARDINALITY(t.locations_k2) AS locations_count
FROM licenses_locations_coll_tab t
WHERE CARDINALITY(t.locations_k2) = 0;

-- 3. Преобразование вложенной коллекции K2 к реляционному виду

SELECT
    t.license_data.license_id AS license_id,
    t.license_data.product_id AS product_id,
    loc.location_id AS location_id,
    loc.room_number AS room_number,
    loc.planned_growth_seats AS planned_growth_seats
FROM licenses_locations_coll_tab t,
     TABLE(t.locations_k2) loc
ORDER BY
    t.license_data.license_id,
    loc.location_id;
/

-- 4. BULK операции на примере коллекции K1
CREATE TABLE license_bulk_demo (
    license_id NUMBER,
    product_id NUMBER,
    locations_count NUMBER
);

DECLARE
    k1 license_with_locations_nt;

    TYPE number_nt IS TABLE OF NUMBER;

    v_license_ids number_nt := number_nt();
    v_product_ids number_nt := number_nt();
    v_locations_counts number_nt := number_nt();
BEGIN

    SELECT VALUE(t)
    BULK COLLECT INTO k1
    FROM licenses_locations_coll_tab t;

    v_license_ids.EXTEND(k1.COUNT);
    v_product_ids.EXTEND(k1.COUNT);
    v_locations_counts.EXTEND(k1.COUNT);

    FOR i IN 1 .. k1.COUNT LOOP
        v_license_ids(i) := k1(i).license_data.license_id;
        v_product_ids(i) := k1(i).license_data.product_id;
        v_locations_counts(i) := CARDINALITY(k1(i).locations_k2);
    END LOOP;

    FORALL i IN 1 .. v_license_ids.COUNT
        INSERT INTO license_bulk_demo (
            license_id,
            product_id,
            locations_count
        )
        VALUES (
            v_license_ids(i),
            v_product_ids(i),
            v_locations_counts(i)
        );
END;
/

SELECT *
FROM license_bulk_demo
ORDER BY license_id;
/