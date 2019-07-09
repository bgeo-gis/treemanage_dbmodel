SET search_path='SCHEMA_NAME',public;

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
    startdate timestamp(6) without time zone DEFAULT ("left"((date_trunc('second'::text, now()))::text, 19))::timestamp without time zone,
    enddate timestamp(6) without time zone DEFAULT now(),
    user_name character varying(50) DEFAULT "current_user"(),
    webclient_id character varying(50),
    expl_id integer,
    the_geom public.geometry(Point,25831),
    descript text,
    is_done boolean,
    lot_id integer,
    class_id integer,
    status integer,
    feature_type text,
    suspendendcat_id integer
);


CREATE TABLE om_visit_cat (
    id integer NOT NULL PRIMARY KEY,
    name character varying(30),
    type character varying(18),
    startdate date DEFAULT now(),
    enddate date,
    descript text,
    active boolean DEFAULT true,
    extusercat_id integer,
    duration text
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
    text text,
    event_code character varying(30),
    index_val smallint,
    is_last boolean
);



CREATE TABLE om_visit_event_photo (
    id integer NOT NULL PRIMARY KEY,
    visit_id bigint,
    event_id bigint,
    tstamp timestamp(6) without time zone DEFAULT now(),
    value text,
    text text,
    compass double precision,
    hash text,
    filetype text,
    xcoord double precision,
    ycoord double precision,
    fextension character varying(16)
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
    vdefault text,
    short_descript character varying(30)
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

CREATE TABLE selector_lot (
    id integer NOT NULL,
    lot_id integer,
    cur_user text
);

CREATE TABLE om_visit_x_node  (
    id bigint NOT NULL PRIMARY KEY,
    visit_id bigint,
    node_id character varying(16)
);

CREATE TABLE om_visit_x_arc (
    id bigint NOT NULL,
    visit_id bigint,
    arc_id character varying(16)
);

CREATE TABLE doc_x_visit (
    id integer NOT NULL,
    doc_id character varying(30),
    visit_id integer
);


CREATE TABLE om_visit_typevalue (
    parameter_id text NOT NULL,
    id integer NOT NULL,
    idval text,
    descript text
);

CREATE TABLE om_visit_class (
    id serial PRIMARY KEY NOT NULL,
    idval character varying(30),
    descript text,
    active boolean DEFAULT true,
    ismultifeature boolean,
    ismultievent boolean,
    feature_type text,
    sys_role_id character varying(30),
    visit_type integer,
    param_options json
);

CREATE TABLE om_visit_class_x_parameter (
    id serial NOT NULL,
    class_id integer NOT NULL,
    parameter_id character varying(50) NOT NULL
);

CREATE TABLE om_visit_class_type (
    id serial NOT NULL,
    idval character varying(30),
    descript text
);

CREATE TABLE om_visit_file(
  id bigserial NOT NULL PRIMARY KEY,
  visit_id bigint NOT NULL,
  filetype varchar(30),
  hash text,
  url text,
  xcoord float,
  ycoord float,
  compass double precision,
  fextension varchar(16),
  tstamp timestamp(6) without time zone DEFAULT now()
);


CREATE TABLE om_visit_lot(
  id serial NOT NULL primary key,
  idval character varying(30),
  startdate date DEFAULT now(),
  enddate date,
  visitclass_id integer,
  descript text,
  active boolean DEFAULT true,
  team_id integer,
  duration text,
  feature_type text,
  status integer,
  the_geom public.geometry(POLYGON, SRID_VALUE));



CREATE TABLE om_visit_lot_x_arc( 
  lot_id integer,
  arc_id varchar (16),
  code varchar(30),
  status integer,
  observ text,
  constraint om_visit_lot_x_arc_pkey PRIMARY KEY (lot_id, arc_id));

  CREATE TABLE om_visit_lot_x_node( 
  lot_id integer,
  node_id varchar (16),
  code varchar(30),
  status integer,
  observ text,
  constraint om_visit_lot_x_node_pkey PRIMARY KEY (lot_id, node_id));

  CREATE TABLE om_visit_lot_x_connec( 
  lot_id integer,
  connec_id varchar (16),
  code varchar(30),
  status integer,
  observ text,
  constraint om_visit_lot_x_connec_pkey PRIMARY KEY (lot_id, connec_id));


CREATE TABLE om_visit_lot_x_user (
    id serial NOT NULL,
    user_id character varying(16) DEFAULT "current_user"() NOT NULL,
    team_id integer NOT NULL,
    lot_id integer NOT NULL,
    starttime timestamp without time zone DEFAULT ("left"((date_trunc('second'::text, now()))::text, 19))::timestamp without time zone,
    endtime timestamp without time zone,
    the_geom public.geometry(Point,25831)
);


CREATE TABLE om_visit_type (
    id serial NOT NULL,
    idval character varying(30),
    descript text
);


CREATE TABLE om_visitcat_x_user (
    id serial NOT NULL,
    visitcat_id integer,
    username character varying(50)
);

CREATE TABLE om_visit_cat_type (
    id serial NOT NULL,
    idval character varying(30),
    descript text
);

CREATE TABLE om_visit_cat_status (
    id SERIAL NOT NULL,
    idval character varying(30),
    descript text
);

CREATE TABLE om_visit_filetype_x_extension (
    filetype character varying(30) NOT NULL,
    fextension character varying(16) NOT NULL
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
