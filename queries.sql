use as1;
with main_data as (  -- using of CTE, and then joining 5 tables into one main_data
    select 
        n.id,
        n.name,
        h.hp,
        a.alignment,
        c.cr,
        s.speed
    from names_monsters n
    join hp_monsters h on n.id = h.id
    join alig_monsters a on n.id = a.id
    join cr_monsters c on n.id = c.id
    join speed_monsters s on n.id = s.id
)
select -- select query
    alignment,
    avg(hp) as avg_hp,
    avg(cr) as avg_cr -- our main goal is to find avarage cr (how strong a monster is) and hp for each alignment. We can have kawful good, evil, neutral, chaotic good or evil etc. I'll use pattern matching to find patterns in alignments names
from main_data
where alignment like '%good%'
  and cr > (select min(cr) from main_data) -- subquery. only excluding the weakest
group by alignment
having avg(hp) > 5 -- avg hp must be more than 5
union all -- we'll do the same for neautral and evil, uniting all, without deleting copies
select
    alignment,
    avg(hp) as avg_hp,
    avg(cr) as avg_cr
from main_data
where alignment like '%evil%'
  and cr > (select min(cr) from main_data)
group by alignment
union all
select
    alignment,
    avg(hp) as avg_hp,
    avg(cr) as avg_cr
from main_data
where alignment like '%neutral%'
  and cr > (select min(cr) from main_data)
group by alignment
having avg(hp) > 0
order by avg_cr desc
limit 5;