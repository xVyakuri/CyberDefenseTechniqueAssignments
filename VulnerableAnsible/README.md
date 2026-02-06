# GreyTeam
Terraform and Ansible Automated Setup for Vulnerabilities in an infrastructure

### Vulnerable Ansible Active Directory Lab Setup
This repository contains Ansible playbooks and scripts for setting up an Active Directory lab environment, including intentionally vulnerable configurations for security testing and penetration testing practice. 
These Ansible Playbooks creates a Domain Controller that also maintains DNS, while also creating users and service accounts with SPNs with weak passwords that allows for Kerberoasting as its main vulnerability. Other vulnerabilites such as disabled SMB Signing are also present if there are servers that are configured to handle SMB are made on the same environment as this domain controller. These allow students pentesting or defending this domain controller to understand what exactly can be exploited of especially with Active Directory that may contain many privileged users which can in turn lead to massive privilege escalation for other services, leading to a larger breach of services.

### Competition Use Cases
Grey Team
  Can be used as the main domain controller and DNS handler for the network topology and also can provide another vulnerability to SMB for the SMB server, which makes whoever is defending the SMB server have to look towards the domain controller at some point too.
Blue Team
  Great for blue team to broaden their scope of what they need to look towards in order to defend a specific service.
Red Team
  Great for using a built script to kerberoast for service accounts based on bad and predictable passwords.

### Documentation
- Deployment Guide Documentation within docs folder
- Exploitation Guide Documentation within docs folder
- Troubleshooting in Deployment Guide Documentation
- Playbook Description Documentation within docs folder

### Vulnerabilities Made
- Kerberoastable service accounts with weak passwords
- SMB signing disabled
- LDAP (Lightweight Directory Access Control) signing disabled
- Unconstrained delegation on computers
- Weak password policy
- LLMNR (Link-Local Multicast Name Resolution) enabled

### Prerequisites

## Control Machine (Ansible Host)
- Ansible 2.9+
- Python 3.6+
- pywinrm: `pip install pywinrm`

## Target Windows Server
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
