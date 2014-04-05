DROP TABLE paymenttype;

CREATE TABLE paymenttype (
       payid NUMBER PRIMARY KEY,
       paydesc VARCHAR(32) NOT NULL );

INSERT INTO paymenttype VALUES (1, 'Credit Card');
INSERT INTO paymenttype VALUES (2, 'Purchase Order');
INSERT INTO paymenttype VALUES (3, 'Fast Track');
INSERT INTO paymenttype VALUES (4, 'Petty Cash');
INSERT INTO paymenttype VALUES (5, 'Reg. Payment Request');
INSERT INTO paymenttype VALUES (6, 'Open Purchase Order');
INSERT INTO paymenttype VALUES (7, 'Travel');
