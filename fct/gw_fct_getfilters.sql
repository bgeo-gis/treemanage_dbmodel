﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_getfilters(
    p_istilemap boolean,
    device integer,
    lang character varying)
  RETURNS json AS
$BODY$

/*example
SELECT SCHEMA_NAME.gw_fct_getfilters(true, 3, 'en');
SELECT SCHEMA_NAME.gw_fct_getfilters(false, 3, 'en');
*/

DECLARE


--	Variables
	selected_json json;	
	form_json json;
	formTabs_explotations json;
	formTabs_networkStates json;
	formTabs_hydroStates json;
	formTabs_lotSelector json;
	formTabs text;
	json_array json[];
	api_version json;
	rec_tab record;
	v_active boolean=true;
	v_firsttab boolean=false;
	v_istiled_filterstate varchar;
	

BEGIN


-- Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;

--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO api_version;

-- Start the construction of the tabs array
	formTabs := '[';

-- Tab Exploitation
        SELECT * INTO rec_tab FROM config_web_tabs WHERE layer_id='F33' AND formtab='tabExploitation' ;
	IF rec_tab.id IS NOT NULL THEN

		-- Get exploitations, selected and unselected
		IF p_istilemap THEN	

			-- setting whole exploitations for user when is tilemap acoording sys_exploitation_x_user variable			
			IF (SELECT value FROM config_param_system WHERE parameter ='sys_exploitation_x_user')::boolean THEN
				DELETE FROM selector_expl WHERE cur_user = current_user;
				INSERT INTO selector_expl (expl_id, cur_user) SELECT expl_id,current_user FROM exploitation_x_user WHERE user_id=current_user;

				-- getting json
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name as label, exploitation.expl_id as name, ''check'' as type, ''boolean'' as "dataType", true as "value" , true AS disabled
				FROM exploitation JOIN exploitation_x_user ON exploitation_x_user.expl_id=exploitation.expl_id
				WHERE exploitation.expl_id IN (SELECT expl_id FROM selector_expl WHERE cur_user=' || quote_literal('qgisserver') || ')
				AND username=current_user
				UNION
				SELECT name as label, exploitation.expl_id as name, ''check'' as type, ''boolean'' as "dataType", false as "value" , true AS disabled
				FROM exploitation JOIN exploitation_x_user ON exploitation_x_user.expl_id=exploitation.expl_id
				WHERE exploitation.expl_id NOT IN (SELECT expl_id FROM selector_expl WHERE cur_user=' || quote_literal('qgisserver') || '
				AND username=current_user) 
				ORDER BY label) a'
					INTO formTabs_explotations;
			ELSE
				DELETE FROM selector_expl WHERE cur_user = current_user;
				INSERT INTO selector_expl (expl_id, cur_user) SELECT expl_id,current_user FROM exploitation;		
				
				-- getting json
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name as label, expl_id as name, ''check'' as type, ''boolean'' as "dataType", true as "value" , true AS disabled
				FROM exploitation WHERE expl_id IN (SELECT expl_id FROM selector_expl WHERE cur_user=' || quote_literal('qgisserver') || ')
				UNION
				SELECT name as label, expl_id as name, ''check'' as type, ''boolean'' as "dataType", false as "value" , true AS disabled
				FROM exploitation WHERE expl_id NOT IN (SELECT expl_id FROM selector_expl WHERE cur_user=' || quote_literal('qgisserver') || ') ORDER BY label) a'
				INTO formTabs_explotations;
				
			END IF;
			

		ELSE
			-- setting whole exploitations for user acoording sys_exploitation_x_user variable			
			IF (SELECT value FROM config_param_system WHERE parameter ='sys_exploitation_x_user')::boolean THEN
			
				-- getting json
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name as label, exploitation.expl_id as name, ''check'' as type, ''boolean'' as "dataType", true as "value" , false AS disabled
				FROM exploitation JOIN exploitation_x_user ON exploitation_x_user.expl_id=exploitation.expl_id
				WHERE exploitation.expl_id IN (SELECT expl_id FROM selector_expl WHERE cur_user=current_user) AND username=current_user
				UNION
				SELECT name as label, exploitation.expl_id as name, ''check'' as type, ''boolean'' as "dataType", false as "value" , false AS disabled
				FROM exploitation JOIN exploitation_x_user ON exploitation_x_user.expl_id=exploitation.expl_id
				WHERE exploitation.expl_id NOT IN (SELECT expl_id FROM selector_expl WHERE cur_user=current_user) AND username=current_user
				ORDER BY label) a'
					INTO formTabs_explotations;
			ELSE 		
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name as label, expl_id as name, ''check'' as type, ''boolean'' as "dataType", true as "value" , false AS disabled
				FROM exploitation WHERE exploitation.expl_id IN (SELECT expl_id FROM selector_expl WHERE cur_user=current_user)
				UNION
				SELECT name as label, expl_id as name, ''check'' as type, ''boolean'' as "dataType", false as "value" , false AS disabled
				FROM exploitation WHERE exploitation.expl_id IN (SELECT expl_id FROM selector_expl WHERE cur_user=current_user) ORDER BY label) a'
					INTO formTabs_explotations;
			END IF;
		END IF;	
		-- Add tab name to json
		formTabs_explotations := ('{"fields":' || formTabs_explotations || '}')::json;
		formTabs_explotations := gw_fct_json_object_set_key(formTabs_explotations, 'tabName', 'selector_expl'::TEXT);
		formTabs_explotations := gw_fct_json_object_set_key(formTabs_explotations, 'tabLabel', rec_tab.tablabel::TEXT);
		formTabs_explotations := gw_fct_json_object_set_key(formTabs_explotations, 'tabIdName', 'expl_id'::TEXT);
		formTabs_explotations := gw_fct_json_object_set_key(formTabs_explotations, 'active', v_active);

		-- Create tabs array
		IF v_firsttab THEN 
			formTabs := formTabs || ',' || formTabs_explotations::text;
		ELSE 
			formTabs := formTabs || formTabs_explotations::text;
		END IF;

		v_firsttab := TRUE;
		v_active :=FALSE;
	END IF;

