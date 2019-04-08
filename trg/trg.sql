
DROP TRIGGER IF EXISTS trg_edit_node ON SCHEMA_NAME.v_edit_node;
CREATE TRIGGER trg_edit_node INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.v_edit_node
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_edit_node('node');

DROP TRIGGER IF EXISTS trg_edit_plan_unit ON SCHEMA_NAME.v_ui_planning_unit;
CREATE TRIGGER trg_edit_plan_unit INSTEAD OF INSERT OR UPDATE OR DELETE 
ON SCHEMA_NAME.v_ui_planning_unit FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_edit_plan_unit();

DROP TRIGGER IF EXISTS trg_edit_price ON SCHEMA_NAME.v_edit_price;
CREATE TRIGGER trg_edit_price INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.v_edit_price
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_edit_price('');

DROP TRIGGER IF EXISTS trg_edit_verify_node ON SCHEMA_NAME.v_edit_verify_node;
CREATE TRIGGER trg_edit_verify_node INSTEAD OF UPDATE ON SCHEMA_NAME.v_edit_verify_node
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_edit_verify_node();

DROP TRIGGER IF EXISTS trg_planned_visit ON SCHEMA_NAME.om_visit_event;
CREATE TRIGGER trg_planned_visit AFTER INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.om_visit_event
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_planned_visit('om_visit_event');

DROP TRIGGER IF EXISTS trg_review_cat_mu ON "SCHEMA_NAME".v_review_cat_mu;
CREATE TRIGGER trg_review_cat_mu INSTEAD OF UPDATE ON "SCHEMA_NAME".v_review_cat_mu FOR EACH ROW EXECUTE PROCEDURE "SCHEMA_NAME".trg_review_cat_mu('');

DROP TRIGGER IF EXISTS trg_visit_undone ON SCHEMA_NAME.om_visit_event;
CREATE TRIGGER trg_visit_undone AFTER INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.om_visit_event
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_visit_undone('om_visit_event');


DROP TRIGGER IF EXISTS trg_edit_ext_code_executed_visit ON SCHEMA_NAME.v_trim_executed;
CREATE TRIGGER trg_edit_ext_code_executed_visit  INSTEAD OF UPDATE ON SCHEMA_NAME.v_trim_executed
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_edit_ext_code_executed_visit();
