Param($enrollment_token);
write-output $enrollment_token;
$hostname = hostname;
write-output = "hostname $hostname";

### ScaleFT Paths;
$scaleft_path = "C:\windows\system32\config\systemprofile\AppData\Local\ScaleFT\"; 
$enrollment_token_path = $scaleft_path + "enrollment.token"; 
$device_token_path = $scaleft_path + "state\device.token";
$sftconfigfilepath = $scaleft_path + "sftd.yaml";

### OS Check;
$OSversion = (Get-WmiObject -class Win32_OperatingSystem).Caption;
	If ($OSversion -notlike "*Windows Server*")
	{
    		Write-Output "Unsupported OS: $OSversion";
    		return;
    	}
### See if scaleft is already installed;
$serviceStauts = get-service scaleft-server-tools;

	If ($serviceStauts.Status -eq "Running" -and (Test-Path $device_token_path))
	{
		write-output "scaleft is already installed and the service is running, no work required...exiting";
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

        mkdir "C:\windows\system32\config\systemprofile\AppData\Local\ScaleFT\";

        $enrollment_token | Out-File $enrollment_token_path -Encoding "ASCII" -Force;

        Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/qn /I $env:TEMP\scaleft.msi" -Wait -NoNewWindow -Verbose;

        Restart-Service scaleft-server-tools -Force;
     
        Write-Output -NoNewline "Waiting for Enrollment..";
		$count = 0;
		while (((Test-Path $device_token_path) -eq $false) -and $count -lt 30)
		{ $count++;
    			Write-Host -NoNewline ".";
    			Start-Sleep -Seconds 1;
		}

		if ((Test-Path $device_token_path) -eq $false)
		{
			Write-Output "Error.";
			$msg = "Info: device.token was not created within $count seconds.";
    		Write-Host $msg;
			Write-Error $msg;
			throw [System.IO.FileNotFoundException] $msg;
		}
		else
		{
   			Write-Host "Done.";
    		Get-ChildItem $device_token_path | % { "Info: device.token Created [$($_.name)] LastWrite: [$($_.lastwritetime)]" };
		}
     }
