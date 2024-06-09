-- Данные для тестирования предполагают отсутствие 
-- null значений, но ограничений на таблице не создано
-- 3 банка, 3 клиента, максимум 5 типов договоров
-- в задаче 1: в результате будут клиенты 1 и 2;
-- в задаче 2: в результате будут клиенты 1 и 3;
-- в задаче 5: самый большой банк с идент. 3;

create table contract (
  id        integer,
  type_id   integer,
  id_client integer,
  id_bank   integer,
  stat      integer,
  name      varchar2(30),
  constraint contract_pk primary key (id)
  
);

--data for tasks
-- 1
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (1,1,1,1,1,'d-0001');
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (2,1,1,2,1,'m-0001');

Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (3,1,2,1,1,'d-0002');
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (4,1,2,2,1,'m-0002');

Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (5,1,3,3,1,'f-0001');

-- 2
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (6,2,1,1,1,'d-0003');
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (7,3,1,1,1,'d-0004');

Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (9,2,3,3,1,'f-0002');
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (10,3,3,3,1,'f-0003');
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (11,4,3,3,1,'f-0004');

-- 3
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (8,4,1,1,0,'d-0005');

-- 5
Insert into contract (ID,TYPE_ID,ID_CLIENT,ID_BANK,STAT,NAME) values (12,5,3,3,1,'f-0005');

commit;

--1.
-- v.1
select distinct c1.id_client
from contract c1, contract c2
where c1.id_client = c2.id_client
and c1.stat = 1
and c2.stat = 1
and c1.id_bank != c2.id_bank;

-- v.2
select distinct c1.id_client
from contract c1
cross join contract c2
where c1.id_client = c2.id_client
and c1.id_bank != c2.id_bank
and c1.stat = 1
and c2.stat = 1;

-- v.3
select distinct c1.id_client
from contract c1
inner join contract c2
  on c1.id_client = c2.id_client and c1.id_bank != c2.id_bank
where c1.stat = 1
and c2.stat = 1;

-- v.4
select c.id_client
from contract c
where c.stat = 1
group by c.id_client
having count(distinct c.id_bank) > 1;

--2.
-- v.1
select distinct r.id_client
from (
  select t.id_client, t.id_bank, count(distinct t.type_id) q_c
  from contract t
  group by t.id_client, t.id_bank) r
where r.q_c >= 3
order by r.id_client;

-- v.2
select distinct c1.id_client
  from contract c1, contract c2, contract c3
where c1.id_client = c2.id_client
  and c1.id_client = c3.id_client
  and c1.id_bank = c2.id_bank
  and c1.id_bank = c3.id_bank
  and c1.type_id != c2.type_id
  and c2.type_id != c3.type_id  
  and c1.type_id != c3.type_id;

-- v.3
select distinct c1.id_client
  from contract c1
inner join contract c2
  on c1.id_client = c2.id_client
  and c1.id_bank = c2.id_bank
  and c1.type_id != c2.type_id
inner join contract c3
  on c1.id_client = c3.id_client
  and c1.id_bank = c3.id_bank
  and c2.type_id != c3.type_id  
  and c1.type_id != c3.type_id;
  
-- 3.
-- v.1
select c1.id_bank, c1.type_id, count(distinct c1.id_client) as num
from contract c1
where c1.stat = 1
group by c1.id_bank, c1.type_id
order by c1.id_bank, c1.type_id;

-- v.2
select distinct c1.id_bank, c1.type_id,
  (select count(distinct t.id_client)
  from contract t
  where t.id_bank = c1.id_bank
  and t.type_id = c1.type_id) as num 
from contract c1
where c1.stat = 1
order by c1.id_bank, c1.type_id;

--4.
--v.1
select 
  c1.id_bank,
  (select sum(1)
    from contract c2
    where c2.id <= c1.id
    and c2.stat = 1
    and c2.id_bank = c1.id_bank
    ) as num,
  c1.name
from contract c1
where c1.stat = 1
order by c1.id_bank, num;

--v.2
select s1.id_bank, sum(1) as num, s1.name
from contract s1
inner join contract s2
  on s1.id_bank = s2.id_bank
  and s2.id <= s1.id
  and s2.stat = 1
where s1.stat = 1
group by s1.id_bank, s1.id, s1.name
order by s1.id_bank, num;

--5.
-- v.1
select distinct all_banks.id_client
from contract all_banks
minus
select distinct big_b.id_client
from contract big_b
where big_b.id_bank = 
(select r1.id_bank
from 
  (select c1.id_bank, count(c1.id) q
  from contract c1
  where c1.stat = 1
  group by c1.id_bank) r1
where r1.q = (select max(r2.q) m_q
                from 
                  (select c1.id_bank, count(c1.id) q
                  from contract c1
                  where c1.stat = 1
                  group by c1.id_bank) r2
            )
);

-- v.2
-- using pseudo-column "rownum" in oracle like a
-- expression "limit n" in other rdbms
select distinct not_big.id_client
from contract not_big
minus
select distinct big_b.id_client
from contract big_b
where big_b.id_bank = 
  (select big.id_bank
  from (
    select c.id_bank, count(c.id) q_c
    from contract c
    where c.stat = 1
    group by c.id_bank
    order by q_c desc) big
  where rownum = 1);
  
  

