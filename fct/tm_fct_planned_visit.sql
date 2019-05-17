-- Function: SCHEMA_NAME.tm_fct_planned_visit(integer, integer)

-- DROP FUNCTION SCHEMA_NAME.tm_fct_planned_visit(integer, integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.tm_fct_planned_visit(
    p_visit_id integer,
    p_visit_class integer)
  RETURNS void AS
$BODY$

	DECLARE 
	visit_aux record;
	mu_aux integer;
	work_aux integer;
	campaign_aux integer;

	BEGIN

	    
--  Search path
    SET search_path = "SCHEMA_NAME", public;
		raise notice 'p_visit_id,%',p_visit_id;
	--Select all the data related to visit

	 		SELECT om_visit.id,om_visit_parameter.id as parameter_id,om_visit_event.id as event_id, om_visit_event.value,om_visit_x_node.node_id 
	 		INTO visit_aux FROM om_visit 
	 		JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id 
	 		JOIN om_visit_parameter ON om_visit_parameter.id=om_visit_event.parameter_id 
	 		JOIN om_visit_x_node ON om_visit.id=om_visit_x_node.visit_id WHERE om_visit.id=p_visit_id limit 1;
			raise notice 'visit_aux,%',visit_aux;
	--CHECK mu_id
			IF p_visit_class=2 THEN
				SELECT mu_id INTO mu_aux
				FROM node WHERE node_id=visit_aux.node_id;
				raise notice 'poblacion,%',mu_aux;
			END IF;
	--check work_id
			SELECT id INTO work_aux
			FROM cat_work WHERE visit_aux.parameter_id=cat_work.parameter_id;


	--check campaign dates
			SELECT id INTO campaign_aux
			FROM cat_campaign WHERE start_date<=date(visit_aux.value) and end_date>=date(visit_aux.value) AND cat_campaign.active=TRUE;

	--update planning or planning_unit, depending on the used parameter; update frequency count of unit planning
			IF p_visit_class=2 THEN

				UPDATE planning SET plan_execute_date=date(visit_aux.value) WHERE campaign_id=campaign_aux
				and planning.mu_id=mu_aux and planning.work_id=work_aux;

			ELSE 
				raise notice 'campana,node_id,work,%,%,%',campaign_aux,visit_aux.node_id,work_aux;

				UPDATE planning_unit SET plan_execute_date=date(visit_aux.value), frequency_executed=frequency_executed+1 WHERE campaign_id=campaign_aux
				and planning_unit.node_id=visit_aux.node_id and planning_unit.work_id=work_aux;

	 		END IF;

	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

