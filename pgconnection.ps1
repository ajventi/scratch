
# Can't inherit from a "Sealed Class" so this is all moot

# class PGConnection : System.Data.Odbc.OdbcConnection { # Cannot inherit from Sealed Class !!!!
#     [System.Data.Odbc.OdbcTransaction] $_transaction = $null

#     [bool] IfTransaction ([string] $orMessage = "") {
#         # If transaction exists return true, or warn with message
#         if ($null -eq $this._transaction) {
#             if ($orMessage.Length -gt 0) {
#                 Write-Warning $orMessage
#             } 
#             return $false
#         }
#         return $true
#     }

#     [bool] BeginTransaction () {
#         if ($this.IfTransaction()) {
#             Write-Warning "Attempting to create a transaction when one already exists!"
#             return $false
#         }
#         $this._transaction = [System.Data.Odbc.OdbcConnection]$this.BeginTransaction()
#         Write-Information "PGConnection BeginTransaction()"
#         return $true
#     }

#     [bool] Rollback () {
#         if ($this.Iftransaction("Cannot Rollback, no transaction exists.")) {
#             $this._transaction.Rollback()
#             return $true
#         } 
#         return $false
#     }

#     [bool] Commit () {
#         $this._transaction.Commit()
#         return $true
#     }

#     PGConnection (
#         [string] $database,
#         [string] $uid,
#         [int] $port
#     ) {
#         $this.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};database=$database;uid=$uid;port=$port"
#     }

# }
