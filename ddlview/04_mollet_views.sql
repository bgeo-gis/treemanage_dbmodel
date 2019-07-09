

SET search_path='SCHEMA_NAME',public;


--calculate the number of trees in each mu
DROP VIEW IF EXISTS temp_node_x_mu;
CREATE OR REPLACE VIEW temp_node_x_mu AS 
 SELECT node.mu_id,
    count(node.node_id) AS num_arboles_x_poblacion
   FROM node
  GROUP BY node.mu_id;

--temporal table of events
DROP VIEW IF EXISTS temp_podas_2019;
CREATE OR REPLACE VIEW temp_podas_2019 AS 
 SELECT om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    node.the_geom
   FROM om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
  WHERE om_visit_event.value::date::text > '01/11/2018'::text AND om_visit_event.value::date::text < '31/10/2019'::text AND om_visit_event.value::date::text > '2018-11-01'::text AND om_visit_event.value::date::text < '2019-10-31'::text OR om_visit_event.value IS NULL AND om_visit_event.tstamp > '2018-11-01 00:00:00'::timestamp without time zone AND om_visit_event.tstamp < '2019-10-31 00:00:00'::timestamp without time zone
  ORDER BY node.mu_id;

--table of specific works (events) executed during the defined period of time. Calcating the amount of trees on which the work was done.
DROP VIEW IF EXISTS v_podas_2018_2019;
CREATE OR REPLACE VIEW v_podas_2018_2019 AS 
 SELECT DISTINCT row_number() OVER (ORDER BY temp_podas_2019.mu_id) AS row_number,
    temp_podas_2019.mu_id AS poblacion_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS poblacion_name,
    temp_podas_2019.parameter_id AS tipo_poda,
    temp_podas_2019.value,
    temp_podas_2019.tstamp::date AS tstamp,
    temp_podas_2019.builder,
    count(temp_podas_2019.node_id) AS num_poda_x_poblacion,
    temp_node_x_mu.num_arboles_x_poblacion,
    st_collect(temp_podas_2019.the_geom) AS the_geom
   FROM temp_podas_2019
     LEFT JOIN cat_mu ON cat_mu.id = temp_podas_2019.mu_id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
     LEFT JOIN temp_node_x_mu ON temp_node_x_mu.mu_id = temp_podas_2019.mu_id
  WHERE temp_podas_2019.parameter_id::text <> 'arrencada'::text AND temp_podas_2019.parameter_id::text <> 'reg'::text
  GROUP BY temp_podas_2019.mu_id, (concat(cat_location.street_name, ' - ', cat_species.species)), 
  temp_podas_2019.parameter_id, temp_node_x_mu.num_arboles_x_poblacion, temp_podas_2019.value, temp_podas_2019.tstamp, temp_podas_2019.builder
  ORDER BY temp_podas_2019.mu_id;



--View presenting the last plantation
DROP VIEW IF EXISTS v_ultimas_plantaciones;
CREATE OR REPLACE VIEW v_ultimas_plantaciones AS 
 SELECT node.node_id,
    node.mu_id,
    cat_location.street_name_concat AS location,
    cat_species.species,
    node.plant_date,
        CASE
            WHEN node.plant_date >= '2015-09-01'::date AND node.plant_date < '2016-09-01'::date THEN '2015/2016'::text
            WHEN node.plant_date >= '2016-09-01'::date AND node.plant_date < '2017-09-01'::date THEN '2016/2017'::text
            WHEN node.plant_date >= '2017-09-01'::date AND node.plant_date < '2018-09-01'::date THEN '2017/2018'::text
            ELSE NULL::text
        END AS campanya,
    node.the_geom
   FROM node
     LEFT JOIN cat_location ON node.location_id = cat_location.id
     LEFT JOIN cat_species ON node.species_id = cat_species.id
  WHERE node.plant_date IS NOT NULL AND node.plant_date >= '2015-09-01'::date AND node.plant_date < '2018-09-01'::date
  ORDER BY (
        CASE
            WHEN node.plant_date >= '2015-09-01'::date AND node.plant_date < '2016-09-01'::date THEN '2015/2016'::text
            WHEN node.plant_date >= '2016-09-01'::date AND node.plant_date < '2017-09-01'::date THEN '2016/2017'::text
            WHEN node.plant_date >= '2017-09-01'::date AND node.plant_date < '2018-09-01'::date THEN '2017/2018'::text
            ELSE NULL::text
        END);

