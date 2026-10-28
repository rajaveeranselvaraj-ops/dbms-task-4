USE BrightMartDB;

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    UNIQUE (Customer_ID, Order_ID),
    CHECK (Total_Amount >= 0),
    CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    UNIQUE (Order_ID, Product_ID),
    CHECK (Quantity > 0),
    CHECK (Price >= 0),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
        ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

INSERT INTO Orders
(Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(1, CURDATE(), 0, 'Pending');

INSERT INTO Order_Details
(Order_ID, Product_ID, Quantity, Price)
VALUES
(1, 101, 2, 500.00),
(1, 102, 1, 300.00);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 1
)
WHERE Order_ID = 1;

UPDATE Orders
SET Order_Status = 'Shipped'
WHERE Order_ID = 1;

UPDATE Order_Details
SET Quantity = 3
WHERE Order_ID = 1 AND Product_ID = 101;

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 1
)
WHERE Order_ID = 1;

DELETE FROM Orders
WHERE Order_Status = 'Cancelled';

SELECT o.Order_ID, c.Customer_ID,
       o.Order_Date, p.Product_ID,
       p.Product_Name, od.Quantity,
       od.Price, o.Total_Amount,
       o.Order_Status
FROM Orders o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN Order_Details od ON o.Order_ID = od.Order_ID
JOIN Product p ON od.Product_ID = p.Product_ID;

SELECT Customer_ID, Order_ID,
       Order_Date, Total_Amount, Order_Status
FROM Orders
ORDER BY Customer_ID, Order_Date DESC;

SELECT p.Product_ID, p.Product_Name,
       od.Order_ID, od.Quantity, od.Price
FROM Product p
JOIN Order_Details od
ON p.Product_ID = od.Product_ID;

SELECT Product_ID,
       COUNT(DISTINCT Order_ID) AS Times_Ordered
FROM Order_Details
GROUP BY Product_ID;

SELECT Product_ID,
       SUM(Quantity) AS Total_Quantity_Sold
FROM Order_Details
GROUP BY Product_ID;

SELECT Customer_ID, COUNT(*) AS Total_Orders
FROM Orders
GROUP BY Customer_ID
HAVING COUNT(*) = (
    SELECT MAX(order_count)
    FROM (
        SELECT COUNT(*) AS order_count
        FROM Orders
        GROUP BY Customer_ID
    ) AS T
);

SELECT AVG(Total_Amount) AS Average_Order_Value
FROM Orders
WHERE Order_Status <> 'Cancelled';