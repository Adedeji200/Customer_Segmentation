CREATE TABLE IF EXISTS retails(
	invoice_no INT,
	stock_code VARCHAR(30),
	decsription VARCHAR(255),
	quantity INT,
	invoice_date TIMESTAMP,
	unit_price FLOAT,
	customer_id INT,
	country VARCHAR(255)
)

-- Lets chcek the table 
SELECT * FROM retails


--What is the distribution of order values across all customers in the dataset?
WITH order_values AS(SELECT
		customer_id,
		invoice_no,
		stock_code,
		ROUND (CAST(SUM(quantity*unit_price)AS numeric),2) AS orderValue
	FROM
		retails
	GROUP BY
		 customer_id,2,3
	HAVING 
		customer_id IS NOT NULL AND
		ROUND(CAST(SUM(quantity*unit_price)AS numeric),2) > 0),
	OrderGrouping AS (SELECT 
	  	*,
		CASE 
	  		WHEN orderValue <= 500 THEN 'a, 5h class' 
			WHEN orderValue <= 1000 THEN 'b, 1k class' 
			WHEN orderValue <=10000 THEN 'c, 10k class' 
			WHEN orderValue <= 50000 THEN 'd, 50k class'
	  	ELSE 
	  		'e, ballers'
	  	END AS OrderCategory
	FROM order_values)
	
	SELECT
		COUNT(*) AS CustomerCount,
		OrderCategory
	FROM
		OrderGrouping
	GROUP BY
		OrderCategory


--How many unique products has each customer purchased?
SELECT 
	Customer_id ,	
	COUNT(DISTINCT stock_code) AS UniqueProductCount
FROM
	retails
WHERE 
	customer_id IS NOT NULL
GROUP BY 
	Customer_id;


--Which customers have only made a single purchase from the company
SELECT 
	customer_id,
	COUNT(invoice_no) AS TotalProductSold
FROM 
	retails
GROUP BY 
	customer_id
HAVING
	COUNT(invoice_no) = 1;



--Which products are most commonly purchased together by customers in datasets?

	WITH order_pair AS (
		SELECT 
			re.stock_code AS product1,
			r.stock_code AS product2
		FROM
			retails AS re
		JOIN
			retails AS r
		ON
			re.invoice_no = r.invoice_no
		WHERE
			re.stock_code > r.stock_code)
	SELECT 
		COUNT(*) AS PairPurchaseCount,
		product1,
		product2
	FROM
		order_pair
	GROUP BY
			2,3
	ORDER BY
			1 DESC