---

-- View: v_web_*

CREATE OR REPLACE VIEW v_web_node AS 
 SELECT node.node_id AS nid,
    'TREE'::text AS custom_type
   FROM node;

-- DROP VIEW v_web_plant;

CREATE OR REPLACE VIEW v_web_plant AS 
 SELECT node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS "població",
    node.location_id as "localització_id",
    cat_location.situation AS "situació",
 node.species_id as "especie_id",	
    node.plant_date AS "data_plantació",
    node.observ AS "observació"
   FROM node
     LEFT JOIN cat_species ON node.species_id = cat_species.id
     LEFT JOIN cat_location ON node.location_id = cat_location.id
  WHERE node.state_id = 1 AND node.plant_date IS NOT NULL;



-- DROP VIEW v_web_review;

CREATE OR REPLACE VIEW v_web_review AS 
 SELECT review_node.id AS nid,
    'TREE_REVIEW'::text AS custom_type
   FROM review_node;
-- DROP VIEW v_web_review_node;

CREATE OR REPLACE VIEW v_web_review_node AS 
 SELECT review_node.id,
    review_node.node_id,
    cat_location.street_name as "ubicació",
    cat_species.species as especie,
    cat_size.name AS mida,
    review_node.plant_date as "data plantació",
    review_node.observ as "observació",
    value_state.name AS estat,
    review_node.geom_changed,
    review_node.tstamp,
    review_node.cur_user
   FROM review_node
     LEFT JOIN value_state ON review_node.state_id = value_state.id
     LEFT JOIN cat_size ON review_node.size_id = cat_size.id
     LEFT JOIN cat_species ON review_node.species_id = cat_species.id
     LEFT JOIN cat_location ON review_node.location_id = cat_location.id;


--view with the last visit made on every node
CREATE MATERIALIZED VIEW v_last_work AS 
 SELECT DISTINCT ON (node.node_id) node.node_id,
    node.the_geom,
    a.parameter_id,
    a.value
   FROM node
     JOIN LATERAL ( SELECT DISTINCT ON (om_visit_x_node_1.node_id) om_visit_x_node_1.node_id,
            om_visit_event_1.parameter_id,
            om_visit_event_1.value
           FROM om_visit_event om_visit_event_1
             LEFT JOIN om_visit_x_node om_visit_x_node_1 ON om_visit_x_node_1.visit_id = om_visit_event_1.visit_id
          WHERE om_visit_x_node_1.node_id::text = node.node_id::text
          ORDER BY om_visit_x_node_1.node_id, om_visit_event_1.tstamp DESC) a ON true
WITH DATA;


CREATE VIEW v_price_compare AS
 SELECT final_result.type,
    final_result."Campanya 2017/2018",
    final_result."Campanya 2018/2019",
    final_result."Escoles nadal 2018 - Lot 1",
    final_result."Escoles nadal 2018 - Lot 2"
   FROM public.crosstab('SELECT concat(cat_work.name,'' - '',cat_size.name) as type, campaign_id ,price 
FROM cat_price 
JOIN cat_work ON work_id=cat_work.id
JOIN cat_size ON size_id=cat_size.id
WHERE  campaign_id = ANY (''{1, 5, 6, 7}'') ORDER BY 1,2;'::text) final_result(type text, "Campanya 2017/2018" numeric, "Campanya 2018/2019" numeric, "Escoles nadal 2018 - Lot 1" numeric, "Escoles nadal 2018 - Lot 2" numeric);


