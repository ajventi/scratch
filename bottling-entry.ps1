#requires -Modules ./postgres
function New-BottlingEntry {
    <#
    .EXAMPLE
    $bottlingInfo = @{
        date = "'2018-09-13'"
        quantity = 101*12
        labelName = "'Carignane'"
        vintage = 2018
        bottleVolume = 0.75
        bulkId = 4016093
    }
    $c = New-DBConnection -database foobar -uid bazzie
    $transaction = New-BottlingEntry -c $c @bottlingInfo 
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([System.Data.Odbc.OdbcTransaction])]
    Param (
        # OdbcConnection
        [Parameter(Mandatory=$true,Position=0)]
        [Alias("c")]
        [System.Data.Odbc.OdbcConnection]
        $DBConnection,

        [Parameter(Mandatory=$true)]
        [string]
        $labelName,

        # Bottling Date
        [Parameter(Mandatory=$true)]
        [string]
        $date,

        # Total count of bottles bottled
        [Parameter(Mandatory=$true)]
        [int]
        $quantity,

        [Parameter(Mandatory=$false)]
        [string]
        $vintage = $null,

        # Liters
        [Parameter(Mandatory=$false)]
        [double]
        $bottleVolume = 0.75,

        [Parameter(Mandatory=$true)]
        [int]
        $bulkId
    )

    # Get info from database
    $sql = "SELECT id, color FROM blend WHERE id in (SELECT blend_id FROM bulk_wine WHERE id = $bulkId);"
    $blendInfo = Import-DBQuery -c $DBConnection $sql

    # Create Wine_label
    $trans = $DBConnection.BeginTransaction()
    $sql = @(
        "INSERT INTO wine_label (name, vintage, blend_id, bottle_volume, color)",
        "SELECT $labelName, $vintage, $($blendInfo.id), $bottleVolume, '$($blendInfo.color)'",
        "RETURNING id;"
    ) -join " "
    $labelId = (Import-DBQuery -t $trans $sql).id

    # Make Bottling Entry
    Import-DBQuery -t $trans "INSERT INTO bottled_wine (label_id, quantity, date, type) SELECT $labelId, $quantity, $date, 'BOTTLING';"

    # Empty Bulk Wine
    Import-DBQuery -t $trans "UPDATE bulk_wine SET empty_date = $date WHERE id = $bulkId;"
    if (!$PSCmdlet.ShouldProcess("Rolling Back Transaction")) {
        $trans.Rollback();
        Write-Verbose "Transaction rolled back"
    }
    return $trans
}