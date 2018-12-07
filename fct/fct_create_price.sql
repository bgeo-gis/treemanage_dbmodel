-- Function: SCHEMA_NAME.create_price(integer, integer)

/*Goal: The function is used to create new empty registers of prices in the cat_price for the campaign. The values can be copied from the existing dataset.
The function is activated by the button of a tree_manage plugin.*/

-- DROP FUNCTION SCHEMA_NAME.create_price(integer, integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.create_price(
    new_campaign_aux integer,
    old_campaign_aux integer)
  RETURNS void AS
$BODY$
DECLARE
price_aux float;
existing_price record;
exist_new boolean;
exist_old boolean;
BEGIN

 	SET search_path = "SCHEMA_NAME", public;

--check if the new camapaign inserted by the user already exists and if the capaign from which the data should be copied exists
	select exists (select distinct campaign_id from arbrat_viari.cat_price where campaign_id=new_campaign_aux) into exist_new;
	select exists (select distinct campaign_id from arbrat_viari.cat_price where campaign_id=old_campaign_aux)into exist_old;

 	IF old_campaign_aux=0 AND exist_new IS FALSE then
--	If there is no existing campaign, create new rows for combination of work-size-new campaign_id with all prices=0,00
 		INSERT INTO cat_price(work_id,size_id, campaign_id,price) SELECT DISTINCT cat_work.id, cat_size.id,new_campaign_aux,0 FROM arbrat_viari.cat_work, arbrat_viari.cat_size order by 1,2;

 	ELSIF exist_new is true and exist_old is true then
--if the new and old campaign exists: Remove all the existing new campaign_id data and copy the existing ones of the old campaign_id 		
 		DELETE FROM cat_price where campaign_id=new_campaign_aux;
 		INSERT INTO cat_price(work_id,size_id, campaign_id, price) SELECT DISTINCT work_id, size_id, new_campaign_aux, price FROM arbrat_viari.cat_price
 		WHERE campaign_id=old_campaign_aux order by 1,2;
 	ELSE
--create registers by copying the data of the old campaign_id and assigning them the new campaign_id.
 		INSERT INTO cat_price(work_id,size_id, campaign_id, price) SELECT DISTINCT work_id, size_id, new_campaign_aux, price FROM arbrat_viari.cat_price
 		WHERE campaign_id=old_campaign_aux order by 1,2;
 	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
