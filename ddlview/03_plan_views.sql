
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
    sum(cat_price.price) AS sum,
    cat_price.campaign_id,
    cat_campaign.name AS campaign_name,
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
    cat_campaign.name AS campaign_name,
    planning.plan_month_start,
    planning.plan_month_end,
    planning.plan_execute_date,
    planning.plan_code,
    planning.work_id,
    cat_work.name AS work_name,
    planning.price,
    planning.tree_number AS plan_tree_number
   FROM (((((planning
     LEFT JOIN cat_mu ON ((planning.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_work ON ((cat_work.id = planning.work_id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning.campaign_id)));

DROP VIEW IF EXISTS v_plan_unit_poda;
CREATE VIEW v_plan_unit_poda AS
 SELECT planning_unit.id,
    planning_unit.node_id,
    cat_campaign.name AS campana,
    cat_location.street_name_concat AS ubicacion,
    cat_species.species AS especie,
    (planning_unit.plan_date)::date AS fecha_plan,
    planning_unit.plan_execute_date AS fechas_ejecucion,
    cat_work.name AS tipo_poda,
    cat_size.name AS tamano,
    planning_unit.frequency AS podas_planificadas,
    planning_unit.price AS precio_planificado,
    node.the_geom
   FROM ((((((planning_unit
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
     LEFT JOIN node ON (((node.node_id)::text = (planning_unit.node_id)::text)))
     LEFT JOIN cat_location ON ((cat_location.id = node.location_id)))
     LEFT JOIN cat_species ON ((cat_species.id = node.species_id)))
     LEFT JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
     LEFT JOIN cat_size ON ((cat_size.id = planning_unit.size_id)))
  WHERE (planning_unit.work_id <> 11);


DROP VIEW IF EXISTS v_ui_planning_unit;
CREATE VIEW v_ui_planning_unit AS
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    planning_unit.node_id,
    cat_location.street_name_concat,
    cat_species.species,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    planning_unit.work_id,
    cat_work.name,
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
CREATE VIEW v_plan_unit_poda AS 
 SELECT planning_unit.id,
    planning_unit.node_id,
    cat_campaign.name AS campana,
    cat_location.street_name_concat as ubicacion,
    cat_species.species as especie,
    planning_unit.plan_date::date as fecha_plan,
    planning_unit.plan_execute_date as fechas_ejecucion,
    cat_work.name as tipo_poda,
    cat_size.name AS tamano,
    planning_unit.frequency as podas_planificadas,
    planning_unit.price as precio_planificado,
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
CREATE  VIEW v_plan_unit_reg AS 
 SELECT planning_unit.id,
    planning_unit.node_id,
    cat_campaign.name AS campana,
    cat_location.street_name_concat as ubicacion,
    cat_species.species as especie,
    planning_unit.plan_date::date as fecha_plan,
    planning_unit.plan_execute_date as fechas_ejecucion,
    cat_work.name as tipo_poda,
    cat_size.name AS tamano,
    planning_unit.frequency as reg_planificado,
    planning_unit.frequency_executed as reg_ejecutado,
    planning_unit.price as precio_planificado,
    node.the_geom
   FROM planning_unit
     LEFT JOIN cat_campaign ON cat_campaign.id = planning_unit.campaign_id
     LEFT JOIN node ON node.node_id::text = planning_unit.node_id::text
     LEFT JOIN cat_location ON cat_location.id = node.location_id
     LEFT JOIN cat_species ON cat_species.id = node.species_id
     LEFT JOIN cat_work ON cat_work.id = planning_unit.work_id
     LEFT JOIN cat_size ON cat_size.id = planning_unit.size_id
     WHERE planning_unit.work_id=11;