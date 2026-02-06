### Setup-ad.yml
  - Sets up the regular details of the computer, such as time and hostname
  - Calls Domain Controller and AD Users Roles
    - Domain Controller
      - Installs Active Directory Domain Features
      - Check if the domain is already configured
      - Promotes target server to Domain Controller
      - Sets DNS server as itself, creates forward & reverse lookup zones, and creates A & PTR records for hosts
      - Enable SMB2 Protocol so that we can have SMB2 Signing Disabled without interfering with Group Policies
    - AD Users
      - Creates Domain Admins and puts them into Domain Admins Group
      - Creates Domain users
      - Adds defined users to Domain Users Group

### vulnerable-ad.yml
  - Applies Vulnerable Configurations through vulnerable-configs role
    - Creates AD service accounts with SPNs
    - Configures multiple GPO's that include Disabled SMB and LDAP Signing
    - Creates Unconstrained Delegated Computers
    - Enforces a very weak password policy

### validate-ad.yml 
  - Verifies Completion of proper installations
    - Checks for proper Active Directory Domain
    - Lists all AD users and service accounts
    - Lists all GPOs in the domain
