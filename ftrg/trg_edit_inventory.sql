
/*Goal:Function allows to insert, update and delete data into node table. It generates new registers in cat_mu based on the values of location and species.
Triggers activates itselfs on doing one of the listed actions on the view v_edit_node.
*/

-- DROP FUNCTION SCHEMA_NAME.trg_edit_node();
-- Function: SCHEMA_NAME.trg_edit_node()


CREATE OR REPLACE FUNCTION trg_edit_inventory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 


BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';


 IF TG_OP = 'INSERT' THEN

 INSERT INTO  inventory (node_id,location_id, species_id, work_id, size_id, size_descript, development, plant_date, observ, the_geom, state_id)
 VALUES (NEW.node_id, NEW.location_id, NEW.species_id, NEW.work_id, NEW.size_id, NEW.size_descript, NEW.development, NEW.plant_date, NEW.observ, NEW.the_geom,NEW.state_id);

RETURN NEW;

 ELSIF TG_OP = 'UPDATE' THEN 

 	UPDATE inventory SET location_id=NEW.location_id, species_id=NEW.species_id, work_id=NEW.work_id, size_id=NEW.size_id, size_descript=NEW.size_descript, development=NEW.development,
 	plant_date=NEW.plant_date, observ=NEW.observ, the_geom=NEW.the_geom, state_id=NEW.state_id
 	WHERE node_id=NEW.node_id;

	INSERT INTO  review_inventory (inventory_id, location_id, species_id, size_id, plant_date, observ, the_geom, state_id)
	VALUES (OLD.node_id, OLD.location_id, OLD.species_id, OLD.size_id, OLD.plant_date, OLD.observ, OLD.the_geom,OLD.state_id);

RETURN NEW;

ELSIF TG_OP = 'DELETE' THEN
	
	DELETE FROM inventory WHERE id=OLD.id;

	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



