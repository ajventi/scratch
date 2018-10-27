#requires -Modules ./postgres

# Output CSV in nice table :
# Import-Csv .\sampletable.csv | format-table

<#
$Conn = New-PGConnection
$SupplyIds = @(4014100)
$entry = New-RackingEntry $Conn $SupplyIds -Date "'2018-09-03'"
$entry.BlendId()
$fillers = @(@{'id'='VT-1k5'; 'volume'=1000})
$entry.fillContainers($fillers)
# Verify all is good
$entry.Close()
#>



# How I'd like to do it:
<#
$args = @{
    OdbcConnection = New-PGConnection
    SupplyIds = @(4014100)
    Date = "'2018-09-03'"
    FilledContainers = @( @{ id = 'VT-1k5' ; volume = 1000 } )
    Confirm = $true     # Will need to add SupportsShouldProcess to CmdletBinding
}
$entry = New-RackingEntry @args
# User will be promted for confirmation before committing transactions

#>

# Working = 2018-09-05
#

#requires db.ps1
$Vinho = New-DBConnection -IdFile .\dbprofile.json
$date = "'2018-09-05'"
$bulkId = 4014101

$transaction = $Vinho.BeginTransaction()
$newLabel = "INSERT INTO wine_label (name, vintage, blend_id, bottle_volume, color) SELECT 'Vino Rosso', NULL, blend_id, .375, 'RED' FROM bulk_wine WHERE id = $bulkId RETURNING id;"

$labelRow = Import-DBQuery -DBTransaction $transaction -Query $newLabel

$bottlingEntry = "INSERT INTO bottled_wine (label_id, quantity, date, type) SELECT $($labelRow.id), $(99*12), $date, 'BOTTLING';"
# This is a simple command with no return results, do we need a different command?
Import-DBQuery -Transaction $transaction -Query $bottlingEntry

Import-DBQuery -t $transaction -Query "UPDATE bulk_wine SET empty_date = $date WHERE id = $bulkId;" 
$newBulkRow = Import-DBQuery -t $transaction -Query "INSERT INTO bulk_wine (fill_date, blend_id, container_id, volume) SELECT $date, blend_id, 'VT-1k5', 544 FROM bulk_wine where id = $bulkId RETURNING id;" 

# Verify and commit
Import-DBQuery -t $transaction "SELECT * from Bulk_wine where blend_id = 2014032;" | Out-GridView
Import-DBQuery -t $transaction "SELECT * FROM bottled_wine WHERE label_id = $($labelRow.id);" 

#$transaction.Commit()

# 2018-09-07
$BulkId = 4014102
$blendId = $(Import-DBQuery -c $Vinho "SELECT blend_id FROM bulk_wine WHERE id = $bulkId;").blend_id
$Date = "'2018-09-06'"

$transaction = $Vinho.BeginTransaction()
$labelRow = Import-DBQuery -t $transaction -Query "INSERT INTO wine_label (name, vintage, blend_id, color) SELECT 'Patience', NULL, $blendId, 'RED' RETURNING *;"
Import-DBQuery -t $transaction -Query "INSERT INTO bottled_wine (label_id, quantity, date, type) SELECT $($labelRow.id), $(12*60), $date, 'BOTTLING';" -WhatIf
Import-DBQuery -t $transaction -Query "UPDATE bulk_wine SET empty_date = $date WHERE id = $bulkId;"
# Verify and commit
Import-DBQuery -t $transaction -Query "SELECT * FROM bulk_wine WHERE blend_id = $blendId;" | Out-GridView
Import-DBQuery -t $transaction "SELECT * FROM bottled_wine WHERE label_id = $($labelRow.id);" 

#$transaction.Commit()

# Fruit Received
$fruitIn = @(
    @{ date = '2018-09-04'; weight = 622 },
    @{ date = '2018-09-06'; weight = 659 }
)

