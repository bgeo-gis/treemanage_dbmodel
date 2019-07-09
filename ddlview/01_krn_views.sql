
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
    cat_species.color_autumn,
    cat_species.color_flowering,
    cat_species.color_species,
    'NODE'::text AS feature_type
   FROM selector_state,
    node
     LEFT JOIN cat_species ON node.species_id = cat_species.id
     LEFT JOIN cat_location ON node.location_id = cat_location.id
     LEFT JOIN cat_development ON cat_species.development_name::text = cat_development.name::text AND node.size_id = cat_development.size_id
  WHERE node.state_id = selector_state.state_id AND selector_state.cur_user = "current_user"()::text;



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


 

CREATE OR REPLACE VIEW v_events_executed AS 
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom,
    om_visit_cat.id AS expl_id,
    om_visit.startdate AS from_date
   FROM selector_date,
    (((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
  WHERE ((((om_visit.startdate IS NOT NULL) AND (((om_visit.startdate)::date)::text >= (selector_date.from_date)::text)) AND (((om_visit.startdate)::date)::text <= (selector_date.to_date)::text)) AND (selector_date.cur_user = ("current_user"())::text))
  ORDER BY om_visit_event.id, node.mu_id;



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
----------
--irrigation
----------

DROP VIEW  IF EXISTS v_irrigation_x_maintainer;
CREATE VIEW v_irrigation_x_maintainer AS
 SELECT DISTINCT ON (node.node_id) node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    cat_location.situation,
    cat_builder.name AS maintainer,
    node.plant_date,
    node.observ,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    cat_campaign.name AS campaign,
    ((now())::date - (om_visit.startdate)::date) AS last_irrigation,
    node.maintainer_id AS expl_id,
    node.the_geom
   FROM selector_expl,
    selector_campaign,
    ((((((((om_visit_event
     JOIN om_visit ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN ( SELECT om_visit_x_node_1.node_id,
            om_visit_event_1.parameter_id,
            max((om_visit_1.startdate)::date) AS max_tstamp
           FROM ((om_visit_event om_visit_event_1
             JOIN om_visit om_visit_1 ON ((om_visit_1.id = om_visit_event_1.visit_id)))
             JOIN om_visit_x_node om_visit_x_node_1 ON ((om_visit_event_1.visit_id = om_visit_x_node_1.visit_id)))
          WHERE (((om_visit_1.startdate)::date > (('now'::text)::date - '180 days'::interval)) AND ((om_visit_event_1.parameter_id)::text = 'reg'::text))
          GROUP BY om_visit_x_node_1.node_id, om_visit_event_1.parameter_id
          ORDER BY om_visit_x_node_1.node_id, max((om_visit_1.startdate)::date)) a ON ((a.max_tstamp = (om_visit.startdate)::date)))
     RIGHT JOIN node ON (((node.node_id)::text = (a.node_id)::text)))
     JOIN om_visit_x_node ON (((om_visit_x_node.node_id)::text = (node.node_id)::text)))
     LEFT JOIN cat_species ON ((node.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((node.location_id = cat_location.id)))
     LEFT JOIN cat_builder ON ((cat_builder.id = node.maintainer_id)))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE ((((((((om_visit_event.parameter_id IS NULL) OR ((om_visit_event.parameter_id)::text = 'reg'::text)) AND (node.state_id = 1)) AND (node.maintainer_id IS NOT NULL)) AND (selector_expl.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = node.maintainer_id)) AND (selector_campaign.campaign_id = cat_campaign.id)) AND (selector_campaign.cur_user = ("current_user"())::text))
  ORDER BY node.node_id;


drop view if EXISTS v_irrigation_planned;
CREATE VIEW v_irrigation_planned AS
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    (planning_unit.node_id)::integer AS feature_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
  WHERE (((planning_unit.campaign_id = selector_campaign.campaign_id) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 11));


DROP VIEW IF EXISTS v_irrigation_planned_work;
CREATE VIEW v_irrigation_planned_work AS
 SELECT DISTINCT ON (planning_unit.id) (planning_unit.node_id)::integer AS node_id,
    planning_unit.id AS planning_id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom,
    row_number() OVER (ORDER BY planning_unit.id) AS row_id
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
  WHERE ((((planning_unit.plan_execute_date IS NULL) AND (planning_unit.campaign_id = selector_campaign.campaign_id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 11));


DROP VIEW IF EXISTS v_irrigation_executed;
CREATE OR REPLACE VIEW v_irrigation_executed AS 
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    om_visit.startdate::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN planning_unit.plan_execute_date IS NOT NULL THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_campaign,
    selector_expl,
    om_visit
     LEFT JOIN om_visit_event ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     JOIN node ON node.node_id::text = om_visit_x_node.node_id::text
     JOIN om_visit_cat ON om_visit_cat.id = om_visit.visitcat_id
     LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
     LEFT JOIN planning_unit ON node.node_id::text = planning_unit.node_id::text AND om_visit.startdate::date = planning_unit.plan_execute_date AND om_visit.class_id = 1
     LEFT JOIN cat_campaign ON cat_campaign.start_date <= om_visit.startdate::date AND cat_campaign.end_date >= om_visit.startdate::date AND cat_campaign.active = true
  WHERE om_visit.startdate IS NOT NULL AND selector_campaign.campaign_id = cat_campaign.id AND selector_campaign.cur_user = "current_user"()::text AND om_visit_event.parameter_id::text ~~* 'reg%'::text AND selector_expl.expl_id = node.maintainer_id AND selector_expl.cur_user = "current_user"()::text;


DROP VIEW IF EXISTS v_irrigation_historical;
CREATE VIEW v_irrigation_historical AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_date,
    selector_expl,
    (((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND (((om_visit.startdate)::date)::text >= (selector_date.from_date)::text)) AND (((om_visit.startdate)::date)::text <= (selector_date.to_date)::text)) AND ((om_visit_event.parameter_id)::text ~~* 'reg%'::text)) AND (selector_date.cur_user = ("current_user"())::text)) AND (selector_expl.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = node.maintainer_id))
  ORDER BY om_visit_event.id, node.node_id;

----------
--cut
----------

DROP VIEW IF EXISTS v_cut_planned;
CREATE VIEW v_cut_planned AS
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    (planning_unit.node_id)::integer AS node_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
  WHERE (((planning_unit.campaign_id = selector_campaign.campaign_id) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 9));


DROP VIEW IF EXISTS v_cut_planned_work;
CREATE VIEW v_cut_planned_work AS
 SELECT DISTINCT ON (planning_unit.id) (planning_unit.node_id)::integer AS node_id,
    planning_unit.id AS planning_id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom,
    row_number() OVER (ORDER BY planning_unit.id) AS row_id
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
  WHERE ((((planning_unit.plan_execute_date IS NULL) AND (planning_unit.campaign_id = selector_campaign.campaign_id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 9));


DROP VIEW IF EXISTS v_cut_executed;
CREATE VIEW v_cut_executed AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    cat_campaign.name AS campaign,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom,
    om_visit_cat.id AS expl_id
   FROM selector_campaign,
    selector_expl,
    (((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE ((((((om_visit.startdate IS NOT NULL) AND (selector_campaign.campaign_id = cat_campaign.id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = om_visit_cat.id)) AND (selector_expl.cur_user = ("current_user"())::text)) AND ((om_visit_event.parameter_id)::text ~~* 'tala%'::text))
  ORDER BY om_visit_event.id, node.mu_id;


DROP VIEW IF EXISTS v_cut_historical;
CREATE VIEW v_cut_historical AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_date,
    selector_expl,
    (((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND (selector_expl.expl_id = om_visit_cat.id)) AND (selector_expl.cur_user = ("current_user"())::text)) AND ((om_visit_event.parameter_id)::text ~~* 'tala%'::text)) AND ((om_visit.startdate)::date > selector_date.from_date)) AND ((om_visit.startdate)::date < selector_date.to_date)) AND (selector_date.cur_user = ("current_user"())::text))
  ORDER BY om_visit_event.id, node.mu_id;


----------
--plant
----------

DROP VIEW IF EXISTS v_plant;
CREATE VIEW v_plant AS
 SELECT node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.location_id,
    cat_location.situation,
    node.species_id,
    node.plant_date,
    node.observ,
    node.the_geom,
    node.plant_date AS from_date
   FROM selector_date,
    ((node
     LEFT JOIN cat_species ON ((node.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((node.location_id = cat_location.id)))
  WHERE ((((((node.plant_date)::text > (selector_date.from_date)::text) AND ((node.plant_date)::text < (selector_date.to_date)::text)) AND (selector_date.cur_user = ("current_user"())::text)) AND (node.state_id = 1)) AND (node.plant_date IS NOT NULL));


DROP VIEW IF EXISTS v_plant_planned;
CREATE VIEW v_plant_planned AS
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    (planning_unit.node_id)::integer AS node_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
  WHERE (((planning_unit.campaign_id = selector_campaign.campaign_id) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 12));


DROP VIEW IF EXISTS v_plant_planned_work;
CREATE VIEW v_plant_planned_work AS
 SELECT DISTINCT ON (planning_unit.id) (planning_unit.node_id)::integer AS node_id,
    planning_unit.id AS planning_id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom,
    row_number() OVER (ORDER BY planning_unit.id) AS row_id
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
  WHERE ((((planning_unit.plan_execute_date IS NULL) AND (planning_unit.campaign_id = selector_campaign.campaign_id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 12));


DROP VIEW IF EXISTS v_plant_executed;
CREATE VIEW v_plant_executed AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
    planning_unit.plan_execute_date,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    om_visit_event.ext_code,
    om_visit_work_x_node.work_cost,
    node.the_geom,
    om_visit_cat.id AS expl_id
   FROM selector_campaign,
    selector_expl,
    ((((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN om_visit_work_x_node ON ((om_visit_work_x_node.event_id = om_visit_event.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND (selector_campaign.campaign_id = cat_campaign.id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = om_visit_cat.id)) AND ((om_visit_event.parameter_id)::text ~~* 'plant%'::text)) AND (selector_expl.cur_user = ("current_user"())::text)) AND (selector_campaign.cur_user = ("current_user"())::text))
  ORDER BY om_visit_event.id, node.mu_id;


DROP VIEW IF EXISTS v_plant_historical;
CREATE VIEW v_plant_historical AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    om_visit_event.ext_code,
    om_visit_work_x_node.work_cost,
    node.the_geom
   FROM selector_date,
    selector_expl,
    ((((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN om_visit_work_x_node ON ((om_visit_work_x_node.event_id = om_visit_event.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND (selector_expl.expl_id = om_visit_cat.id)) AND ((om_visit_event.parameter_id)::text ~~* 'plant%'::text)) AND (selector_expl.cur_user = ("current_user"())::text)) AND ((om_visit.startdate)::date > selector_date.from_date)) AND ((om_visit.startdate)::date < selector_date.to_date)) AND (selector_date.cur_user = ("current_user"())::text))
  ORDER BY om_visit_event.id, node.mu_id;

----------
--trim
----------

DROP VIEW IF EXISTS v_trim_planned;
CREATE OR REPLACE VIEW v_trim_planned AS 
 SELECT planning.id,
    planning.campaign_id,
    cat_campaign.name AS campaign,
    'PODA POBLACION'::text AS type,
    planning.mu_id AS feature_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning.plan_month_start AS plan_date,
    planning.plan_execute_date,
    cat_work.name AS work,
    planning.price,
    st_collect(node.the_geom) AS the_geom
   FROM selector_campaign,
    planning
     LEFT JOIN node ON node.mu_id = planning.mu_id
     LEFT JOIN cat_mu ON planning.mu_id = cat_mu.id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
     LEFT JOIN cat_campaign ON cat_campaign.id = planning.campaign_id
     JOIN cat_work ON cat_work.id = planning.work_id
  WHERE planning.campaign_id = selector_campaign.campaign_id AND selector_campaign.cur_user = "current_user"()::text AND (planning.work_id = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7]))
  GROUP BY planning.id, cat_work.name, cat_location.street_name, cat_species.species, cat_campaign.name
UNION
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
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
     LEFT JOIN cat_campaign ON cat_campaign.id = planning_unit.campaign_id
     JOIN cat_work ON cat_work.id = planning_unit.work_id
  WHERE planning_unit.campaign_id = selector_campaign.campaign_id AND selector_campaign.cur_user = "current_user"()::text AND (planning_unit.work_id = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7]));


DROP VIEW IF EXISTS v_trim_planned_work;
CREATE OR REPLACE VIEW v_trim_planned_work AS 
 SELECT a.node_id,
    a.planning_id,
    a.campaign_id,
    a.campaign,
    a.type,
    a.feature_id,
    a.mu_name,
    a.plan_date,
    a.work,
    a.price,
    a.the_geom,
    row_number() OVER (ORDER BY a.node_id) AS row_id
   FROM ( SELECT DISTINCT node.node_id,
            planning.id AS planning_id,
            planning.campaign_id,
            cat_campaign.name AS campaign,
            'PODA POBLACION'::text AS type,
            planning.mu_id AS feature_id,
            concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
            planning.plan_month_start AS plan_date,
            cat_work.name AS work,
            planning.price,
            node.the_geom
           FROM selector_campaign,
            planning
             LEFT JOIN node ON node.mu_id = planning.mu_id
             LEFT JOIN cat_mu ON planning.mu_id = cat_mu.id
             LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
             LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
             LEFT JOIN cat_campaign ON cat_campaign.id = planning.campaign_id
             JOIN cat_work ON cat_work.id = planning.work_id
          WHERE planning.plan_execute_date IS NULL AND planning.campaign_id = selector_campaign.campaign_id AND selector_campaign.cur_user = "current_user"()::text AND (planning.work_id = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7]))
        UNION
         SELECT DISTINCT node.node_id,
            planning_unit.id AS planning_id,
            planning_unit.campaign_id,
            cat_campaign.name AS campaign,
            'PODA UNITARIA'::text AS type,
            planning_unit.node_id::integer AS feature_id,
            concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
            planning_unit.plan_date::date AS plan_date,
            cat_work.name AS work,
            planning_unit.price,
            node.the_geom
           FROM selector_campaign,
            planning_unit
             LEFT JOIN node ON planning_unit.node_id::text = node.node_id::text
             LEFT JOIN cat_mu ON node.mu_id = cat_mu.id
             LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
             LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
             LEFT JOIN cat_campaign ON cat_campaign.id = planning_unit.campaign_id
             JOIN cat_work ON cat_work.id = planning_unit.work_id
          WHERE planning_unit.plan_execute_date IS NULL AND planning_unit.campaign_id = selector_campaign.campaign_id AND selector_campaign.cur_user = "current_user"()::text AND (planning_unit.work_id = ANY (ARRAY[1, 2, 3, 4, 5, 6, 7]))) a;


DROP VIEW IF EXISTS v_trim_executed;
CREATE VIEW v_trim_executed AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN planning_unit.plan_execute_date
            WHEN (planning.plan_execute_date IS NOT NULL) THEN planning.plan_execute_date
            ELSE NULL::date
        END AS plan_execute_date,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            WHEN (planning.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    om_visit_event.ext_code,
    om_visit_work_x_node.work_cost,
    node.the_geom,
    om_visit_cat.id AS expl_id
   FROM selector_campaign,
    selector_expl,
    (((((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN om_visit_work_x_node ON ((om_visit_work_x_node.event_id = om_visit_event.id)))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
     LEFT JOIN planning_unit ON (((((((node.node_id)::text = (planning_unit.node_id)::text) AND (om_visit_work_x_node.work_id = planning_unit.work_id)) AND (cat_campaign.start_date <= (om_visit.startdate)::date)) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
     LEFT JOIN planning ON ((((((node.mu_id = planning.mu_id) AND (om_visit_work_x_node.work_id = planning.work_id)) AND (cat_campaign.start_date <= (om_visit.startdate)::date)) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND (selector_campaign.campaign_id = cat_campaign.id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = om_visit_cat.id)) AND ((om_visit_event.parameter_id)::text ~~* 'poda%'::text)) AND (selector_expl.cur_user = ("current_user"())::text)) AND (selector_campaign.cur_user = ("current_user"())::text))
  ORDER BY om_visit_event.id, node.mu_id;


DROP VIEW IF EXISTS v_trim_historical;
CREATE VIEW v_trim_historical AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            WHEN (planning.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    om_visit_event.ext_code,
    om_visit_work_x_node.work_cost,
    node.the_geom
   FROM selector_date,
    selector_expl,
    (((((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN om_visit_work_x_node ON ((om_visit_work_x_node.event_id = om_visit_event.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN planning ON ((((node.mu_id = planning.mu_id) AND ((om_visit.startdate)::date = planning.plan_execute_date)) AND (om_visit.class_id = 2))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND ((om_visit.startdate)::date > selector_date.from_date)) AND ((om_visit.startdate)::date < selector_date.to_date)) AND (selector_date.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = om_visit_cat.id)) AND ((om_visit_event.parameter_id)::text ~~* 'poda%'::text)) AND (selector_expl.cur_user = ("current_user"())::text))
  ORDER BY om_visit_event.id, node.mu_id;

----------
--remove trunk
----------

DROP VIEW IF EXISTS v_remove_trunk;
CREATE VIEW v_remove_trunk AS
 SELECT DISTINCT node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.location_id,
    cat_location.situation,
    node.species_id,
    node.state_id AS state,
    (om_visit.startdate)::date AS cut_date,
    node.the_geom
   FROM selector_state,
    ((((((node
     LEFT JOIN cat_species ON ((node.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((node.location_id = cat_location.id)))
     LEFT JOIN cat_development ON ((((cat_species.development_name)::text = (cat_development.name)::text) AND (node.size_id = cat_development.size_id))))
     LEFT JOIN om_visit_x_node ON (((om_visit_x_node.node_id)::text = (node.node_id)::text)))
     LEFT JOIN om_visit_event ON ((om_visit_x_node.visit_id = om_visit_event.visit_id)))
     LEFT JOIN om_visit ON ((om_visit.id = om_visit_event.visit_id)))
  WHERE ((node.species_id = 216) AND ((om_visit_event.parameter_id)::text = 'tala'::text));


DROP VIEW IF EXISTS v_remove_trunk_planned;
CREATE VIEW v_remove_trunk_planned AS
 SELECT planning_unit.id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    (planning_unit.node_id)::integer AS feature_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
  WHERE (((planning_unit.campaign_id = selector_campaign.campaign_id) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 10));


DROP VIEW IF EXISTS v_remove_trunk_planned_work;
CREATE VIEW v_remove_trunk_planned_work AS
 SELECT DISTINCT ON (planning_unit.id) (planning_unit.node_id)::integer AS node_id,
    planning_unit.id AS planning_id,
    planning_unit.campaign_id,
    cat_campaign.name AS campaign,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    planning_unit.plan_date,
    planning_unit.plan_execute_date,
    cat_work.name AS work,
    node.observ,
    planning_unit.price,
    node.the_geom,
    row_number() OVER (ORDER BY planning_unit.id) AS row_id
   FROM selector_campaign,
    ((((((planning_unit
     LEFT JOIN node ON (((planning_unit.node_id)::text = (node.node_id)::text)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN cat_campaign ON ((cat_campaign.id = planning_unit.campaign_id)))
     JOIN cat_work ON ((cat_work.id = planning_unit.work_id)))
  WHERE ((((planning_unit.plan_execute_date IS NULL) AND (planning_unit.campaign_id = selector_campaign.campaign_id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (planning_unit.work_id = 10));


DROP VIEW IF EXISTS v_remove_trunk_executed;
CREATE VIEW v_remove_trunk_executed AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    cat_campaign.name AS campaign,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom,
    om_visit_cat.id AS expl_id
   FROM selector_campaign,
    selector_expl,
    (((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE ((((((om_visit.startdate IS NOT NULL) AND (selector_campaign.campaign_id = cat_campaign.id)) AND (selector_campaign.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = om_visit_cat.id)) AND (selector_expl.cur_user = ("current_user"())::text)) AND ((om_visit_event.parameter_id)::text ~~* 'destoconar%'::text))
  ORDER BY om_visit_event.id, node.mu_id;


DROP VIEW IF EXISTS v_remove_trunk_historical;
CREATE VIEW v_remove_trunk_historical AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    cat_campaign.name AS campaign,
        CASE
            WHEN (planning_unit.plan_execute_date IS NOT NULL) THEN 'PLANIFICAT'::text
            ELSE 'NO PLANIFICAT'::text
        END AS planning,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM selector_date,
    selector_expl,
    (((((((((om_visit
     LEFT JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
     LEFT JOIN planning_unit ON (((((node.node_id)::text = (planning_unit.node_id)::text) AND ((om_visit.startdate)::date = planning_unit.plan_execute_date)) AND (om_visit.class_id = 1))))
     LEFT JOIN cat_campaign ON ((((cat_campaign.start_date <= (om_visit.startdate)::date) AND (cat_campaign.end_date >= (om_visit.startdate)::date)) AND (cat_campaign.active = true))))
  WHERE (((((((om_visit.startdate IS NOT NULL) AND ((om_visit.startdate)::date > selector_date.from_date)) AND ((om_visit.startdate)::date < selector_date.to_date)) AND (selector_date.cur_user = ("current_user"())::text)) AND (selector_expl.expl_id = om_visit_cat.id)) AND (selector_expl.cur_user = ("current_user"())::text)) AND ((om_visit_event.parameter_id)::text ~~* 'destoconar%'::text))
  ORDER BY om_visit_event.id, node.mu_id;


----------
--incidents
----------

DROP VIEW IF EXISTS v_incident_forecast;
CREATE VIEW v_incident_forecast AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.location_id,
    cat_location.situation,
    node.species_id,
    node.state_id AS state,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    node.the_geom
   FROM selector_state,
    ((((((node
     LEFT JOIN cat_species ON ((node.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((node.location_id = cat_location.id)))
     LEFT JOIN cat_development ON ((((cat_species.development_name)::text = (cat_development.name)::text) AND (node.size_id = cat_development.size_id))))
     LEFT JOIN om_visit_x_node ON (((om_visit_x_node.node_id)::text = (node.node_id)::text)))
     LEFT JOIN om_visit_event ON ((om_visit_x_node.visit_id = om_visit_event.visit_id)))
     LEFT JOIN om_visit ON ((om_visit_x_node.visit_id = om_visit.id)))
  WHERE (((om_visit_event.parameter_id)::text ~~* 'previsio%'::text) AND ((om_visit_event.value2 IS NULL) OR (om_visit_event.value2 = 1)));
