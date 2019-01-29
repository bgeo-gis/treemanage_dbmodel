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
