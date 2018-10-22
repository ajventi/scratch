
-- 9/3
SELECT * FROM Bulk_Wine where container_id = 'VT1-k5';

-- Racking
BEGIN; -- VS Code extenstion cant deal with transactions, seems to send a single query
UPDATE Bulk_wine set empty_date = '2018-09-03' where id = 4014100 returning *;
INSERT INTO Bulk_Wine (fill_date, container_id, blend_id, volume ) 
    SELECT '2018-09-03', 'VT-1k5', 2014032, 1000;
SELECT * FROM Bulk_Wine where container_id = 'VT1-k5';
ROLLBACK;