-- Function: SCHEMA_NAME.trg_visit_undone()
/*Goal: In case of changes of event data the visit automatically is set to undone (id_don=FALSE)
Trigger activates itself on insert,update,delete of values in om_visit_event table.*/

-- DROP FUNCTION SCHEMA_NAME.trg_visit_undone();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_visit_undone()
  RETURNS trigger AS
$BODY$
DECLARE 
visit_aux record;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

 IF TG_OP = 'INSERT' THEN
--SELECT the data of visit related to the new event and set the is_done to FALSE
 		SELECT * INTO visit_aux FROM om_visit JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id WHERE om_visit_event.id=NEW.id;

 		UPDATE om_visit SET is_done=FALSE WHERE id=visit_aux.id;
 		RETURN NULL;

 ELSIF TG_OP = 'UPDATE' THEN 
 --SELECT the data of visit related to the modified event and set the is_done to FALSE
 		SELECT * INTO visit_aux FROM om_visit JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id WHERE om_visit_event.id=NEW.id;
 		UPDATE om_visit SET is_done=FALSE WHERE id=visit_aux.id;
 		RETURN NULL;

ELSIF TG_OP = 'DELETE' THEN

 		UPDATE om_visit SET is_done=FALSE WHERE id=OLD.id;
 		RETURN NULL;

END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


