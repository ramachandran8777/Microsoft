Get-Content -Path "C:\Pathto\ip.txt" | ForEach {

    $details = Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue

    if ($details) {

        $props = @{
            ComputerName = $_
            IP = $details.IPV4Address.IPAddressToString
        }

        New-Object PsObject -Property $props
    }

    Else {    
        $props = @{
            ComputerName = $_
            IP = 'Unreachable'
        }

        New-Object PsObject -Property $props
    }

} | Sort ComputerName | Export-Csv "C:\Pathto\IPReport.csv" -NoTypeInformation
