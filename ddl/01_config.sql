
SET search_path='SCHEMA_NAME',public;


-----------------
--sequences
-----------------
/*
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
*/

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


CREATE TABLE audit_cat_param_user (
    id text NOT NULL,
    context text,
    description text,
    sys_role_id character varying(30),
    qgis_message text,
    dv_table text,
    dv_column text,
    dv_clause text,
    data_type text,
    label text,
    dv_querytext text,
    dv_parent_id text,
    isenabled boolean,
    layout_id integer,
    layout_order integer,
    project_type character varying,
    isparent boolean,
    dv_querytext_filterc text,
    feature_field_id text,
    feature_dv_parent_value text,
    isautoupdate boolean,
    datatype character varying(30),
    widgettype character varying(30),
    vdefault text
);

CREATE TABLE audit_cat_table (
    id text NOT NULL,
    context text,
    description text,
    sys_role_id character varying(30),
    sys_criticity smallint,
    sys_rows text,
    qgis_role_id character varying(30),
    qgis_criticity smallint,
    qgis_message text,
    sys_sequence text,
    sys_sequence_field text
);

CREATE TABLE audit_check_project (
    id serial NOT NULL,
    table_id text,
    table_host text,
    table_dbname text,
    table_schema text,
    fprocesscat_id integer,
    criticity smallint,
    enabled boolean,
    message text,
    tstamp timestamp without time zone DEFAULT now(),
    user_name text DEFAULT "current_user"(),
    observ text
);
-----------------
--config
-----------------

CREATE TABLE config_param_system (
    id serial NOT NULL,
    parameter character varying(50),
    value text NOT NULL,
    data_type character varying(20),
    context character varying(50),
    descript text,
    label text,
    dv_querytext text,
    dv_filterbyfield text,
    isenabled boolean,
    layout_id integer,
    layout_order integer,
    project_type character varying,
    dv_isparent boolean,
    isautoupdate boolean,
    datatype character varying,
    widgettype character varying,
    tooltip text,
    ismandatory boolean,
    iseditable boolean,
    reg_exp text,
    dv_orderby_id boolean,
    dv_isnullvalue boolean,
    stylesheet json,
    widgetcontrols json,
    placeholder text
);


CREATE TABLE config_param_user (
    id serial NOT NULL PRIMARY KEY,
    parameter character varying(50),
    value text,
    data_type character varying(20),
    cur_user character varying(30),
    context character varying(50),
    descript text,
    ismandatory boolean
);

CREATE TABLE sys_feature_cat (
    id character varying(30) NOT NULL PRIMARY KEY,
    type character varying(30),
    orderby integer,
    tablename character varying(100),
    shortcut_key character varying(100)
);

CREATE TABLE version_tm (
    id serial NOT NULL PRIMARY KEY,
    giswater character varying(16) NOT NULL,
    wsoftware character varying(16) NOT NULL,
    postgres character varying(512) NOT NULL,
    postgis character varying(512) NOT NULL,
    date timestamp(6) without time zone DEFAULT now() NOT NULL,
    language character varying(50) NOT NULL,
    epsg integer NOT NULL
);

CREATE TABLE version (
    id integer DEFAULT nextval('version_id_seq'::regclass) NOT NULL,
    giswater character varying(16) NOT NULL,
    wsoftware character varying(16) NOT NULL,
    postgres character varying(512) NOT NULL,
    postgis character varying(512) NOT NULL,
    date timestamp(6) without time zone DEFAULT now() NOT NULL,
    language character varying(50) NOT NULL,
    epsg integer NOT NULL
);

CREATE TABLE temp_table (
id serial PRIMARY KEY,
fprocesscat_id smallint,
text_column text,
geom_point public.geometry(POINT, SRID_VALUE),
geom_line public.geometry(LINESTRING, SRID_VALUE),
geom_polygon public.geometry(MULTIPOLYGON, SRID_VALUE),
user_name text DEFAULT current_user
);

-----------------
--bmaps config
-----------------

CREATE TABLE config_client_dvalue (
    id serial NOT NULL PRIMARY KEY,
    table_id text,
    column_id text,
    dv_table text,
    dv_key_column text,
    dv_value_column text,
    orderby_value boolean,
    allow_null boolean
);

CREATE TABLE config_client_forms (
    id serial NOT NULL PRIMARY KEY,
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



-----------------
--add sequence to table
-----------------

--ALTER TABLE ONLY config_client_dvalue ALTER COLUMN id SET DEFAULT nextval('config_client_dvalue_id_seq'::regclass);

--ALTER TABLE ONLY config_client_forms ALTER COLUMN id SET DEFAULT nextval('config_client_forms_id_seq'::regclass);

--ALTER TABLE ONLY config_web_forms ALTER COLUMN id SET DEFAULT nextval('config_web_forms_id_seq'::regclass);

--ALTER TABLE ONLY config_web_layer_tab ALTER COLUMN id SET DEFAULT nextval('config_web_layer_tab_id_seq'::regclass);

--ALTER TABLE ONLY version_tm ALTER COLUMN id SET DEFAULT nextval('version_id_seq'::regclass);