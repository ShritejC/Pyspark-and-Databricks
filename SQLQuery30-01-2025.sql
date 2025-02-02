use AdventureWorks2022

select count(*) from HumanResources.Employee where Gender='F';

-- 1. Find the employee having salaried flag as 1
select * from HumanResources.Employee where SalariedFlag='1';

-- 2. Find all the employees havinf vaccation hours more than 70
select * from HumanResources.Employee where VacationHours>'70';

-- 3. vacation hour more than 70 but less than 90
select * from HumanResources.Employee where VacationHours>'70' and VacationHours <90;

-- 4. Find all jobs having title as designer
select * from HumanResources.Employee where JobTitle like('%Designer%');

-- 5. total emp worked as technician
select * from HumanResources.Employee where JobTitle like('%Technician%')

-- 6. nationl id no,jobtitle,marritial status ,gender for all under marketing job title

select NationalIDNumber,JobTitle,MaritalStatus,Gender from HumanResources.Employee where JobTitle like('%Marketing%')

--  7. find all unique maritl status
select distinct MaritalStatus from HumanResources.Employee

--  8. find the max vacaction hours
select max(VacationHours) from HumanResources.Employee

-- 9. find less sick leaves
select MIN(SickLeaveHours) from HumanResources.Employee


select * from HumanResources.Department

select * from HumanResources.EmployeeDepartmentHistory 

-- 10.all emp from production dpt
select * from HumanResources.Department where Name='Production'

select * from HumanResources.Employee
where BusinessEntityID in
(select BusinessEntityID 
from HumanResources.EmployeeDepartmentHistory 
where DepartmentID=7)

-- 11. all dept under research and dev

select * from HumanResources.Department

select * from HumanResources.Department where GroupName='Research and Development'

select * from HumanResources.Employee


-- 12. all emp under research and dev
select * from HumanResources.Department where GroupName='Research and Development'


select count(*) from HumanResources.Employee 
where BusinessEntityID in
(select BusinessEntityID 
from HumanResources.EmployeeDepartmentHistory 
where DepartmentID in(
select DepartmentID 
from HumanResources.Department 
where GroupName='Research and Development'))


-- 13. find all employees who work in day shift

select count(*) from HumanResources.Employee where BusinessEntityID 
in(select BusinessEntityID from HumanResources.EmployeeDepartmentHistory where ShiftID 
in(select ShiftID from HumanResources.Shift where Name='Day'))

-- 14. count of emp having payfreq is 1

select count(*) from HumanResources.Employee where BusinessEntityID 
in(select BusinessEntityID from HumanResources.EmployeePayHistory where PayFrequency=1)

-- 15. all jobID which are not placed

select * from HumanResources.Employee where BusinessEntityID 
in(select JobCandidateID from HumanResources.JobCandidate where BusinessEntityID IS NULL)

-- 16. address of employee

select * from Person.Address
select * from Person.BusinessEntityAddress
select * from HumanResources.Employee
select * from HumanResources.Department
select * from Person.Person
select * from HumanResources.EmployeeDepartmentHistory

select * from Person.Address where AddressID 
in(select AddressID from Person.BusinessEntityAddress where BusinessEntityID 
in(select BusinessEntityID from HumanResources.Employee))

-- 17. find name of emp working in R&D

select FirstName from Person.Person where BusinessEntityID 
in(select BusinessEntityID from HumanResources.EmployeeDepartmentHistory where DepartmentID 
in(select DepartmentID from HumanResources.Department where GroupName='Research and development'))


---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


-- Corelated subquery
   ------------------

select BusinessEntityID,NationalIDNumber,JobTitle,
(select firstname from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)fname
from HumanResources.Employee e

-- 1. add personal details of emp mname,lastname

select BusinessEntityID,NationalIDNumber,JobTitle,
(select firstname from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)fname,
(select MiddleName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)mname,
(select LastName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)lname
from HumanResources.Employee e


-- 2. Concat

select concat(FirstName,' ',MiddleName,' ',LastName)as Full_Name from Person.Person 

select BusinessEntityID,NationalIDNumber,JobTitle,
(select concat(firstname,MiddleName,LastName) from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)Full_name
from HumanResources.Employee e

-- 3. word separater concat_ws()

select BusinessEntityID,NationalIDNumber,JobTitle,
(select concat_ws(' - ',firstname,MiddleName,LastName) from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)Full_name
from HumanResources.Employee e


-- 4. display  national_id ,department name,department group

select(select  concat_ws(' - ',FirstName,LastName) from Person.Person p where p.BusinessEntityID=ed.BusinessEntityID)Full_Name,
(select NationalIDNumber from HumanResources.Employee e where e.BusinessEntityID=ed.BusinessEntityID) Nationl_Id,
(select concat_ws(' - ',Name,GroupName) from HumanResources.Department d where d.DepartmentID=ed.DepartmentID)Dept
 from HumanResources.EmployeeDepartmentHistory ed



