Prepping Ansible Installations:
  - Run in PowerShell on the target Domain Controller
    - Set-ExecutionPolicy Bypass -Scope Process -Force
    - [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    - iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    - Choco install -y git curl wget python openssh
    - Python -m venv ansible-env
    - Inside ansible-env (Still in PowerShell)
      - Pip install –upgrade pip
      - Pip install ansible ansible-lint

Prepping Domain Controller for SSH:
  - Run in Powershell
    - Get-NetFirewallPortFilter | Where-Object {$_.LocalPort -eq 22}
      - If nothing prints, then there are no firewall rules allowing traffic on port 22
    - New-NetFirewallRule `
      	-Name “OpenSSH-22” `
      	-DisplayName “OpenSSH Server” `
      	-Enabled True `
      	-Direction Inbound `
      	-Protocol TCP `
      	-Action Allow `
      	-LocalPort 22
  - Get-Service sshd
    - If Error, run
      - AddWindowsCapability -Online -Name OpenSSH.server~~~~0.0.1.0
  - Start-service sshd
  - Set-service sshd -StartUpType Automatic

Prerequisites to running Ansible:
  - Desired Domain Controller should be made as Windows Server 2022
  - Follow “Prepping Ansible Installations” earlier in the document to install Git, Curl, Wget, Python, and OpenSSH
  - Enable SSH on that target Windows Server 2022 (If you haven’t already)
  - Follow SSH instructions
  - Change Ansible Host IP address and Host Name within inventory/hosts.ini to the details of the Windows Server
  - Make Setup-ssh.sh an executable by running the following:
    - Chmod +x setup-ssh.sh

Installation & Configuration:
  - After verifying proper connectivity from your ansible host to the targeted Windows Server, change the details in inventory/hosts.ini to match your desired network configurations if you have not already done so.
  - Run the following command in order:
    - Ansible-playbook ~/playbooks/setup-ad.yml
    - Ansible-playbook ~/playbooks/vulnerable-ad.yml
    - Ansible-playbook ~/playbooks/validate.yml
  - Check Screenshots of the expected outcome in the Screenshots folder in this repository.
    - Note that there will be skipped or changed items. This is due to items already being configured from previous runs of these playbooks and since there have been no new changes to those configurations, the playbooks skip over them.

Troubleshooting:
  - Ensure you maintain connectivity from your Ansible host to the target domain controller.
  - Ensure that you are putting in the correct configurations for your desired domain details as well as putting the correct target domain controller network configurations.
  - Any executable file, such as scripts, ensure that they are executable as a file permission (if not, just make them executable)
    - Chmod +x “filename”
  - When running ansible all -m ping
    - If it’s a windows server you’re trying to ping, you have to use win_ping

Verification:
  - After running ~/playbooks/validate.yml, all of the checks should be good and without any failures.
  - Connect to the server via console and open up Active Directory.
    - Check Service Accounts and confirm Domain (lab.local)
    - Check Group Policy Management and ensure vulnerable group policies are made
