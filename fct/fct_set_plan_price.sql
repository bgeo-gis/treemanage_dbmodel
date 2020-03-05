-- Function: SCHEMA_NAME.set_plan_price(integer, integer, integer)
/*Goal:Compare if exists the information of the price for the selected trees,work and campaign and adding the values for the planification
The function is activated when the new elements are being saved in the planning table.
*/
-- DROP FUNCTION SCHEMA_NAME.set_plan_price(integer, integer, integer);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.set_plan_price(
    mu_id_aux integer,
    work_id_aux integer,
    campaign_aux integer)
  RETURNS void AS
$BODY$
DECLARE
price_aux float;
tree_num_aux integer;

BEGIN

 	SET search_path = "SCHEMA_NAME", public;
	--check if mu_id still exists
IF mu_id_aux IN (SELECT DISTINCT mu_id FROM node) THEN
--sum the price of the selected works for the selected cat_mu
	price_aux=(select sum(cat_price.price)FROM cat_mu  LEFT JOIN node ON cat_mu.id = node.mu_id
	LEFT JOIN cat_work ON cat_work.id = cat_mu.work_id
	LEFT JOIN cat_price ON cat_price.work_id = work_id_aux AND node.size_id = cat_price.size_id and cat_price.campaign_id=campaign_aux where cat_mu.id=mu_id_aux);
--calculate the number of trees in the mu
	tree_num_aux=(select count(node_id) FROM node WHERE mu_id=mu_id_aux);
--check if there is created the price dataset for the mu
	IF price_aux is null then
		RAISE exception 'Faltan precios para la combinacion de año,poblacion,trabajo,% ,% ,% ',campaign_aux, mu_id_aux,work_id_aux;
	END IF;
--update the planning table adding the information of the work price and current number of tree
	UPDATE planning 
	SET price=price_aux, tree_number=tree_num_aux
	where mu_id=mu_id_aux and work_id=work_id_aux and campaign_id=campaign_aux;
END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
