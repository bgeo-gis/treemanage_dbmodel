SET search_path='SCHEMA_NAME',public;

INSERT INTO config_param_system VALUES (31, 'street_layer', 'ext_streetaxis', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (32, 'street_field_code', 'id', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (33, 'street_field_name', 'name', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (34, 'portal_layer', 'ext_address', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (35, 'portal_field_code', 'streetaxis', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (36, 'portal_field_number', 'number', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (9, 'expl_field_name', 'name', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (7, 'expl_layer', 'exploitation', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (16, 'network_field_arc_code', 'code', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (13, 'network_layer_element', 'element', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (18, 'network_field_element_code', 'code', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (19, 'network_field_gully_code', 'code', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (22, 'hydrometer_urban_propierties_field_code', 'connec_id', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (11, 'network_layer_arc', 'v_edit_arc', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (12, 'network_layer_connec', 'v_edit_connec', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (2, 'doc_absolute_path', 'c:\', '1', '1', NULL);
INSERT INTO config_param_system VALUES (25, 'hydrometer_field_urban_propierties_code', 'connec_id', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (15, 'network_layer_node', 'v_edit_node', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (24, 'hydrometer_field_code', 'hydrometer_id', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (17, 'network_field_connec_code', 'code', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (23, 'hydrometer_layer', 'v_rtc_hydrometer', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (20, 'network_field_node_code', 'code', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (14, 'network_layer_gully', 'v_edit_gully', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (21, 'hydrometer_urban_propierties_layer', 'v_edit_connec', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (4, 'om_visit_absolute_path', 'https://www.', '2', '2', NULL);
INSERT INTO config_param_system VALUES (10, 'scale_zoom', '2500', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (37, 'portal_field_postal', 'postcode', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (38, 'street_field_expl', 'muni_id', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (8, 'expl_field_code', 'muni_id', NULL, 'searchplus', NULL);
INSERT INTO config_param_system VALUES (1000, 'hydrometer_link_absolute_path', 'https://www.giswater.org', NULL, 'connec', NULL);
INSERT INTO config_param_system VALUES (5, 'custom_giswater_folder', 'D:\dades\github\giswater_java_v3\sql\api', '1', '1', NULL);



INSERT INTO sys_feature_cat VALUES ('PLANTACION', 'NODE', 1, 'v_plantacion', NULL);
INSERT INTO sys_feature_cat VALUES ('NODE', 'NODE', 2, 'v_edit_node', NULL);


INSERT INTO version_tm VALUES (1, '3.0.114', 'WS', 'PostgreSQL 9.3.1, compiled by Visual C++ build 1600, 64-bit', '', '2018-03-27 12:44:43.09935', 'EN', 25831);
INSERT INTO version_tm VALUES (5, '3.0.115', 'WS', 'PostgreSQL 9.4.15 on x86_64-unknown-linux-gnu, compiled by gcc (Debian 4.9.2-10) 4.9.2, 64-bit', '', '2018-04-09 09:02:32.119068', 'en', 0);
INSERT INTO version_tm VALUES (6, '3.0.115', 'WS', 'PostgreSQL 9.4.15 on x86_64-unknown-linux-gnu, compiled by gcc (Debian 4.9.2-10) 4.9.2, 64-bit', '', '2018-04-09 09:02:37.952235', 'en', 0);
INSERT INTO version_tm VALUES (7, '3.0.115', 'WS', 'PostgreSQL 9.4.15 on x86_64-unknown-linux-gnu, compiled by gcc (Debian 4.9.2-10) 4.9.2, 64-bit', '', '2018-04-09 09:59:05.551046', 'en', 0);

