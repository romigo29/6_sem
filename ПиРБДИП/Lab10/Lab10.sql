DROP TABLE products_lob;

CREATE TABLESPACE lob_tbs
DATAFILE 'lob_tbs01.dbf'
SIZE 100M
AUTOEXTEND ON
NEXT 10M
MAXSIZE 500M;


CREATE USER lob_user IDENTIFIED BY lob_password
DEFAULT TABLESPACE lob_tbs
TEMPORARY TABLESPACE temp
QUOTA 50M ON lob_tbs;

GRANT CREATE SESSION TO lob_user;
GRANT CREATE TABLE TO lob_user;
GRANT CREATE PROCEDURE TO lob_user;
GRANT CREATE ANY DIRECTORY TO lob_user;
GRANT DROP ANY DIRECTORY TO lob_user;


CREATE OR REPLACE DIRECTORY LOB_DOC_DIR AS '/opt/oracle/oradata/lob_files';

GRANT READ ON DIRECTORY LOB_DOC_DIR TO lob_user;
GRANT WRITE ON DIRECTORY LOB_DOC_DIR TO lob_user;


--lob_user
CREATE TABLE products_lob (
    foto BLOB,
    doc BFILE
)

INSERT INTO products_lob (foto, doc) VALUES 
        (EMPTY_BLOB(), BFILENAME('LOB_DOC_DIR', 'license_document.pdf')
);

COMMIT;

--Загрузка фото
DECLARE
    v_bfile BFILE;
    v_blob  BLOB;
BEGIN
    v_bfile := BFILENAME('LOB_DOC_DIR', 'product_photo.jpg');

    SELECT foto INTO v_blob
    FROM products_lob
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);

    DBMS_LOB.LOADFROMFILE(
        dest_lob => v_blob,
        src_lob => v_bfile,
        amount => DBMS_LOB.GETLENGTH(v_bfile)
    );

    DBMS_LOB.FILECLOSE(v_bfile);

    COMMIT;
END;
/

SELECT * FROM products_lob;
SELECT DBMS_LOB.FILEEXISTS(doc) AS doc_exists FROM products_lob;