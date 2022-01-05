 --if we want the sumof price by maker and type,by only type,by only maker,and total sum then 

 select * from bike
 go 
 update bike 
 SET type ='Super bike' where ID=7

   select maker,null,sum(price)AS SUM
from bike
group by maker

 union all

 select null,type,sum(price)
 from bike
 group by type
 
 --OR

  select maker,[type],sum(price)
  from bike 
  group by 
       Grouping sets
  (maker,type)

  
   ---------------------------------------------------------------

   select  maker,type,SUM(price) as SUMOFGROUP
from bike
group by maker,type

union all

select maker,null,sum(price)
from bike
group by maker

 union all

 select null,type,sum(price)
 from bike
 group by type

 union all

 select null,null,sum(price)
 from bike
 

 --alternatively this can be achieved by grouping set
 select maker,type,sum(price)
 from bike
 group by
   Grouping sets
   (
   (maker,type),--by maker and type
   (maker),--by maker
   (type),--by type
   ()  --total sum
   )
   ----Roll up_-          
   --aggreagate operation on multiple level heirarchy
   select maker,sum(price)
   from bike
   group by ROLLUP(maker)

--OR can also be written as
 select maker,sum(price)
   from bike
   group by maker with ROLLUP

   ---without using rollup

   select maker,sum(price)
   from bike
   group by maker
 union all
 select null,sum(price)
   from bike
  
  
  --by using grouping sets
  
  select maker,sum(price)
   from bike
   group by 
   grouping sets
   (
   (maker),()
   )

   

   --if want sum of sal by country and type by using roll up

   select maker,type,sum(price)
   from bike
   group by ROLLUP(maker,type)


   --CUBE
   --produces result set by generating all combination of column specified in group by cube()
   select maker,type,Sum(price)
   from bike
   group by cube(maker,type)

   --or can be written as
    select maker,type,Sum(price)
   from bike
   group by maker,type with cube


   --this can be acheived by 
   select maker,type,sum(price)
 from bike
 group by
   Grouping sets
   (
   (maker,type),--by maker and type
   (maker),--by maker
   (type),--by type
   ()  --total sum
   )



   --Grouping function=grouping indicates whether the column in a group by it is aggregated or not .It returns 1 for aggregated or 0 for not aggregated.
   
   select maker,type,sum(price),grouping(maker),grouping(type)
   from bike
   group by ROLLUP(maker,type)

   --replace null value with 
   
   select case 
   when grouping(maker)=1 then 'All'  else isnull(maker,'unknown')end,
   case when grouping(type)=1 then 'All'  else isnull(maker,'unknown')
	end
	 from bike
   group by ROLLUP(maker,type)
--In this we cant use isnull function instead of grouping because it will mislead and if grouping column contain null value it will convert it to all.

--Offset next fetch
--offset fetch clause makes easy to paging
--return page of result from result set
--order by clause is required


Create table tbl_product (id int,name varchar(50),product_description varchar(100),price int)

Declare @start int
set @start=1
Declare @name varchar(50)
Declare @productdescription varchar(100)

while(@start<=100)
Begin
set @name='Product'+ cast(@start as varchar)
set @productdescription='Product description'+cast(@start as varchar)
insert into tbl_product values(@start,@name,@productdescription,@start*10)
 Set @start=@start+1
 END
 select * from tbl_product

 /*SYNTAX

 SELECT * FROM Table_Name
ORDER BY Column_List
OFFSET Rows_To_Skip ROWS
FETCH NEXT Rows_To_Fetch ROWS ONLY*/

select *  from tbl_product
order by price 
offset 20 rows
fetch next 40 rows only
go 
create proc pagenobypagesize

 @pageno int,
 @pagesize int
 AS
select * from tbl_product
order by price
offset (@pageno-1)*@pagesize rows
fetch next @pagesize rows only
Go

pagenobypagesize 2,10


