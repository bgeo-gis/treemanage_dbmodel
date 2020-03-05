-- Function: SCHEMA_NAME.tm_fct_planned_visit(integer, integer)

-- DROP FUNCTION SCHEMA_NAME.tm_fct_planned_visit(integer, integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.tm_fct_planned_visit(
    p_visit_id integer,
    p_visit_class integer)
  RETURNS void AS
$BODY$

	DECLARE 
	v_visit record;
	v_mu_id integer;
	v_work_id integer;
	v_campaign integer;
	v_unchangeable_trim text;
	v_changeable_trim text;
	v_action text;
	v_accept_exact_planned_work text;
	v_changeable_remove text;
	v_changeable_cut text;
	v_changeable_reg text;
	
	BEGIN

	    
--  Search path
    SET search_path = "SCHEMA_NAME", public;
		raise notice 'p_visit_id,%',p_visit_id;

	SELECT value  into v_accept_exact_planned_work FROM SCHEMA_NAME.config_param_system WHERE parameter='accept_exact_planned_work';
	SELECT (value::json -> 'trim'::text)  into v_changeable_trim FROM SCHEMA_NAME.config_param_system WHERE parameter='plan_changeable_work';
	SELECT (value::json -> 'remove'::text)  into v_changeable_remove FROM SCHEMA_NAME.config_param_system WHERE parameter='plan_changeable_work';
	SELECT (value::json -> 'cut'::text)  into v_changeable_cut FROM SCHEMA_NAME.config_param_system WHERE parameter='plan_changeable_work';
	SELECT (value::json -> 'reg'::text)  into v_changeable_reg FROM SCHEMA_NAME.config_param_system WHERE parameter='plan_changeable_work';

	--Select all the data related to visit

	 		SELECT om_visit.id,om_visit_parameter.id as parameter_id,om_visit_event.id as event_id, om_visit_event.value,om_visit_x_node.node_id,om_visit.startdate
	 		INTO v_visit FROM om_visit 
	 		JOIN om_visit_event ON om_visit.id=om_visit_event.visit_id 
	 		JOIN om_visit_parameter ON om_visit_parameter.id=om_visit_event.parameter_id 
	 		JOIN om_visit_x_node ON om_visit.id=om_visit_x_node.visit_id WHERE om_visit.id=p_visit_id limit 1;
			raise notice 'v_visit,%',v_visit;
	--CHECK mu_id
			IF p_visit_class=2 THEN
				SELECT mu_id INTO v_mu_id
				FROM node WHERE node_id=v_visit.node_id;
				raise notice 'poblacion,%',v_mu_id;
			END IF;
	--check work_id
			SELECT id INTO v_work_id
			FROM cat_work WHERE v_visit.parameter_id=cat_work.parameter_id;

raise notice 'v_work_id,%',v_work_id;
	--check campaign dates
			SELECT id INTO v_campaign
			FROM cat_campaign WHERE start_date<=date(v_visit.startdate) and end_date>=date(v_visit.startdate) AND cat_campaign.active=TRUE;
					raise notice 'v_changeable_trim,v_changeable_remove,v_changeable_cut, %,%,%',v_changeable_trim,v_changeable_remove,v_changeable_cut;		
	--check if work is in any
	v_changeable_trim=replace(replace(v_changeable_trim::text,'[','{'),']','}');
	v_changeable_remove=replace(replace(v_changeable_remove::text,'[','{'),']','}');
	v_changeable_cut=replace(replace(v_changeable_cut::text,'[','{'),']','}');
	v_changeable_reg=replace(replace(v_changeable_reg::text,'[','{'),']','}');


			IF (v_work_id = ANY((v_changeable_trim)::integer[]) and v_action IS NULL) THEN
				v_action='trim';
			END IF;
			
			IF (v_work_id = ANY((v_changeable_remove)::integer[]) and v_action IS NULL) THEN
				v_action='remove';

			END IF;
			IF v_work_id =  ANY((v_changeable_cut)::integer[]) and v_action IS NULL THEN
				v_action='cut';
			END IF;
			
			IF v_work_id =  ANY((v_changeable_reg)::integer[]) and v_action IS NULL THEN
				v_action='reg';
			END IF;
			raise notice 'v_changeable_trim, v_action,v_work_id::text, %,%,%',v_changeable_trim,v_action,v_work_id::text;
	raise notice 'v_changeable_remove,%',v_changeable_remove;
	raise notice 'v_changeable_cut,%',v_changeable_cut;
	
	--update planning or planning_unit, depending on the used parameter; update frequency count of unit planning
			IF p_visit_class=2 THEN

				IF (v_accept_exact_planned_work = 'FALSE' AND v_action IS NOT NULL) THEN		
				
					IF v_action='trim' THEN
						UPDATE planning SET plan_execute_date=date(v_visit.startdate), executed_work=v_work_id 
						WHERE  id IN (SELECT id FROM planning WHERE campaign_id=v_campaign
						and planning.mu_id=v_mu_id AND work_id =  ANY((v_changeable_trim)::integer[]) AND
						plan_execute_date is null ORDER BY id LIMIT 1 );
					
					ELSIF v_action='remove' THEN
						UPDATE planning SET plan_execute_date=date(v_visit.startdate), executed_work=v_work_id 
						WHERE id IN (SELECT id FROM planning WHERE campaign_id=v_campaign
						and planning.mu_id=v_mu_id AND work_id =  ANY((v_changeable_remove)::integer[]) AND
						plan_execute_date is null ORDER BY id LIMIT 1);
						
					ELSIF v_action='cut' THEN
						UPDATE planning SET plan_execute_date=date(v_visit.startdate), executed_work=v_work_id 
						WHERE id IN (SELECT id FROM planning WHERE campaign_id=v_campaign
						and planning.mu_id=v_mu_id AND work_id =  ANY((v_changeable_cut)::integer[]) AND
						plan_execute_date is null ORDER BY id LIMIT 1);
					
					ELSIF v_action='reg' THEN
						UPDATE planning SET plan_execute_date=date(v_visit.startdate), executed_work=v_work_id 
						WHERE id IN (SELECT id FROM planning WHERE campaign_id=v_campaign
						and planning.mu_id=v_mu_id AND work_id =  ANY((v_changeable_reg)::integer[]) AND
						plan_execute_date is null ORDER BY work_id LIMIT 1);

					END IF;
					
				ELSE
					UPDATE planning SET plan_execute_date=date(v_visit.startdate), executed_work=v_work_id WHERE campaign_id=v_campaign
					and planning.mu_id=v_mu_id and planning.work_id=v_work_id AND plan_execute_date is null;
				END IF;
				
			ELSE 
				raise notice 'campana,node_id,work,v_action,%,%,%,%',v_campaign,v_visit.node_id,v_work_id,v_action;

				IF (v_accept_exact_planned_work = 'FALSE' AND v_action IS NOT NULL) THEN		
				
					IF v_action='trim' THEN
						UPDATE planning_unit SET plan_execute_date=date(v_visit.startdate), frequency_executed=frequency_executed+1, executed_work=v_work_id,
						visit_id=p_visit_id WHERE  id IN (SELECT id FROM planning_unit WHERE campaign_id=v_campaign and planning_unit.node_id=v_visit.node_id and work_id =  ANY((v_changeable_trim)::integer[]) AND
						plan_execute_date is null ORDER BY plan_date LIMIT 1 );
				
					ELSIF v_action='remove' THEN
						UPDATE planning_unit SET plan_execute_date=date(v_visit.startdate), frequency_executed=frequency_executed+1, executed_work=v_work_id,
						visit_id=p_visit_id
						WHERE  id IN (SELECT id FROM planning_unit WHERE campaign_id=v_campaign and planning_unit.node_id=v_visit.node_id and 
						work_id =  ANY((v_changeable_remove)::integer[]) AND plan_execute_date is null  ORDER BY plan_date LIMIT 1);
				
					ELSIF v_action='cut' THEN
						UPDATE planning_unit SET plan_execute_date=date(v_visit.startdate), frequency_executed=frequency_executed+1, executed_work=v_work_id,
						visit_id=p_visit_id
						WHERE  id IN (SELECT id FROM planning_unit WHERE campaign_id=v_campaign and planning_unit.node_id=v_visit.node_id and 
						work_id =  ANY((v_changeable_cut)::integer[]) and plan_execute_date is null  ORDER BY plan_date LIMIT 1);

					ELSIF v_action='reg' THEN
						UPDATE planning_unit SET plan_execute_date=date(v_visit.startdate), frequency_executed=frequency_executed+1, executed_work=v_work_id,
						visit_id=p_visit_id
						WHERE  id IN (SELECT id FROM planning_unit WHERE campaign_id=v_campaign and planning_unit.node_id=v_visit.node_id and 
						work_id =  ANY((v_changeable_reg)::integer[]) and plan_execute_date is null ORDER BY plan_date LIMIT 1);

					END IF;
				ELSE
					UPDATE planning_unit SET plan_execute_date=date(v_visit.startdate), frequency_executed=frequency_executed+1,executed_work=v_work_id,
					visit_id=p_visit_id WHERE campaign_id=v_campaign
					and planning_unit.node_id=v_visit.node_id and planning_unit.work_id=v_work_id AND plan_execute_date is null;
				END IF;
	 		END IF;

	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

