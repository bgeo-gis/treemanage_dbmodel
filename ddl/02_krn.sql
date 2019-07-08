SET search_path='SCHEMA_NAME',public;

-----------------
--sequences
-----------------

CREATE SEQUENCE cat_builder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE cat_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE cat_development_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE cat_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE cat_mu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE cat_price_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE cat_size_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE cat_species_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE value_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE cat_work_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE node_id_seq
    START WITH 11
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE review_node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
-----------------
--catalogs
-----------------

CREATE TABLE cat_builder (
    id integer NOT NULL PRIMARY KEY,
    name character varying(150)
);

CREATE TABLE cat_campaign (
    id integer DEFAULT nextval('cat_campaign_id_seq'::regclass) NOT NULL PRIMARY KEY,
    name character varying(150),
    start_date date,
    end_date date,
    active boolean
);

CREATE TABLE cat_development (
    id integer NOT NULL PRIMARY KEY,
    name character varying(150),
    size_id integer,
    descript character varying(250)
);

CREATE TABLE cat_location (
    id integer NOT NULL PRIMARY KEY,
    code character varying(50),
    street_name character varying(150),
    location_type character varying(150),
    street_name_old character varying(150),
    street_name_concat character varying(200),
    situation character varying(150),
    the_geom_line public.geometry(LineString,SRID_VALUE),
    the_geom_pol public.geometry(Polygon,SRID_VALUE)
);

CREATE TABLE cat_mu (
    id integer NOT NULL PRIMARY KEY,
    location_id integer,
    species_id integer,
    work_id integer
);

CREATE TABLE cat_price (
    id integer NOT NULL PRIMARY KEY,
    work_id integer,
    size_id integer,
    price numeric(10,2),
    campaign_id integer
);

CREATE TABLE cat_size (
    id integer NOT NULL PRIMARY KEY,
    name character varying(150)
);


CREATE TABLE cat_species (
    id integer NOT NULL PRIMARY KEY,
    species character varying(150),
    common_name character varying(150),
    species_old character varying(150),
    development_name character varying(150),
    color_autumn text,
    color_flowering text,
    color_species text
);


CREATE TABLE value_state (
    id integer NOT NULL PRIMARY KEY,
    name character varying(150)
);


CREATE TABLE cat_work (
    id integer NOT NULL PRIMARY KEY,
    name character varying(150),
    parameter_id character varying(50)
);

CREATE TABLE cat_verify(
  id integer NOT NULL PRIMARY KEY,
  name character varying(50)
);
-----------------
--node
-----------------

CREATE TABLE node (
    node_id character varying(16) DEFAULT nextval('node_id_seq'::regclass) NOT NULL PRIMARY KEY,
    code character varying(30),
    mu_id integer,
    location_id integer,
    species_id integer,
    work_id integer,
    work_id2 integer,
    size_id integer,
    plant_date date,
    observ text,
    the_geom public.geometry(Point,SRID_VALUE),
    state_id integer,
    price_id integer,
    inventory boolean,
    builder_id integer,
    maintainer_id integer
);

--table review can be used to review all the changes in the node table
CREATE TABLE review_node (
    id integer NOT NULL PRIMARY KEY,
    node_id character varying(16),
    mu_id integer,
    location_id integer,
    species_id integer,
    work_id integer,
    work_id2 integer,
    size_id integer,
    plant_date date,
    observ text,
    the_geom public.geometry(Point,SRID_VALUE),
    state_id integer,
    price_id integer,
    tstamp timestamp without time zone DEFAULT now(),
    cur_user text,
    geom_changed boolean
);


--table verify can be used to review only the changes in the fields location and species of the node table
CREATE TABLE verify_node
(
  id serial NOT NULL PRIMARY KEY,
  node_id character varying(16),
  species_id_old integer,
  location_id_old integer,
  species_id_new integer,
  location_id_new integer,
  verify_id integer
);


--barrios
CREATE TABLE cat_zone
(id integer NOT NULL PRIMARY KEY,
code character varying(30),
name character varying(150),
descript text,
the_geom public.geometry(Polygon,SRID_VALUE)
);

CREATE TABLE cat_address
(id integer NOT NULL PRIMARY KEY,
code character varying(50),
cat_zone integer,
location_id integer,
street_number character varying(200),
the_geom public.geometry(Point,SRID_VALUE)
);

