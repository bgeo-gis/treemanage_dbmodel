
SET search_path='SCHEMA_NAME',public;


--DROP
ALTER TABLE om_visit_event DROP CONSTRAINT IF EXISTS om_visit_event_parameter_id_fkey;;
ALTER TABLE om_visit_event DROP CONSTRAINT IF EXISTS om_visit_event_visit_id_fkey;
ALTER TABLE om_visit DROP CONSTRAINT IF EXISTS om_visit_om_visit_cat_id_fkey; 
--ALTER TABLE om_visit_x_arc DROP CONSTRAINT IF EXISTS om_visit_x_arc_visit_id_fkey;     
--ALTER TABLE om_visit_x_connec DROP CONSTRAINT IF EXISTS om_visit_x_connec_visit_id_fkey; 
ALTER TABLE om_visit_x_node DROP CONSTRAINT IF EXISTS om_visit_x_node_node_id_fkey;
ALTER TABLE om_visit_x_node DROP CONSTRAINT IF EXISTS om_visit_x_node_visit_id_fkey;


ALTER TABLE doc_x_visit DROP CONSTRAINT IF EXISTS doc_x_visit_visit_id_fkey;
ALTER TABLE om_visit_work_x_node DROP CONSTRAINT IF EXISTS nom_visit_work_x_node_node_id_fkey;
ALTER TABLE om_visit_work_x_node DROP CONSTRAINT IF EXISTS om_visit_work_x_node_builder_id_fkey;
ALTER TABLE om_visit_work_x_node DROP CONSTRAINT IF EXISTS om_visit_work_x_node_size_id_fkey;
ALTER TABLE om_visit_work_x_node DROP CONSTRAINT IF EXISTS om_visit_work_x_node_work_id_fkey;
ALTER TABLE om_visit_work_x_node DROP CONSTRAINT IF EXISTS om_visit_work_x_node_event_id_fkey;

ALTER TABLE om_visit_parameter DROP CONSTRAINT IF EXISTS om_visit_parameter_parameter_type_fkey;

ALTER TABLE om_visit_class_x_parameter DROP CONSTRAINT IF EXISTS om_visit_class_x_parameter_class_fkey;
ALTER TABLE om_visit_class_x_parameter DROP CONSTRAINT IF EXISTS om_visit_class_x_parameter_parameter_fkey;

ALTER TABLE selector_lot DROP CONSTRAINT IF EXISTS selector_lot_lot_id_cur_user_unique;
ALTER TABLE selector_lot DROP CONSTRAINT IF EXISTS selector_lot_lot_id_fkey;
--ADD
ALTER TABLE om_visit_event
    ADD CONSTRAINT om_visit_event_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES om_visit_parameter(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit_event
    ADD CONSTRAINT om_visit_event_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES om_visit(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit
    ADD CONSTRAINT om_visit_om_visit_cat_id_fkey FOREIGN KEY (visitcat_id) REFERENCES om_visit_cat(id) ON UPDATE CASCADE ON DELETE RESTRICT;

/*ALTER TABLE om_visit_x_arc
    ADD CONSTRAINT om_visit_x_arc_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES om_visit(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit_x_connec
    ADD CONSTRAINT om_visit_x_connec_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES om_visit(id) ON UPDATE CASCADE ON DELETE CASCADE;
*/
ALTER TABLE om_visit_x_node
    ADD CONSTRAINT om_visit_x_node_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(node_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit_x_node
    ADD CONSTRAINT om_visit_x_node_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES om_visit(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE doc_x_visit
    ADD CONSTRAINT doc_x_visit_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES om_visit(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_work_x_node
    ADD CONSTRAINT nom_visit_work_x_node_node_id_fkey FOREIGN KEY (node_id) REFERENCES node(node_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE om_visit_work_x_node
    ADD CONSTRAINT om_visit_work_x_node_builder_id_fkey FOREIGN KEY (builder_id) REFERENCES cat_builder(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_work_x_node
    ADD CONSTRAINT om_visit_work_x_node_size_id_fkey FOREIGN KEY (size_id) REFERENCES cat_size(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_work_x_node
    ADD CONSTRAINT om_visit_work_x_node_work_id_fkey FOREIGN KEY (work_id) REFERENCES cat_work(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_work_x_node
    ADD CONSTRAINT om_visit_work_x_node_event_id_fkey FOREIGN KEY (event_id) REFERENCES om_visit_event(id) ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_parameter
    ADD CONSTRAINT om_visit_parameter_parameter_type_fkey FOREIGN KEY (parameter_type) REFERENCES om_visit_parameter_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE om_visit_class_x_parameter 
ADD CONSTRAINT om_visit_class_x_parameter_class_fkey FOREIGN KEY (class_id) REFERENCES om_visit_class (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE om_visit_class_x_parameter
  ADD CONSTRAINT om_visit_class_x_parameter_parameter_fkey FOREIGN KEY (parameter_id) REFERENCES om_visit_parameter (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE selector_lot ADD CONSTRAINT selector_lot_lot_id_cur_user_unique UNIQUE(lot_id, cur_user);

ALTER TABLE selector_lot
  ADD CONSTRAINT selector_lot_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES om_visit_lot (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE RESTRICT;
