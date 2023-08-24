/* 
Deepak Binkam 
INST327
0202
*/


#Question 1


USE ex; 


WITH RECURSIVE management_cte AS 
(SELECT employee_id, CONCAT(first_name, ' ', last_name) AS employee_name, department_number,  manager_id FROM employees) 
SELECT employees.employee_id, CONCAT(first_name, ' ', last_name) AS employee_name, employees.department_number, employees.manager_id
FROM employees 


LEFT JOIN departments
ON employees.department_number = departments.department_number;


#Question 2


SET SESSION SQL_SAFE_UPDATES = 0; 
SET GLOBAL MAX_CONNECTIONS = 60;


SET SESSION AUTOCOMMIT = 0;
SET SESSION AUTOCOMMIT = 1;


SET GLOBAL MAX_EXECUTION_TIME = 10;
SET SESSION CTE_MAX_RECURSION_DEPTH = 300;


SHOW VARIABLES LIKE 'SQL_SAFE_UPDATES';
SHOW VARIABLES LIKE 'MAX_CONNECTIONS';
SHOW VARIABLES LIKE 'AUTOCOMMIT';
SHOW VARIABLES LIKE 'MAX_EXECUTION_TIME'; #I am confused why this value does not change when it is displayed
SHOW VARIABLES LIKE 'CTE_MAX_RECURSION_DEPTH';


SHOW VARIABLES;


#Question 3


CREATE USER 'falcon'@'localhost' IDENTIFIED BY 'cap';
CREATE USER 'bucky_barnes'@'localhost' IDENTIFIED BY 'longing_rusted_seventeen';
CREATE USER 'john_walker'@'localhost' IDENTIFIED BY 'battlestar';
CREATE USER 'flag_smasher'@'localhost' IDENTIFIED BY 'Karli';


ALTER USER 'falcon'@'localhost' PASSWORD EXPIRE INTERVAL 60 DAY;
ALTER USER 'bucky_barnes'@'localhost' PASSWORD EXPIRE INTERVAL 60 DAY;
ALTER USER 'john_walker'@'localhost' PASSWORD EXPIRE INTERVAL 60 DAY;
ALTER USER 'flag_smasher'@'localhost' PASSWORD EXPIRE INTERVAL 60 DAY;


RENAME USER 'falcon'@'localhost' TO 'captain_america'@'localhost';
ALTER USER 'captain_america'@'localhost' IDENTIFIED BY 'redwing';
DROP USER 'john_walker'@'localhost'; 


# Question 4


DROP VIEW IF EXISTS late_invoices;
USE ap;




CREATE VIEW late_invoices AS
SELECT vendors.vendor_name AS 'Vendor Name', invoices.invoice_number AS 'Invoice Number', 
DATE_FORMAT(invoices.invoice_due_date, '%M %D') AS 'Invoice Due Date', 
DATE_FORMAT(invoices.payment_date, '%M %D') AS 'Payment Date',


DATEDIFF(invoices.payment_date, invoices.invoice_due_date) AS 'Days Late', 
CONCAT('$', FORMAT(invoices.invoice_total, 'C')) AS 'Total Invoice Amount'


FROM invoices 
INNER JOIN vendors ON invoices.vendor_id = vendors.vendor_id
WHERE (invoices.payment_date > invoices.invoice_due_date OR invoices.payment_date = NULL)
ORDER BY DATEDIFF(invoices.payment_date, invoices.invoice_due_date) DESC, invoices.invoice_total DESC;


SELECT * FROM late_invoices


-- Q3 Trigger


DROP TRIGGER IF EXISTS new_invoice_row;


DELIMITER //


CREATE TRIGGER new_invoice_row


        AFTER INSERT ON invoices
        FOR EACH ROW
        
BEGIN
        DECLARE invoice_id_var INT;
        DECLARE invoice_total_var DECIMAL (9,2);
        DECLARE vendor_id_var INT;
        DECLARE vendor_name_var VARCHAR(30);


        SET invoice_id_var = NEW.invoice_id;
        SET invoice_total_var = NEW.invoice_total;
        SET vendor_id_var = NEW.vendor_id;
        SELECT vendor_name INTO vendor_name_var FROM vendors WHERE vendor_id = vendor_id_var;
        INSERT INTO new_invoice_records VALUES
        (invoice_id_var, concat("You have added a new invoice from ", vendor_name_var, " with an invoice total of $", invoice_total_var), NOW());
END//


DELIMITER ;




INSERT INTO invoices VALUES (118,34,'ZXA-080','2018-02-01',14092.59,0,0,3,'2018-03-01', NULL);
SELECT * FROM new_invoice_records;



/* 
Deepak Binkam 
INST327
0202
*/


/* Question 5 */


USE my_guitar_shop;


SELECT DISTINCT
product_name AS "Product Name", 
category_name AS "Category", 
quantity AS "Number Purchased", 
CONCAT(ROUND((discount_amount/list_price)*100, 2), "%") AS "Discount", 
CONCAT("$", (list_price - discount_amount)*quantity) AS "Discounted Order"
FROM products


JOIN categories
ON products.category_id = categories.category_id
JOIN order_items
ON products.product_id = order_items.product_id
ORDER BY product_name;


/* Question 6 */


USE my_guitar_shop;


SELECT DISTINCT CONCAT(first_name,' ', last_name) as "Customer Name", 
email_address AS "Customer Email",
CONCAT(line1, ' ',line2) AS "Customer Address",
CONCAT(city, ', ', state, ' ', zip_code) AS "Customer City/State/Zip-Code"
FROM customers


