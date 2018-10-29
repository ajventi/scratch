#requires -Modules ./postgres



# Things to look at:

# Name                         MemberType Definition
# ----                         ---------- ----------
# Disposed                     Event      System.EventHandler Disposed(System.Object, System.EventArgs)
# InfoMessage                  Event      System.Data.Odbc.OdbcInfoMessageEventHandler InfoMessage(System.Object, System.Data.Odbc.OdbcInfoMessageEventArgs)
# StateChange                  Event      System.Data.StateChangeEventHandler StateChange(System.Object, System.Data.StateChangeEventArgs)
# BeginTransaction             Method     System.Data.Odbc.OdbcTransaction BeginTransaction(), System.Data.Odbc.OdbcTransaction BeginTransaction(System.Data...
# ChangeDatabase               Method     void ChangeDatabase(string value), void IDbConnection.ChangeDatabase(string databaseName)
# Clone                        Method     System.Object ICloneable.Clone()
# Close                        Method     void Close(), void IDbConnection.Close()
# CreateCommand                Method     System.Data.Odbc.OdbcCommand CreateCommand(), System.Data.IDbCommand IDbConnection.CreateCommand()
# CreateObjRef                 Method     System.Runtime.Remoting.ObjRef CreateObjRef(type requestedType)
# Dispose                      Method     void Dispose(), void IDisposable.Dispose()
# EnlistDistributedTransaction Method     void EnlistDistributedTransaction(System.EnterpriseServices.ITransaction transaction)
# EnlistTransaction            Method     void EnlistTransaction(System.Transactions.Transaction transaction)
# Equals                       Method     bool Equals(System.Object obj)
# GetHashCode                  Method     int GetHashCode()
# GetLifetimeService           Method     System.Object GetLifetimeService()
# GetSchema                    Method     System.Data.DataTable GetSchema(), System.Data.DataTable GetSchema(string collectionName), System.Data.DataTable G...
# GetType                      Method     type GetType()
# InitializeLifetimeService    Method     System.Object InitializeLifetimeService()
# Open                         Method     void Open(), void IDbConnection.Open()
# OpenAsync                    Method     System.Threading.Tasks.Task OpenAsync(), System.Threading.Tasks.Task OpenAsync(System.Threading.CancellationToken ...
# ToString                     Method     string ToString()
# ConnectionString             Property   string ConnectionString {get;set;}
# ConnectionTimeout            Property   int ConnectionTimeout {get;set;}
# Container                    Property   System.ComponentModel.IContainer Container {get;}
# Database                     Property   string Database {get;}
# DataSource                   Property   string DataSource {get;}
# Driver                       Property   string Driver {get;}
# ServerVersion                Property   string ServerVersion {get;}
# Site                         Property   System.ComponentModel.ISite Site {get;set;}


# State                        Property   System.Data.ConnectionState State {get;}
# -- Open or Closed


# How to register events (DOn't Know)
# Look at Microsoft.Powershell.Utility
# Register-ObjectEvent
