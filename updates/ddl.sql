SET search_path='SCHEMA_NAME',public;


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


CREATE TABLE selector_species
( species_id integer,
  cur_user text,
  CONSTRAINT selector_species_pkey PRIMARY KEY (species_id,cur_user)
);




ALTER TABLE config_param_system ADD COLUMN label text;
ALTER TABLE config_param_system ADD COLUMN dv_querytext text;
ALTER TABLE config_param_system ADD COLUMN dv_filterbyfield text;
ALTER TABLE config_param_system ADD COLUMN isenabled boolean;
ALTER TABLE config_param_system ADD COLUMN layout_id integer;
ALTER TABLE config_param_system ADD COLUMN layout_order integer;
ALTER TABLE config_param_system ADD COLUMN project_type character varying;
ALTER TABLE config_param_system ADD COLUMN dv_isparent boolean;
ALTER TABLE config_param_system ADD COLUMN isautoupdate boolean;
ALTER TABLE config_param_system ADD COLUMN datatype character varying;
ALTER TABLE config_param_system ADD COLUMN widgettype character varying;
ALTER TABLE config_param_system ADD COLUMN tooltip text;
ALTER TABLE config_param_system ADD COLUMN ismandatory boolean;
ALTER TABLE config_param_system ADD COLUMN iseditable boolean;
ALTER TABLE config_param_system ADD COLUMN reg_exp text;
ALTER TABLE config_param_system ADD COLUMN dv_orderby_id boolean;
ALTER TABLE config_param_system ADD COLUMN dv_isnullvalue boolean;
ALTER TABLE config_param_system ADD COLUMN stylesheet json;
ALTER TABLE config_param_system ADD COLUMN widgetcontrols json;
ALTER TABLE config_param_system ADD COLUMN placeholder text;



-- om_visit
ALTER TABLE om_visit ADD column lot_id integer;
ALTER TABLE om_visit ADD COLUMN class_id integer;
ALTER TABLE om_visit ADD COLUMN status integer;

---OM TABLES

CREATE TABLE om_visit_typevalue(
  parameter_id text PRIMARY KEY,
  id integer NOT NULL,
  idval text,
  descript text
);


CREATE TABLE om_visit_class
( id serial NOT NULL,
  idval character varying(30),
  descript text,
  active boolean DEFAULT true,
  ismultifeature boolean,
  ismultievent boolean,
  feature_type text,
  sys_role_id character varying(30),
  CONSTRAINT om_visit_class_pkey PRIMARY KEY (id)
);

ALTER TABLE om_visit ADD COLUMN feature_type text;
ALTER TABLE om_visit_parameter ADD COLUMN short_descript varchar(30);

CREATE TABLE om_visit_class_x_parameter (
    id serial primary key,
    class_id integer NOT NULL,
    parameter_id character varying(50) NOT NULL
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

  
  CREATE TABLE selector_lot(
  id serial PRIMARY KEY,
  lot_id integer ,
  cur_user text ,
  CONSTRAINT selector_lot_lot_id_cur_user_unique UNIQUE (lot_id, cur_user));

  
  CREATE TABLE om_visit_filetype_x_extension
(
  filetype varchar (30),
  fextension varchar (16),
  CONSTRAINT om_visit_filetype_x_extension_pkey PRIMARY KEY (filetype, fextension)
);


CREATE TABLE cat_users(
id varchar(50) NOT NULL PRIMARY KEY,
"name" varchar(150),
"context" varchar(50)
);

CREATE TABLE exploitation
(
  expl_id integer NOT NULL,
  name character varying(50) NOT NULL,
  CONSTRAINT exploitation_pkey PRIMARY KEY (expl_id)
);

CREATE TABLE selector_expl
(
  expl_id integer NOT NULL,
  cur_user text NOT NULL,
    CONSTRAINT selector_expl_pkey PRIMARY KEY (expl_id, cur_user),
  CONSTRAINT selector_expl_id_fkey FOREIGN KEY (expl_id)
      REFERENCES exploitation (expl_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT expl_id_cur_user_unique UNIQUE (expl_id, cur_user)
);


CREATE TABLE audit_check_project(
id serial PRIMARY KEY,
table_id text,
table_host text,
table_dbname text,
table_schema text,
fprocesscat_id integer,
criticity smallint,
enabled boolean,
message text,
tstamp timestamp DEFAULT now(),
user_name text DEFAULT "current_user"(),
observ text
 );


CREATE TABLE exploitation_x_user
(
  id serial NOT NULL,
  expl_id integer,
  username character varying(50),
  CONSTRAINT exploitation_x_user_pkey PRIMARY KEY (id),
  CONSTRAINT exploitation_x_user_expl_id_fkey FOREIGN KEY (expl_id)
      REFERENCES exploitation (expl_id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT exploitation_x_user_username_fkey FOREIGN KEY (username)
      REFERENCES cat_users (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT exploitation_x_user_expl_username_unique UNIQUE (expl_id, username)
);