RIGHT JOIN addresses 
ON customers.customer_id = addresses.customer_id
WHERE customers.customer_id IN (SELECT customer_id FROM orders)


GROUP BY last_name
ORDER BY last_name;


/* Question 7 */ 


USE my_guitar_shop;


WITH valid_card_cte 
AS( 
SELECT CONCAT(first_name, " ", last_name) AS customer_name, 
order_id, 
card_number,
CASE WHEN card_type = "American Express" OR card_type = "Discover" THEN "Invalid Card Type" ELSE card_type
END AS card_type, card_expires
FROM orders, customers
WHERE orders.customer_id = customers.customer_id 
)


SELECT customer_name, order_items.order_id, product_name, CONCAT('$', item_price) AS "item_price", card_number, card_type, card_expires
FROM order_items, products, valid_card_cte
WHERE order_items.order_id = valid_card_cte.order_id 
AND order_items.product_id = products.product_id;


/* 
Deepak Binkam 
INST327
0202
*/


/* Question 8 */


USE my_guitar_shop;


DROP TABLE IF EXISTS customers_copy;
CREATE TABLE customers_copy LIKE customers;
INSERT INTO customers_copy 
SELECT* FROM customers;


DROP TABLE IF EXISTS products_copy;
CREATE TABLE products_copy LIKE products;
INSERT INTO products_copy 
SELECT* FROM products;


DROP TABLE IF EXISTS addresses_copy;
CREATE TABLE addresses_copy LIKE addresses;
INSERT INTO addresses_copy 
SELECT* FROM addresses;


/* Question 9 */ 


USE my_guitar_shop;
INSERT INTO customers_copy (Customer_id, Email_address, Password, First_name, Last_name, Shipping_address_id, billing_address_id) 
VALUES (default, 'vdiker@murach.com', '7a718fbd768d2378z511f8249b54897f940e9023', 'Vedat', 'Diker', 10, 1); 


/* Question 10 */ 


USE my_guitar_shop;
INSERT INTO products_copy (Product_id, Category_id, Product_code, Product_name, Description, list_price, discount_percent, date_added) 
VALUES 
(11, 4, 'Y_PK100', 'Yamaha PK-100', "The Yamaha PK-100 88-key weighted action digital piano has a Graded Hammer Standard Action, 192-note Polyphony, 24 Sounds, Stereo Sound System, EQ, and Drum Patterns/Virtual Accompaniment - Black", 800.00, 20.00, NOW());  


/* Question 11 */


USE my_guitar_shop;
UPDATE products_copy 
SET list_price = '689.99', discount_percent = '40'
WHERE Product_name = 'Yamaha PK-100'; 


/* Question 12 */


USE my_guitar_shop;
UPDATE addresses_copy
SET disabled = 1
WHERE state = 'CA' OR state = 'OR';


/* Question 13 */


USE my_guitar_shop;
SELECT CONCAT(customers.first_name, ' ', customers.last_name) AS "Name", customers.shipping_address_id AS "Address", orders.order_id AS "Order ID", (orders.ship_amount + orders.tax_amount) AS Total, orders.ship_date AS "Ship Date"
FROM customers
INNER JOIN orders ON customers.customer_id = orders.customer_id;


DELETE FROM orders
WHERE order_id = (SELECT product_id FROM products_copy WHERE product_name = 'Fender Stratocaster');


DELETE FROM order_items
WHERE order_id = (SELECT product_id FROM products_copy WHERE product_name = 'Fender Stratocaster');


DELETE FROM products_copy
WHERE product_name = 'Fender Stratocaster';


/* 
Deepak Binkam 
INST327
0202
*/


/* Question 14 */
USE ap;


SELECT vendor_name AS Vendor, CONCAT('Phone#: ', vendor_phone) AS "Phone Number", vendor_city AS City, vendor_address1 AS "Address"
FROM vendors 
WHERE vendor_state > 'C' AND vendor_state < 'CO'
ORDER BY vendor_city, vendor_name;


/* Question 15 */
USE om;


SELECT order_date, 'Not yet shipped' AS shipped_date, customer_state, customer_address, CONCAT(customer_first_name, ' ', customer_last_name) AS 'customer_full_name' 
FROM orders
LEFT JOIN customers
ON orders.customer_id = customers.customer_id
WHERE shipped_date IS NULL


UNION


SELECT order_date, shipped_date, customer_state, customer_address, CONCAT(customer_first_name, ' ', customer_last_name) AS 'customer_full_name'
FROM orders
RIGHT JOIN customers
ON orders.customer_id = customers.customer_id
WHERE shipped_date IS NOT NULL


ORDER BY order_date DESC;


/* Question 16 */
USE ap;


SELECT invoice_number, invoice_total, vendor_name, CONCAT(vendor_contact_first_name, ' ', vendor_contact_last_name) AS "vendor_contact_name", vendor_phone, vendor_address1 AS "vendor_address"         
FROM invoices
RIGHT JOIN vendors 
ON invoices.vendor_id = vendors.vendor_id
LEFT JOIN vendor_contacts
ON vendors.vendor_id = vendor_contacts.vendor_id


ORDER BY vendor_name;


/* Question 17 */
USE ap;
SELECT vendor_name, CONCAT(vendor_city, '.', vendor_state) AS "vendor_city/state", invoice_number, payment_total, invoice_date, invoice_due_date
FROM invoices
INNER JOIN vendors ON invoices.vendor_id = vendors.vendor_id
WHERE month(invoice_due_date) > 5 AND month(invoice_due_date) < 7
ORDER BY invoice_due_date;