---Cursors=Pointer to a row
Declare @id int
Declare @price int
Declare  cr_tbl_product cursor for
Select id,price from tbl_product where  price<=1000-----get table in result set

open cr_tbl_product 
Fetch next from cr_tbl_product into @id,@price  --First row

While(@@FETCH_STATUS=1)  --return 0 as long as there is row in result set
Begin 

Fetch next from cr_tbl_product into @id,@price
END
Close cr_tbl_product  --release result set
Deallocate cr_tbl_product---deallocate resoures used by cursor
go 
  
 --- To view dependency there are 3 ways 
  --1.by using view dependency feature from object explorer
 -- 2.By dynamic management function
  
  select * from employees.employees

create view allempname   -----referencing_entities-object Which has sql expression
AS 
Select [name]  
from employees.employees          ---referenced entities-Object appearing inside sql expression

select * from allempname
select * from sys.dm_sql_referencing_entities('[employees].[employees]','object')

select * from sys.dm_sql_referenced_entities('[dbo].[allempname]','object')

drop table employees.employees
----Scheme bound dependency
--:It prevents referenced object to be drop or modify until referencing object exists.

----Non Schema bound dependency
--:Doesnt prevent referenced object of being drp or modify
go 
create view allemployeename   
With SchemaBinding
AS 
Select [name]  
from employees.employees 

----3. sp_depends   --might be depricate in future version of sql server
exec sp_depends 'objectname'     --tablename,viewname,stored procedure
exec sp_depends allemployeename
exec sp_depends allempname


--Sequence object 
create SEQUENCE [dbo].[Sequence1] 
AS INT                      --if datatype not specified then default is bigint
START WITH 1                --value from which we want to increment or decrement sequence
INCREMENT BY 1              --want decrementing sequence then -1
MINVALUE 0
MAXVALUE 100
cycle                        --restart  from min value when reached upto max value . 
                             --if not specified then by default it is nocycle and 
							  --throws error after reaching max value.
cache 10                      --improve performance ,cached after 10 value

Select next value for [dbo].[Sequence1]    --generate next value

select current_value  from sys.sequences where name='Sequence1'  --retrieve current sequence value

select * from sys.sequences where name='Sequence1'    ---gives all info

Alter sequence sequence1 restart with 1   --reset sequence value


Drop sequence sequence1



--GUID-
--:16 bit binary datatype stands for Global Unique Identifier
--declare @ID UNIQUE IDENTIFIER
--create guid-NEWID() function .It is unique across table,database,server




create table class1(roll_no int primary key identity,name varchar(15))
insert into class1 values('Ram'),('Shyam'),('Mohan')
create table class2(roll_no int  identity,name varchar(15))
insert into class2 values('Radha'),('Siya'),('Shakti')


create table class1AND2 (roll_no int primary key ,name varchar(15))
  select * from class1AND2
  
  insert into class1AND2
  select * from class1
  union 
  select * from class2
  ----Violation of PRIMARY KEY constraint 'PK__class1AN__9560EEE19B60D6AE'. Cannot insert duplicate key in object 'dbo.class1AND2'. The duplicate key value is (1).
   drop table class1
   drop table class2
  drop table class1AND2

  

create table class1(roll_no uniqueidentifier default NEWID(),name varchar(15))
insert into class1 values(Default,'Ram'),(Default,'Shyam'),(Default,'Mohan')
create table class2(roll_no uniqueidentifier primary key default NEWID() ,name varchar(15))
insert into class2 values(Default,'Radha'),(Default,'Siya'),(Default,'Shakti')


create table class1AND2 (roll_no uniqueidentifier default NEWID() ,name varchar(15))
  
  insert into class1AND2
  select * from class1
  union 
  select * from class2

  select * from class1AND2



  ---TO GET empty guid means contain all 0's
  select cast(cast(0 as binary) as uniqueidentifier)
  
  --OR

  select cast(0x0 as uniqueidentifier)s