CREATE TABLE exploitation
(
  expl_id integer NOT NULL,
  name character varying(50) NOT NULL,
  CONSTRAINT exploitation_pkey PRIMARY KEY (expl_id)
);


CREATE TABLE exploitation_x_user
(  id serial NOT NULL PRIMARY KEY,
  expl_id integer,
  username character varying(50)
  );

CREATE TABLE cat_users (
    id character varying(50) NOT NULL,
    name character varying(150),
    context character varying(50)
);

CREATE TABLE cat_team (
    id serial NOT NULL,
    idval text,
    descript text,
    active boolean DEFAULT true
);

CREATE TABLE om_visit_team_x_user (
    team_id integer NOT NULL,
    user_id character varying(16) NOT NULL,
    starttime timestamp without time zone DEFAULT now(),
    endtime timestamp without time zone
);


-----------------
--SELECTORS 
-----------------
-- DROP TABLE selector_date;

CREATE TABLE selector_date
( id serial NOT NULL PRIMARY KEY,
  from_date date,
  to_date date,
  context character varying(30),
  cur_user text
);

CREATE TABLE selector_state
(  state_id integer,
  cur_user text,
  CONSTRAINT selector_state_pkey PRIMARY KEY (state_id,cur_user)
);

CREATE TABLE selector_campaign
( campaign_id integer,
  cur_user text,
  CONSTRAINT selector_campaign_pkey PRIMARY KEY (campaign_id,cur_user)
);

CREATE TABLE selector_composer (
    field_id text NOT NULL,
    field_value text,
    user_name text NOT NULL
);

CREATE TABLE selector_expl (
    expl_id integer NOT NULL,
    cur_user text NOT NULL
);

CREATE TABLE selector_species (
    species_id integer NOT NULL,
    cur_user text NOT NULL
);

-----------------
--add sequence to table
-----------------

ALTER TABLE ONLY cat_builder ALTER COLUMN id SET DEFAULT nextval('cat_builder_id_seq'::regclass);

ALTER TABLE ONLY cat_location ALTER COLUMN id SET DEFAULT nextval('cat_location_id_seq'::regclass);

ALTER TABLE ONLY cat_mu ALTER COLUMN id SET DEFAULT nextval('cat_mu_id_seq'::regclass);

ALTER TABLE ONLY cat_price ALTER COLUMN id SET DEFAULT nextval('cat_price_id_seq'::regclass);

ALTER TABLE ONLY cat_size ALTER COLUMN id SET DEFAULT nextval('cat_size_id_seq'::regclass);

ALTER TABLE ONLY cat_species ALTER COLUMN id SET DEFAULT nextval('cat_species_id_seq'::regclass);

ALTER TABLE ONLY value_state ALTER COLUMN id SET DEFAULT nextval('value_state_id_seq'::regclass);

ALTER TABLE ONLY cat_work ALTER COLUMN id SET DEFAULT nextval('cat_work_id_seq'::regclass);

ALTER TABLE ONLY review_node ALTER COLUMN id SET DEFAULT nextval('review_node_id_seq'::regclass);

-----------------
--create index
-----------------

CREATE INDEX node_mu_id_index ON node USING btree (mu_id);
CREATE INDEX node_location_id_index ON node USING btree (location_id);
CREATE INDEX node_species_id_index ON node USING btree (species_id);
CREATE INDEX node_work_id_index ON node USING btree (work_id);
CREATE INDEX node_mwork_id2_index ON node USING btree (work_id2);
CREATE INDEX node_size_id_index ON node USING btree (size_id);
CREATE INDEX node_builder_id_index ON node USING btree (builder_id);


CREATE INDEX cat_mu_species_id_index ON cat_mu USING btree (species_id);
CREATE INDEX cat_mu_location_id_index ON cat_mu USING btree (location_id);
CREATE INDEX cat_mu_work_id_index ON cat_mu USING btree (work_id);

CREATE INDEX cat_price_work_id_index ON cat_price USING btree (work_id);
CREATE INDEX cat_price_size_id_index ON cat_price USING btree (size_id);
CREATE INDEX cat_price_campaign_id_index ON cat_price USING btree (campaign_id);
