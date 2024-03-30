--1.How many customers do not have DOB information available?
SELECT COUNT(*) AS Num_Customers_No_DOB
FROM Customers
WHERE dob IS NULL;
--2.How many customers are there in each pincode and gender combination?
SELECT primary_pincode, gender, COUNT(*) AS num_customers
FROM Customers
GROUP BY primary_pincode, gender;
--3.Print product name and mrp for products which have more than 50000 MRP? 
SELECT product_name, mrp
FROM Products
WHERE mrp > 50000;
--4.How many delivery personal are there in each pincode?
SELECT pincode, COUNT(*) AS num_delivery_personnel
FROM Delivery_Person
GROUP BY pincode;
--5.For each Pin code, print the count of orders, sum of total amount paid, average amount  paid, maximum amount paid, minimum amount paid for the transactions which were paid by 'cash'. Take only 'buy' order types
SELECT 
    o.delivery_pincode AS pincode,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount_paid) AS total_amount_paid,
    AVG(o.total_amount_paid) AS average_amount_paid,
    MAX(o.total_amount_paid) AS max_amount_paid,
    MIN(o.total_amount_paid) AS min_amount_paid
FROM 
    Orders o
JOIN 
    Delivery_Person dp ON o.delivery_person_id = dp.delivery_person_id
WHERE 
    o.payment_type = 'cash' AND 
    o.order_type = 'buy'
GROUP BY 
    o.delivery_pincode;
--6.For each delivery_person_id, print the count of orders and total amount paid for product_id = 12350 or 12348 and total units > 8. Sort the output by total amount paid in descending order. Take only 'buy' order types
SELECT 
    o.delivery_person_id,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount_paid) AS total_amount_paid
FROM 
    Orders o
WHERE 
    o.order_type = 'buy' 
    AND o.product_id IN (12350, 12348) 
    AND o.tot_units > 8
GROUP BY 
    o.delivery_person_id
ORDER BY 
    total_amount_paid DESC;
--7.Print the Full names (first name plus last name) for customers that have email on "gmail.com"?
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM Customers
WHERE email LIKE '%@gmail.com';
--8.Which pincode has average amount paid more than 150,000? Take only 'buy' order types
SELECT 
    delivery_pincode AS pincode,
    AVG(total_amount_paid) AS avg_amount_paid
FROM 
    Orders
WHERE 
    order_type = 'buy'
GROUP BY 
    delivery_pincode
HAVING 
    AVG(total_amount_paid) > 150000;
--9.Create following columns from order_dim data - order_date Order day Order month Order year
SELECT 
    order_date,
    DAY(order_date) AS order_day,
    MONTH(order_date) AS order_month,
    YEAR(order_date) AS order_year
FROM 
    order_dim;
--10.How many total orders were there in each month and how many of them were returned? Add a column for return rate too.return rate = (100.0 * total return orders) / total buy ordersHint: You will need to combine SUM() with CASE WHEN
SELECT 
    MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_type = 'return' THEN 1 ELSE 0 END) AS total_return_orders,
    (100.0 * SUM(CASE WHEN order_type = 'return' THEN 1 ELSE 0 END)) / COUNT(*) AS return_rate
FROM 
    Orders
GROUP BY 
    MONTH(order_date);
--11.How many units have been sold by each brand? Also get total returned units for each brand.
SELECT p.brand, 
       SUM(o.tot_units) AS total_units_sold, 
       SUM(o.tot_units_returned) AS total_units_returned 
FROM orders o 
JOIN products p ON o.product_id = p.product_id 
GROUP BY p.brand;
--12.How many distinct customers and delivery boys are there in each state?
SELECT p.state, COUNT(DISTINCT c.cust_id) as num_customers, COUNT(DISTINCT dp.delivery_person_id) as num_delivery_boys
FROM Customers c
JOIN Pincode p ON c.primary_pincode = p.pincode
JOIN Delivery_Person dp ON p.pincode = dp.delivery_pincode
GROUP BY p.state;
--13.For every customer, print how many total units were ordered, how many units were ordered from their primary_pincode and how many were ordered not from the primary_pincode. Also calulate the percentage 
SELECT 
  c.cust_id, 
  c.first_name, 
  c.last_name,
  SUM(o.tot_units) AS total_units,
  SUM(CASE WHEN p.pincode = c.primary_pincode THEN o.tot_units ELSE 0 END) AS units_from_primary_pincode,
  SUM(CASE WHEN p.pincode <> c.primary_pincode THEN o.tot_units ELSE 0 END) AS units_not_from_primary_pincode,
  (SUM(CASE WHEN p.pincode = c.primary_pincode THEN o.tot_units ELSE 0 END) / SUM(o.tot_units)) * 100 AS percentage_from_primary_pincode,
  (SUM(CASE WHEN p.pincode <> c.primary_pincode THEN o.tot_units ELSE 0 END) / SUM(o.tot_units)) * 100 AS percentage_not_from_primary_pincode
FROM 
  customers c
  JOIN orders o ON c.cust_id = o.cust_id
  JOIN pincode p ON o.delivery_pincode = p.pincode
GROUP BY 
  c.cust_id, 
  c.first_name, 
  c.last_name;
