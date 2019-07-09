
SET search_path='SCHEMA_NAME',public;


--DROP
ALTER TABLE cat_mu DROP CONSTRAINT IF EXISTS cat_mu_location_id_fkey;
ALTER TABLE cat_mu DROP CONSTRAINT IF EXISTS cat_mu_species_id_fkey;
ALTER TABLE cat_price DROP CONSTRAINT IF EXISTS cat_price_size_id_fkey;
ALTER TABLE cat_price DROP CONSTRAINT IF EXISTS cat_price_work_id_fkey;

ALTER TABLE node DROP CONSTRAINT IF EXISTS node_builder_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_location_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_maintainer_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_mu_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_price_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_size_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_species_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_state_id_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_work_id2_fkey;
ALTER TABLE node DROP CONSTRAINT IF EXISTS node_work_id_fkey;

ALTER TABLE verify_node DROP CONSTRAINT IF EXISTS verify_node_verify_id_fkey;

ALTER TABLE om_visit_work_x_node DROP CONSTRAINT IF EXISTS om_visit_work_x_node_event_id_fkey;

ALTER TABLE exploitation_x_user DROP CONSTRAINT exploitation_x_user_expl_username_unique;
ALTER TABLE exploitation_x_user DROP CONSTRAINT exploitation_x_user_expl_id_fkey;
ALTER TABLE exploitation_x_user DROP CONSTRAINT exploitation_x_user_username_fkey;

ALTER TABLE selector_expl DROP CONSTRAINT selector_expl_id_fkey;

ALTER TABLE om_visitcat_x_user DROP CONSTRAINT visitcat_x_user_expl_username_unique;
ALTER TABLE om_visitcat_x_user DROP CONSTRAINT visitcat_x_user_username_fkey;
ALTER TABLE om_visitcat_x_user DROP CONSTRAINT visitcat_x_user_visitcat_id_fkey;


--ADD
ALTER TABLE cat_mu
    ADD CONSTRAINT cat_mu_location_id_fkey FOREIGN KEY (location_id) REFERENCES cat_location(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE cat_mu
    ADD CONSTRAINT cat_mu_species_id_fkey FOREIGN KEY (species_id) REFERENCES cat_species(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE cat_price
    ADD CONSTRAINT cat_price_size_id_fkey FOREIGN KEY (size_id) REFERENCES cat_size(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE cat_price
    ADD CONSTRAINT cat_price_work_id_fkey FOREIGN KEY (work_id) REFERENCES cat_work(id) ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE node
    ADD CONSTRAINT node_builder_id_fkey FOREIGN KEY (builder_id) REFERENCES cat_builder(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_location_id_fkey FOREIGN KEY (location_id) REFERENCES cat_location(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_maintainer_id_fkey FOREIGN KEY (maintainer_id) REFERENCES cat_builder(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_mu_id_fkey FOREIGN KEY (mu_id) REFERENCES cat_mu(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_price_id_fkey FOREIGN KEY (price_id) REFERENCES cat_price(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_size_id_fkey FOREIGN KEY (size_id) REFERENCES cat_size(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_species_id_fkey FOREIGN KEY (species_id) REFERENCES cat_species(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_state_id_fkey FOREIGN KEY (state_id) REFERENCES value_state(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_work_id2_fkey FOREIGN KEY (work_id2) REFERENCES cat_work(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE node
    ADD CONSTRAINT node_work_id_fkey FOREIGN KEY (work_id) REFERENCES cat_work(id) ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE verify_node
    ADD CONSTRAINT verify_node_verify_id_fkey FOREIGN KEY (verify_id) REFERENCES cat_verify(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_work_x_node ADD CONSTRAINT om_visit_work_x_node_event_id_fkey FOREIGN KEY (event_id)
      REFERENCES om_visit_event (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE exploitation_x_user ADD CONSTRAINT exploitation_x_user_expl_username_unique UNIQUE(expl_id, username);

ALTER TABLE exploitation_x_user
  ADD CONSTRAINT exploitation_x_user_expl_id_fkey FOREIGN KEY (expl_id) REFERENCES exploitation (expl_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE exploitation_x_user
  ADD CONSTRAINT exploitation_x_user_username_fkey FOREIGN KEY (username) REFERENCES cat_users (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE selector_expl
  ADD CONSTRAINT selector_expl_id_fkey FOREIGN KEY (expl_id) REFERENCES exploitation (expl_id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visitcat_x_user ADD CONSTRAINT visitcat_x_user_expl_username_unique UNIQUE(visitcat_id, username);

ALTER TABLE om_visitcat_x_user
  ADD CONSTRAINT visitcat_x_user_username_fkey FOREIGN KEY (username) REFERENCES cat_users (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visitcat_x_user
  ADD CONSTRAINT visitcat_x_user_visitcat_id_fkey FOREIGN KEY (visitcat_id) REFERENCES om_visit_cat (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
