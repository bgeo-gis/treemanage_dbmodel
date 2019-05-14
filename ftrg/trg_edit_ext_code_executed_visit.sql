-- Function: SCHEMA_NAME.trg_edit_ext_code_executed_visit()
/*Goal: the trigger allows to modify the values of ext_code (nr de factura) using the views of executed actions*/
-- DROP FUNCTION SCHEMA_NAME.trg_edit_ext_code_executed_visit();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_edit_ext_code_executed_visit()
  RETURNS trigger AS
$BODY$
DECLARE 


BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';


IF TG_OP = 'UPDATE' THEN

	UPDATE om_visit_event SET ext_code=NEW.ext_code WHERE om_visit_event.id=NEW.event_id;

RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




