/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2786
--SELECT SCHEMA_NAME.gw_fct_check_importdxf();
CREATE OR REPLACE FUNCTION SCHEMA_NAME.tm_fct_copy_planning(p_data json)
RETURNS json AS
$BODY$
/*
SELECT tm_fct_copy_planning($${"client":{"device":9, "infoType":100, "lang":"ES"}, 
"form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, 
"parameters":{"txt_campaign":"15", "cbx_pendientes":"11", "chk_pendiente":"true", 
"cbx_campaigns":"14", "chk_campaign":"true"}}}$$)::text;
*/

DECLARE 
v_new_campaign integer;
v_undone_campaign integer;
v_isundone boolean;
v_total_campaign integer;
v_istotal boolean;

rec record;

v_result json;
v_result_info json;
v_result_point json;
v_result_polygon json;
v_result_line json;
v_version text;

 
BEGIN 


	-- search path
	SET search_path = "SCHEMA_NAME", public;

	SELECT  giswater INTO  v_version FROM version order by id desc limit 1;

	-- get input data 	
	v_new_campaign := ((p_data ->>'data')::json->>'parameters')::json->>'txt_campaign'::text;
	v_undone_campaign := ((p_data ->>'data')::json->>'parameters')::json->>'cbx_pendientes'::text;
	v_isundone := ((p_data ->>'data')::json->>'parameters')::json->>'chk_pendiente'::text;
	v_total_campaign := ((p_data ->>'data')::json->>'parameters')::json->>'cbx_campaigns'::text;
	v_istotal := ((p_data ->>'data')::json->>'parameters')::json->>'chk_campaign'::text;

	DELETE FROM planning WHERE campaign_id = v_new_campaign;

	--copy undone data from selected campaign
	IF v_isundone IS TRUE THEN
		INSERT INTO planning(mu_id, work_id, campaign_id,  builder_id,  comment)
	    SELECT mu_id, work_id, v_new_campaign, builder_id, 
	    CONCAT('COPIED FROM CAMPAIGN: ',v_undone_campaign)
	    FROM planning WHERE campaign_id = v_undone_campaign AND plan_execute_date IS NULL;
	END IF;

	--copy planning defined from selected campaign
	IF v_istotal IS TRUE THEN
		INSERT INTO planning(mu_id, work_id, campaign_id, builder_id, comment)
	    SELECT mu_id, work_id, v_new_campaign, builder_id, comment
	    FROM planning WHERE campaign_id = v_total_campaign AND plan_execute_date IS NULL 
	    ON CONFLICT (mu_id, campaign_id) DO NOTHING;
	END IF;

	--update prices for planning
	FOR rec IN (SELECT * FROM planning WHERE campaign_id=v_new_campaign) LOOP
		PERFORM set_plan_price (rec.mu_id, rec.work_id, v_new_campaign);
	END LOOP;

	-- get results
	-- info
	v_result_info := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result_info, '}');

	--points
	v_result = null;

	v_result := COALESCE(v_result, '{}'); 
	
	IF v_result::text = '{}' THEN 
		v_result_point = '{"geometryType":"", "values":[]}';
	ELSE 
		v_result_point = concat ('{"geometryType":"Point", "values":',v_result,',"category_field":"descript","size":4}');
	END IF;

	v_result_line = '{"geometryType":"", "values":[],"category_field":""}';
	v_result_polygon = '{"geometryType":"", "values":[],"category_field":""}';

--  Return
    RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||'}'||
		       '}'||
	    '}')::json;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

