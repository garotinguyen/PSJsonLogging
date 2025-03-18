Set-StrictMode -Version Latest

function Start-Log {

	[CmdletBinding(
		SupportsShouldProcess=$true,
		ConfirmImpact="Low"
	)]

	[OutputType([Hashtable])]

	param (
		[parameter(mandatory=$true,position=0)]
		[String]
		$Path,

		[parameter(mandatory=$true,position=1)]
		[String]
		$Name,

		[parameter()]
		[Hashtable]
		$AddtionalLogData
	)

	process {

		Write-Verbose "Checking to see if log directory path $Path exists"
		if (Test-Path $Path) {
			Write-Verbose "Log directory path $Path exists"
		}
		else {
			Write-Verbose "Log directory path $Path does not exist, creating"
			Set-Path $Path
		}

		$pidId = [System.Diagnostics.Process]::GetCurrentProcess().Id
		$i = 0
		$iLimit = 1000

		do {
			$filename = (@(
					$Name,
					$(Get-Date -Format 'yyyyMMdd_hhmmss'),
					$pidId,
					[Convert]::ToString($i).PadLeft([Convert]::ToString($iLimit).Length-1, '0')
				) -join '_') + '.log'
			$i++
		} while ($(Test-Path $(Join-Path $Path $filename)) -and $i -le $iLimit)

		$logPath = Join-Path $Path $filename
		Write-Verbose "Log path set to $logPath"

		if (Test-Path $logPath) {
			throw "Unable to generate log path, last tried $logPath"
		}
		else {
			$message = @{
				severity = 'Information';
				timeStamp = (Get-Date -Format 'yyyy-MM-ddThh:mm:ss.ffff%K');
				hostname = $env:ComputerName;
				pidId = $pidId;
				username = $env:Username;
				logPath = $logPath;
				logData = @{
					message = "Starting PSJsonLogger $logPath";
				}
			}
			if ($AddtionalLogData -ne $null) {
				$message.Add('addtionalLogData', $AddtionalLogData)
			}
			if ($Cmdlet.ShouldProcess($logPath)) {
				ConvertTo-Json $message -Compress -Depth 100 | Out-File -FilePath $logPath -Encoding utf8
			}
		}

		return @{
			LogPath = $logPath;
			AddtionalLogData = $AddtionalLogData
		}
	}
}
