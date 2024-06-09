-- create by Sergey Ermachkov 07.06.2024
-- using Oracle 11g

-- В качестве тестовых данных создано 6 магазинов в 3-х регионах
-- Сотрудники: 6 менеджеров; 12 продавцов и другие
-- Для отчётов:
-- 1.a: товар который не покулся ни разу - "trousers"(брюки)
-- b.: в каждом магазине не имеют продаж 
     --продавцы с минимальными идентификаторами 
-- c: лучший продавец из магазина Sportmaster в регионе Che
-- 2: сбои произошли 10.05.24 и 20.05.24 Sportmaster в регионе SainP
--	и Zara в регионе Che

-- ddl инструкции для создания таблиц
create table shops (
  id          number(20),
  name        varchar2(200) not null,
  region      varchar2(200) not null,
  city        varchar2(200) not null,
  address     varchar2(200) not null,
  manager_id  number(20)    not null,
  constraint shops_pk primary key (id)
);

create table employees (
  id          number(20),
  first_name  varchar2(100) not null,
  last_name   varchar2(100) not null,
  phone       varchar2(50)  not null,
  e_mail      varchar2(50)  not null,
  job_name    varchar2(50)  not null,
  shop_id     number(20),
  constraint employees_pk primary key (id)

);

create table purchases (
  id          number(20),
  datatime    date        not null,
  amount      number(20)  not null,
  seller_id   number(20),
  constraint purchases_pk primary key (id)
);

create table products (
  id      number(20),
  code    varchar2(50)  not null,
  name    varchar2(200) not null,
  constraint products_pk primary key (id),
  constraint products_code_uk unique (code)
);

create table purchase_receipts (
  purchase_id     number(20),
  ordinal_number  number(5),
  product_id      number(20)    not null,
  quantity        number(25,5)  not null,
  amount_full     number(20)    not null,
  amount_discount number(20)    not null,
  constraint purchase_receipts_pk primary key (purchase_id, ordinal_number)
);

--foreign key constraints 
alter table shops add constraint shops_employees_fk foreign key (manager_id) references employees(id);
alter table employees add constraint employees_shops_fk foreign key (shop_id) references shops(id);
alter table purchases add constraint purchases_employees_fk foreign key (seller_id) references employees(id);
alter table purchase_receipts add constraint purchase_receipts_purchases_fk foreign key (purchase_id) references purchases(id);
alter table purchase_receipts add constraint purchase_receipts_products_fk foreign key (product_id) references products(id);

--sequences
-- sequens for id in tables
create sequence ids_seq start with 1 nocycle nocache;
-- sequens for product code 
create sequence pcode_seq start with 1 nocycle nocache;

--triggers для обновления значения атрибута shop_id
-- в таблице employees при назначении менеджера магазина
-- trigger for upd shop_id for employees
create or replace trigger cascade_upd_emp_shop
after update of manager_id on shops
for each row
begin
    
   update employees e
   set e.shop_id = :new.id
   where e.id = :new.manager_id;
   
end;  
-- trigger after insert for upd shop_id for employees
create or replace trigger csd_upd_after_insert_emp_shop
after insert on shops
for each row
begin
  
   update employees e
   set e.shop_id = :NEW.id
   where e.id = :NEW.manager_id;
   
end;  
  
-- dml
-- add managers
insert into employees values(ids_seq.nextval, 'Firstname1', 'Lastname1', '333-333', '1@ya.ru', 'Manager', null);
insert into employees values(ids_seq.nextval, 'Firstname2', 'Lastname2', '444-444', '2@ya.ru', 'Manager', null);
insert into employees values(ids_seq.nextval, 'Firstname3', 'Lastname3', '555-555', '3@ya.ru', 'Manager', null);
insert into employees values(ids_seq.nextval, 'Firstname4', 'Lastname4', '666-666', '4@ya.ru', 'Manager', null);
insert into employees values(ids_seq.nextval, 'Firstname5', 'Lastname5', '333-333', '5@ya.ru', 'Manager', null);
insert into employees values(ids_seq.nextval, 'Firstname6', 'Lastname6', '444-444', '6@ya.ru', 'Manager', null);

