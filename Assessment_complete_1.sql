use AdventureWorks2022                    -- e,c,h

-- A.  Find first 20 employees who joined very early in the company

select * from HumanResources.Employee
select * from Person.Person

select concat_ws(' ',FirstName,LastName)Emp_Name from Person.Person p where p.BusinessEntityID in
(select top 20 BusinessEntityID from HumanResources.Employee e order by e.HireDate asc)

-- B.  Find all employees name , job title, card details whose credit card 
--     expired in the month 9 and year as 2009

select * from Person.Person  --beid,Name      p
select * from Sales.CreditCard   -- cID,expiry    cc
select * from Sales.PersonCreditCard  --beid,cID      pcc
select * from HumanResources.Employee  -- beid,jobtitle   e

select p.FirstName,e.JobTitle,pcc.CreditCardID
from Sales.PersonCreditCard pcc
join Sales.CreditCard cc
on pcc.CreditCardID=cc.CreditCardID
join Person.Person p
on p.BusinessEntityID=pcc.BusinessEntityID
join HumanResources.Employee e
on e.BusinessEntityID=pcc.BusinessEntityID
where cc.ExpMonth=9 and cc.ExpYear=2009

--C. Find the store address and contact number based on tables store 
--   and Business entity check if any other table is required.

select * from Sales.Store  --bussiness entity id,nameofstore,salespersonid
select * from sales.vStoreWithAddresses --bussinessentiity id,addressline 1
select * from Sales.vStoreWithContacts --bussiensseentiid,phonenumber

select s.Name,sa.AddressLine1,sc.PhoneNumber from sales.store s,sales.vStoreWithAddresses sa,Sales.vStoreWithContacts sc where
s.BusinessEntityID=sa.BusinessEntityID and sa.BusinessEntityID=sc.BusinessEntityID

-- D.  check if any employee from job candidate table is having any payment revisions

select * from HumanResources.JobCandidate   --jobcid,beid
select * from HumanResources.EmployeePayHistory  --beid,ratechange date
select * from HumanResources.Employee  --Beid

select jc.BusinessEntityID from HumanResources.JobCandidate jc
join HumanResources.EmployeePayHistory eph on eph.BusinessEntityID=jc.BusinessEntityID
join HumanResources.Employee e on e.BusinessEntityID=e.BusinessEntityID
group by jc.BusinessEntityID having count(eph.RateChangeDate)>1

-- E. check colour wise standard cost

select * from Production.Product

select Color,avg(StandardCost)std_cost 
from Production.Product 
where Color is not null
group by Color

-- F. Which product is purchased more? (purchase order details)

select * from Purchasing.PurchaseOrderDetail  --pid,orderqty
select * from Production.Product   -- pid,Name
 
select top 1 max(pod.OrderQty)cnt,p.Name
from Purchasing.PurchaseOrderDetail pod,Production.Product p
where p.ProductID=pod.ProductID
group by p.Name
order by cnt desc

-- G.  Find the total values for line total product having maximum order

select * from Production.Product  -- pid ,name
select * from Sales.SalesOrderDetail  --pid

select top 1 p.Name,sum(sod.LineTotal)total,sum(sod.OrderQty)qty
from Production.Product p
join Sales.SalesOrderDetail sod
on sod.ProductID=p.ProductID
group by sod.ProductID,p.Name
order by qty desc

-- H.  Which product is the oldest product as on the date (refer  the product sell start date)

select * from Production.Product  -- pid,name,sell startdate

select top 1 year(GETDATE())-year(SellStartDate)prod_age,Name,SellStartDate 
from Production.Product

 -- I. Find all the employees whose salary is more than the average salary

select * from HumanResources.EmployeePayHistory  --beid,rate
select * from Person.Person  -- beid,Name

select eph.Rate,
(select concat_ws(' ',FirstName,LastName) from Person.Person p where p.BusinessEntityID=eph.BusinessEntityID)Name,
(select p.BusinessEntityID from Person.Person p where p.BusinessEntityID=eph.BusinessEntityID)Beid
from HumanResources.EmployeePayHistory eph
where eph.Rate>(select avg(Rate) from HumanResources.EmployeePayHistory)

-- J. Display country region code, group average sales quota based on territory id 

select * from Sales.SalesPersonQuotaHistory  --beid,sales quota
select * from Sales.SalesTerritory  -- tid,crcode,group
select * from Sales.SalesTerritoryHistory --beid,tid

select avg(qh.SalesQuota)avg_sales_Quota,sth.TerritoryID,st.CountryRegionCode
from Sales.SalesTerritoryHistory sth
join Sales.SalesTerritory st
on st.TerritoryID=sth.TerritoryID
join Sales.SalesPersonQuotaHistory qh
on qh.BusinessEntityID=sth.BusinessEntityID
group by sth.TerritoryID,st.CountryRegionCode

--k. Find the average age of male and female

select*from HumanResources.Employee

select avg((year(GETDATE())-year(BirthDate)))Avg_age,Gender
from HumanResources.Employee
group by Gender

-- L. Which territory having more stores

select * from Sales.Customer
select * from sales.SalesTerritory

select top 1 count(StoreID)store_cnt,st.Name
from Sales.Customer c
join sales.SalesTerritory st
on st.TerritoryID = c.TerritoryID
group by st.Name
order by store_cnt desc

-- M. Check for sales person details  which are working in Stores (find the sales person ID)

select * from sales.Store  -- beid
select * from Sales.SalesPerson --beid,tid
select * from sales.SalesTerritoryHistory  -- beid,tid

select  sp.BusinessEntityID
from sales.Store s 
join Sales.SalesPerson sp
on sp.BusinessEntityID=s.BusinessEntityID

-- N.  display the product name and product price 
--     and count of product cost revised (productcost history)

select * from Production.ProductCostHistory  --pid
select * from Production.Product   -- pid

select p.Name,count(p.ModifiedDate)pc_revised,p.ListPrice
from Production.Product p,Production.ProductCostHistory pch
where p.ProductID=pch.ProductID
group by p.Name,p.ListPrice

-- O.  check the department having more salary revision

select * from HumanResources.Department  --deptid,Gname
select * from HumanResources.EmployeePayHistory -- beid,rate
select * from HumanResources.EmployeeDepartmentHistory --beid,dptid,

select top 1 d.GroupName,count(eph.RateChangeDate) as revised from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Department d on d.DepartmentID=edh.DepartmentID
join HumanResources.EmployeePayHistory eph on eph.BusinessEntityID=edh.BusinessEntityID
group by d.GroupName 
order by revised desc