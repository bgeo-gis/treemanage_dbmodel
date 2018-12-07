-----------------
--sequences
-----------------

CREATE SEQUENCE om_visit_cat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE om_visit_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE om_visit_event_photo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE om_visit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE om_visit_parameter_x_parameter_pxp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE om_visit_work_x_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

/*
CREATE SEQUENCE om_visit_x_arc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE om_visit_x_connec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
*/

CREATE SEQUENCE om_visit_x_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE doc_x_visit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-----------------
--om visit
-----------------

CREATE TABLE om_visit (
    id bigint NOT NULL PRIMARY KEY,
    visitcat_id integer,
    ext_code character varying(30),
    startdate timestamp(6) without time zone DEFAULT now(),
    enddate timestamp(6) without time zone DEFAULT now(),
    user_name character varying(50) DEFAULT "current_user"(),
    webclient_id character varying(50),
    expl_id integer,
    the_geom public.geometry(Point,25831),
    descript text,
    is_done boolean
);


CREATE TABLE om_visit_cat (
    id integer NOT NULL PRIMARY KEY,
    name character varying(30),
    type character varying(18),
    startdate date DEFAULT now(),
    enddate date,
    descript text
);



CREATE TABLE om_visit_event (
    id bigint NOT NULL PRIMARY KEY,
    ext_code character varying(16),
    visit_id bigint,
    position_id character varying(50),
    position_value double precision,
    parameter_id character varying(50),
    value text,
    value1 integer,
    value2 integer,
    geom1 double precision,
    geom2 double precision,
    geom3 double precision,
    xcoord double precision,
    ycoord double precision,
    compass double precision,
    tstamp timestamp(6) without time zone DEFAULT now(),
    text text
);



CREATE TABLE om_visit_event_photo (
    id integer NOT NULL PRIMARY KEY,
    visit_id bigint,
    event_id bigint,
    tstamp timestamp(6) without time zone DEFAULT now(),
    value text,
    text text,
    compass double precision
);


CREATE TABLE om_visit_parameter (
    id character varying(50) NOT NULL PRIMARY KEY,
    code character varying(30),
    parameter_type character varying(30),
    feature_type character varying(30),
    data_type character varying(16),
    criticity smallint,
    descript character varying(100),
    form_type character varying(30),
    vdefault text
);

CREATE TABLE om_visit_parameter_cat_action (
    id integer NOT NULL PRIMARY KEY,
    action_name text
);


CREATE TABLE om_visit_parameter_type (
    id character varying(30) NOT NULL PRIMARY KEY,
    descript text
);


CREATE TABLE om_visit_parameter_x_parameter (
    pxp_id bigint NOT NULL PRIMARY KEY,
    parameter_id1 character varying(50),
    parameter_id2 character varying(50),
    action_type integer,
    action_value text
);


CREATE TABLE om_visit_value_criticity (
    id smallint NOT NULL PRIMARY KEY,
    descript text
);


CREATE TABLE om_visit_value_position (
    id character varying(50) NOT NULL PRIMARY KEY,
    feature character varying(30),
    descript character varying(50)
);


CREATE TABLE om_visit_work_x_node (
    id integer NOT NULL PRIMARY KEY,
    node_id character varying(16),
    work_id integer,
    work_date date,
    builder_id integer,
    size_id integer,
    price numeric(12,2),
    units double precision,
    work_cost numeric(12,2),
    event_id integer
);

/*
CREATE TABLE om_visit_x_arc (
    id bigint NOT NULL PRIMARY KEY,
    visit_id bigint,
    arc_id character varying(16)
);


CREATE TABLE om_visit_x_connec (
    id bigint NOT NULL PRIMARY KEY,
    visit_id bigint,
    connec_id character varying(16)
);
*/


CREATE TABLE om_visit_x_node (
    id bigint NOT NULL PRIMARY KEY,
    visit_id bigint,
    node_id character varying(16)
);

SET search_path='SCHEMA_NAME',public;

CREATE TABLE doc_x_visit (
    id integer NOT NULL,
    doc_id character varying(30),
    visit_id integer
);

-----------------
--add sequence to table
-----------------


ALTER TABLE ONLY om_visit ALTER COLUMN id SET DEFAULT nextval('om_visit_id_seq'::regclass);

ALTER TABLE ONLY om_visit_cat ALTER COLUMN id SET DEFAULT nextval('om_visit_cat_id_seq'::regclass);

ALTER TABLE ONLY om_visit_event ALTER COLUMN id SET DEFAULT nextval('om_visit_event_id_seq'::regclass);

ALTER TABLE ONLY om_visit_event_photo ALTER COLUMN id SET DEFAULT nextval('om_visit_event_photo_id_seq'::regclass);

ALTER TABLE ONLY om_visit_parameter_x_parameter ALTER COLUMN pxp_id SET DEFAULT nextval('om_visit_parameter_x_parameter_pxp_id_seq'::regclass);

ALTER TABLE ONLY om_visit_work_x_node ALTER COLUMN id SET DEFAULT nextval('om_visit_work_x_node_id_seq'::regclass);

--ALTER TABLE ONLY om_visit_x_arc ALTER COLUMN id SET DEFAULT nextval('om_visit_x_arc_id_seq'::regclass);

--ALTER TABLE ONLY om_visit_x_connec ALTER COLUMN id SET DEFAULT nextval('om_visit_x_connec_id_seq'::regclass);

ALTER TABLE ONLY om_visit_x_node ALTER COLUMN id SET DEFAULT nextval('om_visit_x_node_id_seq'::regclass);

ALTER TABLE ONLY doc_x_visit ALTER COLUMN id SET DEFAULT nextval('doc_x_visit_id_seq'::regclass);

-----------------
--create index
-----------------
CREATE INDEX visit_index ON om_visit USING gist (the_geom);

CREATE INDEX parameter_index ON om_visit_parameter USING btree (parameter_type);
