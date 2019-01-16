SET search_path='SCHEMA_NAME',public;

INSERT INTO cat_state(id, name) VALUES (0, 'baixa');
INSERT INTO cat_state(id, name) VALUES (1, 'alta');

INSERT INTO cat_verify(id, name) VALUES (1, 'Aceptar');
INSERT INTO cat_verify(id, name) VALUES (2, 'Deshacer');
INSERT INTO cat_verify(id, name) VALUES (3, 'Verificar');
