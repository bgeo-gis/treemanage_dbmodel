/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2786
-- DROP FUNCTION SCHEMA_NAME.tm_fct_copy_planning(json);


CREATE OR REPLACE FUNCTION tm_fct_separate_visit() RETURNS void
    LANGUAGE plpgsql
    AS $$


DECLARE
 v_sql 		text;
 rec_table 	record;
 id_last  	bigint;
 

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;

    --Initiation of the process
	v_sql := 'SELECT * FROM table_aux;';
	FOR rec_table IN EXECUTE v_sql

        LOOP
        -- Insert into visit table and visit_x_feature tables
				INSERT INTO om_visit (startdate, enddate, visitcat_id, user_name, the_geom, is_done) 
				VALUES(rec_table.startdate, rec_table.enddate, rec_table.visitcat_id, rec_table.user_name, rec_table.the_geom, rec_table.is_done) 
				RETURNING id INTO id_last;
				INSERT INTO om_visit_x_node (visit_id, node_id) VALUES(id_last,rec_table.node_id);
				

       	-- Insert into event table				
		INSERT INTO om_visit_event (visit_id, parameter_id, value, tstamp, text) 
		VALUES (id_last, rec_table.parameter_id, rec_table.value, rec_table.tstamp, rec_table.text);	    

        END LOOP;

    RETURN;

        
END;$$;


$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

