
SET search_path='SCHEMA_NAME',public;


-----------------
--sequences
-----------------

CREATE SEQUENCE config_client_dvalue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE config_client_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE config_param_system_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE config_param_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE config_web_fields_id_seq
    START WITH 95
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE config_web_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE config_web_layer_tab_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-----------------
--audit
-----------------

CREATE TABLE audit_cat_error (
    id integer NOT NULL PRIMARY KEY,
    error_message text,
    hint_message text,
    log_level smallint DEFAULT 1,
    show_user boolean DEFAULT true,
    project_type text DEFAULT 'utils'::text,
    CONSTRAINT audit_cat_error_log_level_check CHECK ((log_level = ANY (ARRAY[0, 1, 2, 3])))
);

-----------------
--config
-----------------

CREATE TABLE config_param_system (
    id integer NOT NULL PRIMARY KEY,
    parameter character varying(50),
    value text NOT NULL,
    data_type character varying(20),
    context character varying(50),
    descript text
);


CREATE TABLE config_param_user (
    id integer NOT NULL PRIMARY KEY,
    parameter character varying(50),
    value text,
    data_type character varying(20),
    cur_user character varying(30),
    context character varying(50),
    descript text
);

CREATE TABLE sys_feature_cat (
    id character varying(30) NOT NULL PRIMARY KEY,
    type character varying(30),
    orderby integer,
    tablename character varying(100),
    shortcut_key character varying(100)
);

CREATE TABLE version_tm (
    id integer NOT NULL PRIMARY KEY,
    giswater character varying(16) NOT NULL,
    wsoftware character varying(16) NOT NULL,
    postgres character varying(512) NOT NULL,
    postgis character varying(512) NOT NULL,
    date timestamp(6) without time zone DEFAULT now() NOT NULL,
    language character varying(50) NOT NULL,
    epsg integer NOT NULL
);
-----------------
--bmaps config
-----------------

CREATE TABLE config_client_dvalue (
    id integer NOT NULL PRIMARY KEY,
    table_id text,
    column_id text,
    dv_table text,
    dv_key_column text,
    dv_value_column text,
    orderby_value boolean,
    allow_null boolean
);

CREATE TABLE config_client_forms (
    id integer NOT NULL PRIMARY KEY,
    location_type character varying(50) NOT NULL,
    project_type character varying(50) NOT NULL,
    table_id character varying(50) NOT NULL,
    column_id character varying(50) NOT NULL,
    column_index smallint,
    status boolean,
    width integer,
    alias character varying(50),
    dev1_status boolean,
    dev2_status boolean,
    dev3_status boolean,
    dev_alias character varying(50)
);



CREATE TABLE config_web_fields (
    id integer NOT NULL PRIMARY KEY,
    table_id character varying(50),
    name character varying(30),
    is_mandatory boolean,
    "dataType" text,
    field_length integer,
    num_decimals integer,
    placeholder text,
    label text,
    type text,
    dv_table text,
    dv_id_column text,
    dv_name_column text,
    sql_text text,
    is_enabled boolean,
    orderby integer
);

CREATE TABLE config_web_forms (
    id integer NOT NULL PRIMARY KEY,
    table_id character varying(50),
    query_text text,
    device integer
);

CREATE TABLE config_web_layer_tab (
    id integer NOT NULL PRIMARY KEY,
    table_id character varying(50),
    formtab text,
    formname text,
    formid text
);


-----------------
--add sequence to table
-----------------

ALTER TABLE ONLY config_client_dvalue ALTER COLUMN id SET DEFAULT nextval('config_client_dvalue_id_seq'::regclass);

ALTER TABLE ONLY config_client_forms ALTER COLUMN id SET DEFAULT nextval('config_client_forms_id_seq'::regclass);

ALTER TABLE ONLY config_web_forms ALTER COLUMN id SET DEFAULT nextval('config_web_forms_id_seq'::regclass);

ALTER TABLE ONLY config_web_layer_tab ALTER COLUMN id SET DEFAULT nextval('config_web_layer_tab_id_seq'::regclass);

ALTER TABLE ONLY version_tm ALTER COLUMN id SET DEFAULT nextval('version_id_seq'::regclass);