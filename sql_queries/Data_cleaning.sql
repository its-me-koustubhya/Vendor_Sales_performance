-- REMOVING ANY DUPLICATE ROWS

-- checking for duplicate in purchase_prices table
SELECT Brand, Description, Price Unit_Price, PurchasePrice Bulk_Price, VendorNumber, VendorName,
ROW_NUMBER() OVER(PARTITION BY Brand, VendorNumber) 
FROM purchase_prices
ORDER BY Brand;

WITH d_cte AS(
SELECT Brand, Description, Price Unit_Price, PurchasePrice Bulk_Price, VendorNumber, VendorName,
ROW_NUMBER() OVER(PARTITION BY Brand, VendorNumber) row_num
FROM purchase_prices)
SELECT * FROM d_cte
WHERE row_num > 1;

CREATE TABLE purchase_prices2
SELECT * FROM 
(SELECT Brand, Description, Price Unit_Price, PurchasePrice Bulk_Price, VendorNumber, VendorName,
ROW_NUMBER() OVER(PARTITION BY Brand, VendorNumber) row_num 
FROM purchase_prices) TEMP;

SELECT * 
FROM purchase_prices2
WHERE row_num > 1;

DELETE 
FROM purchase_prices2
WHERE row_num > 1;

ALTER TABLE purchase_prices2
DROP COLUMN row_num;

-- EXPLORATORY DATA ANALYSIS

-- Purchases + Sales table

WITH p AS (
SELECT 
	Brand,
    MAX(Description) d,
	VendorNumber,
    MAX(VendorName) vn,
    SUM(Quantity) q, 
    SUM(Dollars) t
FROM purchases
GROUP BY Brand, VendorNumber
),
s AS (
SELECT  
	Brand, 
    VendorNo, 
    SUM(SalesQuantity) qs, 
    SUM(SalesDollars) ts, 
    SUM(ExciseTax) gst
FROM sales
GROUP BY Brand, VendorNo
),
pp AS (
SELECT 
	Brand, 
    VendorNumber, 
    Unit_price up, 
    Bulk_Price bp
FROM purchase_prices2
)
SELECT 
	p.Brand Brand,
    p.d Description,
    p.VendorNumber Vendor_Number,
    p.vn Vendor_Name,
    p.q Quantity_purchased, 
    pp.bp Cost_price, 
    p.t Total_Cost_price, 
    s.qs Quantity_Sold, 
    pp.up Selling_price, 
    s.ts Total_Selling_Price, 
    s.gst Tax
FROM p
LEFT JOIN s
	ON p.Brand = s.Brand AND p.VendorNumber = s.VendorNo
LEFT JOIN pp
	ON p.Brand = pp.Brand AND p.VendorNumber = pp.VendorNumber
;


-- purchasessales + vendor_invoice table to calculte the freight
WITH p AS (
SELECT * 
FROM purchasessales
),
v AS (
SELECT VendorNumber , SUM(Freight) f
FROM vendor_invoice
GROUP BY VendorNumber
)
SELECT 
	p.Brand Brand,
    p.Description Description,
    p.Vendor_Number Vendor_Number,
    p.Vendor_Name Vendor_Name,
    p.Quantity_purchased Quantity_purchased, 
    p.Cost_price Cost_price, 
    p.Total_Cost_price Total_Cost_price, 
    p.Quantity_Sold Quantity_Sold, 
    p.Selling_price Selling_price, 
    p.Total_Selling_Price Total_Selling_Price, 
    p.Tax Tax,
    v.f Transportation_Cost
FROM p
LEFT JOIN v
	ON p.Vendor_Number = v.VendorNumber
;