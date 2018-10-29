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


Export-ModuleMember -Variable Vinho

@(
    "Set-VinhoConnection",
    "New-VinhoTransaction",
    "Close-VinhoTransaction",
    "Remove-VinhoTransaction",
    "Import-VinhoQuery"
) | ForEach-Object { Export-ModuleMember -Function $_ }
