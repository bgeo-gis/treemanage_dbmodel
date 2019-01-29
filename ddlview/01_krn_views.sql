
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
    node.state_id,
    node.price_id,
    node.inventory
   FROM selector_state, (((node
     LEFT JOIN cat_species ON ((node.species_id = cat_species.id)))
     LEFT JOIN cat_location ON ((node.location_id = cat_location.id)))
     LEFT JOIN cat_development ON ((((cat_species.development_name)::text = (cat_development.name)::text) AND (node.size_id = cat_development.size_id))))
  WHERE node.state=selector_state.state_id AND selector_state.cur_user=current_user;


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
   FROM arbrat_viari.cat_mu
  WHERE cat_mu.work_id IS NULL;
