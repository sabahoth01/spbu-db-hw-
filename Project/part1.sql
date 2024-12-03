CREATE DATABASE "securityOrganisation"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    STRATEGY = WAL_LOG -- стандартный метод, используемый в субд для обеспечения целостности и долговечности данных.
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

COMMENT ON DATABASE "securityOrganisation"
    IS 'Database for final project on private security organisation , SPBU first semester, 2024';

