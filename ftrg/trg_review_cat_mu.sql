

-- DROP FUNCTION "SCHEMA_NAME".trg_review_cat_mu();
--Goal: Updating the view v_review_cat_mu where all the mu with the work_id value=NULL are stored

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".trg_review_cat_mu()
  RETURNS trigger AS
$BODY$
DECLARE 
	expl_id_int integer;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	
	UPDATE cat_mu 
	SET work_id=NEW.work_id
	WHERE id=NEW.id;
		
		RETURN NEW;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
  