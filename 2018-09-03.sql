UPDATE Bulk_wine set empty_date = '2018-09-03' where id = 4014100 returning *;
INSERT INTO Bulk_Wine (fill_date, container_id, blend_id, volume )  SELECT '2018-09-03', 'VT-1k5', 2014032, 1000;
SELECT * FROM Bulk_inventory where container_id = 'VT-1k5';

-- As it was entered with pwsh
-- 
-- $entry = New-RackingEntry $Conn $SupplyIds -Date "'2018-09-03'"
-- $entry.BlendId()
-- $fillers = @(@{'id'='VT-1k5'; 'volume'=1000})
-- $entry.fillContainers($fillers)
-- # Verify all is good
-- $entry.Close()