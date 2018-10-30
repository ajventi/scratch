#requires -Modules postgres

$Vinho = [PSCustomObject]@{
    Version = "0.0.0-dev2018-10-29"
    Connection = [System.Data.Odbc.OdbcConnection] $null
    Transaction = [System.Data.Odbc.OdbcTransaction] $null
}
function Set-VinhoConnection {
    [CmdletBinding()]
    Param (
        # Odbc Connection
        [Parameter(Mandatory=$true)]
        [Alias("conn", "c")]
        [System.Data.Odbc.OdbcConnection]
        $DBConnection
    )
    if ($null -eq $Vinho.Connection ) {
        $Vinho.Connection = $DBConnection
    } else {
        Write-Warning "A Connection already exists"
        $Vinho.Connection
    }
}

function New-VinhoTransaction {
    [CmdletBinding()]
    Param()
    if ($null -eq $Vinho.Transaction) {
        if ($null -eq $Vinho.Connection ) {
            throw "Can't begin a transaction when there is no connection"
        } 
        $Vinho.Transaction = $Vinho.Connection.BeginTransaction()
    } else {
        throw "There is already a transaction active, cannot open another."
    }
}

function Close-VinhoTransaction {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param ()
    if ($PSCmdlet.ShouldProcess("Really commit transaction?")) {
        $Vinho.Transaction.Commit()
        $Vinho.Transaction = $null
    }
}
function Remove-VinhoTransaction {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param ()
    if ($PSCmdlet.ShouldProcess("Really rollback the transaction?")) {
        $Vinho.Transaction.Rollback()
        $Vinho.Transaction = $null
    }
}

function Import-VinhoQuery {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        # SQL Command String
        [Parameter(Mandatory=$true)] 
        [string]
        $Query
    )
    if ($null -eq $Vinho.Transaction) {
        if ($null -ne $Vinho.Connection -and $Vinho.Connection.State -eq "Open") {
            if ($PSCmdlet.ShouldProcess('Import-DBQuery from $Vinho.Connection', $Query)) {
                Import-DBQuery -DBConnection $Vinho.Connection -Query $Query
            }
        } else {
            throw "DBConnection is closed or not available"
        }
    } else {
        if ($PSCmdlet.ShouldProcess('Import-DBQuery from $Vinho.Transaction', $Query)) {
            Import-DBQuery -DBTransaction $Vinho.Transaction -Query $Query
        }
    }
}

# These are all helper functions, probably will be internal in final module
function Close-BulkInventory {
    # We should really check that the wines we are emptying are not already marked empty
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [int[]] $bulkIds,
        [string] $date
    )
    $sql = "UPDATE bulk_wine SET empty_date = $date WHERE id in ("
    $sql += $bulkIds -join ','
    $sql += ") RETURNING id, blend_id, volume;"
    if ($PSCmdlet.ShouldProcess("Import-VinhoQuery", $sql)) {
        Import-VinhoQuery $sql
    } else { 
        return @(@{id=0; name="Fake data $sql"})
    }
}

function New-BulkWineEntry {
    [Cmdletbinding(SupportsShouldProcess=$true)]
    Param (
        [string] $FillDate,
        [int] $blendId,
        [Object[]] $filledContainers
    )
    
    $filledContainers | ForEach-Object {
        $sql = "INSERT INTO bulk_wine (fill_date, blend_id, container_id"
        if ($_ -is [string]) {
            $sql += ") SELECT $fillDate, $blendId, '$_'"
        } else { #assume it has id and volume properties 
            $sql += ",volume) SELECT $fillDate, $blendId, '$($_.id)', $($_.volume)"
        }
        $sql += " RETURNING container_id, id;"
        if ($PSCmdlet.ShouldProcess("Import-VinhoQuery", $sql)) {
            return Import-VinhoQuery $sql
        }
    }
}

Export-ModuleMember -Variable Vinho

@(
    "Set-VinhoConnection",
    "Import-VinhoQuery",
    "New-VinhoTransaction",
    "Remove-VinhoTransaction",
    "Close-VinhoTransaction",
    # Helper funcs below probably wont be exported
    "New-BulkWineEntry",
    "Close-BulkInventory"
) | ForEach-Object { Export-ModuleMember -Function $_ }
