Set-StrictMode -Version Latest

function Write-Log {
<#
.SYNOPSIS
Writes to a log file in json format Dan.

.DESCRIPTION
After calling the Start-Log function, you can use this function to write to the log file passing the log object; the actual log message; and severity.

.PARAMETER Log
The Log object returned from Start-Log.

.PARAMETER LogData
The data to be logged.

.PARAMETER Severity
Sets the severity for the log entry. Default is "Information". Valid values are: "Information", "Warning", "Error", "Debug"

.EXAMPLE
$log = Start-Log -Path C:\Temp -Name temp_log
Write-Log -Log $log -LogData 'Hello World!' -Severity 'Debug'

.NOTES
The script will automatically log the pidId; timestamp; hostname; username and path of the file. It will write to the file in json format.
Example of output:
{"pidId":6508,"timeStamp":"Tuesday, 19 July 2016 2:02:24 PM","logData":"Hello World!","hostname":"dev-dantan","username":"daniel.tan","severity":"Information","logPath":"C:\\Temp\\temp_20160719_015931_6508_000.log"}

#>
	[CmdletBinding()]

	param (
		[parameter(mandatory=$true,position=0)]
		[Hashtable]
		$Log,

		[parameter(mandatory=$true,position=1)]
		[Object]
		$LogData,

		[parameter(mandatory=$false)]
		[ValidateSet("Information", "Warning", "Error", "Debug")]
		[String]
		$Severity = "Information"
	)

	process {

		$requiredKeys = @(
			'LogPath',
			'AddtionalLogData'
		)
		foreach ($key in $requiredKeys) {
			Write-Verbose "Checking to see if log parameter contains $key key"
			if ($Log.Keys -contains $key) {
				Write-Verbose "$key key found in Log parameter"
			}
			else {
				throw "Unable to find $key key in Log parameter, you need to pass in result of Start-Log"
			}
		}

		Write-Verbose "Checking to see if log file $($Log.LogPath) exists"
		if (Test-Path $Log.LogPath) {
			Write-Verbose "Found log file $($Log.LogPath)"
		}
		else {
			throw "Unable to find log file $($Log.LogPath)"
		}

		$pidId = [System.Diagnostics.Process]::GetCurrentProcess().Id

		$LogRecord = @{
			severity = $Severity;
			timeStamp = (Get-Date -Format 'yyyy-MM-ddThh:mm:ss.ffff%K');
			hostname = $env:ComputerName;
			pidId = $pidId;
			username = $env:Username;
			logPath = $Log.LogPath;
			logData = $LogData
		}
		if ($null -ne $Log.AddtionalLogData) {
				$LogRecord.Add('addtionalLogData', $Log.AddtionalLogData)
		}
		ConvertTo-Json $LogRecord -Compress -Depth 100 | Out-File -FilePath $Log.LogPath -Append -Encoding utf8
	}
}
