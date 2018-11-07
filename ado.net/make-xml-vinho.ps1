# I am going to attempt Query Postgres using a DataStore, and save it as XML
# Hopefully delve deep enough following relations that we pull from most of the schema

[CmdletBinding(SupportsShouldProcess=$true)]
Param ( 
	[int] $querySize = 12 
)

$csb = [System.Data.Odbc.OdbcConnectionStringBuilder]::new()
$csb.add("uid", "ajv")
$csb.add("database", "vvinves")
$csb.add("driver", "PostgreSQL UNICODE(x64)")

$sql = "SELECT * FROM bulk_wine LIMIT $querySize;"

$VinhoSet = [System.Data.DataSet]::new("Vinho")

try {
	if ($PSCmdlet.ShouldProcess( "DataAdapter::new($sql, $($csb.ConnectionString)" )) {
		$Adaptor1 = [System.Data.Odbc.OdbcDataAdapter]::new($sql, $csb.ConnectionString)
	}
	$Adaptor1.Fill($VinhoSet, "bulk_wine")
    # It doesn't automatically know the table name, I thought it would
	#$VinhoSet.AcceptChanges() 
    $bulkWine = $VinhoSet.Tables["bulk_wine"]
	$bulkWine.PrimaryKey = $bulkWine.Columns["id"] # I don't think it will figure this out itself, but maybe?

	$bulkIds = $bulkWine.Select() | ForEach-Object { $_["blend_id"] } | Select -unique
	$sql = "SELECT * FROM blend WHERE id IN (" 
	$sql += $bulkIds -join ","
	$sql += ");"
	
	Write-Host "Next step is to import blend table with $sql"
	#Seems like we can't reuse the adaptor
    $Adaptor2 = [System.Data.Odbc.OdbcDataAdapter]::new($sql, $csb.ConnectionString)
	$Adaptor2.Fill($VinhoSet, 'blend')

	# Make relations
    #$rel = [System.Data.DataRelation]::new(
	$VinhoSet.Relations.Add("BulkWineBlend", 
        $VinhoSet.Tables['blend'].Columns['id'],		
        $VinhoSet.Tables['bulk_wine'].Columns['blend_id'] )

	# Now output to XML
	$VinhoSet.AcceptChanges() 
	$VinhoSet.WriteXml("./vinho-db.xml")
}
catch {
	write-error "Exception!!!: $($error[0])"
	throw "DIE!!!"
}
finally {
	$Adaptor1.Dispose() 
    $Adaptor2.Dispose()
	"Goodbye"
}





