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