select * from HumanResources.EmployeeDepartmentHistory --be id, d id  
select * from HumanResources.Employee --beid  , nid
select * from HumanResources.Department --department id   ,Name,groupname


-- 5. display first_name,lastname,department,shift time

select * from Person.Person
select * from HumanResources.Department
select * from HumanResources.Shift
select * from HumanResources.EmployeeDepartmentHistory --be id, d id  


select(select  concat_ws(' - ',FirstName,LastName) from Person.Person p where p.BusinessEntityID=ed.BusinessEntityID)Full_Name,
(select Name from HumanResources.Department d where d.DepartmentID=ed.DepartmentID) DeptName,
(select StartTime from HumanResources.Shift s where s.ShiftID=ed.ShiftID)shift_time
 from HumanResources.EmployeeDepartmentHistory ed


--display product name and product review based on product schema

-- 6. find emp_name,job title,credit card details,when it expire

select * from Person.Person  -- BEID,Name
select * from HumanResources.Employee  --job titke,BEID
select * from Sales.CreditCard   -- CreditID,Exp  
select * from Sales.PersonCreditCard  -- BEID , CreditID

select 
(select concat_ws(' ',FirstName,LastName) from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)Full_Name,
(select JobTitle from HumanResources.Employee e where e.BusinessEntityID=pc.BusinessEntityID)JobTitle,
(select  concat_ws(' - ',ExpMonth,ExpYear)from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)credit_details
from Sales.PersonCreditCard pc

-- 7. disp records from currency rate from usd to aud

select * from Sales.CurrencyRate
select * from Sales.Currency

select * from Sales.CurrencyRate where FromCurrencyCode='USD' and ToCurrencyCode='AUD'


-- 8. disp emp name,teritory name,group,sales last yr,sales quota,bonus

select * from Sales.SalesPerson  -- ttID,BEID,  Bonus,quota
select * from Sales.SalesTerritory -- ttID,name,group,sales LY
select * from Person.Person-- BEID,  fname

select 
(select concat(FirstName,'',LastName) from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)FullName,
(select Name from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)TerritoryName,
(select [Group] from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)GroupName,
(select SalesLastYear from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)SalesLY,
SalesQuota,Bonus
from Sales.SalesPerson sp



-- 9. disp emp name,teritory name,group,sales last yr,sales quota,bonus from germany and UK

select 
(select concat(FirstName,'',LastName) from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)FullName,
(select Name from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)TerritoryName,
(select [Group] from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)GroupName,
(select SalesLastYear from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)SalesLY,
SalesQuota,Bonus
from Sales.SalesPerson sp 
where sp.TerritoryID in(select TerritoryID from Sales.SalesTerritory st where Name in ('United kingdom','Germany'))

-- 10. find all emp who worked in all North america continent

select 
(select concat(FirstName,'',LastName) from Person.Person p where p.BusinessEntityID=sp.BusinessEntityID)FullName,
(select [Group] from Sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)GroupName
from Sales.SalesPerson sp 
where sp.TerritoryID in(select TerritoryID from Sales.SalesTerritory st where [Group]='North America')




---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


-- Questionaries

--1) find the average currency rate conversion from USD to Algerian Dinar and Australian Doller 

select * from Sales.CurrencyRate
select * from Sales.Currency

select AverageRate from Sales.CurrencyRate where FromCurrencyCode='USD' and ToCurrencyCode='AUD' or ToCurrencyCode='DZD'


-- 2)Find the products having offer on it and display product name , safety Stock Level,
--Listprice,  and product model id,type of discount,  percentage of discount,  offer start date and offer end date
  
select * from Sales.SpecialOffer --special offer id,discount type,discount percent,offer S_dates E_dates,description.
select * from Sales.SpecialOfferProduct--special offer id,product id
select * from Sales.SalesOrderDetail --product id, special offer id
select * from Production.Product --prodcut id,product name,safety stock,listprice,product model id


select 
(Select Description from Sales.SpecialOffer so where so.SpecialOfferID=sod.SpecialOfferID)descrip,
(Select DiscountPct from Sales.SpecialOffer so where so.SpecialOfferID=sod.SpecialOfferID)disc,
(Select Type from Sales.SpecialOffer so where so.SpecialOfferID=sod.SpecialOfferID)typeofdisc,
(Select StartDate from Sales.SpecialOffer so where so.SpecialOfferID=sod.SpecialOfferID)sd,
(Select EndDate from Sales.SpecialOffer so where so.SpecialOfferID=sod.SpecialOfferID)ed,
(Select Name from Production.Product p where p.ProductID=sod.ProductID)P_name,
(Select SafetyStockLevel from Production.Product p where p.ProductID=sod.ProductID)SSlevel,
(Select ListPrice from Production.Product p where p.ProductID=sod.ProductID)L_price,
(Select ProductModelID from Production.Product p where p.ProductID=sod.ProductID)ModelId
from Sales.SalesOrderDetail sod


--3)create  view to display Product name and Product review
