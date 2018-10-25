#require ./db.ps1
<#
TODO:
* Use parameter sets for different scenarios
#>


class RackingEntry {
    [System.Data.Odbc.OdbcTransaction] $transaction
    [System.Collections.Hashtable]$blendComponents
    [string]$date
    [int] hidden $_blendId
    [int[]] hidden $_newIds
    [string] $_debug

    [int] BlendID () {
        if ($this._blendId -ne 0) { return $this._blendId }
        elseif ($this.blendComponents.Count -eq 1) {
            # redundant code !!!
            $k = @(0)
            $this.blendComponents.Keys.CopyTo($k,0)
            $this._blendId = $k[0]
            return $this._blendId
        } else {
            # You have to makeNewBlend
            return $null
        }
    }
    
    [int] makeNewBlend ([string] $name, [string] $color, [int] $year) {
        if ($this._blendId -ne 0) { return $this._blendId }
        if ($this.blendComponents.Count -eq 1) {
            $k = @(0)
            $this.blendComponents.Keys.CopyTo($k,0)
            $this._blendId = $k[0]
        } else {
            $cmd = $this.transaction.Connection.CreateCommand()
            $cmd.Transaction = $this.transaction
            $cmd.CommandText = "INSERT INTO BLEND (year, name, color) SELECT"
            $cmd.CommandText += " $year, '$name', '$color' RETURNING blend_id;"
            $rdr = $cmd.ExecuteReader()
            $this._blendId = $rdr.GetInt32(0)
            $this.blendComponents.keys | ForEach-Object {
                $cmd.CommandText = 'INSERT INTO blend_component (blend_id, component_blend_id, volume, date)'
                $cmd.CommandText += 'SELECT $this._blendId, $_, $this.blendComponents.$_, $this.date;'
                $cmd.ExecuteNonQuery()
            }
            $rdr.Close()
            $cmd.Dispose()
        }
        return $this._blendId
    }

    # For fixed volume simply pass a string for container ID, otherwise pass a hash {id=, volume=}
    [int[]] fillContainers ([System.Object[]]$ContainersAndVolumes) {
        $cmd = $this.transaction.Connection.CreateCommand()
        $cmd.Transaction = $this.transaction
        $this._newIds = @()
        foreach ($c in $ContainersAndVolumes) {
            $Ldate = $this.date
            $blendId = $this._blendId
            $cmd.CommandText = "INSERT INTO bulk_wine (fill_date, blend_id, container_id, volume) SELECT $Ldate, $blendId, "
            if ($c -is [string]) {
                $cmd.CommandText += "'$c', NULL"
            } else {
                $id = $c.id
                $vol = $c.volume
                $cmd.CommandText += "'$id', $vol"
            }   
            $cmd.CommandText += " RETURNING id;"
            $this._debug = $cmd.CommandText
            $rdr = $cmd.ExecuteReader()
            $rdr.read()
            $this._debug = $rdr.GetName(0)
            $this._newIds += $rdr.GetInt32(0)
            $rdr.close()
        }   
        return $this._newIds
    }

    [void] verifyEntry () {
        # Code to show entries are all good before commit
    }

    [void] Close ([boolean]$rollback = $false) {
        if ($rollback -eq $false) {
            $this.transaction.Commit()
        } else {
            $this.transaction.Rollback()
        }
    }

}

function ConvertTo-SQL {
    Param (
        [int[]]$TextList
    )
    $str = ConvertTo-Json $TextList -Compress
    return $str.Replace("[","(").Replace("]",")")
}
# 

function New-RackingEntry {
    <#  
    .SYNOPSIS 
        Prepare entry to record racking and blending cellar activity.
    .DESCRIPTION
        Records all wines emptied into a blend, updates database inside a transaction.

        Returns WineBlob Object, which will then be used to record the filling of bulk 
        containers by the Set-RackingEntry commandlet.

        Please write more help
    #>
    [CmdletBinding()]
    [OutputType([RackingEntry])]
    Param (
        #OdbcConnection (Must first be open)
        [Parameter(Mandatory=$true)]
        [System.Data.Odbc.OdbcConnection]
        $OdbcConnection,

        #Bulk IDs of all emptied bulk containers
        [Parameter(Mandatory=$true)]
        [int[]] 
        $SupplyIDs,
        
        #Date of activity, defaults to CURRENT_DATE
        [Parameter(Mandatory=$false)]
        [string] 
        $Date = "CURRENT_DATE",

        # Echo SQL Commands, do not actually perform anything 
        [Parameter(Mandatory=$false)]
        [switch]
        $simulate

    )
    $transaction = $OdbcConnection.BeginTransaction()
    $cmd = $OdbcConnection.CreateCommand()
    $cmd.Transaction = $transaction
    $ids = ConvertTo-SQL($SupplyIDs)
    $cmd.CommandText = "UPDATE bulk_wine SET EMPTY_DATE = $Date"
    $cmd.CommandText += " WHERE id IN $ids RETURNING id, blend_id, volume;"
    if ($simulate -eq $true) {
        Write-Output $cmd.CommandText
    } else {
        $reader = $cmd.ExecuteReader()
    }
    $blendComponents = @{}
    while ($reader.read()) {
        $blendComponents[$reader.getInt32(1)] += $reader.GetDouble(2)
    }
    
    # What needs to be in our RackingEntry Object?
    $r = New-Object RackingEntry
    $r.transaction = $transaction
    $r.blendComponents = $blendComponents
    $r.date = $date
    $reader.Close()
    $cmd.Dispose()

    return $r
}

function New-RackingWorksheet {
    [CmdletBinding()]
    [OutputType([System.Data.Odbc.OdbcTransaction])]
    Param (
        [Parameter(Mandatory=$true)]
        [System.Data.Odbc.OdbcConnection]
        $DBConnection,
        
        [Parameter(Mandatory=$true)]
        [int[]]
        $InputIds,

        [Parameter(Mandatory=$true)]
        [System.Object[]]
        $FilledContainers,

        [Parameter(Mandatory=$false)]
        [string]
        $Date = 'CURRENT_DATE'
    )
    Process {
        $trans = $DBConnection.BeginTransaction()
        $ids = ConvertTo-SQL($InputIDs)
        $CommandText = "UPDATE bulk_wine SET EMPTY_DATE = $Date"
        $CommandText += " WHERE id IN $ids RETURNING id, blend_id, volume;"
        $rows = Import-DBQuery -Transaction $trans $CommandText
        if (($rows | Select-Object -Property blend_id -Unique).count) -ne 1) {
            throw "There must be one blend, no more, no less"
        }
        $FillCommands = $FilledContainers | ForEach-Object {
            $query = "INSERT INTO bulk_wine (Date, Container_ID, Volume) SELECT $Date, "
            if ($_.GetType() -is [string]) {
                $query += "$_, NULL"
            } else {
                $query += "{0}, {1}" -f $_.id, $_.volume
            }
            $query += " RETURNING container_id, id;"
            return $query
        }
        $rows = $FillCommands | Import-DBQuery -Transaction $trans 
        return $transaction
    }
}
