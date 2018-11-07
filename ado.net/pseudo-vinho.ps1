
[CmdletBinding()] Param ()

$Vinho = [System.Data.DataSet]::new("VinhoDB")

$bulkWine = [System.Data.DataTable]::new("bulk_wine")
$columns = @( [System.Data.DataColumn]::new("id", [Int]),
			  [System.Data.DataColumn]::new("blend_id", [int]),
			  [System.Data.DataColumn]::new("container_id", [string]),
			  [System.Data.DataColumn]::new("volume", [int]),
			  [System.Data.DataColumn]::new("fill_date", [System.DateTime]),
			  [System.Data.DataColumn]::new("empty_date", [System.DateTime]) )

foreach ($c in $columns) {
	$bulkWine.Columns.Add($c)
}
$Vinho.Tables.Add($bulkWine)

$csv = @"
id, blend_id, container_id, volume, fill_date, empty_date
4009123,2009010, 08-12, 225, 2009-12-01,1999-12-31
4009127,2009010, 08-14, 225, 2009-12-01,2010-03-14
"@

$csv | ConvertFrom-CSV | ForEach-Object {
	$row = $bulkWine.newRow()
	$row.id = $_.id
	$row.blend_id = $_.blend_id
	$row.container_id = $_.container_id
	$row.volume = $_.volume
	$row.fill_date = $_.fill_date
	$row.empty_date = [System.DateTime] $_.empty_date # Null Values are proving problematic
#	foreach ($col in $bulkWine.Columns) {
#		$v = $_[$col.ColumnName]
#		write-verbose "$($col.ColumnName) :: $_ :: $v"
#		$row[$col.ColumnName] = $v
#	}
	$bulkWine.Rows.Add($row)
}

$Vinho.AcceptChanges()
$Vinho.WriteXml("pseudo-vinho.xml")
