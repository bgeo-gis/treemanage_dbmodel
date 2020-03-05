-- Function: SCHEMA_NAME.trg_edit_plan_unit()
/*Goal: Inserting data on planning_unit table in order to make a unitary planning of actions (one action for each node(tree)).
Trigger activates itself when the data is inserted using v_ui_planning_unit (plugin tree_manage).
*/


-- DROP FUNCTION arbrat_viari.trg_edit_plan_unit();

CREATE OR REPLACE FUNCTION arbrat_viari.trg_edit_plan_unit()
  RETURNS trigger AS
$BODY$
DECLARE 

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

 IF TG_OP = 'INSERT' THEN
--Inserting data into planning_unit table, calculating the price by multiplying the price but the frequency of action
 	INSERT INTO planning_unit (campaign_id, node_id, work_id, frequency,size_id, price, builder_id, comment, priority_id)
 	SELECT NEW.campaign_id, NEW.node_id, NEW.work_id, NEW.frequency, node.size_id, (cat_price.price*NEW.frequency), NEW.builder_id, NEW.comment, NEW.priority_id
 	FROM node 
 	LEFT JOIN cat_price ON cat_price.work_id = NEW.work_id AND node.size_id = cat_price.size_id AND cat_price.campaign_id = NEW.campaign_id
 	WHERE node_id=NEW.node_id;
	
	UPDATE node SET observ=NEW.observ WHERE node_id=NEW.node_id;
 	
	RETURN NEW;

 ELSIF TG_OP = 'UPDATE' THEN 
 --Upating data in planning_unit table, calculating the price by multiplying the price but the frequency of action
	UPDATE planning_unit SET frequency=NEW.frequency, price=(cat_price.price*NEW.frequency)
	FROM cat_price 
	WHERE cat_price.work_id = NEW.work_id AND cat_price.size_id = NEW.size_id AND cat_price.campaign_id = NEW.campaign_id AND planning_unit.id=NEW.id;
	
	UPDATE node SET observ=NEW.observ WHERE node_id=NEW.node_id;

	RETURN NEW;
	
 ELSIF TG_OP = 'DELETE' THEN 
--Delete data from planning_unit table;
 	DELETE FROM planning_unit WHERE id=OLD.id;

 	RETURN NULL;
END IF;

 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
