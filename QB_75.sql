 use AdventureWorks2022

--Q1.find the average currency conversion rate from USD to Algerian Dinar and Australian Dollar

select*from sales.Currency
select*from sales.CurrencyRate
select*from sales.CountryRegionCurrency

select concat_ws('  To  ',FromCurrencyCode,ToCurrencyCode)as Currency_Conversion,
avg(AverageRate) as Average_Currency_Rate
from sales.CurrencyRate 
where FromCurrencyCode='USD'
and ToCurrencyCode in ('DZD','AUD')
group by FromCurrencyCode,ToCurrencyCode


--Q2. Find the products having offer on it and display product name, safety stock level,listprice,
--and product model id, type of discount, percentage of discount,offer start date and offer end date.

select*from  Production.Product
select*from Sales.SpecialOffer
select*from Sales.SpecialOfferProduct

select
(select p.ProductModelID from Production.Product p where p.ProductID=sop.ProductID)as Product_ModelID,
(select p.Name from Production.Product p where p.ProductID=sop.ProductID)as Product_Name,
(select p.SafetyStockLevel from Production.Product p where p.ProductID=sop.ProductID)as Safety_Stock_Level,
(select p.ListPrice from Production.Product p where p.ProductID=sop.ProductID)as List_Price,
(select sp.DiscountPct from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Percentage_of_discount,
(select sp.Type from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Type_of_discount,
(select concat_ws('  and  ',sp.StartDate,sp.EndDate) from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Start_and_end_date
from sales.SpecialOfferProduct sop


--3.  create  view to display Product name and Product review 

select * from Production.ProductReview pr
select * FROM Production.Product p

go
CREATE VIEW Custumer AS
SELECT 
    pr.Comments,
    p.Name
FROM Production.ProductReview pr
INNER JOIN Production.Product p ON pr.ProductID = p.ProductID;

-- 4.  find out the vendor for product paint, Adjustable Race and blade  

select * from Purchasing.Vendor  --Beid , VName
select * from Production.Product --pid , PName
select * FROM Purchasing.ProductVendor --Pid,Beid


select 
(select Name from Purchasing.Vendor v where v.BusinessEntityID=pv.BusinessEntityID)Vendor_Name,
(select Name from Production.Product p where p.ProductID=pv.ProductID)Prod_Name
from Purchasing.ProductVendor pv where ProductID in(select ProductID from Production.Product
where Name='Adjustable race' or Name like('%Paint%') or name='blade')


--Q5. find product details shipped through ZY-EXPRESS

select* from Purchasing.ShipMethod
select*from Production.Product
select* from Purchasing.PurchaseOrderDetail
select*from Purchasing.PurchaseOrderHeader

select
(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
(select p.ProductNumber from Production.Product p where p.ProductID=pd.ProductID)as ProductNumber,
(select sm.ShipMethodID from Purchasing.ShipMethod sm where sm.ShipMethodID=ph.ShipMethodID)as ShipID,
(select sm.Name from Purchasing.ShipMethod sm where sm.ShipMethodID=ph.ShipMethodID)as ShipName
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
    on pd.PurchaseOrderID = ph.PurchaseOrderID
where ph.ShipMethodID = (
    select s.ShipMethodID 
    from Purchasing.ShipMethod s 
    where s.Name LIKE 'ZY - EXPRESS'
)


--Q6. find the tax amount for products where order date and ship date are on the same day

select * from Production.Product
select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.PurchaseOrderDetail

select 
(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
ph.TaxAmt as Tax_Amount
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
on pd.PurchaseOrderID = ph.PurchaseOrderID
where day(ph.OrderDate)=day(ph.ShipDate)


--Q7. find the average days required to ship the product based on shipment type.

select* from Purchasing.ShipMethod
select* from Production.Product
select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.PurchaseOrderDetail

select 
    ps.Name as Shipment_Type, 
    avg(datediff(day, ph.OrderDate, ph.ShipDate)) as Avg_Shipping_Days
from Purchasing.PurchaseOrderHeader ph
join Purchasing.ShipMethod ps 
    on ph.ShipMethodID = ps.ShipMethodID
where ph.ShipDate is not null
group by ps.Name
order by Avg_Shipping_Days desc;



--Q8. Find the name of employees working in day shift 
select concat_ws(' ',FirstName,LastName)as EmployeeName from Person.Person  where BusinessEntityID IN 
(SELECT BusinessEntityID from HumanResources.EmployeeDepartmentHistory where ShiftID in 
( select ShiftID from HumanResources.Shift where ShiftID=1))


--Q9. based on product and product cost history find the name, service provider time, and average standard cost

select* from Production.Product
select* from Production.ProductCostHistory

select 
p.Name as Product_Name,
datediff_big(day,min(StartDate),max(EndDate)) as service_provider_time,
avg(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name


--Q10. find products with average cost more than 500

select 
p.Name as Product_Name,
avg(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name
having avg(ph.StandardCost)>500


--Q11. find the employees who worked in mulitple territories
select* from Person.Person
select*from HumanResources.Employee
select*from sales.SalesTerritory
select* from Sales.SalesTerritoryHistory

select
e.BusinessEntityID,
count(st.TerritoryID) as Territory_Count,
(select concat_ws(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as Employee_Name
from HumanResources.Employee e
join
sales.SalesTerritoryHistory sth
on
e.BusinessEntityID=sth.BusinessEntityID
join
sales.SalesTerritory st
on
st.TerritoryID=sth.TerritoryID
group by e.BusinessEntityID
having count(st.TerritoryID)>1


--Q12. find out the product model name, product description for culture as Arabic
select* from Production.ProductModel
select* from Production.ProductDescription
select* from Production.Culture
select* from Production.ProductModelProductDescriptionCulture

select pm.Name as Product_Model_Name,
pd.Description as Product_Description
from Production.ProductModel pm
join Production.ProductModelProductDescriptionCulture pdc
on pm.ProductModelID=pdc.ProductModelID
join Production.ProductDescription pd
on pd.ProductDescriptionID=pd.ProductDescriptionID
join Production.Culture pc
on pc.CultureID=pdc.CultureID
where pc.Name like 'Arabic'
group by pm.Name,pd.Description


--13.  display EMP name, territory name, saleslastyear salesquota and bonus 

select * from Person.Person  --beid ,name
select * from Sales.SalesTerritory   --terrid ,Terr_name
select * from sales.SalesPerson  --Beid ,terrid,salesq,bonus

select SalesLastYear,SalesQuota,Bonus,
(SELECT concat(FirstName,' ',LastName) from Person.Person p where p.BusinessEntityID=s.BusinessEntityID)Name,
(select Name from Sales.SalesTerritory st where st.TerritoryID=s.TerritoryID)T_Name
from Sales.SalesPerson s

--14.  display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom 

select * from Person.Person
select * from Sales.SalesTerritory
Select * from Sales.SalesPerson


select 
(select concat(FirstName,'',LastName) from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)FullName,
(select Name from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)TerritoryName,
(select [Group] from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)GroupName,
(select SalesLastYear from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)SalesLY,
SalesQuota,Bonus
from Sales.SalesPerson sp 
where sp.TerritoryID in(select TerritoryID from Sales.SalesTerritory st where Name in ('United kingdom','Germany'))


--15.  Find all employees who worked in all North America territory 

select * from Person.Person -- Bied, name
select * from Sales.SalesTerritory --terid,Group
select * from Sales.SalesPerson --beid,terrid

select 
(select concat(FirstName,'',LastName) from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)FullName,
(select [Group] from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)GroupName
from Sales.SalesPerson sp 
where sp.TerritoryID in(select TerritoryID from Sales.SalesTerritory st where [Group]='North America')


--Q16. find all produccts in the cart

select
(Select Name from Production.Product pp where pp.ProductID=sc.ProductID)as ProductName,
(Select ProductNumber from Production.Product pp where pp.ProductID=sc.ProductID)as ProductNumber,
Quantity
from Sales.ShoppingCartItem sc


--Q17. find all products with special offer

select Name from Production.Product pp
where pp.ProductID in (
select ProductID from sales.SpecialOfferProduct sop
where SpecialOfferID in (
select SpecialOfferID from Sales.SpecialOffer where Type='No Discount'
))


--Q18. find all employees name, job title, card details of those whose creedit card expired in the month 11 and year 2008

select(select concat_ws(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select concat_ws(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)Card_detail
from Sales.PersonCreditCard pc where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc 
where cc.ExpMonth=11 and cc.ExpYear=2008)



--19.  Find the employee whose payment might be revised  (Hint : Employee payment history) 

select * from HumanResources.EmployeePayHistory
select * from Person.Person

select
	(select CONCAT_WS(' ',p.FirstName,p.LastName)from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)full_name,e.BusinessEntityID,
	(select count(eph.RateChangeDate)from HumanResources.EmployeePayHistory eph where eph.BusinessEntityID=e.BusinessEntityID)revision
from  HumanResources.Employee e 
where(select count(eph.RateChangeDate)from HumanResources.EmployeePayHistory eph where eph.BusinessEntityID=e.BusinessEntityID)>1

-- 20. Find the personal details with address and address type(hint: Business Entiy Address , Address, Address type) 

select * from Person.Person --Beid,name
select * from Person.Address --Addid,add
select * from Person.AddressType --addtid
select * from Person.BusinessEntityAddress  --beid,addtid,addid

select p.FirstName,p.LastName,a.AddressLine1,a.AddressLine2,a.PostalCode,a.City,a.StateProvinceID,
(select name from Person.AddressType at where at.AddressTypeID=be.AddressTypeID)type
from Person.BusinessEntityAddress be,Person.Person p,Person.Address a,Person.AddressType at
where p.BusinessEntityID=be.BusinessEntityID and a.AddressID=be.AddressID and at.AddressTypeID=be.AddressTypeID

--21.  Find the name of employees working in group of North America territory 

select * from Person.Person -- Bied, name
select * from Sales.SalesTerritory --terid,Group
select * from Sales.SalesPerson --beid,terrid

select CONCAT_WS(FirstName,' ',LastName) name                           ---Done
from Person.Person p
join Sales.SalesPerson sp on p.BusinessEntityID=sp.BusinessEntityID 
join Sales.SalesTerritory st on st.TerritoryID=sp.TerritoryID
where st.[Group]='North America'


--22.  Find the employee whose payment is revised for more than once 

select * from HumanResources.EmployeePayHistory
select * from Person.Person
select * from HumanResources.Employee

select
(select CONCAT_WS(' ',p.FirstName,p.LastName)from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)full_name,e.BusinessEntityID,
(select count(eph.RateChangeDate)from HumanResources.EmployeePayHistory eph where eph.BusinessEntityID=e.BusinessEntityID)revision
from  HumanResources.Employee e 
where(select count(eph.RateChangeDate)from HumanResources.EmployeePayHistory eph where eph.BusinessEntityID=e.BusinessEntityID)>1

--23. display the personal details of  employee whose payment is revised for more than once.

select * from HumanResources.EmployeePayHistory --beid,rate change
select * from Person.Person   --beid,Name
select * from Person.BusinessEntityAddress--beid,addid
select * from Person.Address  --beid,Addid

select eph.BusinessEntityID,CONCAT_WS(' ',p.FirstName, p.LastName) as full_name, 
a.AddressLine1 from HumanResources.EmployeePayHistory eph
	join Person.Person p on eph.BusinessEntityID=p.BusinessEntityID
	join Person.BusinessEntityAddress bea on bea.BusinessEntityID=p.BusinessEntityID
	join Person.Address a on a. AddressID=bea.AddressID
group by eph.BusinessEntityID, p. FirstName, p. LastName, a.AddressLine1
having count(eph.RateChangeDate)>1

--24.  find the duration of payment revision on every interval  (inline view) Output must be as given format   

select * from Person.Person
select * from HumanResources.EmployeePayHistory

SELECT p.FirstName, p.LastName, SalaryRevisions.RevisedTime, 
       DATEDIFF(YEAR, SalaryRevisions.FirstRevisionDate, SalaryRevisions.LastRevisionDate) AS Duration
FROM (
    SELECT eph.BusinessEntityID, 
           COUNT(eph.RateChangeDate) AS RevisedTime, 
           MIN(eph.RateChangeDate) AS FirstRevisionDate, 
           MAX(eph.RateChangeDate) AS LastRevisionDate
    FROM HumanResources.EmployeePayHistory eph
    GROUP BY eph.BusinessEntityID
) AS SalaryRevisions
JOIN Person.Person p ON p.BusinessEntityID = SalaryRevisions.BusinessEntityID
ORDER BY RevisedTime DESC;  


--25.  check if any employee from jobcandidate table is having any payment revisions

select * from HumanResources.JobCandidate    --jcid,beid
select * from HumanResources.EmployeePayHistory  --beid,rate
select * from HumanResources.Employee  --beid

select jc.BusinessEntityID from HumanResources.JobCandidate jc
join HumanResources.EmployeePayHistory eph on eph.BusinessEntityID=jc.BusinessEntityID
join HumanResources.Employee e on e.BusinessEntityID=e.BusinessEntityID
group by jc.BusinessEntityID having count(eph.RateChangeDate)>1


-----------------------------------------------------------------------------------------------------------------------------------

select TerritoryID,coalesce(CurrencyRateID,0) from Sales.SalesOrderHeader  --replace null values with given value

-----------------------------------------------------------------------------------------------------------------------------------

--  26. check the department having more salary revision 

select * from HumanResources.Department  --deptid,Gname
select * from HumanResources.EmployeePayHistory -- beid,rate
select * from HumanResources.EmployeeDepartmentHistory --beid,dptid,

select top 1 d.GroupName,count(eph.RateChangeDate) as revised from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Department d on d.DepartmentID=edh.DepartmentID
join HumanResources.EmployeePayHistory eph on eph.BusinessEntityID=edh.BusinessEntityID
group by d.GroupName 
order by revised desc


-- 27. check the employee whose payment is not yet revised 

select * from HumanResources.EmployeePayHistory -- beid,rate
select * from Person.Person  --Beid,name

select e.BusinessEntityID, concat_ws(' ',p.FirstName, p.LastName)as EmployeeName
from HumanResources.Employee e
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
where e.BusinessEntityID not in 
(select distinct BusinessEntityID from HumanResources.EmployeePayHistory)

-- 28. find the job title having more revised payments 

select top 1 d.GroupName,count(eph.RateChangeDate) as revised 
from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Department d 
on d.DepartmentID=edh.DepartmentID
join HumanResources.EmployeePayHistory eph 
on eph.BusinessEntityID=edh.BusinessEntityID
group by d.GroupName 
order by revised desc


-- 29. find the employee whose payment is revised in shortest duration (inline view) 

select BusinessEntityID, FirstName, LastName, min(datediff(day,StartDate, EndDate)) 
as ShortestRevisionDuration
from (
    select e.BusinessEntityID, p.FirstName, p.LastName, eph.StartDate, eph.EndDate
    from HumanResources.EmployeeDepartmentHistory eph
    join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
    join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
) as PaymentRevisions
group by  BusinessEntityID, FirstName, LastName;


-- 30.	 find the colour wise count of the product (tbl: product) 

select * from Production.Product  

select Color, count(*) AS Color_Count from Production.Product where Color is not null
group by Color
order by Color_Count desc

-- 31. find out the product who are not in position to sell (hint: check the sell start and end date) 

select * from Production.Product
select * from Production.ProductCostHistory
select * from Production.ProductListPriceHistory
select * from Sales.SpecialOffer

select ProductID, Name
from Production.Product
where SellEndDate is not null
and 
SellEndDate < getdate() 
or 
SellStartDate is not null

--32. find the class wise, style wise average standard cost 

select * from Production.Product   --  pid, class,style,std cost

select class Class,style Style,avg(StandardCost)Avg_Cost from Production.Product where
class is not null and Style is not null
group by Class,Style 
order by Avg_Cost 

-- 33.	 check colour wise standard cost 

select * from Production.Product   --  pid, colour,std cost

 select color Color,avg(StandardCost)Clr_AvgCost from Production.Product
 where color is not null 
 group by Color
 order by Clr_AvgCost

-- 34.	 find the product line wise standard cost 

select * from Production.Product   --  productLine,std cost

select Productline Prod_line,avg(StandardCost)Std_cost
from Production.Product
where ProductLine is not null
group by ProductLine
order by Std_cost


-- 35.	Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 

select * from Sales.SalesTaxRate  --spid,  Taxrate
select * from Person.StateProvince  --spid,  Name

select sp.Name,avg(sr.TaxRate) as tax from Sales.SalesTaxRate sr,Person.StateProvince sp  
where sp.StateProvinceID=sr.StateProvinceID  group by sp.Name order by sp.Name

-- 36.	Find the department wise count of employees 

select * from HumanResources.Employee   -- beid
select * from HumanResources.Department  -- GroupName, dptid

select count(e.BusinessEntityID) as Emp_Cont,d.GroupName 
from HumanResources.Employee e,HumanResources.Department d
group by d.GroupName

-- 37.	Find the department which is having more employees 

select top 1 count(e.BusinessEntityID) as Emp_Cont,d.GroupName 
from HumanResources.Employee e,HumanResources.Department d
group by d.GroupName 

-- 38.	Find the job title having more employees 

select * from HumanResources.Employee   -- beid, jb_title   290
select * from HumanResources.Department  -- dptid           16

select top 1 count(e.BusinessEntityID) as cnt,e.JobTitle 
from HumanResources.Employee e 
group by e.JobTitle 
order by cnt desc


--39.	Check if there is mass hiring of employees on single day 

select * from HumanResources.Employee

select top 1 HireDate,count(BusinessEntityID)as HiringCount
from HumanResources.Employee
group by HireDate
order by HiringCount desc

-- 40.	Which product is purchased more? (purchase order details) 

select * from Purchasing.PurchaseOrderDetail  -- pid,order_quant
select * from Production.Product   --pid,Name

select top 1 max(pod.OrderQty)cnt,p.Name
from Purchasing.PurchaseOrderDetail pod,Production.Product p
where p.ProductID=pod.ProductID
group by p.Name
order by cnt desc

--Q41. Find the territory wise customers count(hint: customer) 

select * from Sales.Customer
select*from sales.SalesTerritory

select t.Name as TerritoryName,count(c.CustomerID)as CustomerCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name

-- Q42. Which territory is having more customers (hint: customer) 

select * from Sales.Customer
select*from sales.SalesTerritory

select top 1 t.Name as TerritoryName,count(c.CustomerID)as CustomerCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name
order by CustomerCount desc

-- Q43. Which territory is having more stores (hint: customer)

select * from Sales.Customer
select * from sales.SalesTerritory

select top 1 count(StoreID)store_cnt,st.Name
from Sales.Customer c
join sales.SalesTerritory st
on st.TerritoryID = c.TerritoryID
group by st.Name
order by store_cnt desc

-- Q44. Is there any person having more than one credit card (hint: PersonCreditCard)

use AdventureWorks2022
select* from Sales.PersonCreditCard
select*from Person.Person

select concat_ws(' ',p.FirstName,p.LastName)as PersonName,
count(pc.CreditCardID) as CreditCardCount
from Person.Person p
join sales.PersonCreditCard pc
on p.BusinessEntityID=pc.BusinessEntityID
group by p.FirstName,p.LastName
having count(pc.CreditCardID)>1

-- Q45. Find the product wise sales price (sales order details)

select*from Production.Product
select*from sales.SalesOrderDetail

select p.Name,count(sod.UnitPrice)SalesPrice 
from Production.Product p
join Sales.SalesOrderDetail sod
on p.ProductID=sod.ProductID
group by p.Name

--Q46. Find the total values for line total product having maximum order

select*from Production.Product
select*from sales.SalesOrderDetail

select top 1 sum(sod.LineTotal)lt,p.Name
from Production.Product p
join Sales.SalesOrderDetail sod
on p.ProductID=sod.ProductID
group by p.Name
order by lt desc

--Q48.	Calculate the age of employees 

select * from Person.Person
select * from HumanResources.Employee

select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.BirthDate)as Age
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Q49. Calculate the year of experience of the employee based on hire date

select * from HumanResources.Employee
select * from Person.Person
 
 select p.FirstName as Name,
 year(GETDATE())-year(e.HireDate) as Exp_Yr
 from HumanResources.Employee e
 join Person.Person p
 on e.BusinessEntityID=p.BusinessEntityID

--Q50.	Find the age of employee at the time of joining 

select*from HumanResources.Employee

select p.FirstName as Name,
year(HireDate)-year(BirthDate) age_at_joining from HumanResources.Employee e
 join Person.Person p
 on e.BusinessEntityID=p.BusinessEntityID

-- Q51.	Find the average age of male and female

select*from HumanResources.Employee

select avg((year(GETDATE())-year(BirthDate)))Avg_age,Gender
from HumanResources.Employee
group by Gender

--53.	Find the product wise sale price (sales order details)
SELECT p.ProductID, p.Name AS ProductName, 
       SUM(sod.OrderQty * sod.UnitPrice) AS TotalSalesPrice
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalSalesPrice DESC

--54.	Find the total values for line total product having maximum order
 select * from Purchasing.PurchaseOrderDetail

 select Top 1 PurchaseOrderID,
 sum(LineTotal)as TotalLines,
 max(OrderQty)as Max_Order
 from Purchasing.PurchaseOrderDetail
 group by PurchaseOrderID
 having max(OrderQty)>1



 --55.Calculate the age of employees

 select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.BirthDate)as Age
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--56.Calculate the year of experience of the employee based on hire date
select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.HireDate)Experience
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--57.	Find the age of employee at the time of joining
SELECT BusinessEntityID,BirthDate, HireDate, 
    DATEDIFF(YEAR, BirthDate, HireDate) AS AgeAtJoining
FROM HumanResources.Employee

--58.Find the average age of male and female

select Gender,Avg(datediff(YEAR,birthdate,GETDATE()))Avg_Age from HumanResources.Employee
group by Gender



--59.Which product is the oldest product as on the date (refer  the product sell start date)
select top 1 name,
 max(year(getdate())-year(SellStartDate))as productage
 from Production.Product
 group by Name






 --60.Display the product name, standard cost, and time duration for the same cost. (Product cost history)
  select * from Production.ProductCostHistory

  select p.Name,
         ph.StandardCost,
	     DATEDIFF(YEAR,ph.EndDate,ph.StartDate)Time_duration,
         avg(ph.Standardcost)over(partition by DATEDIFF(YEAR,ph.EndDate,ph.StartDate))Avg_StandardCost
  from Production.ProductCostHistory ph
  join Production.Product p
  on p.ProductID=ph.ProductID
  where ph.EndDate is not null and
  ph.StartDate is not null

  --61.	Find the purchase id where shipment is done 1 month later of order date  
  Select * from Purchasing.ShipMethod
  select * from Purchasing.PurchaseOrderHeader

 select PurchaseOrderID
        
 from Purchasing.PurchaseOrderHeader where datediff(MONTH,OrderDate,ShipDate)=1 

 --62Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)

 select sum(TotalDue)Total
 from Purchasing.PurchaseOrderHeader where datediff(MONTH,OrderDate,ShipDate)=1 


 --63.Find the average difference in due date and ship date based on  online order flag
 SELECT OnlineOrderFlag, 
       AVG(DATEDIFF(DAY, ShipDate, DueDate)) AS Avg_Days_Difference
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag

--64.	Display business entity id, marital status, gender, vacationhr, average vacation based on marital status

select * from HumanResources.Employee
select * from HumanResources.Department
select BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by maritalstatus)Vac_Mari_Status
from HumanResources.Employee

--65Display business entity id, marital status, gender, vacationhr, average vacation based on gender

select BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by gender)Avg_Based_Gender
from HumanResources.Employee
 
 --66.Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level

 select  BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by Organizationlevel )Vac__Org_level
from HumanResources.Employee

--67Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept


SELECT  
    e.BusinessEntityID, 
    e.HireDate, 
    d.Name AS DepartmentName, 
    COUNT(e.BusinessEntityID) OVER (PARTITION BY d.Name) AS DepartmentEmployeeCount,
    COUNT(e.BusinessEntityID) OVER (PARTITION BY d.Name, ed.OrganizationLevel) AS OrgLevelEmployeeCount,
    COALESCE(ed.OrganizationLevel, 0) AS OrganizationLevel -- Handling NULL values
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory ed 
    ON e.BusinessEntityID = ed.BusinessEntityID
JOIN HumanResources.Department d 
    ON ed.DepartmentID = d.DepartmentID;


--68.Display department name, average sick leave and sick leave per department
select distinct
	   d.Name DepartmentName,
	   avg (SickLeaveHours) over(Partition by d.departmentID)Depart_Wise_Sickleave,
	   count(SickLeaveHours) over(Partition by d.departmentid)Org_lev_Sickleave
	   from HumanResources.Employee e join HumanResources.EmployeeDepartmentHistory eh
	   on e.BusinessEntityID=eh.BusinessEntityID
	   join HumanResources.Department d on 
	   d.DepartmentID=eh.DepartmentID


--69.Display the employee details first name, last name,  with total count 
--of various shift done by the person and shifts count per department

Select * from Person.Person
select * from HumanResources.Shift
select * from HumanResources.Employee
select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory

select p.FirstName,
       p.LastName,
	   Count(s.ShiftID)TotalShift,
	   count(*)over(partition by d.departmentid)Dept_Shift_count
from Person.Person p
join HumanResources.Employee e
on p.BusinessEntityID=e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory ed
on ed.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=ed.DepartmentID
join HumanResources.Shift s
on s.ShiftID=ed.ShiftID
group by e.BusinessEntityID,p.FirstName,p.LastName,d.DepartmentID,d.Name

--70.Display country region code, group average sales quota based on territory id
select * from Sales.SalesPerson
select * from Sales.SalesTerritory

select st.CountryRegionCode,
       st.[Group],
	   avg(sp.SalesQuota) as Avg_SalesQuota
from Sales.SalesTerritory st
join Sales.SalesPerson sp
on sp.TerritoryID=st.TerritoryID
where SalesQuota is not null
group by st.CountryRegionCode,st.[Group]
order by st.CountryRegionCode,Avg_SalesQuota Desc




--71.	Display special offer description, category and avg(discount pct) per the category


Select * from Sales.SpecialOfferProduct
Select * from Sales.SpecialOffer

select distinct description,
        Category,
		avg(DiscountPct)over(partition by  category)Avg_By_Dispt_Cat
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct
sp
on sp.SpecialOfferID=so.SpecialOfferID

--72.	Display special offer description, category and avg(discount pct) per the month

SELECT distinct
    Description, 
    Category, 
    Month(StartDate) AS OfferMonth,
    AVG(DiscountPct) OVER (PARTITION BY Month(StartDate)) AS Avg_Discount_By_Year
FROM Sales.SpecialOffer so
JOIN Sales.SpecialOfferProduct sp 
    ON sp.SpecialOfferID = so.SpecialOfferID;

--73.	Display special offer description, category and avg(discount pct) per the year
SELECT distinct
    Description, 
    Category, 
    YEAR(StartDate) AS OfferYear,
	
    AVG(so.DiscountPct) OVER (PARTITION BY YEAR(so.StartDate),Year(so.Enddate)) AS Avg_Discount_By_Year
FROM Sales.SpecialOffer so
JOIN Sales.SpecialOfferProduct sp 
    ON sp.SpecialOfferID = so.SpecialOfferID;


--74.	Display special offer description, category and avg(discount pct) per the type
select distinct description,
        Category,
		avg(DiscountPct)over(partition by  type)Avg_By_Dispt_Type
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct
sp
on sp.SpecialOfferID=so.SpecialOfferID



--75.	Using rank and dense rank find territory wise top sales person
 select * from Sales.SalesTerritory
 select * from HumanResources.Employee

SELECT 
    sp.BusinessEntityID,
    st.TerritoryID,
    st.Name AS TerritoryName,
    sp.SalesYTD,
    RANK() OVER (PARTITION BY st.TerritoryID ORDER BY sp.SalesYTD DESC) AS Rank_YTD,
    DENSE_RANK() OVER (PARTITION BY st.TerritoryID ORDER BY sp.SalesYTD DESC) AS Dense_Rank_YTD
FROM Sales.SalesPerson sp
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
WHERE sp.SalesYTD IS NOT NULL
ORDER BY st.TerritoryID, Rank_YTD;
