-- Bottled 99 Case Vino Rosso 375-mL
-- from Bulk ID 4014101
--
-- Bottling Procedure:
-- 1. make a new entry into wine_label
INSERT INTO wine_label (name, vintage, blend_id, bottle_volume, color) 
    SELECT 'Vino Rosso', NULL, blend_id, .375, 'RED' 
        FROM bulk_wine WHERE id = 4014101 
    RETURNING id; 
-- label_id = 501410

-- 2. Entry in bottled_wine
INSERT INTO bottled_wine (label_id, quantity, date, type)
    SELECT 501410, 99*12, '2018-09-05', 'BOTTLING';

-- empty bulk_wine 
-- This is a rare thing, we used ~456 L of 1kL bulk
-- So we really rack this into its own container. 
UPDATE bulk_wine SET empty_date = '2018-09-05' WHERE id = 4014101;
INSERT INTO bulk_wine (fill_date, blend_id, container_id, volume) SELECT '2018-09-05', 2014032, 'VT-1k5', 544 RETURNING id;

-- 2018-09-06 
-- Bottled 60 case Patience 750-mL from 4014102
INSERT INTO wine_label (name, vintage, blend_id, color)
    SELECT 'Patience', NULL, 2014032, 'RED' RETURNING *;
-- 501411
INSERT INTO bottled_wine (label_id, quantity, date, type)
    SELECT 501411, 12*60, '2018-09-06', 'BOTTLING';
UPDATE bulk_wine SET empty_date = '2018-09-06' WHERE id = 4014102;


