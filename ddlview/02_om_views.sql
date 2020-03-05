
SET search_path='SCHEMA_NAME',public;

DROP VIEW IF EXISTS v_om_visit_work_x_node;
CREATE OR REPLACE VIEW v_om_visit_work_x_node AS 
 SELECT om_visit_work_x_node.id,
    om_visit_event.visit_id,
    om_visit_work_x_node.event_id,
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
    om_visit_event.ext_code,
    sys_combo_values.idval AS status,
    node.the_geom
   FROM om_visit_work_x_node
     JOIN node ON node.node_id::text = om_visit_work_x_node.node_id::text
     LEFT JOIN om_visit_event ON om_visit_work_x_node.event_id = om_visit_event.id
     LEFT JOIN cat_species ON node.species_id = cat_species.id
     LEFT JOIN cat_location ON node.location_id = cat_location.id
     LEFT JOIN cat_size ON om_visit_work_x_node.size_id = cat_size.id
     LEFT JOIN cat_work ON om_visit_work_x_node.work_id = cat_work.id
     LEFT JOIN cat_builder ON om_visit_work_x_node.builder_id = cat_builder.id
     LEFT JOIN om_visit ON om_visit.id = om_visit_event.visit_id
     LEFT JOIN sys_combo_values ON sys_combo_values.id = om_visit.status AND sys_combo_values.sys_combo_cat_id = 3;



-- View: v_ui_om_visit_x_node