commit;


--add shops with managers
-- region Moscow
insert into shops values( ids_seq.nextval, 'Zara', 'Msc', 'Moskow', 'addr', (select e.id from employees e where upper(e.last_name) = upper('Lastname1') and upper(e.job_name) = upper('Manager')));
insert into shops values( ids_seq.nextval, 'Sportmaster', 'Msc', 'Moskow', 'addr1', (select e.id from employees e where upper(e.last_name) = upper('Lastname2') and upper(e.job_name) = upper('Manager')));

-- region Saint Petersburg
insert into shops values( ids_seq.nextval, 'Zara', 'SaintP', 'Saint Petersburg', 'addr', (select e.id from employees e where upper(e.last_name) = upper('Lastname3') and upper(e.job_name) = upper('Manager')));
insert into shops values( ids_seq.nextval, 'Sportmaster', 'SaintP', 'Saint Petersburg', 'addr1', (select e.id from employees e where upper(e.last_name) = upper('Lastname4') and upper(e.job_name) = upper('Manager')));

-- region Chelyabinsk
insert into shops values( ids_seq.nextval, 'Zara', 'Che', 'Chelyabinsk', 'addr', (select e.id from employees e where upper(e.last_name) = upper('Lastname5') and upper(e.job_name) = upper('Manager')));
insert into shops values( ids_seq.nextval, 'Sportmaster', 'Che', 'Chelyabinsk', 'addr1', (select e.id from employees e where upper(e.last_name) = upper('Lastname6') and upper(e.job_name) = upper('Manager')));

commit;


-- other employees
insert into employees values(ids_seq.nextval, 'Firstname1', 'Lastname1', '333-333', '1@xf.ru', 'Seller', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Msc') ));
insert into employees values(ids_seq.nextval, 'Firstname2', 'Lastname2', '333-333', '2@xf.ru', 'Seller', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Msc') ));
insert into employees values(ids_seq.nextval, 'Firstname3', 'Lastname3', '444-444', '3@xf.ru', 'Booker', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Msc') ));
insert into employees values(ids_seq.nextval, 'Firstname4', 'Lastname4', '555-555', '4@xf.ru', 'Cleaner', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Msc') ));

insert into employees values(ids_seq.nextval, 'Firstname5', 'Lastname5', '333-333', '5@xf.ru', 'Seller', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('SaintP') ));
insert into employees values(ids_seq.nextval, 'Firstname6', 'Lastname6', '333-333', '6@xf.ru', 'Seller', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('SaintP') ));
insert into employees values(ids_seq.nextval, 'Firstname7', 'Lastname7', '444-444', '7@xf.ru', 'Booker', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('SaintP') ));
insert into employees values(ids_seq.nextval, 'Firstname8', 'Lastname8', '555-555', '8@xf.ru', 'Cleaner', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('SaintP') ));

