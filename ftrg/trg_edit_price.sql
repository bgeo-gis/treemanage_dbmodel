-- Function: SCHEMA_NAME.trg_edit_price()
/*Goal: the trigger allows to modify the values in the price catalog*/
-- DROP FUNCTION SCHEMA_NAME.trg_edit_price();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.trg_edit_price()
  RETURNS trigger AS
$BODY$
DECLARE 
mu_aux integer;
rec_node  record;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';


IF TG_OP = 'UPDATE' THEN

	UPDATE cat_price SET price=NEW.price WHERE cat_price.id=NEW.id;

RETURN NEW;

END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




