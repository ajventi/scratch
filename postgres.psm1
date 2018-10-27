<#
.SYNOPSIS
    Some Simple wrappers for using Postgresql via Odbc
#>

<#
TODO: 
* give option for User profile file to store database and uid info
#>

function New-DBConnection {
    <#
    .SYNOPSIS
        Creates, opens and return a new System.Data.Odbc.OdbcConnection
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

        # Server Port
        [Parameter(Mandatory = $false,
            ParameterSetName = "Common")]
        [ValidateNotNull()]
        [int]
        $port = 5432,

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
                Write-Verbose "Getting parameters from $IdFile"
                $args = Get-Content -Path $IdFile | ConvertFrom-Json
                $database = $args.database
                $uid = $args.uid
                $port = $args.port
            }
        }
        # Maybe oneday have something like a .vinho file 
    }

    Process {
        $Conn = New-Object System.Data.Odbc.OdbcConnection
        $cs = "Driver={PostgreSQL UNICODE(x64)};database=$database;uid=$uid;port=$port"
        if ($PSCmdlet.ShouldProcess("Connect to DB", $cs)) {
            trap {
                "OdbcConnection Error: $_" 
                break
            }
            $Conn.ConnectionString = $cs
            $Conn.Open()
        }
        return $Conn
    }
}

function Import-DBQuery {
    <#
    .SYNOPSIS 
        Perform a query on the database and receive results
    .BUGS
        Presently this cannot handle commands spanning multiple lines, it's dumb

    .TODO 
        Remove pipeline processing, it's making things complex for no reason.
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
        $returnTables = @()
    }

    Process {
        trap { "ODBC Read Error: $_" }
        if ($PSCmdlet.ShouldProcess($Query)) {
            $cmd.CommandText = $Query  
            Write-Information -Msg $Query -Tags "Queries"
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
            Write-Information -Msg $table -Tags "Results"
            $reader.Close()
        } else {
            # IDK If we should give this fake output when doing whatif or confim testing
            $table = @([PSCustomObject]@{
                id = "Whatif Fake Output"
                query = $Query
            })
        }
        $returnTables += $null
        $returnTables[$returnTables.length-1] = $table
    }

    End {
        $cmd.Dispose()
        return $returnTables
    }
}

#Export-ModuleMember -Function New-DBConnection