$commands = $fruitIn | ForEach-Object {
    "INSERT INTO material_received (date, variety, vineyard, weight) SELECT '$($_.date)', 'Marquette', 'MAR', $($_.weight) RETURNING *;"
}
$transaction = $Vinho.BeginTransaction()
$rows = $commands | Import-DBQuery -t $transaction 
Import-DBQuery -t $transaction "SELECT * FROM material_received WHERE open;"

#$transaction.commit()

# Create our first batch
$fruitIds = "'{" + ([string[]] (Import-DBQuery -c $Vinho "SELECT id FROM material_received WHERE open;").id -join ',') + "}'"
$transaction = $Vinho.BeginTransaction()

Import-DBQuery -Transaction $transaction "INSERT INTO batch_creation_entry (name, date, components) SELECT 'Marquette', '2018-09-07', $fruitIds;" -whatif
Import-DBQuery -DBTransaction $transaction "SELECT * FROM Batch;" 
Import-DBQuery -DBTransaction $transaction "UPDATE material_received SET open = false WHERE open;"

# 2018-09-11 
# A Simple Racking
$date = "'2018-09-11'"

$targets = Import-DBQuery -c $Vinho "SELECT bulk_id, volume FROM bulk_inventory WHERE blend_id = 2016021;"
$emptied = $targets.bulk_id
$volume = $targets.volume | ForEach-Object -Begin { $sum = 0 } -Process { $sum += $_ } -End { $sum }
$filled = @(@{id="VT-2k2"; volume=$volume})
$transaction = New-RackingWorksheet -DBConnection $Vinho -InputIds $emptied -date $date -FilledContainers $filled

#Verify 
Import-DBQuery -Transaction $transaction "SELECT * FROM Bulk_inventory where blend_id = 2016021;" 
# Success
#$transaction.commit()

# 2018-09-11 A real Blending!
$date = "'2018-09-11'"

$emptied = @(4016066, 4017007, 4017008, 4017009) # Taken from notes

# Doing stuff for reals
$blendName = "Fratelli 2"

$transaction = $Vinho.BeginTransaction()
$emptyRows = Import-DBQuery -t $transaction ("UPDATE bulk_wine set empty_date = $date where id IN (" + ($emptied -join ",") + ") RETURNING blend_id, volume;") 
$components = @{}
$emptyRows | ForEach-Object { $components[$_.blend_id] += $_.volume }
$blendId = (Import-DBQuery -t $transaction "INSERT INTO blend (name, color, year) SELECT '$blendName', 'RED', 2017 RETURNING id;").id

$components.keys | ForEach-Object {
    Import-DBQuery -t $transaction "INSERT INTO blend_component (blend_id, component_blend_id, volume, date) SELECT $blendId, $_, $($components[$_]), $date;" 
}

$containerId = "VT-1k5"
$totalVolume = $components.keys | ForEach-Object -Begin { $s = 0} -Process { $s += $components[$_]} -End {$s}
$newId = (Import-DBQuery -t $transaction "INSERT INTO bulk_wine (blend_id, container_id, volume, fill_date) SELECT $blendId, '$containerId', $totalVolume, $date RETURNING id;").id

# Now lets verify
Import-DBQuery -t $transaction "SELECT * FROM bulk_wine WHERE fill_date = $date OR empty_date = $date;" | Out-GridView
Import-DBQuery -t $transaction "SELECT * FROM blend_component WHERE blend_id = $blendId;" | Out-GridView

$transaction.Commit()

# 2018-09-13 Bottling 
# 101 cases 2017 Carignane

# I am attempting to make this entry work more progmatic and dependant on specialized functions
$bottlingInfo = @{
    date = "'2018-09-13'"
    quantity = 101*12
    labelName = "'Carignane'"
    vintage = 2018
    bottleVolume = 0.75
    bulkId = 4016093
}

# Now to write New-BottlingEntry
$transaction = New-BottlingEntry -c $Vinho @bottlingInfo -whatif -InformationAction Continue

#$transaction.Commit()
