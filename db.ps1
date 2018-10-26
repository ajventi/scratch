
<#
.DESCRIPTION
    Working with the vinho database.
#>

<#
TODO: 
* give option for User profile file to store database and uid info
#>

function New-DBConnection {
    <#
    .SYNOPSIS
        Create, open and return a new connection
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([System.Data.Odbc.OdbcConnection])]
    Param (
        # Database name
        [Parameter(Mandatory = $true,
            ParameterSetName = "Common")]
        [ValidateNotNull()]
        [string]
        $database,

        # User name
        [Parameter(Mandatory = $true,
            ParameterSetName = "Common")]
        [ValidateNotNull()]
        [string]
        $uid,

        # Optional config file for database and uid
        [Parameter (Mandatory = $true,
            ParameterSetName = "ConfigFiles")]
        [string]
        $IdFile
    )

    Begin {
        # determine database and username
        if ($IdFile.Length -gt 0) {
            if (Test-Path -Path $IdFile -PathType Leaf) {
                write-debug "Reading login information from $IdFile"
                $args = Get-Content -Path $IdFile | ConvertFrom-Json
                $database = $args.database
                $uid = $args.uid
            }
        }
        # Maybe oneday have something like a .vinho file 
    }

    Process {
        $Conn = New-Object System.Data.Odbc.OdbcConnection
        $cs = "Driver={PostgreSQL UNICODE(x64)};database=$database;uid=$uid;"
        if ($PSCmdlet.ShouldProcess("Connect to DB", $cs)) {
            trap {
                "OdbcConnection Error: $_" 
                break
            }
            $Conn.ConnectionString = $cs
            $Conn.Open()
            return $Conn
        } 
        return $false 
    }
}

function Import-DBQuery {
    <#
    .SYNOPSIS 
        Perform a query on the database and receive results
    .BUGS
        Presently this cannot handle commands spanning multiple lines, it's dumb
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([PSCustomObject[]])]
    Param (
        # Database connection (see New-DBConnection)
        [Parameter(Mandatory=$true, ParameterSetName="Basic")]
        [Alias("Connection", "C")]
        [System.Data.Odbc.OdbcConnection]
        $DBConnection,

        # Database Transaction if performing inside transaction
        [Parameter(Mandatory=$true, ParameterSetName="Transaction")]
        [Alias("Transaction","T")]
        [System.Data.Odbc.OdbcTransaction]
        $DBTransaction,

        # SQL Query
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position="1")]
        [string]
        $Query
    )
    Begin {
        if ($null -ne $DBTransaction) {
            $DBConnection = $DBTransaction.Connection
        }
        $cmd = $DBConnection.CreateCommand()
        $cmd.Transaction = $DBTransaction
        # Can we also add support to do this in a transaction?
        # We should try!
        # It will require having an option to pass a transaction instead of a connection
        # as well which will be connected to the new command created
    }

    Process {
        trap { "ODBC Read Error: $_" }
        if ($PSCmdlet.ShouldProcess($Query)) {
            $cmd.CommandText = $Query  
            $reader = $cmd.ExecuteReader()
            $columnNames = @()
            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $columnNames += $reader.GetName($i)
            }
            $table = @()   
            while ($reader.Read()) {
                $row = @{}
                for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                    $row[$reader.GetName($i)] = $reader.GetValue($i)
                }
                $rowObj = [PSCustomObject]$row
                $table += $rowObj
            }
            $reader.Close()
        }
        return $table
    }

    End {
        $cmd.Dispose()
    }
}

#Export-ModuleMember -Function New-DBConnection
