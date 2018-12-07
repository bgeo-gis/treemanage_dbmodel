-- Function: SCHEMA_NAME.trg_planned_visit()
/*Goal: check if the planified work has been executed during the planned period.
Triggered when new data is inserted into om_visit_event table */
-- DROP FUNCTION SCHEMA_NAME.trg_planned_visit();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_planned_visit()
  RETURNS trigger AS
$BODY$

DECLARE 
visit_aux record;
mu_aux integer;
work_aux integer;
campaign_aux integer;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

 IF TG_OP = 'INSERT' THEN
--Select all the data related to visit
 		SELECT om_visit.id,om_visit_parameter.id as parameter_id,om_visit_event.id as event_id, om_visit_event.tstamp,om_visit_x_node.node_id 
 		INTO visit_aux FROM om_visit 
 		JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id 
 		JOIN om_visit_parameter ON om_visit_parameter.id=om_visit_event.parameter_id 
 		JOIN om_visit_x_node ON om_visit.id=om_visit_x_node.visit_id WHERE om_visit_event.id=NEW.id;

--CHECK mu_id
		SELECT mu_id INTO mu_aux
		FROM node WHERE node_id=visit_aux.node_id;

--check work_id
		SELECT id INTO work_aux
		FROM cat_work WHERE visit_aux.parameter_id=cat_work.parameter_id;
		
--check campaign dates
		SELECT id INTO campaign_aux
		FROM cat_campaign WHERE start_date<=date(visit_aux.tstamp) and end_date>=date(visit_aux.tstamp);
--update planning or planning_unit, depending on the used parameter; update frequency count of unit planning
		IF (SELECT parameter_type FROM om_visit_parameter WHERE id=visit_aux.parameter_id)='MULTIPLE' THEN
			UPDATE planning SET plan_execute_date=date(visit_aux.tstamp) WHERE campaign_id=campaign_aux
			and planning.mu_id=mu_aux and planning.work_id=work_aux;
		ELSIF (SELECT parameter_type FROM om_visit_parameter WHERE id=visit_aux.parameter_id)='SIMPLE' THEN
raise notice 'campana,node_id,work,%,%,%',campaign_aux,visit_aux.node_id,work_aux;
			UPDATE planning_unit SET plan_execute_date=date(visit_aux.tstamp), frequency_executed=frequency_executed+1 WHERE campaign_id=campaign_aux
			and planning_unit.node_id=visit_aux.node_id and planning_unit.work_id=work_aux;
 		END IF;

 ELSIF TG_OP = 'UPDATE' THEN

 		SELECT om_visit.id,om_visit_parameter.id as parameter_id,om_visit_event.id as event_id, om_visit_event.tstamp,om_visit_x_node.node_id 
 		INTO visit_aux FROM om_visit 
 		JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id 
 		JOIN om_visit_parameter ON om_visit_parameter.id=om_visit_event.parameter_id 
 		JOIN om_visit_x_node ON om_visit.id=om_visit_x_node.visit_id WHERE om_visit_event.id=NEW.id;

--CHECK mu_id
		SELECT mu_id INTO mu_aux
		FROM node WHERE node_id=visit_aux.node_id;

--check work_id
		SELECT id INTO work_aux
		FROM cat_work WHERE visit_aux.parameter_id=cat_work.parameter_id;

--check campaign
		SELECT id INTO campaign_aux
		FROM cat_campaign WHERE start_date<=date(visit_aux.tstamp) and end_date>=date(visit_aux.tstamp);

--Update the execution data 
 		UPDATE planning SET plan_execute_date=date(visit_aux.tstamp) 
 		WHERE planning.campaign_id=campaign_aux and planning.mu_id=mu_aux and planning.work_id=work_aux;

 ELSIF TG_OP = 'DELETE' THEN

		
 		SELECT * INTO visit_aux FROM om_visit
 		JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id 
 		JOIN om_visit_parameter ON om_visit_parameter.id=om_visit_event.parameter_id 
 		JOIN om_visit_x_node ON om_visit.id=om_visit_x_node.visit_id;

		
--CHECK mu_id
		SELECT mu_id INTO mu_aux
		FROM node WHERE node_id=visit_aux.node_id;
--check campaign
		SELECT id INTO campaign_aux
		FROM cat_campaign WHERE start_date<=date(visit_aux.tstamp) and end_date>=date(visit_aux.tstamp);
		
--check work_id
		SELECT id INTO work_aux
		FROM cat_work WHERE visit_aux.parameter_id=cat_work.parameter_id;
		
--Set the execution data tu NULL
 		UPDATE planning SET plan_execute_date=NULL WHERE campaign_id=campaign_aux and planning.mu_id=mu_aux and planning.work_id=work_aux;
 		
END IF;
	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

DROP TRIGGER IF EXISTS trg_planned_visit ON arbrat_viari_dev.om_visit_event;

CREATE TRIGGER trg_planned_visit AFTER INSERT OR UPDATE OR DELETE ON arbrat_viari_dev.om_visit_event
  FOR EACH ROW EXECUTE PROCEDURE arbrat_viari_dev.trg_planned_visit('om_visit_event');