--14.. For each product name, print the sum of number of units, total amount paid, total displayed selling price, total mrp of these units, and finally the net discount from selling price.(i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) &the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp)
SELECT 
  p.product_name,
  SUM(o.tot_units) AS total_units,
  SUM(o.total_amount_paid) AS total_amount_paid,
  SUM(o.tot_units * o.displayed_selling_price_per_unit) AS total_displayed_selling_price,
  SUM(o.tot_units * p.mrp) AS total_mrp,
  (100.0 - 100.0 * SUM(o.total_amount_paid) / SUM(o.tot_units * o.displayed_selling_price_per_unit)) AS net_discount_from_selling_price,
  (100.0 - 100.0 * SUM(o.total_amount_paid) / SUM(o.tot_units * p.mrp)) AS net_discount_from_mrp
FROM 
  products p
  JOIN orders o ON p.product_id = o.product_id
GROUP BY 
  p.product_name;
  --15.For every order_id (exclude returns), get the product name and calculate the discount percentage from selling price. Sort by highest discount and print only those rows where discount percentage was above 10.10%
 SELECT 
    o.order_id,
    p.product_name,
    (1 - (o.displayed_selling_price_per_unit / p.mrp)) * 100 as discount_percentage
FROM 
    Orders o
Join 
    Products p on o.product_id = p.product_id
WHERE 
    o.order_type <> 'returns'
ORDER BY
    discount_percentage DESC
HAVING
    discount_percentage > 10.10;
--16.. Using the per unit procurement cost in product_dim, find which product category has made the most profit in both absolute amount and percentageAbsolute Profit = Total Amt Sold - Total Procurement Cost Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0 
WITH ProfitSummary AS (
    SELECT 
        p.category AS product_category,
        SUM(o.total_amount_paid) AS total_amount_sold,
        SUM(o.tot_units * pd.procurement_cost_per_unit) AS total_procurement_cost,
        SUM(o.total_amount_paid) - SUM(o.tot_units * pd.procurement_cost_per_unit) AS absolute_profit,
        ((100.0 * SUM(o.total_amount_paid)) / SUM(o.tot_units * pd.procurement_cost_per_unit)) - 100.0 AS percentage_profit
    FROM 
        Orders o
    INNER JOIN 
        Products p ON o.product_id = p.product_id
    INNER JOIN 
        Product_dim pd ON o.product_id = pd.product_id
    GROUP BY 
        p.category
)

SELECT 
    product_category,
    MAX(absolute_profit) AS max_absolute_profit,
    MAX(percentage_profit) AS max_percentage_profit
FROM 
    ProfitSummary
GROUP BY 
    product_category;
--17. For every delivery person(use their name), print the total number of order ids (exclude returns) by month in separate columns i.e. there should be one row for each delivery_person_id and 12 columns for every month in the year
SELECT 
    d.name AS Delivery_Person,
    YEAR(o.order_date) AS Year,
    COUNT(CASE WHEN MONTH(o.order_date) = 1 THEN o.order_id END) AS Jan,
    COUNT(CASE WHEN MONTH(o.order_date) = 2 THEN o.order_id END) AS Feb,
    COUNT(CASE WHEN MONTH(o.order_date) = 3 THEN o.order_id END) AS Mar,
    COUNT(CASE WHEN MONTH(o.order_date) = 4 THEN o.order_id END) AS Apr,
    COUNT(CASE WHEN MONTH(o.order_date) = 5 THEN o.order_id END) AS May,
    COUNT(CASE WHEN MONTH(o.order_date) = 6 THEN o.order_id END) AS Jun,
    COUNT(CASE WHEN MONTH(o.order_date) = 7 THEN o.order_id END) AS Jul,
    COUNT(CASE WHEN MONTH(o.order_date) = 8 THEN o.order_id END) AS Aug,
    COUNT(CASE WHEN MONTH(o.order_date) = 9 THEN o.order_id END) AS Sep,
    COUNT(CASE WHEN MONTH(o.order_date) = 10 THEN o.order_id END) AS Oct,
    COUNT(CASE WHEN MONTH(o.order_date) = 11 THEN o.order_id END) AS Nov,
    COUNT(CASE WHEN MONTH(o.order_date) = 12 THEN o.order_id END) AS Dec
FROM
    Orders o
        JOIN
    Delivery_Person d ON o.delivery_person_id = d.delivery_person_id
WHERE
    o.order_type <> 'returns'
GROUP BY
    d.name , YEAR(o.order_date)
ORDER BY
    d.name , YEAR(o.order_date) ;
--18.. For each gender - male and female - find the absolute and percentage profit (like in Q15) by product name
SELECT 
    p.product_name,
    SUM(o.total_amount_paid - (p.procurement_cost_per_unit * o.tot_units)) AS Absolute_Profit,
    ROUND(100.0 * SUM(o.total_amount_paid - (p.procurement_cost_per_unit * o.tot_units)) / SUM(p.procurement_cost_per_unit * o.tot_units), 2) AS Percentage_Profit
FROM
    Orders o
JOIN
    Products p ON o.product_id = p.product_id
JOIN
    Customers c ON o.cust_id = c.cust_id
WHERE
    o.order_type <> 'returns'
GROUP BY
    p.product_name, c.gender;
--19. Generally the more numbers of units you buy, the more discount seller will give you. For 'Dell AX420' is there a relationship between number of units ordered and average discount from selling price? Take only 'buy' order types
SELECT 
    FLOOR(tot_units / 10) AS units_range,
    AVG((displayed_selling_price_per_unit - total_amount_paid) / displayed_selling_price_per_unit) * 100 AS avg_discount_percentage
FROM 
    Orders
WHERE 
    order_type = 'buy' 
    AND product_id = (SELECT product_id FROM Products WHERE product_name = 'Dell AX420')
GROUP BY 
    FLOOR(tot_units / 10)
ORDER BY 
    units_range;

