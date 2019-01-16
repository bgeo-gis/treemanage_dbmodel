-- Function: SCHEMA_NAME.trg_edit_verify_node()
/*Goal: Verification of the modifications made on location and species fields of node table. In case of setting value 2 ('Undo') in the v_edit_verify_node  
the changes made on the node table are being reversed.
Trigger activates while modifying the values of verify_id in the v_edit_verify_node view.

*/
-- DROP FUNCTION SCHEMA_NAME.trg_edit_verify_node();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_edit_verify_node()
  RETURNS trigger AS
$BODY$
DECLARE 

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

IF TG_OP = 'UPDATE' THEN 
--Update the value of verify_id
	UPDATE verify_node SET verify_id=NEW.verify_id WHERE id=NEW.id;
--If verify_id=2 ('Undo') reverse the changes.
	IF NEW.verify_id=2 THEN
		UPDATE node SET location_id=location_id_old, species_id=species_id_old FROM verify_node WHERE node.node_id=verify_node.node_id AND verify_node.id=NEW.id;
	END IF;
	
 	RETURN NEW;
END IF;

 	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


