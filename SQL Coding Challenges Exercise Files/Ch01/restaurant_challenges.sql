/**************************************************************/
/* Create invitations for a party */
/**************************************************************/
SELECT FirstName, LastName, Email FROM Customers ORDER BY LastName;


/**************************************************************/
/* Create a table to store information */
/**************************************************************/
CREATE TABLE PartyAttendees("CustomerID" INTEGER PRIMARY KEY,"PartySize" INTEGER);
SELECT * FROM PartyAttendees

/**************************************************************/
/* Print a menu */
/**************************************************************/

-- Menu 1: All items sorted by price, low to high
SELECT * FROM Dishes;
SELECT * FROM Dishes ORDER BY Price;

-- Menu 2: Apetizers and beverages, by type
SELECT * FROM Dishes WHERE Type IS "Appetizer";

-- Menu 3: All items except beverages, by type
SELECT * FROM Dishes WHERE Type IS NOT "Beverage" ORDER BY Type;

/**************************************************************/
/* Sign a customer up for your loyalty program */
/**************************************************************/
INSERT INTO Customers 
    (FirstName, LastName, Email, Address, City, State, Phone, Birthday)
    VALUES ("Anna", "Smith", "asmith@kinetecoinc.com", "479 Lapis Dr.", "Memphis", "TN", "(555)-555-1212", "1973-07");

/**************************************************************/
/* Update a customer's personal information */
/**************************************************************/
UPDATE Customers 
    SET Address = "111 Wilshire Ave.", City = "Los Angeles", State = "CA"
    WHERE CustomerID = 101;

/**************************************************************/
/* Remove a customer's record */
/**************************************************************/
DELETE FROM Customers WHERE CustomerID = 101;

/**************************************************************/
/* Log customer responses */
/**************************************************************/
INSERT INTO PartyAttendees 
    (CustomerID, PartySize) 
    VALUES (
        (SELECT CustomerID FROM Customers WHERE Email = "atapley2j@kinetecoinc.com"),
        4
    );
SELECT * FROM PartyAttendees;

/**************************************************************/
/* Look up reservations */
/**************************************************************/
SELECT * FROM Reservations AS r JOIN Customers as c 
    ON r.CustomerID = c.CustomerID
    WHERE c.LastName LIKE "Ste%" AND PartySize = 4;

/**************************************************************/
/* Take a reservation */
/**************************************************************/
SELECT * FROM Customers  WHERE Email = "smac@rouxacademy.com"; -- DOES NOT EXIST
INSERT INTO Customers (FirstName, LastName, Email) VALUES ("Sam", "McAdams", "smac@rouxacademy.com");
SELECT CustomerID FROM Customers WHERE Email = "smac@rouxacademy.com"; -- 102

INSERT INTO Reservations (CustomerID, Date, PartySize)
    VALUES ("102", DATETIME("2016-06-01 15:30:30"),"5")
    ;
    
SELECT * FROM Reservations 
WHERE CustomerID = 102;

/**************************************************************/
/* Take a delivery order */
/**************************************************************/
-- Find customer and their id in Customers table
SELECT * FROM Customers WHERE FirstName = "Loretta" AND LastName = "Hundey"; -- EXISTS!
SELECT CustomerID FROM Customers WHERE FirstName = "Loretta" AND LastName = "Hundey"; -- 70

-- Update Orders table with date and matching customer id from Customers
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (1001, 70, DATETIME('NOW'));
SELECT * FROM Orders WHERE CustomerID = 70;

-- Determine price of all dishes customer is ordering
SELECT DishID FROM Dishes 
    WHERE Name = "House Salad" 
    OR Name = "Mini Cheeseburgers" 
    OR Name = "Tropical Blue Smoothie";
-- 4, 7, 20

-- Update OrdersDishes table with matching OrderID and DishID (multiple)
INSERT INTO OrdersDishes (OrdersDishesID, OrderID, DishID) VALUES (4022, 1001, 4);
INSERT INTO OrdersDishes (OrdersDishesID, OrderID, DishID) VALUES (4022, 1001, 7);
INSERT INTO OrdersDishes (OrdersDishesID, OrderID, DishID) VALUES (4022, 1001, 20);

-- Check result
SELECT C.CustomerID, c.LastName, o.OrderID, o.CustomerID, o.OrderDate, ordersWithNames.DishID, ordersWithNames.Name FROM Orders AS o 
    JOIN (
        SELECT od.OrderID, od.DishID, d.Name 
        FROM OrdersDishes as od JOIN Dishes as d 
        ON od.DishID = d.DishID
    ) AS ordersWithNames
    ON o.OrderID = ordersWithNames.OrderID
    JOIN Customers AS c ON o.CustomerID = c.CustomerID
    ORDER BY ordersWithNames.OrderID DESC
;

-- Calculate total amount
SELECT SUM(d.Price) AS Total FROM OrdersDishes as od 
    JOIN Dishes as d on od.DishID = d.DishID 
    WHERE od.OrderID = 1001;
