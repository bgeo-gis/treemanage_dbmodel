SET search_path='SCHEMA_NAME',public;


-----------------
--sequences
-----------------

CREATE SEQUENCE planning_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


CREATE SEQUENCE planning_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-----------------
--plan tables
-----------------
CREATE TABLE planning (
    id integer NOT NULL PRIMARY KEY,
    mu_id integer,
    plan_year integer,
    plan_month_start date,
    plan_month_end date,
    plan_execute_date date,
    plan_code character varying(30),
    work_id integer,
    price numeric(10,2),
    campaign_id integer,
    tree_number integer
);

CREATE TABLE planning_unit (
    id integer NOT NULL PRIMARY KEY,
    campaign_id integer,
    node_id character varying(16),
    plan_date timestamp without time zone DEFAULT now(),
    plan_execute_date date,
    work_id integer,
    size_id integer,
    frequency integer DEFAULT 1,
    price numeric(10,2),
    frequency_executed integer DEFAULT 0
);

-----------------
--add sequence to table
-----------------

ALTER TABLE ONLY planning ALTER COLUMN id SET DEFAULT nextval('planning_id_seq'::regclass);

ALTER TABLE ONLY planning_unit ALTER COLUMN id SET DEFAULT nextval('planning_unit_id_seq'::regclass);

-----------------
--create index
-----------------

CREATE INDEX planning_mu_id_index ON arbrat_viari_test.planning USING btree (mu_id);
CREATE INDEX planning_work_id_index ON arbrat_viari_test.planning USING btree (work_id);
CREATE INDEX planning_campaign_id_index ON arbrat_viari_test.planning USING btree (campaign_id);