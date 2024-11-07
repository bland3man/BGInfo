# Define the path for the output text file
$OutputFile = "C:\BGInfo\IPAddress.txt"

# Get all active IPv4 addresses
$IPv4Addresses = (Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {
    $_.IPEnabled -eq $true -and $_.IPAddress -match '\d+\.\d+\.\d+\.\d+'
}).IPAddress | Where-Object { $_ -match '\.' }

# Check if any IP addresses were found and write to the output file
if ($IPv4Addresses -and $IPv4Addresses.Count -gt 0) {
    # Join the IP addresses with new lines and write to the file
    $IPv4AddressString = $IPv4Addresses -join "`r`n"
    Set-Content -Path $OutputFile -Value $IPv4AddressString
} else {
    # Write a placeholder message if no IP addresses were found
    Set-Content -Path $OutputFile -Value "No IPv4 address found"
}