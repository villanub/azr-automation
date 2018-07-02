$scaleft_path = "C:\windows\system32\config\systemprofile\AppData\Local\ScaleFT\"; 
$enrollment_token_path = $scaleft_path + "enrollment.token"; 
$device_token_path = $scaleft_path + "state\device.token";
$sftconfigfilepath = $scaleft_path + "sftd.yaml";

$serviceStauts = get-service scaleft-server-tools;

	If ($serviceStauts.Status -eq "Running")
	{
		Write-host "ScaleFT is running";
		return;		
	}

	Else
	{
        Invoke-WebRequest -uri "https://dist.scaleft.com/server-tools/windows/latest/ScaleFT-Server-Tools-latest.msi" -OutFile "$env:TEMP\scaleft.msi" -Verbose;

        $enrollment_token | Out-File $enrollment_token_path -Encoding "ASCII" -Force;
        $scaleft_path = "C:\windows\system32\config\systemprofile\AppData\Local\ScaleFT\"; 
        $enrollment_token_path = $scaleft_path + "enrollment.token"; 
        $device_token_path = $scaleft_path + "state\device.token";
        $sftconfigfilepath = $scaleft_path + "sftd.yaml";

        $enrollment_token | Out-File $enrollment_token_path -Encoding "ASCII" -Force;

        Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/qn /I $env:TEMP\scaleft.msi" -Wait -NoNewWindow -Verbose;

        Restart-Service scaleft-server-tools -Force;
     
          }