-- Tab network state
	SELECT * INTO rec_tab FROM config_web_tabs WHERE layer_id='F33' AND formtab='tabNetworkState' ;
	IF rec_tab.id IS NOT NULL THEN
		
		-- Get states, selected and unselected
		IF p_istilemap THEN
			SELECT ((value::json)->>'istiled_filterstate') as id FROM config_param_system WHERE parameter='api_config_parameters' INTO v_istiled_filterstate;

			-- setting state = 1  for user when is tilemap
			DELETE FROM selector_state WHERE cur_user = current_user AND state_id=1;
			INSERT INTO selector_state (state_id, cur_user) VALUES (1,current_user);
			
			IF v_istiled_filterstate = 'publish_user' THEN
				
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , true AS disabled
				FROM value_state WHERE id IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal('qgisserver') || ')
				UNION
				SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", false AS "value" , true AS disabled
				FROM value_state WHERE id NOT IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal('qgisserver') || ') ORDER BY name) a'
				INTO formTabs_networkStates;	
				RAISE NOTICE 'TEST10 -> %',formTabs_networkStates;
				
			ELSIF v_istiled_filterstate = 'current_user' THEN
				
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , CASE WHEN id=1 THEN true ELSE false END AS disabled
				FROM value_state WHERE id IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal(current_user) || ')
				UNION
				SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", false AS "value" , CASE WHEN id=1 THEN true ELSE false END AS disabled
				FROM value_state WHERE id NOT IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal(current_user) || ') ORDER BY name) a'
				INTO formTabs_networkStates;	
				
				RAISE NOTICE 'TEST20 -> %',formTabs_networkStates;
				
			ELSIF v_istiled_filterstate = 'disabled' THEN
			
				EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , true AS disabled
				FROM value_state WHERE id IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal('qgisserver') || ')
				UNION
				SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , true AS disabled
				FROM value_state WHERE id NOT IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal('qgisserver') || ') ORDER BY name) a'
				INTO formTabs_networkStates;	
				RAISE NOTICE 'TEST30 ->%',formTabs_networkStates;
				
			END IF;
			
			
		ELSE
			EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
			SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , false AS disabled
			FROM value_state WHERE id IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal(current_user) || ')
			UNION
			SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", false AS "value" , false AS disabled
			FROM value_state WHERE id NOT IN (SELECT state_id FROM selector_state WHERE cur_user=' || quote_literal(current_user) || ') ORDER BY name) a'
			INTO formTabs_networkStates;	
		END IF;	
		
		-- Add tab name to json
		formTabs_networkStates := ('{"fields":' || formTabs_networkStates || '}')::json;
		formTabs_networkStates := gw_fct_json_object_set_key(formTabs_networkStates, 'tabName', 'selector_state'::TEXT);
		formTabs_networkStates := gw_fct_json_object_set_key(formTabs_networkStates, 'tabLabel', rec_tab.tablabel::TEXT);
		formTabs_networkStates := gw_fct_json_object_set_key(formTabs_networkStates, 'tabIdName', 'state_id'::TEXT);
		formTabs_networkStates := gw_fct_json_object_set_key(formTabs_networkStates, 'active', v_active);

		raise notice 'formTabs_networkStates %', formTabs_networkStates;

		IF p_istilemap=TRUE AND v_istiled_filterstate = 'disabled' THEN
		
			-- If istiled_filterstate is disable, dont create tab Network States
		ELSE
			-- Create tabs array
			IF v_firsttab THEN 
				formTabs := formTabs || ',' || formTabs_networkStates::text;
			ELSE 
				formTabs := formTabs || formTabs_networkStates::text;
			END IF;

			v_firsttab := TRUE;
			v_active :=FALSE;
			
		END IF;
	END IF;

