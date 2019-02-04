SET search_path='SCHEMA_NAME',public;


CREATE TABLE selector_state
( id serial NOT NULL PRIMARY KEY,
  state_id integer,
  cur_user text
);

CREATE TABLE selector_campaign
(
  id serial NOT NULL,
  campaign_id integer,
  cur_user text,
  CONSTRAINT selector_campaign_pkey PRIMARY KEY (id)
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
