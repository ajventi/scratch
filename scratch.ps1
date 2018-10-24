
# Output CSV in nice table :
# Import-Csv .\sampletable.csv | format-table

# Also try format-list (for full detail)
$Conn.Close()
function New-PGConnection {
    $Conn = New-Object System.Data.Odbc.OdbcConnection
    $Conn.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};database=vvinves;uid=ajv;"
    $Conn.Open()
    return $Conn
}

<#
$Conn = New-PGConnection
$SupplyIds = @(4014100)
$entry = New-RackingEntry $Conn $SupplyIds -Date "'2018-09-03'"
$entry.BlendId()
$fillers = @(@{'id'='VT-1k5'; 'volume'=1000})
$entry.fillContainers($fillers)
# Verify all is good
$entry.Close()
#>



# How I'd like to do it:
<#
$args = @{
    OdbcConnection = New-PGConnection
    SupplyIds = @(4014100)
    Date = "'2018-09-03'"
    FilledContainers = @( @{ id = 'VT-1k5' ; volume = 1000 } )
    Confirm = $true     # Will need to add SupportsShouldProcess to CmdletBinding
}
$entry = New-RackingEntry @args
# User will be promted for confirmation before committing transactions

#>