-- Tab hydrometer state
	SELECT * INTO rec_tab FROM config_web_tabs WHERE layer_id='F33' AND formtab='tabHydroState' ;
	IF rec_tab.id IS NOT NULL THEN
	
		-- Get hydrometer states, selected and unselected
		EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , false AS disabled
		FROM ext_rtc_hydrometer_state WHERE id IN (SELECT state_id FROM selector_hydrometer WHERE cur_user=' || quote_literal(current_user) || ')
		UNION
		SELECT name AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", false AS "value" , false AS disabled
		FROM ext_rtc_hydrometer_state WHERE id NOT IN (SELECT state_id FROM selector_hydrometer WHERE cur_user=' || quote_literal(current_user) || ') ORDER BY name) a'
		INTO formTabs_hydroStates;

	
		-- Add tab name to json
		formTabs_hydroStates := ('{"fields":' || formTabs_hydroStates || '}')::json;
		formTabs_hydroStates := gw_fct_json_object_set_key(formTabs_hydroStates, 'tabName', 'selector_hydrometer'::TEXT);
		formTabs_hydroStates := gw_fct_json_object_set_key(formTabs_hydroStates, 'tabLabel', rec_tab.tablabel::TEXT);
		formTabs_hydroStates := gw_fct_json_object_set_key(formTabs_hydroStates, 'tabIdName', 'state_id'::TEXT);
		formTabs_hydroStates := gw_fct_json_object_set_key(formTabs_hydroStates, 'active', false);

		-- Create tabs array
		IF v_firsttab THEN 
			formTabs := formTabs || ',' || formTabs_hydroStates::text;
		ELSE 
			formTabs := formTabs || formTabs_hydroStates::text;
		END IF;

		v_firsttab := TRUE;
		v_active :=FALSE;
	END IF;

-- Tab lot selector
	SELECT * INTO rec_tab FROM config_web_tabs WHERE layer_id='F33' AND formtab='tabLotSelector' ;
	IF rec_tab.id IS NOT NULL THEN

		-- control if user has permisions
		 IF 'role_om_lot' IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, 'member')) THEN

			-- Get hydrometer states, selected and unselected
			EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
				SELECT idval AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", true AS "value" , false AS disabled
				FROM om_visit_lot WHERE id IN (SELECT lot_id FROM selector_lot WHERE cur_user=' || quote_literal(current_user) || ')
				UNION
				SELECT idval AS label, id AS name, ''check'' AS type, ''boolean'' AS "dataType", false AS "value" , false AS disabled
				FROM om_visit_lot WHERE id NOT IN (SELECT lot_id FROM selector_lot WHERE cur_user=' || quote_literal(current_user) || ') ORDER BY name) a'
				INTO formTabs_lotSelector;

			-- Add tab name to json
			formTabs_lotSelector := ('{"fields":' || formTabs_lotSelector || '}')::json;
			formTabs_lotSelector := gw_fct_json_object_set_key(formTabs_lotSelector, 'tabName', 'selector_lot'::TEXT);
			formTabs_lotSelector := gw_fct_json_object_set_key(formTabs_lotSelector, 'tabLabel', rec_tab.tablabel::TEXT);
			formTabs_lotSelector := gw_fct_json_object_set_key(formTabs_lotSelector, 'tabIdName', 'lot_id'::TEXT);
			formTabs_lotSelector := gw_fct_json_object_set_key(formTabs_lotSelector, 'active', false);

			-- Create tabs array
			IF v_firsttab THEN 
				formTabs := formTabs || ',' || formTabs_lotSelector::text;
			ELSE 
				formTabs := formTabs || formTabs_lotSelector::text;
			END IF;
			v_firsttab := TRUE;
			v_active :=FALSE;
		END IF;
	END IF;


-- Finish the construction of the tabs array
	formTabs := formTabs ||']';


-- Check null
	formTabs := COALESCE(formTabs, '[]');	

-- Return
	IF v_firsttab IS FALSE THEN
		-- Return not implemented
		RETURN ('{"status":"Accepted"' ||
		', "apiVersion":'|| api_version ||
		', "message":"Not implemented"'||
		'}')::json;
	ELSE 
		-- Return formtabs
		RETURN ('{"status":"Accepted"' ||
			', "apiVersion":'|| api_version ||
			', "formTabs":' || formTabs ||
			'}')::json;
	END IF;

-- Exception handling
--	EXCEPTION WHEN OTHERS THEN 
		--RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
