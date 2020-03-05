-- Function: SCHEMA_NAME.trg_edit_ext_code_executed_visit()
/*Goal: the trigger allows to modify the values of ext_code (nr de factura) using the views of executed actions*/
-- DROP FUNCTION SCHEMA_NAME.trg_edit_ext_code_executed_visit();

CREATE OR REPLACE FUNCTION trg_edit_freque() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 


BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';


IF TG_OP = 'UPDATE' THEN

	UPDATE planning_unit SET frequency=NEW.frequency, work_id=NEW.work_id WHERE planning_unit.id=NEW.id;

RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




