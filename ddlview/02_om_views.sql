
SET search_path='SCHEMA_NAME',public;

DROP VIEW IF EXISTS v_om_visit_work_x_node;
CREATE VIEW v_om_visit_work_x_node AS
 SELECT om_visit_work_x_node.id,
    om_visit_work_x_node.node_id,
    cat_species.species,
    cat_location.street_name_concat,
    cat_work.name AS work,
    om_visit_work_x_node.work_date,
    cat_builder.name AS builder,
    cat_size.name AS size,
    om_visit_work_x_node.price,
    om_visit_work_x_node.units,
    om_visit_work_x_node.work_cost,
    node.the_geom
   FROM ((((((om_visit_work_x_node
     JOIN node ON (((node.node_id)::text = (om_visit_work_x_node.node_id)::text)))
     JOIN cat_species ON ((node.species_id = cat_species.id)))
     JOIN cat_location ON ((node.location_id = cat_location.id)))
     JOIN cat_size ON ((om_visit_work_x_node.size_id = cat_size.id)))
     JOIN cat_work ON ((om_visit_work_x_node.work_id = cat_work.id)))
     JOIN cat_builder ON ((om_visit_work_x_node.builder_id = cat_builder.id)));


DROP VIEW IF EXISTS v_ui_om_visit_x_node;
CREATE VIEW v_ui_om_visit_x_node AS
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit_parameter.descript,
    om_visit.startdate AS visit_start,
    om_visit.enddate AS visit_end,
    om_visit.user_name,
    om_visit.is_done,
    om_visit_event.tstamp,
    om_visit_x_node.node_id,
    om_visit_event.parameter_id,
    om_visit_parameter.parameter_type,
    om_visit_parameter.feature_type,
    om_visit_parameter.form_type,
    om_visit_event.value,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.ext_code AS event_ext_code,
        CASE
            WHEN (a.event_id IS NULL) THEN false
            ELSE true
        END AS gallery,
        CASE
            WHEN (b.visit_id IS NULL) THEN false
            ELSE true
        END AS document
   FROM (((((om_visit
     JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     JOIN om_visit_x_node ON ((om_visit_x_node.visit_id = om_visit.id)))
     LEFT JOIN om_visit_parameter ON (((om_visit_parameter.id)::text = (om_visit_event.parameter_id)::text)))
     LEFT JOIN ( SELECT DISTINCT om_visit_event_photo.event_id
           FROM om_visit_event_photo) a ON ((a.event_id = om_visit_event.id)))
     LEFT JOIN ( SELECT DISTINCT doc_x_visit.visit_id
           FROM doc_x_visit) b ON ((b.visit_id = om_visit.id)))
  ORDER BY om_visit_x_node.node_id;


DROP VIEW IF EXISTS v_ui_om_visitman_x_node;
CREATE VIEW v_ui_om_visitman_x_node AS
 SELECT DISTINCT ON (v_ui_om_visit_x_node.visit_id) v_ui_om_visit_x_node.visit_id,
    v_ui_om_visit_x_node.code,
    om_visit_cat.name AS visitcat_name,
    v_ui_om_visit_x_node.node_id,
    date_trunc('second'::text, v_ui_om_visit_x_node.visit_start) AS visit_start,
    date_trunc('second'::text, v_ui_om_visit_x_node.visit_end) AS visit_end,
    v_ui_om_visit_x_node.user_name,
    v_ui_om_visit_x_node.is_done,
    v_ui_om_visit_x_node.feature_type,
    v_ui_om_visit_x_node.form_type
   FROM (v_ui_om_visit_x_node
     JOIN om_visit_cat ON ((om_visit_cat.id = v_ui_om_visit_x_node.visitcat_id)));


DROP VIEW IF EXISTS v_om_visit_work_x_node_dates;

CREATE OR REPLACE VIEW v_om_visit_work_x_node_dates AS 
 SELECT DISTINCT row_number() OVER (ORDER BY node.mu_id) AS row_number,
    node.node_id,
    node.mu_id AS poblacion_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS poblacion_name,
    cat_size.name AS tamano,
    om_visit_event.parameter_id,
        CASE
            WHEN om_visit_event.value IS NOT NULL THEN om_visit_event.value
            ELSE om_visit_event.tstamp::date::text
        END AS poda_data,
    cat_builder.name AS builder,
    planning.plan_code,
    cat_campaign.id AS campana,
    om_visit_work_x_node.price AS precio,
    node.the_geom
   FROM selector_date,
    node
     JOIN om_visit_x_node ON om_visit_x_node.node_id::text = node.node_id::text
     JOIN om_visit_event ON om_visit_event.visit_id = om_visit_x_node.visit_id
     JOIN cat_mu ON cat_mu.id = node.mu_id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
     LEFT JOIN cat_work ON cat_work.parameter_id::text = om_visit_event.parameter_id::text
     LEFT JOIN om_visit_work_x_node ON om_visit_work_x_node.event_id = om_visit_event.id
     LEFT JOIN cat_builder ON cat_builder.id = om_visit_work_x_node.builder_id
     LEFT JOIN cat_size ON cat_size.id = node.size_id
     LEFT JOIN cat_campaign ON om_visit_event.value::date > cat_campaign.start_date AND om_visit_event.value::date < cat_campaign.end_date OR om_visit_event.tstamp::date > cat_campaign.start_date AND om_visit_event.tstamp::date < cat_campaign.end_date AND om_visit_event.value IS NULL
     LEFT JOIN planning ON node.mu_id = planning.mu_id AND cat_work.id = planning.work_id AND om_visit_event.value::date > planning.plan_month_start AND om_visit_event.value::date < planning.plan_month_end OR om_visit_event.tstamp::date > planning.plan_month_start AND om_visit_event.tstamp::date < planning.plan_month_end AND om_visit_event.value IS NULL
  WHERE om_visit_event.value::date > selector_date.from_date AND om_visit_event.value::date < selector_date.to_date AND selector_date.cur_user = "current_user"()::text OR om_visit_event.tstamp::date > selector_date.from_date AND om_visit_event.tstamp::date < selector_date.to_date AND selector_date.cur_user = "current_user"()::text AND om_visit_event.value IS NULL;