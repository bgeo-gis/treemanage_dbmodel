-- Function: SCHEMA_NAME.trg_edit_visit_plant()

-- DROP FUNCTION SCHEMA_NAME.trg_edit_visit_plant();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_edit_visit_plant()
  RETURNS trigger AS
$BODY$
DECLARE 

v_plant_date date;
v_parameter_id text;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

    SELECT parameter_id INTO v_parameter_id FROM om_visit_event WHERE visit_id = NEW.visit_id;

	IF v_parameter_id = 'plantacio' THEN
		SELECT startdate::date INTO v_plant_date FROM om_visit WHERE id = NEW.visit_id;

		UPDATE v_edit_node SET plant_date = v_plant_date WHERE node_id = NEW.node_id;

	END IF;


RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
