
# Output CSV in nice table :
# Import-Csv .\sampletable.csv | format-table

# Also try format-list (for full detail)
$Conn.close()

$Conn = New-Object System.Data.Odbc.OdbcConnection
$Conn.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};database=vvinves;uid=ajv;"
$Conn.Open()
$SupplyIds = @(4014100)

$r = New-RackingEntry $conn $SupplyIds
$r.BlendId()

$fillers = @(@{'id'='VT-1k5'; 'volume'=1000})
$r.fillContainers($fillers)

function rerun () {
    $r.transaction.Rollback()
    $r = New-RackingEntry $conn $SupplyIds
    $r.BlendId()
}
