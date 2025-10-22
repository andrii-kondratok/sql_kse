use hw2;

CREATE INDEX ix_enc_location  ON dnd_encounters(location); -- індекси для тих значень, які будемо використовувати в умовах
CREATE INDEX ix_items_type_effect    ON dnd_items_num(item_type, effect);

WITH -- робимо за допомиогою CTE, не сабселекту
c AS (
  SELECT id, name
  FROM dnd_characters
  WHERE id > 1000
),
i AS (
  SELECT id, item_type, effect
  FROM dnd_items_num
  WHERE item_type > 4
    AND effect BETWEEN 3 AND 7
),
e AS (
  SELECT id, location
  FROM dnd_encounters
  WHERE location LIKE 'Forest%' -- шукаємо лише перше слово в рядку (для цього створювали індекс), це пришвидшить виконання
)
SELECT
  c.id,
  c.name,
  e.location,
  i.item_type,
  i.effect
FROM c
JOIN i ON i.id = c.id  
JOIN e ON e.id = c.id
ORDER BY c.id
LIMIT 10;