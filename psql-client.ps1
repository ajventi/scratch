<#
.SYNOPSIS
    Simple Postgresql client
#>

[CmdletBinding()]
Param (
    [Parameter(ValueFromPipeline=$true)][string[]]$SQLCode,
    [string]$server = "localhost",
    [int]$port = 5432,
    [string]$database = "vvinves",
    [string]$uid = "ajv"
)

Begin {
    $ConnString = "Driver={PostgreSQL UNICODE(x64)};Server=$server;Port=$port;Database=$database;Uid=$uid;"
    $DBConn = New-Object System.Data.Odbc.OdbcConnection
    $DBConn.ConnectionString = $ConnString
    $DBConn.Open()
}

Process {
    $DBCmd = $DBConn.CreateCommand() # OdbcCommand Class
    ## Of course we want input: 
    #$DBCmd.CommandText = "SELECT * from bulk_inventory limit 10;"
    $DBCmd.CommandText = $_
    # Reader is type System.Data.Odbc.OdbcDataReader
    $reader = $DBCmd.ExecuteReader()
    $j = $reader.FieldCount - 1
    $lines = 0 .. $j | forEach { $reader.getName($_) } 
    while ($reader.Read()) {
        # NULL VALUES OR EMPTY Rows cause a problem
        $line = 0 .. $j | forEach { "." + $reader.GetString($_) }
        $lines += $line
    }
    $reader.Close()
    $lines | Format-Table
}

#Do things with $reader here
# Look at https://stackoverflow.com/questions/1184893/how-to-loop-datareader-and-create-datatable-in-powershell
End {
    $DBConn.Close()
}