insert into employees values(ids_seq.nextval, 'Firstname9', 'Lastname9', '333-333', '9@xf.ru', 'Seller', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Che') ));
insert into employees values(ids_seq.nextval, 'Firstname10', 'Lastname10', '333-333', '10@xf.ru', 'Seller', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Che') ));
insert into employees values(ids_seq.nextval, 'Firstname11', 'Lastname11', '444-444', '11@xf.ru', 'Booker', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Che') ));
insert into employees values(ids_seq.nextval, 'Firstname12', 'Lastname12', '555-555', '12@xf.ru', 'Cleaner', (select id from shops where upper(name) = upper('Zara') and upper(region) = upper('Che') ));

--
insert into employees values(ids_seq.nextval, 'Firstname13', 'Lastname13', '333-333', '13@mt.ru', 'Seller', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Msc') ));
insert into employees values(ids_seq.nextval, 'Firstname14', 'Lastname14', '333-333', '14@mt.ru', 'Seller', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Msc') ));
insert into employees values(ids_seq.nextval, 'Firstname15', 'Lastname15', '444-444', '15@mt.ru', 'Booker', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Msc') ));
insert into employees values(ids_seq.nextval, 'Firstname16', 'Lastname16', '555-555', '16@mt.ru', 'Cleaner', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Msc') ));

insert into employees values(ids_seq.nextval, 'Firstname17', 'Lastname17', '333-333', '17@mt.ru', 'Seller', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('SaintP') ));
insert into employees values(ids_seq.nextval, 'Firstname18', 'Lastname18', '333-333', '18@mt.ru', 'Seller', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('SaintP') ));
insert into employees values(ids_seq.nextval, 'Firstname19', 'Lastname19', '444-444', '19@mt.ru', 'Booker', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('SaintP') ));
insert into employees values(ids_seq.nextval, 'Firstname20', 'Lastname20', '555-555', '20@mt.ru', 'Cleaner', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('SaintP') ));

insert into employees values(ids_seq.nextval, 'Firstname21', 'Lastname21', '333-333', '21@mt.ru', 'Seller', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Che') ));
insert into employees values(ids_seq.nextval, 'Firstname22', 'Lastname22', '333-333', '22@mt.ru', 'Seller', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Che') ));
insert into employees values(ids_seq.nextval, 'Firstname23', 'Lastname23', '444-444', '23@mt.ru', 'Booker', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Che') ));
insert into employees values(ids_seq.nextval, 'Firstname24', 'Lastname24', '555-555', '24@mt.ru', 'Cleaner', (select id from shops where upper(name) = upper('Sportmaster') and upper(region) = upper('Che') ));

commit;

-- products
insert into products values(ids_seq.nextval, pcode_seq.nextval, 'shirt');
insert into products values(ids_seq.nextval, pcode_seq.nextval, 'trousers');
insert into products values(ids_seq.nextval, pcode_seq.nextval, 'boots');
insert into products values(ids_seq.nextval, pcode_seq.nextval, 'socks');

commit;

-- purchases
--01.05.24
insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('01.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('Msc'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('01.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('SaintP'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('01.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Che'))
  )
from dual;

--05.05.24

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('05.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('Msc'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('05.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('SaintP'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('05.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Che'))
  )
from dual;

--10.05.24
insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('10.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('Msc'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('10.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('SaintP'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('10.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('Che'))
  )
from dual;

--15.05.24
insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('15.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Msc'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('15.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('SaintP'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('15.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Che'))
  )
from dual;

-- 20.05.24
insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('20.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Msc'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('20.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('SaintP'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('20.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('Che'))
  )
from dual;

-- 25.05.24
insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('25.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('Msc'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('25.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Zara') and upper(s.region) = upper('SaintP'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('25.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Che'))
  )
from dual;

insert into purchases (id, datatime,amount, seller_id)
select 
  ids_seq.nextval, 
  to_date('26.05.2024 08:00:00', 'dd.mm.yyyy hh24:mi:ss'), 
  10000, 
  (select max(e.id)
    from employees e
    where upper(e.job_name) = upper('seller') 
      and e.shop_id = 
        (select s.id from shops s where upper(s.name) = upper('Sportmaster') and upper(s.region) = upper('Che'))
  )
from dual;

commit;

-- purchase_receipts
-- insert with amount_full = 0 and then next step calculate value
insert into purchase_receipts (
  purchase_id,
  ordinal_number,
  product_id,
  quantity,
  amount_full,
  amount_discount)
select pc.id, sum(1) as num, p.id, 1 as q, 0, 2000
  from purchases pc
  cross join products p
  inner join products p2
    on p.id <= p2.id
    and p2.name != all ('shirt','trousers')
  where p.name != all ('shirt','trousers')
  group by pc.id, p.id, p.name
  order by pc.id, num, p.name;
  
commit;  

-- calc and upd amount_full  
update purchase_receipts pr 
set pr.amount_full = (
  ((select p.amount from purchases p where p.id = pr.purchase_id) + 
    (select sum(t.amount_discount) from purchase_receipts t where t.purchase_id = pr.purchase_id  group by t.purchase_id)
  )  / (select sum(t.quantity) from purchase_receipts t where t.purchase_id = pr.purchase_id  group by t.purchase_id));
  
commit;
  
-- upd data for task n.2
-- корректируются данные для задачи №2
update purchases pr
set pr.amount = pr.amount - 2000
where pr.id = 
  (select p.id
  from purchases p
  where to_date(p.datatime) = to_date('10.05.2024', 'dd.mm.yyyy')
  and p.seller_id = 
    (select max(e.id) from employees e 
    where upper(e.job_name) = upper('seller')
    and e.shop_id = 
      (select s.id from shops s where s.name = 'Sportmaster' and s.region = 'SaintP')
    )
);

update purchases pr
set pr.amount = pr.amount - 2000
where pr.id = 
  (select p.id
  from purchases p
  where to_date(p.datatime) = to_date('20.05.2024', 'dd.mm.yyyy')
  and p.seller_id = 
    (select max(e.id) from employees e 
    where upper(e.job_name) = upper('seller')
    and e.shop_id = 
      (select s.id from shops s where s.name = 'Zara' and s.region = 'Che')
    )
);

commit;

-- Решение задач:
-- tasks:
-- n.1
--  a.
  select p.code, p.name
  from products p
  where not exists
    (select 1
    from purchase_receipts pr
      inner join purchases ps
        on pr.purchase_id = ps.id
        and ps.datatime between trunc(add_months(sysdate, -1),'MONTH') and LAST_DAY(add_months(sysdate, -1))
    where pr.product_id = p.id);
    
--  b.
with cte as (
  select s.name,
     e.first_name, e.last_name,
     sum(coalesce(ps.amount, 0)) sum_amount
  from shops s
  inner join employees e
    on e.shop_id = s.id
    and upper(e.job_name) = upper('seller')
  left join purchases ps
    on e.id = ps.seller_id
    and ps.datatime between trunc(add_months(sysdate, -1),'MONTH') and LAST_DAY(add_months(sysdate, -1))
  group by s.name,
     e.first_name, e.last_name
     
), max_amount as (
  select max(mc.sum_amount) max_amt
  from cte mc
)
  
select c.*,
  case
    when (select t.max_amt from max_amount t) = c.sum_amount
      then 'best seller'
    when c.sum_amount = 0
      then 'without amount'
    else 'middle seller'
  end as rank
from cte c
order by c.sum_amount desc;

-- c.
select s.region, 
     sum(ps.amount) sum_amount
  from shops s
  inner join employees e
    on e.shop_id = s.id
    and upper(e.job_name) = upper('seller')
  inner join purchases ps
    on e.id = ps.seller_id
    and ps.datatime between trunc(add_months(sysdate, -1),'MONTH') and LAST_DAY(add_months(sysdate, -1))
  group by s.region
  order by sum_amount desc;
  
-- 2.
  select s.name, 
     ps.amount,
     ps.datatime,
     (select sum(tpr.amount_full) - sum(tpr.amount_discount)
    from purchase_receipts tpr
    where tpr.purchase_id = ps.id) - ps.amount as inequality
  from shops s
  inner join employees e
    on e.shop_id = s.id
    and upper(e.job_name) = upper('seller')
  inner join purchases ps
    on e.id = ps.seller_id
    and ps.datatime between trunc(add_months(sysdate, -1),'MONTH') and LAST_DAY(add_months(sysdate, -1))
  where ps.amount !=
    (select sum(tpr.amount_full) - sum(tpr.amount_discount)
    from purchase_receipts tpr
    where tpr.purchase_id = ps.id);
    
    
  
  