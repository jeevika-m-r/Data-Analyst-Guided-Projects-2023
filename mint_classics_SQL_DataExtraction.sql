USE mintclassics;
-- (1) Where are items stored and if they were rearranged, could a warehouse be eliminated?--

-- to find where the products are stored --
SELECT products.productLine, warehouses.warehouseCode
FROM products
JOIN warehouses ON products.warehouseCode = warehouses.warehouseCode
GROUP BY productLine, warehouseCode;

-- to identify total inventory in the warehouse --
SELECT productLine, warehouseCode, SUM(quantityInStock) AS total_inventory
FROM products
GROUP BY productLine, warehouseCode

-- to identify warehouse with low quantity --
SELECT
      p.warehouseCode,
     SUM(p.quantityInStock) AS total_inventory,
     w.warehouseName,
     w.warehousePctCap
FROM products p
JOIN warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY p.warehouseCode, w.warehouseName, w.warehousePctCap
ORDER BY total_inventory ASC;

-- south warehouse profit margin--
SELECT
  SUM(od.priceEach * od.quantityOrdered) AS total_revenue,
  SUM(p.buyPrice * od.quantityOrdered) AS total_cost,
  SUM(od.priceEach * od.quantityOrdered) - SUM(p.buyPrice * od.quantityOrdered) AS total_profit,
  ((SUM(od.priceEach * od.quantityOrdered) - SUM(p.buyPrice * od.quantityOrdered)) /
        SUM(od.priceEach * od.quantityOrdered)) * 100 AS profit_margin
FROM orderdetails od
INNER JOIN products p ON od.productCode = p.productCode
WHERE p.warehouseCode = 'd';

-- west warehouse profit margin --
SELECT
  SUM(od.priceEach * od.quantityOrdered) AS total_revenue,
  SUM(p.buyPrice * od.quantityOrdered) AS total_cost,
  SUM(od.priceEach * od.quantityOrdered) - SUM(p.buyPrice * od.quantityOrdered) AS total_profit,
  ((SUM(od.priceEach * od.quantityOrdered) - SUM(p.buyPrice * od.quantityOrdered)) /
        SUM(od.priceEach * od.quantityOrdered)) * 100 AS profit_margin
FROM orderdetails od
INNER JOIN products p ON od.productCode = p.productCode
WHERE p.warehouseCode = 'c';

-------------------------------------------------------------------------------------------------------------------------------------

-- (2)	How are inventory numbers related to sales figures? Do the inventory counts seem appropriate for each item?--

-- To calculate inventory turnover --
SELECT p.productCode,
       p.productName,
       SUM(od.quantityOrdered*p.buyPrice) AS costs_of_goods_sold,
       AVG(p.quantityInStock) AS avg_inventory,
       (SUM(od.quantityOrdered*p.buyPrice) / AVG(p.quantityInStock)) AS inventory_turnover 
FROM 
    orderdetails od 
JOIN 
    products p ON od.productCode = p.productCode
GROUP BY
     p.productCode,p.productName
ORDER BY
     inventory_turnover DESC;
     
-- to analyze sales trend --

SELECT 
      p.productCode,
      p.productName,
      CASE
          WHEN p.quantityInStock < COALESCE(SUM(od.quantityOrdered),0) THEN 'Stockout'
          WHEN p.quantityInStock > COALESCE(SUM(od.quantityOrdered),0) THEN 'Overstock'
          ELSE 'Balanced'
	  END AS inventoryStatus,
      COUNT(*) AS productCount
FROM 
     products p
LEFT JOIN
      orderdetails od ON p.productCode = od.productCode
GROUP BY
      p.productCode,p.productName,p.quantityInStock
ORDER BY
      inventoryStatus;
      
-- days of inventory on hand --

SELECT
    p.productCode,
    p.productName,
    p.quantityInStock,
    AVG(od.quantityOrdered * DATEDIFF(o.shippedDate, o.orderDate)) AS average_daily_sales,
    p.quantityInStock / AVG(od.quantityOrdered * DATEDIFF(o.shippedDate, o.orderDate)) AS DOOH
FROM
    products p
JOIN
    orderdetails od ON p.productCode = od.productCode
JOIN
    orders o ON od.orderNumber = o.orderNumber
GROUP BY
    p.productCode, p.productName
ORDER BY
    DOOH DESC;

---------------------------------------------------------------------------------------------------------------------------------
-- (3) Are we storing items that are not moving? Are any items candidates for being dropped from the product line? --
    
-- to calculate inventory holding cost --

SELECT
  productCode,
  productName,
  quantityInStock * buyPrice AS inventory_value
FROM products p
ORDER BY inventory_value DESC
LIMIT 20;

-- to calculate profitability --

 SELECT
  p.productCode,
  p.productName,
  SUM(od.priceEach * od.quantityOrdered) - SUM(p.buyPrice * od.quantityOrdered) AS total_profit
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON p.productCode = od.productCode
GROUP BY productCode, productName
ORDER BY total_profit ASC
LIMIT 20;

-----------------------------------------------------------------------
-- (4)	Are some items sold more than others? --

SELECT 
      p.productCode,
      p.productName,
      SUM(od.quantityOrdered) AS total_quantity_sold
FROM
      products p 
JOIN 
      orderdetails od ON p.productCode = od.productCode
GROUP BY 
       p.productCode,p.productName
ORDER BY 
       total_quantity_sold DESC
LIMIT 10;
