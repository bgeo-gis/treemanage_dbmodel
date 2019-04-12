
SET search_path='SCHEMA_NAME',public;

DROP VIEW IF EXISTS v_edit_price;
CREATE VIEW v_edit_price AS
 SELECT cat_price.id,
    concat(cat_work.name, '- ', cat_size.name) AS type,
    cat_price.work_id,
    cat_price.size_id,
    cat_price.campaign_id,
    cat_campaign.name,
    cat_price.price
   FROM (((cat_price
     JOIN cat_work ON ((cat_price.work_id = cat_work.id)))
     JOIN cat_size ON ((cat_price.size_id = cat_size.id)))
     JOIN cat_campaign ON ((cat_price.campaign_id = cat_campaign.id)))
  ORDER BY cat_price.work_id, cat_price.size_id;

DROP VIEW IF EXISTS v_plan_mu;
CREATE VIEW v_plan_mu AS
 SELECT row_number() OVER (ORDER BY cat_mu.id) AS row_number,
    cat_mu.id AS mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    cat_mu.work_id,
    cat_work.name AS work_name,
    sum(cat_price.price) AS price_sum,
    cat_price.campaign_id,
    cat_campaign.name AS campaign,
    count(node.node_id) AS tree_number
   FROM ((((((cat_mu
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_work ON ((cat_work.id = cat_mu.work_id)))
     JOIN node ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_price ON (((cat_price.work_id = cat_mu.work_id) AND (node.size_id = cat_price.size_id))))
     LEFT JOIN cat_campaign ON ((cat_price.campaign_id = cat_campaign.id)))
  GROUP BY cat_mu.id, node.mu_id, (concat(cat_location.street_name, ' - ', cat_species.species)), cat_mu.work_id, cat_work.name, cat_price.campaign_id, cat_campaign.name
  ORDER BY cat_mu.id;

DROP VIEW IF EXISTS v_plan_mu_year;
CREATE VIEW v_plan_mu_year AS
 SELECT planning.id,
    planning.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning.campaign_id,
    cat_campaign.name AS campaign,
    planning.plan_month_start,
    planning.plan_month_end,
    planning.plan_execute_date,
    planning.plan_code,
    planning.work_id,
    cat_work.name AS work,
    planning.price,
    planning.tree_number
   FROM (((((planning
     LEFT JOIN cat_mu ON ((planning.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_work ON ((cat_work.id = planning.work_id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning.campaign_id)));

-----------------------
--plan_unit
-----------------------

DROP VIEW IF EXISTS v_ui_planning_unit;
CREATE VIEW v_ui_planning_unit AS
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    planning_unit.node_id,
    cat_location.street_name_concat,
    cat_species.species,
    planning_unit.plan_date,
    planning_unit.plan_execute_date AS execution_date,
    planning_unit.work_id,
    cat_work.name as work,
    node.size_id,
    cat_size.name AS size,
    planning_unit.frequency,
    planning_unit.price
   FROM ((((((planning_unit
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
     LEFT JOIN node ON (((node.node_id)::text = (planning_unit.node_id)::text)))
     LEFT JOIN cat_location ON ((cat_location.id = node.location_id)))
     LEFT JOIN cat_species ON ((cat_species.id = node.species_id)))
     LEFT JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
     LEFT JOIN cat_size ON ((cat_size.id = planning_unit.size_id)));


--views for unitary planning of pruning (poda) and irrigation. Important: change the value of planning_unit.work_id, depending on data introduced in cat_work!!!
DROP VIEW IF EXISTS v_plan_unit_poda;
DROP VIEW IF EXISTS v_plan_unit_trim;
CREATE VIEW v_plan_unit_trim AS 
 SELECT planning_unit.id,
    planning_unit.node_id,
    cat_campaign.name AS campaign,
    cat_location.street_name_concat as location,
    cat_species.species,
    planning_unit.plan_date::date,
    planning_unit.plan_execute_date AS execution_date,
    cat_work.name as work,
    cat_size.name AS size,
    planning_unit.frequency,
    planning_unit.price,
    node.the_geom
   FROM planning_unit
     LEFT JOIN cat_campaign ON cat_campaign.id = planning_unit.campaign_id
     LEFT JOIN node ON node.node_id::text = planning_unit.node_id::text
     LEFT JOIN cat_location ON cat_location.id = node.location_id
     LEFT JOIN cat_species ON cat_species.id = node.species_id
     LEFT JOIN cat_work ON cat_work.id = planning_unit.work_id
     LEFT JOIN cat_size ON cat_size.id = planning_unit.size_id
     WHERE planning_unit.work_id!=11;

DROP VIEW IF EXISTS v_plan_unit_reg;
DROP VIEW IF EXISTS v_plan_unit_irrigation;
CREATE  VIEW v_plan_unit_irrigation AS 
 SELECT planning_unit.id,
    planning_unit.node_id,
    cat_campaign.name AS campaign,
    cat_location.street_name_concat as location,
    cat_species.species,
    planning_unit.plan_date::date,
    planning_unit.plan_execute_date as execution_date,
    cat_work.name as work,
    cat_size.name AS size,
    planning_unit.frequency,
    planning_unit.frequency_executed as frequency_executed,
    planning_unit.price,
    node.the_geom
   FROM planning_unit
     LEFT JOIN cat_campaign ON cat_campaign.id = planning_unit.campaign_id
     LEFT JOIN node ON node.node_id::text = planning_unit.node_id::text
     LEFT JOIN cat_location ON cat_location.id = node.location_id
     LEFT JOIN cat_species ON cat_species.id = node.species_id
     LEFT JOIN cat_work ON cat_work.id = planning_unit.work_id
     LEFT JOIN cat_size ON cat_size.id = planning_unit.size_id
     WHERE planning_unit.work_id=11;


-----------------------
--planned work, executed work
-----------------------

CREATE VIEW v_irrigation_planned AS 
SELECT planning.id,
planning.campaign_id,
'GROUP' as type, 
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
'UNIT',
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
'GROUP' as type, 
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
'UNIT',
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


  --ejecutadas

 CREATE OR REPLACE VIEW v_cut_executed AS 
 SELECT om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_date, om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
       LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE (om_visit_event.value IS NOT NULL AND om_visit_event.value!='2018' and om_visit_event.value::date::text >= selector_date.from_date::text AND om_visit_event.value::date::text <= selector_date.to_date::text or
   om_visit_event.value IS NULL AND om_visit_event.tstamp::timestamp::date >= selector_date.from_date AND om_visit_event.tstamp::timestamp::date <= selector_date.to_date)
  AND parameter_id ilike 'tala%' AND cur_user=current_user ORDER BY node.mu_id;




CREATE OR REPLACE VIEW v_irrigation_executed AS 
 SELECT om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_date, om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
       LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE (om_visit_event.value IS NOT NULL AND om_visit_event.value!='2018' and om_visit_event.value::date::text >= selector_date.from_date::text AND om_visit_event.value::date::text <= selector_date.to_date::text or
   om_visit_event.value IS NULL AND om_visit_event.tstamp::timestamp::date >= selector_date.from_date AND om_visit_event.tstamp::timestamp::date <= selector_date.to_date)
  AND parameter_id ilike 'reg%' AND cur_user=current_user ORDER BY node.mu_id;




CREATE OR REPLACE VIEW v_trim_executed AS 
 SELECT om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_date, om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
       LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
  LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
  LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
  WHERE (om_visit_event.value IS NOT NULL AND om_visit_event.value!='2018' and om_visit_event.value::date::text >= selector_date.from_date::text AND om_visit_event.value::date::text <= selector_date.to_date::text or
   om_visit_event.value IS NULL AND om_visit_event.tstamp::timestamp::date >= selector_date.from_date AND om_visit_event.tstamp::timestamp::date <= selector_date.to_date)
  AND parameter_id ilike 'poda%' AND cur_user=current_user ORDER BY node.mu_id;
