-- Function: SCHEMA_NAME_upgrade.trg_edit_om_visit_work_x_node()
/*Goal: the trigger allows to modify the values of ext_code (nr de factura) using the views of executed actions*/
-- DROP FUNCTION SCHEMA_NAME_upgrade.trg_edit_om_visit_work_x_node();
-- Function: SCHEMA_NAME.trg_edit_om_visit_work_x_node()

-- DROP FUNCTION SCHEMA_NAME.trg_edit_om_visit_work_x_node();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_edit_om_visit_work_x_node()
  RETURNS trigger AS
$BODY$
DECLARE 
	v_parameter_id text;
	v_work_id integer;
	v_builder_id integer;
	v_price numeric;
	v_campaign integer;
	v_visit_id integer;
	v_size_id integer;
	v_work_id_old integer;
	v_action_value text;
	v_node text;
BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';



IF TG_OP = 'UPDATE' THEN

v_parameter_id = (SELECT parameter_id FROM cat_work WHERE name=NEW.work); 
v_work_id = (SELECT id FROM cat_work WHERE name=NEW.work);
v_work_id_old = (SELECT id FROM cat_work WHERE name=OLD.work);
v_builder_id = (SELECT id FROM cat_builder WHERE name=NEW.builder);
v_size_id = (SELECT id FROM cat_size WHERE name=NEW.size);

v_visit_id = (SELECT visit_id FROM om_visit_event WHERE id=NEW.event_id);
v_node = (SELECT node_id FROM om_visit_x_node WHERE  visit_id=v_visit_id);

	UPDATE om_visit_event SET ext_code=NEW.ext_code, parameter_id=v_parameter_id, value=NEW.work_date
	WHERE om_visit_event.id=NEW.event_id;

	IF (SELECT parameter_id FROM om_visit_event WHERE om_visit_event.id=NEW.event_id) = 'plantacio' THEN
		UPDATE v_edit_node SET plant_date = NEW.work_date WHERE node_id = v_node;
	END IF;
	
	UPDATE om_visit SET visitcat_id=v_builder_id, startdate=NEW.work_date
	WHERE om_visit.id=v_visit_id;

	UPDATE om_visit_work_x_node SET work_id=v_work_id, work_date=NEW.work_date, builder_id=v_builder_id
	WHERE om_visit_work_x_node.event_id=NEW.event_id;

	IF (SELECT action_type FROM om_visit_parameter_x_parameter WHERE parameter_id1=v_parameter_id AND parameter_id2 is null) = 4 THEN
		
		SELECT action_value FROM om_visit_parameter_x_parameter WHERE parameter_id1=v_parameter_id  AND parameter_id2 is null
		INTO v_action_value;
		RAISE NOTICE 'v_action_value,,v_node,%,%',v_action_value,v_node;
		EXECUTE v_action_value || ' WHERE node_id='''||v_node||''';';

	END IF;

	IF v_work_id!=v_work_id_old THEN
		v_campaign=(select id FROM cat_campaign WHERE start_date<=NEW.work_date and end_date>=NEW.work_date AND active = TRUE);
		v_price = (select price FROM cat_price WHERE size_id=v_size_id AND work_id=v_work_id AND campaign_id=v_campaign);
		raise notice 'v_price,%',v_price;
		UPDATE om_visit_work_x_node SET price=v_price, work_cost = v_price * NEW.units
		WHERE om_visit_work_x_node.event_id=NEW.event_id;
	END IF;

	RETURN NEW;
	
ELSIF TG_OP = 'DELETE' THEN
v_visit_id = (SELECT visit_id FROM om_visit_event WHERE id=OLD.event_id);
	IF (select count(id) FROM om_visit_event WHERE visit_id=v_visit_id) = 1 THEN
		DELETE FROM om_visit WHERE id=v_visit_id;
	ELSE
		RAISE EXCEPTION ' NO SE PUEDE BORRAR EL REGISTRO.EXISTE MÁS QUE 1 EVENTO RELACIONADO CON ESTA VISITA.';
	END IF;
	RETURN NULL;
END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION SCHEMA_NAME.trg_edit_om_visit_work_x_node()
  OWNER TO geoadmin;



