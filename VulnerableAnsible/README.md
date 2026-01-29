# GreyTeam
Terraform and Ansible Automated Setup for Vulnerabilities in an infrastructure

### Vulnerable Ansible Active Directory Lab Setup
This repository contains Ansible playbooks and scripts for setting up an Active Directory lab environment, including intentionally vulnerable configurations for security testing and penetration testing practice.

### Vulnerabilities Made
- Kerberoastable service accounts with weak passwords
- SMB signing disabled
- LDAP (Lightweight Directory Access Control) signing disabled
- Unconstrained delegation on computers
- Weak password policy
- LLMNR (Link-Local Multicast Name Resolution) enabled

### Prerequisites

### Control Machine (Ansible Host)
- Ansible 2.9+
- Python 3.6+
- pywinrm: `pip install pywinrm`

### Target Windows Server
- Windows Server 2016/2019/2022
- WinRM configured and enabled
- PowerShell 5.1+

### Configuration of Inventory and Server Setup
- Edit Inventory/hosts.ini with made server details either from OpenStack or Terraform
- Run ansible-playbook playbooks/setup-ad.yml to setup Active Directory
- Run ansible-playbook playbooks/vulnerable-ad.yml to apply vulnerabilities

### Initial Windows Server Setup
Before running Ansible, configure WinRM on the Windows server:

```powershell
# Run on Windows Server as Administrator
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file
