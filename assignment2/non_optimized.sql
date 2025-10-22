use hw2;
SELECT
  c.id,
  c.name,
  e.location,
  i.item_type,
  i.effect
FROM
  (SELECT id, name     -- subselect
   FROM dnd_characters
   WHERE id > 1000) AS c
JOIN
  (SELECT id, item_type, effect
   FROM dnd_items_num USE INDEX (ix_items_type_effect)
   WHERE item_type > 4
     AND effect BETWEEN 3 AND 7) AS i -- ще один сабселект
  ON i.id = c.id
JOIN dnd_encounters AS e
  ON e.id = c.id
WHERE
  e.location LIKE '%Forest%'         -- ведучий %: індекс не використається
ORDER BY
  c.id 
LIMIT 10;
