CREATE TABLE Sales_Raw (
    OrderID INT,
    OrderDate VARCHAR(20),
    CustomerName VARCHAR(100),
    CustomerPhone VARCHAR(20),
    CustomerCity VARCHAR(50),
    ProductNames VARCHAR(200),
    Quantities VARCHAR(100),
    UnitPrices VARCHAR(100),
    SalesPerson VARCHAR(100)
);
INSERT INTO Sales_Raw VALUES
(101,'2024-01-05','Ravi Kumar','9876543210','Chennai','Laptop,Mouse','1,2','55000,500','Anitha'),
(102,'2024-01-06','Priya Sharma','9123456789','Bangalore','Keyboard,Mouse','1,1','1500,500','Anitha'),
(103,'2024-01-10','Ravi Kumar','9876543210','Chennai','Laptop','1','54000','Suresh'),
(104,'2024-02-01','John Peter','9988776655','Hyderabad','Monitor,Mouse','1,1','12000,500','Anitha'),
(105,'2024-02-10','Priya Sharma','9123456789','Bangalore','Laptop,Keyboard','1,1','56000,1500','Suresh');


CREATE TABLE Customers (
    CustomerID INT IDENTITY PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerPhone VARCHAR(20),
    CustomerCity VARCHAR(50)
);

CREATE TABLE SalesPersons (
    SalesPersonID INT IDENTITY PRIMARY KEY,
    SalesPersonName VARCHAR(100)
);

CREATE TABLE Products (
    ProductID INT IDENTITY PRIMARY KEY,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    SalesPersonID INT
);

CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);


WITH SplitData AS (
    SELECT 
        OrderID,
        CAST(q.value AS INT) AS Qty,
        CAST(p.value AS INT) AS Price,
        ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY (SELECT NULL)) AS rn
    FROM Sales_Raw
    CROSS APPLY STRING_SPLIT(Quantities, ',') q
    CROSS APPLY STRING_SPLIT(UnitPrices, ',') p
),
OrderTotals AS (
    SELECT 
        OrderID,
        SUM(Qty * Price) AS TotalSales
    FROM SplitData
    WHERE rn = rn
    GROUP BY OrderID
),
RankedOrders AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS rnk
    FROM OrderTotals
)
SELECT OrderID, TotalSales
FROM RankedOrders
WHERE rnk = 3;



SELECT 
    sr.SalesPerson,
    SUM(CAST(q.value AS INT) * CAST(p.value AS INT)) AS TotalSales
FROM Sales_Raw sr
CROSS APPLY STRING_SPLIT(sr.Quantities, ',') q
CROSS APPLY STRING_SPLIT(sr.UnitPrices, ',') p
GROUP BY sr.SalesPerson
HAVING SUM(CAST(q.value AS INT) * CAST(p.value AS INT)) > 60000;


WITH CustomerTotals AS (
    SELECT 
        sr.CustomerName,
        SUM(CAST(q.value AS INT) * CAST(p.value AS INT)) AS TotalSpent
    FROM Sales_Raw sr
    CROSS APPLY STRING_SPLIT(sr.Quantities, ',') q
    CROSS APPLY STRING_SPLIT(sr.UnitPrices, ',') p
    GROUP BY sr.CustomerName
)
SELECT CustomerName, TotalSpent
FROM CustomerTotals
WHERE TotalSpent > (
    SELECT AVG(TotalSpent) FROM CustomerTotals
);


SELECT 
    UPPER(CustomerName) AS CustomerName,
    DATENAME(MONTH, CAST(OrderDate AS DATE)) AS OrderMonth,
    CAST(OrderDate AS DATE) AS OrderDate
FROM Sales_Raw
WHERE CAST(OrderDate AS DATE) >= '2026-01-01'
  AND CAST(OrderDate AS DATE) < '2026-02-01';