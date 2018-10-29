$env:PSModulePath += ";" + (Get-Location).path

#requires -Modules postgres, vinho

function Empty-Wines {
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
    }
}

#$Vinho.Connection = New-DBConnection -database vvinves -uid ajv



