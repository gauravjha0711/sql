--create a function to accept pay rate and return monthly pay rate

CREATE FUNCTION dbo.ufnGetStock1
(
    @ProductID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @ret INT;

    SELECT @ret = SUM(p.Quantity)
    FROM Production.ProductInventory AS p
    WHERE p.ProductID = @ProductID
      AND p.LocationID = 6;   

    IF (@ret IS NULL)
        SET @ret = 0;

    RETURN @ret;
END;
GO


SELECT 
    ProductModelID,
    Name,
    dbo.ufnGetStock1(ProductID) AS CurrentSupply
FROM Production.Product;

select * from Production.Product;





--create a function to return employee details based on format type

CREATE FUNCTION dbo.ufn
(
    @format NVARCHAR(9)
)
RETURNS @table_emp TABLE
(
    Emp_Id INT PRIMARY KEY,
    [Emp Name] NVARCHAR(100)
)
AS
BEGIN
    IF (@format = 'SHORTNAME')
    BEGIN
        INSERT INTO @table_emp
        SELECT 
            BusinessEntityID,
            LastName
        FROM HumanResources.vEmployee;
    END
    ELSE IF (@format = 'LONGNAME')
    BEGIN
        INSERT INTO @table_emp
        SELECT 
            BusinessEntityID,
            FirstName + ' ' + LastName
        FROM HumanResources.vEmployee;
    END

    RETURN;
END;
GO

SELECT * FROM dbo.ufn('LONGNAME');

SELECT * FROM dbo.ufn('SHORTNAME');





--create a trigger to log insert action on Employee table
create database triggerdb
use triggerdb

create table Employee(
	Id int primary key,
	Name VARCHAR(45),
	Salary int,
	Gender Varchar(12),
	DepartmentId int
)

insert into Employee Values (1,'Steffan',82000,'Male',3),
(2,'Amelia',52000,'Female',2),
(3,'Antonio',25000,'male',1),
(4,'Marco',47000,'Male',2),
(5,'Eliana',46000,'Female',3)

select * from Employee;

create table Employee_Audit_Test(
	Id int IDENTITY,
	Audit_Action text,
)

create trigger trInsertEmployee
on Employee
for insert
as
begin
	Declare @Id int
	Select @Id  = Id from inserted
	insert into Employee_Audit_Test
	values ('New employee with Id = '+CAST(@Id as varchar(10)) + ' is added at '+CAST(getdate() as varchar(22)))
end

insert into Employee values (6,'Peter',62000,'Male',3)

select * from Employee_Audit_Test







create trigger trDeleteEmployee
on Employee
for delete
as 
Begin
declare @Id int
select @Id=Id from deleted
insert into Employee_Audit_Test
values('Existing Employee with id = '+CAST(@Id as varchar(10))+' is deleted at '+CAST(GetDate() as varchar(22)))
end

delete from Employee where id=7
select * from Employee_Audit_Test;