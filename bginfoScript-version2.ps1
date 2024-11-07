# Terminate any existing BGInfo processes
Stop-Process -Name "BGInfo64" -Force -ErrorAction SilentlyContinue

# Define paths
$stagingDir = "C:\ProgramData\NinjaRMMAgent" # Adjust if necessary
$targetDir = "C:\BGInfo"

# Create hidden directory C:\BGInfo on the target PC if it doesn't exist
if (!(Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force
    (Get-Item $targetDir).Attributes += 'Hidden'
    Write-Output "Created hidden directory $targetDir on the target PC."
    
    # Create the IPAddress.txt file in the C:\BGInfo directory
    $ipAddressFilePath = Join-Path -Path $targetDir -ChildPath "IPAddress.txt"
    New-Item -ItemType File -Path $ipAddressFilePath -Force
    Write-Output "Created IPAddress.txt file in $targetDir."
}

# Recursively search for and copy files from the NinjaRMM staging directory to C:\BGInfo on the target PC
$files = @("BGInfo64.exe", "Get-IPAddress.ps1", "bgDisplay.bgi")
$allFilesCopied = $true

foreach ($file in $files) {
    # Search recursively in the NinjaRMM staging directory for each file
    $stagingFilePath = Get-ChildItem -Path $stagingDir -Recurse -Filter $file -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($stagingFilePath) {
        # Copy the file to C:\BGInfo on the target PC
        Copy-Item -Path $stagingFilePath.FullName -Destination "$targetDir\$file" -Force
        Write-Output "$file found and copied to $targetDir on the target PC."
    } else {
        Write-Output "File $file not found in the NinjaRMM staging directory. Exiting."
        $allFilesCopied = $false
    }
}

# Verify that all files are now in C:\BGInfo on the target PC
if ($allFilesCopied) {
    foreach ($file in $files) {
        if (!(Test-Path -Path "$targetDir\$file")) {
            Write-Output "File $file not found in $targetDir on the target PC after copying. Exiting."
            Exit 1
        }
    }
    Write-Output "All files successfully copied to $targetDir on the target PC. Proceeding with installation."
} else {
    Exit 1
}

# Run findIPaddress.ps1 to save IP address to ipaddress.txt
Set-ExecutionPolicy Bypass -Scope Process -Force
& "$targetDir\Get-IPAddress.ps1"
if ($?) {
    Write-Output "IP address saved successfully to IPAddress.txt."
} else {
    Write-Output "Failed to run Get-IPAddress.ps1."
    Exit 1
}

# Define task settings for updating IP addresses on any user's logon
$taskName = "UpdateIPAddressOnLogon"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$targetDir\Get-IPAddress.ps1`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register the task to run at logon for any user
try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Updates IP Address for BGInfo at each user logon." -Force
    Write-Output "Scheduled task created to update IP address at each user logon using SYSTEM."
} catch {
    Write-Error "Failed to create scheduled task for updating IP address: $_"
}

# Create a new shortcut to run BGInfo at startup for all users
$shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\RunBGInfo.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "C:\BGInfo\BGInfo64.exe"  # Executable path
$shortcut.Arguments = "`"$targetDir\bgDisplay.bgi`" /SILENT /TIMER:0 /ACCEPTEULA"  # Path to the config file
$shortcut.Save()

Write-Output "BGInfo will now run at startup for all users using the shortcut in the All Users Startup folder."

# Finalize with success message
Write-Output "BGInfo deployment completed successfully."

# Final check to terminate any running BGInfo process before exiting
if (Get-Process -Name "BGInfo64" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "BGInfo64" -Force -ErrorAction SilentlyContinue
    Write-Output "BGInfo64 process was running and has been terminated."
}

Exit 0
