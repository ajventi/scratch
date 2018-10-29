#####requires -Modules postgres, vinho

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

$Vinho.Connection = New-DBConnection -database vvinves -uid ajv

New-VinhoTransaction 

$bulkIds = @(4017026)
$date = ConvertTo-SQLString '2018-09-13'
$filled = $('16-08', '16-07', '09-02', 'QK-1', 'C-19-1')

$rows = Empty-Wines -bulkIds $bulkIds -date $date 
$blendId = $rows.blend_id

# All our containers are fixed so volume doesn't matter

$filled | ForEach-Object {
    $sql = @("INSERT INTO bulk_wine (fill_date, blend_id, container_id)",
        "SELECT $date, $blendId, '$_' RETURNING id;") -join " "
    $rows = Import-VinhoQuery $sql -Confirm
}

$rows = Import-VinhoQuery "SELECT * FROM BULK_INVENTORY ORDER BY fill_date DESC;"


