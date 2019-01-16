
SET search_path='SCHEMA_NAME',public;

--DROP
ALTER TABLE planning DROP CONSTRAINT IF EXISTS planning_campaign_id_fkey;
ALTER TABLE planning DROP CONSTRAINT IF EXISTS planning_mu_id_fkey;
ALTER TABLE planning DROP CONSTRAINT IF EXISTS planning_work_id_fkey;
ALTER TABLE planning_unit DROP CONSTRAINT IF EXISTS planning_unit_campaign_id_fkey;
ALTER TABLE planning_unit DROP CONSTRAINT IF EXISTS planning_unit_node_id_fkey;
ALTER TABLE planning_unit DROP CONSTRAINT IF EXISTS planning_unit_work_id_fkey;
ALTER TABLE planning_unit DROP CONSTRAINT IF EXISTS planning_unit_size_id_fkey;

--ADD
ALTER TABLE planning
    ADD CONSTRAINT planning_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES cat_campaign(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE planning
    ADD CONSTRAINT planning_mu_id_fkey FOREIGN KEY (mu_id) REFERENCES cat_mu(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE planning
    ADD CONSTRAINT planning_work_id_fkey FOREIGN KEY (work_id) REFERENCES cat_work(id) ON UPDATE CASCADE ON DELETE RESTRICT;



ALTER TABLE planning_unit
    ADD CONSTRAINT planning_unit_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES cat_campaign(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE planning_unit
    ADD CONSTRAINT planning_unit_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(node_id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE planning_unit
    ADD CONSTRAINT planning_unit_work_id_fkey FOREIGN KEY (work_id) REFERENCES cat_work(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE planning_unit
    ADD CONSTRAINT planning_unit_size_id_fkey FOREIGN KEY (size_id) REFERENCES cat_size(id) ON UPDATE CASCADE ON DELETE RESTRICT;
