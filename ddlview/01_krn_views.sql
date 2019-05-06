
SET search_path='SCHEMA_NAME',public;


DROP VIEW IF EXISTS v_edit_node;
CREATE VIEW v_edit_node AS
 SELECT node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.location_id,
    cat_location.situation,
    node.species_id,
    node.work_id,
    node.work_id2,
    node.size_id,
    cat_species.development_name AS development,
    cat_development.descript AS size_descript,
    node.plant_date,
    node.observ,
    node.the_geom,
    node.state_id AS state,
    node.price_id,
    node.inventory,
    'NODE'::text AS feature_type
   FROM selector_state,
    node
     LEFT JOIN cat_species ON node.species_id = cat_species.id
     LEFT JOIN cat_location ON node.location_id = cat_location.id
     LEFT JOIN cat_development ON cat_species.development_name::text = cat_development.name::text AND node.size_id = cat_development.size_id
  WHERE node.state_id = selector_state.state_id AND selector_state.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS v_plantacion;
CREATE VIEW v_plant AS
 SELECT node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.location_id,
    cat_location.situation,
    node.species_id,
    node.plant_date,
    node.observ,
    node.the_geom
   FROM ((node
     LEFT JOIN cat_species ON ((node.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((node.location_id = cat_location.id)))
  WHERE ((node.state_id = 1) AND (node.plant_date IS NOT NULL));


DROP VIEW IF EXISTS v_edit_verify_node;
CREATE OR REPLACE VIEW v_edit_verify_node AS 
 SELECT verify_node.id,
    verify_node.node_id,
    verify_node.species_id_old,
    species_old.species AS species_old,
    verify_node.location_id_old,
    location_old.street_name_concat AS location_old,
    verify_node.species_id_new,
    species_new.species AS species_new,
    verify_node.location_id_new,
    location_new.street_name_concat AS location_new,
    verify_node.verify_id,
    node.the_geom
   FROM verify_node
     JOIN cat_species species_old ON species_old.id = verify_node.species_id_old
     JOIN cat_species species_new ON species_new.id = verify_node.species_id_new
     JOIN cat_location location_old ON location_old.id = verify_node.location_id_old
     JOIN cat_location location_new ON location_new.id = verify_node.location_id_new
     JOIN node ON node.node_id::text = verify_node.node_id::text
  WHERE verify_node.verify_id IS NULL OR verify_node.verify_id = 3;


DROP VIEW IF EXISTS v_review_cat_mu;
  CREATE OR REPLACE VIEW v_review_cat_mu AS 
 SELECT cat_mu.id,
    cat_mu.location_id,
    cat_mu.species_id,
    cat_mu.work_id
   FROM cat_mu
  WHERE cat_mu.work_id IS NULL;



CREATE VIEW v_irrigation_planned AS 
SELECT planning.id,
planning.campaign_id,
'REG POBLACION' as type, 
planning.mu_id AS feature_id ,
concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
plan_month_start as plan_date, 
plan_execute_date, 
cat_work.name as work,
price,
st_collect(node.the_geom) AS the_geom
  FROM selector_campaign,planning
  LEFT JOIN node ON node.mu_id = planning.mu_id
  LEFT JOIN cat_mu ON planning.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  JOIN cat_work ON cat_work.id=planning.work_id
  WHERE planning.campaign_id=selector_campaign.campaign_id AND cur_user=current_user AND planning.work_id = 11
  GROUP BY planning.id,cat_work.name,cat_location.street_name, cat_species.species
UNION
SELECT 
planning_unit.id, 
planning_unit.campaign_id, 
'REG UNITARIO',
planning_unit.node_id::INTEGER, 
concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
plan_date, 
plan_execute_date, 
cat_work.name,
price,
node.the_geom
  FROM  selector_campaign, planning_unit
  LEFT JOIN node  ON planning_unit.node_id=node.node_id
  LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
   JOIN cat_work ON cat_work.id=planning_unit.work_id
  WHERE planning_unit.campaign_id=selector_campaign.campaign_id AND cur_user=current_user AND planning_unit.work_id = 11;


CREATE VIEW v_cut_planned AS 
SELECT 
planning_unit.id, 
planning_unit.campaign_id, 
planning_unit.node_id::INTEGER, 
concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
plan_date, 
plan_execute_date, 
cat_work.name as work,
price,
node.the_geom
  FROM  selector_campaign, planning_unit
  LEFT JOIN node  ON planning_unit.node_id=node.node_id
   JOIN cat_work ON cat_work.id=planning_unit.work_id
  LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE planning_unit.campaign_id=selector_campaign.campaign_id AND cur_user=current_user AND planning_unit.work_id=9;


create VIEW v_plant_planned AS 
SELECT 
planning_unit.id, 
planning_unit.campaign_id, 
planning_unit.node_id::INTEGER,
concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
plan_date, 
plan_execute_date, 
cat_work.name AS work,
price,
node.the_geom
  FROM  selector_campaign, planning_unit
  LEFT JOIN node  ON planning_unit.node_id=node.node_id
   JOIN cat_work ON cat_work.id=planning_unit.work_id
  LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE planning_unit.campaign_id=selector_campaign.campaign_id AND cur_user=current_user AND planning_unit.work_id=12;


DROP VIEW IF EXISTS v_trim_planned;
CREATE VIEW v_trim_planned AS 
SELECT planning.id,
planning.campaign_id,
'PODA POBLACION' as type, 
planning.mu_id AS feature_id ,
concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
plan_month_start as plan_date, 
plan_execute_date, 
cat_work.name as work,
price,
st_collect(node.the_geom) AS the_geom
  FROM selector_campaign,planning
  LEFT JOIN node ON node.mu_id = planning.mu_id
  LEFT JOIN cat_mu ON planning.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  JOIN cat_work ON cat_work.id=planning.work_id
  WHERE planning.campaign_id=selector_campaign.campaign_id AND cur_user=current_user AND planning.work_id IN (1,2,3,4,5,6,7)
  GROUP BY planning.id,cat_work.name,cat_location.street_name, cat_species.species
UNION
SELECT 
planning_unit.id, 
planning_unit.campaign_id, 
'PODA UNITARIA',
planning_unit.node_id::INTEGER, 
concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
plan_date, 
plan_execute_date, 
cat_work.name,
price,
node.the_geom
  FROM  selector_campaign, planning_unit
  LEFT JOIN node  ON planning_unit.node_id=node.node_id
  LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
   JOIN cat_work ON cat_work.id=planning_unit.work_id
  WHERE planning_unit.campaign_id=selector_campaign.campaign_id AND cur_user=current_user AND planning_unit.work_id IN (1,2,3,4,5,6,7);

DROP VIEW IF EXISTS v_remove_trunk_planned;
CREATE OR REPLACE VIEW v_remove_trunk_planned AS
SELECT planning_unit.id,
    planning_unit.campaign_id,
    'PODA UNITARIA'::text AS type,
    planning_unit.node_id::integer AS feature_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    planning_unit.price,
    node.the_geom
   FROM selector_campaign,
    planning_unit
     LEFT JOIN node ON planning_unit.node_id::text = node.node_id::text
     LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
     JOIN cat_work ON cat_work.id = planning_unit.work_id
  WHERE planning_unit.campaign_id = selector_campaign.campaign_id AND selector_campaign.cur_user = "current_user"()::text AND (planning_unit.work_id = 10);

  --ejecutadas

 CREATE OR REPLACE VIEW v_cut_executed AS 
 SELECT row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
 	om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom,
    om_visit_cat.id AS expl_id,
    om_visit_event.value AS from_date
   FROM selector_date, om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
       LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE (om_visit_event.value IS NOT NULL  and om_visit_event.value::date::text >= selector_date.from_date::text 
    AND om_visit_event.value::date::text <= selector_date.to_date::text )
  AND parameter_id ilike 'tala%' AND cur_user=current_user ORDER BY om_visit_event.id, node.mu_id;




CREATE OR REPLACE VIEW v_irrigation_executed AS 
 SELECT row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
 	om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom,
    om_visit_cat.id AS expl_id,
    om_visit_event.value AS from_date
   FROM selector_date, om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
       LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE (om_visit_event.value IS NOT NULL  and om_visit_event.value::date::text >= selector_date.from_date::text
   AND om_visit_event.value::date::text <= selector_date.to_date::text)
  AND parameter_id ilike 'reg%' AND cur_user=current_user ORDER BY om_visit_event.id, node.mu_id;



CREATE OR REPLACE VIEW v_trim_executed AS 
 SELECT row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    om_visit_event.ext_code,
    node.the_geom,
    om_visit_cat.id AS expl_id,
    om_visit_event.value AS from_date
   FROM selector_date, selector_expl,  om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
     LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE om_visit_event.value::date::text > selector_date.from_date::text AND om_visit_event.value::date::text < selector_date.to_date::text 
  AND selector_expl.expl_id = om_visit_cat.id AND om_visit_event.parameter_id::text ~~* 'poda%'::text AND selector_expl.cur_user = "current_user"()::text 
  AND selector_date.cur_user = "current_user"()::text
  ORDER BY om_visit_event.id, node.mu_id;


CREATE OR REPLACE VIEW v_events_executed AS 
 SELECT row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
 	om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom,
    om_visit_cat.id AS expl_id,
    om_visit_event.value AS from_date
   FROM selector_date, om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
       LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE (om_visit_event.value IS NOT NULL  and om_visit_event.value::date::text >= selector_date.from_date::text AND 
    om_visit_event.value::date::text <= selector_date.to_date::text )
   AND cur_user=current_user ORDER BY om_visit_event.id, node.mu_id;


CREATE OR REPLACE VIEW v_review_node AS 
 SELECT review_node.id,
    review_node.node_id,
    cat_location.street_name,
    cat_species.species,
    cat_size.name AS size,
    review_node.plant_date,
    review_node.observ,
    review_node.the_geom,
    value_state.name AS state,
    review_node.geom_changed,
    review_node.tstamp,
    review_node.cur_user
   FROM review_node
     LEFT JOIN value_state ON review_node.state_id = value_state.id
     LEFT JOIN cat_size ON review_node.size_id = cat_size.id
     LEFT JOIN cat_species ON review_node.species_id = cat_species.id
     LEFT JOIN cat_location ON review_node.location_id = cat_location.id;

