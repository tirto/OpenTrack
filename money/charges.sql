DROP TABLE charges;

CREATE TABLE charges (
       request_id    DATE REFERENCES jobmanage ON DELETE CASCADE,
       charge_id     DATE, -- unique charge id
       order_date    DATE NOT NULL, -- user entered order date
       invoice       VARCHAR(32),
       description   VARCHAR(64) NOT NULL,
       vendor	     VARCHAR(32),
       amount	     NUMBER(8,2) NOT NULL,
       department    NUMBER NOT NULL, -- references 
       payer	     VARCHAR2(20) NOT NULL, -- references assignlist
       paytype	     NUMBER NOT NULL, -- references paymentlist
       received	     CHAR, -- boolean flag
       accounted     CHAR, -- boolean flag
       PRIMARY KEY (request_id, charge_id));