DROP VIEW IF EXISTS v_ui_om_visit_x_node;
CREATE VIEW v_ui_om_visit_x_node AS
 SELECT om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.ext_code AS code,
    om_visit.visitcat_id,
    om_visit_cat.name AS visitcat_name,
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
   FROM ((((((om_visit
     JOIN om_visit_cat ON ((om_visit.visitcat_id = om_visit_cat.id)))
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
 SELECT DISTINCT ON (om_visit_work_x_node.event_id) row_number() OVER (ORDER BY node.mu_id) AS row_id,
    om_visit_work_x_node.event_id,
    om_visit_event.visit_id,
    node.node_id,
    node.mu_id AS poblacion_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS poblacion_name,
    cat_size.name AS tamano,
    om_visit_event.parameter_id,
    om_visit_work_x_node.work_date,
    cat_builder.name AS builder,
    planning.plan_code,
    cat_campaign.id AS campana,
    om_visit_work_x_node.price AS precio,
    om_visit_event.ext_code,
    sys_combo_values.idval AS status,
    node.the_geom
   FROM selector_date,
    node
     JOIN om_visit_x_node ON om_visit_x_node.node_id::text = node.node_id::text
     JOIN om_visit_event ON om_visit_event.visit_id = om_visit_x_node.visit_id
     JOIN om_visit ON om_visit_event.visit_id = om_visit.id
     JOIN cat_mu ON cat_mu.id = node.mu_id
     LEFT JOIN cat_species ON cat_mu.species_id = cat_species.id
     LEFT JOIN cat_location ON cat_mu.location_id = cat_location.id
     LEFT JOIN cat_work ON cat_work.parameter_id::text = om_visit_event.parameter_id::text
     LEFT JOIN om_visit_work_x_node ON om_visit_work_x_node.event_id = om_visit_event.id
     LEFT JOIN cat_builder ON cat_builder.id = om_visit_work_x_node.builder_id
     LEFT JOIN cat_size ON cat_size.id = node.size_id
     LEFT JOIN cat_campaign ON om_visit.startdate::date > cat_campaign.start_date AND om_visit.startdate::date < cat_campaign.end_date OR om_visit_event.tstamp::date > cat_campaign.start_date AND om_visit_event.tstamp::date < cat_campaign.end_date AND om_visit.startdate IS NULL
     LEFT JOIN planning ON node.mu_id = planning.mu_id AND cat_work.id = planning.work_id AND om_visit.startdate::date > planning.plan_month_start AND om_visit.startdate::date < planning.plan_month_end OR om_visit_event.tstamp::date > planning.plan_month_start AND om_visit_event.tstamp::date < planning.plan_month_end AND om_visit.startdate IS NULL
     LEFT JOIN sys_combo_values ON sys_combo_values.id = om_visit.status AND sys_combo_values.sys_combo_cat_id = 3
  WHERE om_visit_work_x_node.work_date > selector_date.from_date AND om_visit_work_x_node.work_date < selector_date.to_date AND selector_date.cur_user = "current_user"()::text
  ORDER BY om_visit_work_x_node.event_id;

  
CREATE OR REPLACE VIEW ve_visit_node_insp AS 
 SELECT om_visit_x_node.visit_id,
    om_visit_x_node.node_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    om_visit.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.lot_id,
    om_visit.status,
    a.param_1 AS sediments_node,
    a.param_2 AS desperfectes_node,
    a.param_3 AS neteja_node
   FROM om_visit
     JOIN om_visit_class ON om_visit_class.id = om_visit.class_id
     JOIN om_visit_x_node ON om_visit.id = om_visit_x_node.visit_id
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1,
            ct.param_2,
            ct.param_3
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value 
            FROM om_visit JOIN om_visit_event ON om_visit.id= om_visit_event.visit_id 
            JOIN om_visit_class on om_visit_class.id=om_visit.class_id
            JOIN om_visit_class_x_parameter on om_visit_class_x_parameter.parameter_id=om_visit_event.parameter_id 
            where om_visit_class.ismultievent = TRUE ORDER  BY 1,2'::text, ' VALUES (''sediments_node''),(''desperfectes_node''),(''neteja_node'')'::text) ct(visit_id integer, param_1 text, param_2 text, param_3 text)) a ON a.visit_id = om_visit.id
  WHERE om_visit_class.ismultievent = true;
  
  
  
  
CREATE OR REPLACE VIEW ve_visit_node_singlevent AS 
 SELECT om_visit_x_node.visit_id,
    om_visit_x_node.node_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    om_visit.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.lot_id,
    om_visit.status,
    om_visit.suspendendcat_id,
    om_visit_event.id AS event_id,
    om_visit_event.event_code,
    om_visit_event.position_id,
    om_visit_event.position_value,
    om_visit_event.parameter_id,
    om_visit_event.value,
    om_visit_event.value1,
    om_visit_event.value2,
    om_visit_event.geom1,
    om_visit_event.geom2,
    om_visit_event.geom3,
    om_visit_event.xcoord,
    om_visit_event.ycoord,
    om_visit_event.compass,
    om_visit_event.tstamp,
    om_visit_event.text,
    om_visit_event.index_val,
    om_visit_event.is_last
   FROM (((om_visit
     JOIN om_visit_event ON ((om_visit.id = om_visit_event.visit_id)))
     JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN om_visit_class ON ((om_visit_class.id = om_visit.class_id)))
  WHERE (om_visit_class.ismultievent = false);
  
  
  
  
CREATE OR REPLACE VIEW ve_visit_noinfra_typea AS 
 SELECT om_visit.id AS visit_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    om_visit.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.lot_id,
    om_visit.status,
    a.param_1 AS comentari_typea
   FROM om_visit
     JOIN om_visit_class ON om_visit_class.id = om_visit.class_id
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value 
            FROM om_visit JOIN om_visit_event ON om_visit.id= om_visit_event.visit_id 
            JOIN om_visit_class on om_visit_class.id=om_visit.class_id
            JOIN om_visit_class_x_parameter on om_visit_class_x_parameter.parameter_id=om_visit_event.parameter_id 
            where om_visit_class.ismultievent = TRUE ORDER  BY 1,2'::text, ' VALUES (''comentari_typea'')'::text) ct(visit_id integer, param_1 text)) a ON a.visit_id = om_visit.id
  WHERE om_visit_class.ismultievent = true;
  
  
  
CREATE OR REPLACE VIEW ve_visit_noinfra_typeb AS 
 SELECT a.visit_id,
    om_visit.visitcat_id,
    om_visit.ext_code,
    om_visit.startdate,
    om_visit.enddate,
    om_visit.user_name,
    om_visit.webclient_id,
    om_visit.expl_id,
    om_visit.the_geom,
    om_visit.descript,
    om_visit.is_done,
    om_visit.class_id,
    om_visit.lot_id,
    om_visit.status,
    a.param_1 AS comentari_typeb
   FROM om_visit
     JOIN om_visit_class ON om_visit_class.id = om_visit.class_id
     LEFT JOIN ( SELECT ct.visit_id,
            ct.param_1
           FROM crosstab('SELECT visit_id, om_visit_event.parameter_id, value 
            FROM om_visit JOIN om_visit_event ON om_visit.id= om_visit_event.visit_id 
            JOIN om_visit_class on om_visit_class.id=om_visit.class_id
            JOIN om_visit_class_x_parameter on om_visit_class_x_parameter.parameter_id=om_visit_event.parameter_id 
            where om_visit_class.ismultievent = TRUE ORDER  BY 1,2'::text, ' VALUES (''comentari_typea'')'::text) ct(visit_id integer, param_1 text)) a ON a.visit_id = om_visit.id
  WHERE om_visit_class.ismultievent = true;
  



CREATE OR REPLACE VIEW v_om_visit_event AS
 SELECT DISTINCT ON (om_visit_event.id) row_number() OVER (ORDER BY om_visit_event.id) AS row_id,
    om_visit_event.id AS event_id,
    om_visit.id AS visit_id,
    om_visit.is_done,
    om_visit_cat.name AS builder,
    om_visit_event.parameter_id,
    (om_visit.startdate)::date AS visit_date,
    om_visit_event.tstamp,
    node.node_id,
    node.mu_id,
    concat(cat_location.street_name, ' - ', cat_species.species) AS mu_name,
    node.the_geom
   FROM (((((((om_visit_event
     JOIN om_visit ON ((om_visit.id = om_visit_event.visit_id)))
     LEFT JOIN om_visit_x_node ON ((om_visit.id = om_visit_x_node.visit_id)))
     JOIN node ON (((node.node_id)::text = (om_visit_x_node.node_id)::text)))
     JOIN om_visit_cat ON ((om_visit_cat.id = om_visit.visitcat_id)))
     LEFT JOIN cat_mu ON ((node.mu_id = cat_mu.id)))
     LEFT JOIN cat_species ON ((cat_mu.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((cat_mu.location_id = cat_location.id)))
  ORDER BY om_visit_event.id, node.mu_id;

