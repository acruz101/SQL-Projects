/**************************************************************/
/* Check book availability */
/**************************************************************/

-- Find number of books available of Dracula
SELECT 
    (SELECT COUNT(*) FROM Books WHERE Title = "Dracula")
    - 
    (SELECT COUNT(*) AS NumberOfNotAvail FROM Loans WHERE BookID IN (SELECT BookID FROM Books WHERE Title = "Dracula") AND ReturnedDate IS NULL)
AS AvailableDracula
;


/**************************************************************/
/* Add new books to the library */
/**************************************************************/
INSERT INTO Books (Title, Author, Published, Barcode) 
    VALUES 
    ("Dracula", "Bram Stoker", 1897, 4819277482),
    ("Gulliver's Travels", "Jonathan Swift", 1729, 4899254401);


/**************************************************************/
/* Check out books */
/**************************************************************/

-- 1. Find PatronID of Patron checking out books
SELECT PatronID FROM Patrons WHERE FirstName = "Jack" AND LastName = "Vaan" AND Email = "jvaan@wisdompets.com"; --50

-- 2. Find BookID of Books being checked out
SELECT BookID FROM Books WHERE Barcode = 2855934983; --11
SELECT BookID FROM Books WHERE Barcode = 4043822646; --93

-- 3. Insert new values into Loans table - use step 1 and 2
INSERT INTO Loans 
    (BookID, PatronID, LoanDate, DueDate)
    VALUES
    (
        (SELECT BookID FROM Books WHERE Barcode = 2855934983), 
        (SELECT PatronID FROM Patrons WHERE FirstName = "Jack" AND LastName = "Vaan" AND Email = "jvaan@wisdompets.com"), 
        DATE("2020-08-25"), 
        DATE("2020-08-25", "+14 days")
    ),
    (
        (SELECT BookID FROM Books WHERE Barcode = 4043822646), 
        (SELECT PatronID FROM Patrons WHERE FirstName = "Jack" AND LastName = "Vaan" AND Email = "jvaan@wisdompets.com"), 
        DATE("2020-08-25"), 
        DATE("2020-08-25", "+14 days")
    )
;

-- 4. View Result
SELECT * FROM Loans WHERE PatronID = 50;


/**************************************************************/
/* Check for books due back */
/**************************************************************/

-- 1. Find PatronID, BookID, and LoanID of books loaned on July 13 2020
SELECT * FROM Loans WHERE DueDate = "2020-07-13" AND ReturnedDate IS NULL

-- 2. Join Loans, Patrons, and Books table based on step 1
SELECT l.LoanID, l.BookID, l.PatronID, l.LoanDate, l.DueDate, l.ReturnedDate, b.Title, p.Email, p.FirstName, p.LastName FROM Loans AS l 
    JOIN Books AS b ON l.BookID = b.BookID
    JOIN Patrons AS p on l.PatronID = p.PatronID
    WHERE l.DueDate = "2020-07-13" AND l.ReturnedDate IS NULL;

/*************************************************************/
/* Return books to the library */
/*************************************************************/

-- Update return date of 3 books that were returned on July 5, 2020
UPDATE Loans SET ReturnedDate = "2020-07-05" 
    WHERE BookID IN (SELECT BookID FROM Books WHERE Barcode = 6435968624 OR Barcode = 5677520613 OR Barcode = 8730298424)
    AND ReturnedDate IS NULL;
    
-- Check result
SELECT * FROM Loans 
    WHERE BookID IN (SELECT BookID FROM Books WHERE Barcode = 6435968624 OR Barcode = 5677520613 OR Barcode = 8730298424)
    AND ReturnedDate = "2020-07-05"; 

/*************************************************************/
/* Encourage patrons to check out books */
/*************************************************************/

-- Create report showing the 10 patrons who have checked out the fewest books
-- Step 1. Use Loans table to determine the PatronID of the 10 patrons who have checked out the fewest books.
SELECT PatronID, COUNT(LoanID) AS TotalLoans FROM Loans 
    GROUP BY PatronID 
    ORDER BY TotalLoans
    LIMIT 10;

-- Step 2. Join Loans and Patrons table to find patrons' names and emails
SELECT p.FirstName, p.LastName, p.Email, l.PatronID, COUNT(l.LoanID) AS TotalLoans FROM Patrons as p 
    JOIN Loans as l 
    ON p.PatronID = l.PatronID
    GROUP BY l.PatronID 
    ORDER BY TotalLoans
    LIMIT 10; 


/*************************************************************/
/* Find books to feature for an event */
/*************************************************************/
-- Create list of books from the 1890s that are currently available

-- 1. Find books published in 1890s
SELECT * FROM Books WHERE Published LIKE "189_";

-- 2. Find books that are available
SELECT * FROM Loans WHERE ReturnedDate IS NOT NULL;

-- 3. Find book published in 1890s that are available
SELECT b.BookID, b.Title, b.Author, b.Published, b.Barcode 
        FROM Books AS b 
        JOIN Loans AS l
        ON b.BookID = l.BookID
        WHERE ReturnedDate IS NOT NULL
        AND Published LIKE "189_"

-- 4. List all UNIQUE barcodes of books published in 1890s that are available
SELECT DISTINCT(Barcode) AS Barcode, Title, BookID, Published FROM 
    (SELECT b.BookID, b.Title, b.Author, b.Published, b.Barcode 
        FROM Books AS b 
        JOIN Loans AS l
        ON b.BookID = l.BookID
        WHERE ReturnedDate IS NOT NULL
        AND Published LIKE "189_")
    ORDER BY Title, BookID;


/*************************************************************/
/* Book Statistics */
/*************************************************************/
-- Create 2 reports

-- Report 1: Create a report showing how many books published each year, with year of most books published at top
SELECT Published, COUNT(BookID) as BooksPublished FROM Books
    GROUP BY Published
    ORDER BY BooksPublished DESC;

-- Report 2: Create a report showing the five most popular books to be checked out since library opened
SELECT COUNT(l.LoanID) AS TotalLoans, l.BookID, b.Title FROM Loans AS l
    JOIN Books AS b
    ON l.BookID = b.BookID
    GROUP BY b.Title
    ORDER BY TotalLoans DESC
    LIMIT 5;



