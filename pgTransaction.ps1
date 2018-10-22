[CmdletBinding()]
Param (
    [Parameter(ValueFromPipeline=$true)][string[]]$SQLCode,
    [string]$server = "localhost",
    [int]$port = 5432,
    [Parameter(Mandatory=$true)][string]$database,
    [Parameter(Mandatory=$true)][string]$uid
)

Begin {
    $ConnString = "Driver={PostgreSQL UNICODE(x64)};Server=$server;Port=$port;Database=$database;Uid=$uid;"
    $DBConn = New-Object System.Data.Odbc.OdbcConnection
    $DBConn.ConnectionString = $ConnString
    $DBConn.Open()
    $DBTransaction = $DBConn.BeginTransaction()
    $lineNumber = 1
}

Process {
    $DBCmd = $DBConn.CreateCommand() # OdbcCommand Class
    $DBCmd.Transaction = $DBTransaction
    $DBCmd.CommandText = $_
    $reader = $DBCmd.ExecuteReader()

    # Output
    Write-Output $lineNumber++
    $j = $reader.FieldCount - 1
    $lines = 0 .. $j | ForEach-Object { $reader.getName($_) } 
    while ($reader.Read()) {
        # NULL VALUES OR EMPTY Rows cause a problem
        $line = 0 .. $j | ForEach-Object { "." + $reader.GetString($_) }
        $lines += $line
    }
    $reader.Close()
    $lines | Format-Table
}

End {
    #Prompt to commit
    $a = Read-Host "Commit y/n?"
    if ($a -eq "y") {
        $DBTransaction.Commit()
    } else {
        $DBTransaction.Rollback()
    }
    $DBConn.Close()
}