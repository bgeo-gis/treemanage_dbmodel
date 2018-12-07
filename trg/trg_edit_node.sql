-- Function: SCHEMA_NAME.trg_edit_node()
/*Goal:Function allows to insert, update and delete data into node table. It generates new registers in cat_mu based on the values of location and species.
Triggers activates itselfs on doing one of the listed actions on the view v_edit_node.
*/
-- DROP FUNCTION SCHEMA_NAME.trg_edit_node();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_edit_node()
  RETURNS trigger AS
$BODY$
DECLARE 
mu_aux integer;
rec_node  record;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';


 IF TG_OP = 'INSERT' THEN

--check if there is a mu that is a combination of location and species
 SELECT id INTO mu_aux FROM cat_mu WHERE location_id = NEW.location_id AND species_id=NEW.species_id;

--set new node_id
IF NEW.node_id IS NULL THEN

		NEW.node_id=(SELECT nextval('node_id_seq'::regclass));

END IF;
--if the mu doesn't exists in the catalog, insert the combination
IF mu_aux is null then
	INSERT INTO cat_mu(location_id,species_id,work_id) VALUES (new.location_id, new.species_id,6);
	SELECT id INTO mu_aux FROM cat_mu WHERE location_id = NEW.location_id AND species_id=NEW.species_id;
END IF;

SELECT id INTO mu_aux FROM cat_mu WHERE location_id = NEW.location_id AND species_id=NEW.species_id;

--insert data into node table
 INSERT INTO  node (node_id,mu_id,location_id, species_id, work_id, work_id2, size_id, plant_date, observ, 
 			the_geom, state_id,price_id, inventory)
 VALUES (NEW.node_id, mu_aux,NEW.location_id, NEW.species_id, NEW.work_id, NEW.work_id2, NEW.size_id,  NEW.plant_date, NEW.observ,
  		NEW.the_geom,1,NEW.price_id,  NEW.inventory);
 
--insert data into review_node table for the traceability of data change
 INSERT INTO  review_node (node_id, location_id, species_id, size_id, plant_date, observ, the_geom, state_id,cur_user)
 VALUES (NEW.node_id, NEW.location_id, NEW.species_id, NEW.size_id, NEW.plant_date, concat('Arbre nou.',NEW.observ), NEW.the_geom,1, current_user);


RETURN NEW;

 ELSIF TG_OP = 'UPDATE' THEN 
 --Check if the new data in the species and location is different than the old one, if so insert changes into verify_node table
 	IF ((SELECT species_id FROM node WHERE node_id=NEW.node_id) != NEW.species_id) OR ((SELECT location_id FROM node WHERE node_id=NEW.node_id) != NEW.location_id) THEN

		INSERT INTO verify_node (node_id, species_id_old, location_id_old, species_id_new, location_id_new)
		SELECT node_id, species_id, location_id, NEW.species_id, NEW.location_id FROM node where node_id = NEW.node_id;
	
	END IF; 
	
--check if there is a mu that is a combination of location and species and insert a new combination if it doesn't exist
	SELECT id INTO mu_aux FROM cat_mu WHERE location_id = NEW.location_id AND species_id=NEW.species_id;

	IF mu_aux is null then
		INSERT INTO cat_mu(location_id,species_id) VALUES (new.location_id, new.species_id);
		SELECT id INTO mu_aux FROM cat_mu WHERE location_id = NEW.location_id AND species_id=NEW.species_id;
	END IF;

	SELECT * INTO rec_node FROM node WHERE node_id=NEW.node_id;
--Update node table.
 	UPDATE node SET location_id=NEW.location_id, species_id=NEW.species_id,size_id=NEW.size_id, 
 	plant_date=NEW.plant_date, observ=NEW.observ, the_geom=NEW.the_geom, state_id=NEW.state_id, mu_id=mu_aux, work_id2=NEW.work_id2,
	inventory= NEW.inventory
 	WHERE node_id=NEW.node_id;
--Insert changed data into review_node table
 	INSERT INTO  review_node (node_id,cur_user,the_geom, location_id,species_id, geom_changed, size_id, plant_date, observ,state_id) 
 	VALUES (OLD.node_id,current_user, OLD.the_geom,
 		CASE WHEN rec_node.location_id!=NEW.location_id THEN OLD.location_id ELSE NULL END,
 		CASE WHEN rec_node.species_id!=NEW.species_id THEN OLD.species_id ELSE NULL END,
 		CASE WHEN rec_node.the_geom::text!=NEW.the_geom::text THEN TRUE ELSE FALSE END,
 		CASE WHEN rec_node.size_id::text!=NEW.size_id::text THEN OLD.size_id ELSE NULL END,
 		CASE WHEN rec_node.plant_date::text!=NEW.plant_date::text THEN OLD.plant_date ELSE NULL END,
 		CASE WHEN rec_node.observ::text!=NEW.observ::text THEN OLD.observ ELSE NULL END,
 		CASE WHEN rec_node.state_id::text!=NEW.state_id::text THEN OLD.state_id ELSE NULL END
 		);

RETURN NEW;

ELSIF TG_OP = 'DELETE' THEN
--delete values from node table and insert changes into review_node table
	DELETE FROM node CASCADE WHERE node_id=OLD.node_id;
	INSERT INTO  review_node (node_id, location_id, species_id, size_id, plant_date, observ, the_geom, state_id,work_id, work_id2, cur_user)
	VALUES (OLD.node_id, OLD.location_id, OLD.species_id, OLD.size_id, OLD.plant_date, 'Eliminat', OLD.the_geom,OLD.state_id,OLD.work_id,OLD.work_id2, current_user);

	END IF;

RETURN NULL;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


DROP TRIGGER IF EXISTS trg_edit_node ON SCHEMA_NAME.v_edit_node;

CREATE TRIGGER trg_edit_node INSTEAD OF INSERT OR UPDATE OR DELETE ON SCHEMA_NAME.v_edit_node
FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.trg_edit_node('node');
