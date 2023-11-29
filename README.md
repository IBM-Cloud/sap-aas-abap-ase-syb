# Automation Scripts for SAP Netweaver on Sybase ASE Additional Application Server Deployment

## Description
This automation solution is designed for the deployment of **SAP Netweaver on ASE DB additional application server** when a SAP Netweaver on ASE DB system, with a primary application server, already exists. The additional application server will be deployed on top of one of the following Operating Systems, the same as for the primary application server: **SUSE Linux Enterprise Server 15 SP 4 for SAP, SUSE Linux Enterprise Server 15 SP 3 for SAP, Red Hat Enterprise Linux 8.6 for SAP, Red Hat Enterprise Linux 8.4 for SAP**, in the same IBM Cloud Gen2 VPC, using the same bastion host with secure remote SSH access as for the primary application server.

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified. IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen.

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Prerequisites](#12-prerequisites)
- [1.3 VSI Configuration](#13-vsi-configuration)
- [1.4 VPC Configuration](#14-vpc-configuration)
- [1.5 Files description and structure](#15-files-description-and-structure)
- [2.1 Executing the deployment of **SAP Netweaver on ASE DB additional application server** in GUI (Schematics)](#21-executing-the-deployment-of-sap-netweaver-on-ase-db-additional-application-server-in-gui-schematics)
- [2.2 Executing the deployment of **SAP Netweaver on ASE DB additional application server** in CLI](#22-executing-the-deployment-of-sap-netweaver-on-ase-db-additional-application-server-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- From the SAP Portal, download the SAP kits on the Deployment Server. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.
- A [SAP Netweaver ABAP ASE SYB standard solution](https://github.com/IBM-Cloud/sap-netweaver-abap-ase-syb-standard) or a [SAP NetWeaver ABAP ASE SYB distributed solution](https://github.com/IBM-Cloud/sap-netweaver-abap-syb-distributed) must have been previously deployed

## 1.3 VSI Configuration
The VSI OS images that are supported for this solution are the following:

For Netweaver primary application server:
- ibm-redhat-8-6-amd64-sap-applications-4
- ibm-redhat-8-4-amd64-sap-applications-7
- ibm-sles-15-4-amd64-sap-applications-6
- ibm-sles-15-3-amd64-sap-applications-9

The VSIs will be accessible via SSH, as root user, based on the SSH key and IBM Cloud SSH keys UUID provided.  
The following storage volumes are created during provisioning for DB and SAP APP VSIs:

SAP Netweaver AAS VSI Disks:
- 1x 32 GB disk with 10 IOPS / GB - SWAP
- 1 x 64 GB disk with 10 IOPS / GB - DATA

In order to perform the deployment you can use either the CLI component or the GUI component (Schematics) of the automation solution.

## 1.4 VPC Configuration
The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

 ## 1.5 Files description and structure

 - `modules` - directory containing the terraform modules
 - `ansible` - directory containing the Ansible playbooks for SAP.
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP, Activity Tracker Name).
 - `integration*.tf & generate*.tf` files - contain the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data for `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
- `input.auto.tfvars` - contains the input variables for the deployment via CLI; the user must provide the values 
 - `versions.tf` - contains the minimum required versions for Terraform and IBM Cloud provider.
 - `sch.auto.tfvars` - contains programatic variables.

## 2.1 Executing the deployment of **SAP Netweaver on ASE DB additional application server** in GUI (Schematics)

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment of a VSI, in the same VPC, Subnet and Security Group as the primary application server. The VSI is intended to be used for the additional application server instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Bash scripts used for the checking of the prerequisites required by SAP VSI deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the SAP additional application server installation.
- Ansible playbooks to install and configure the SAP Netweaver secondary application server.
Please note that Ansible is started by Terraform and must be available on the same host.

### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "IBMCLOUD_API_KEY" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters
The following parameters can be set in the Schematics workspace as below:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
ID_RSA_FILE_PATH | The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders.<br /> Default value: "ansible/id_rsa".
PRIVATE_SSH_KEY | id_rsa private key content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.
REGION | The cloud region where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST). The available regions and zones for VPC can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). Supported locations for IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations)
ZONE | The cloud zone where to deploy the solution. The available regions and zones for VPC can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc)
VPC | The name of an EXISTING VPC where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST). The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SECURITY_GROUP | The name of an EXISTING Security group. Must be the same as for the primary application server (SAP CI HOST). The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups)
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets)
SSH_KEYS | List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys should be created for the same region as the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys)
HOSTNAME | The Hostname for the VSI. The hostname must be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
PROFILE | The instance profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)
IMAGE | The OS image used for the VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)

**Activity Tracker input parameters:**

Parameter | Description
----------|------------
ATR_NAME | The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available [here](https://cloud.ibm.com/observe/activitytracker)

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
SAP_SID | The SAP system ID. Identifies the entire SAP system.<br /> _(See Obs.*)_ | Must be the same as the one on the primary application server (SAP CI HOST). Consists of exactly three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280
SAP_CI_HOST | The IP address of the existing SAP Central Instance VSI |
SAP_CI_HOSTNAME | The hostname of the existing SAP Central Instance VSI |
SAP_ASCS_INSTANCE_NUMBER | The central ABAP service instance number. Technical identifier for internal processes of ASCS| <ul><li>Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_CI_INSTANCE_NUMBER | The SAP central instance number. Technical identifier for internal processes of CI| <ul><li>Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_AAS_INSTANCE_NUMBER | The SAP additional application server instance number. Technical identifier for internal processes of the additional application server| <ul><li>Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation (Sensitive* value).<br /> _(See Obs.*)_ | <ul><li>It must be 10 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It can only contain the following characters: a-z, A-Z, 0-9, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> 
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SAPCAR_1010-70006178.EXE
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SWPM10SP31_7-20009701.SAR
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal. <br /> Default: /storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR

**Obs***: <br />
 - **SAP Password**
The passwords for the SAP system will be hidden during the schematics apply step and will not be available after the deployment.
- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server and the primary application server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.
- OS **image** for **SAP APP VSI**. Supported OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-7, ibm-sles-15-4-amd64-sap-applications-6, ibm-sles-15-3-amd64-sap-applications-9.
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable: APP-IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
- The following SAP **"_SID_"** values are _reserved_ and are _not allowed_ to be used: ADD, ALL, AMD, AND, ANY, ARE, ASC, AUX, AVG, BIT, CDC, COM, CON, DBA, END, EPS, FOR, GET, GID, IBM, INT, KEY, LOG, LPT, MAP, MAX, MIN, MON, NIX, NOT, NUL, OFF, OLD, OMS, OUT, PAD, PRN, RAW, REF, ROW, SAP, SET, SGA, SHG, SID, SQL, SUM, SYS, TMP, TOP, UID, USE, USR, VAR.

### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

    In the output of the Schematics `Apply Plan` the private IP address of the VSI hosts, the hostname of the VSIs and the activity tracker instance name will be displayed.

## 2.2 Executing the deployment of **SAP Netweaver on ASE DB additional application server** in CLI

The solution is based on Terraform scripts and Ansible playbooks executed in CLI and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment of a VSI, in the same VPC, Subnet and Security Group as the primary application server. The VSI is intended to be used for the additional application server instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Bash scripts used for the checking of the prerequisites required by SAP VSI deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the SAP additional application server installation.
- Ansible playbooks to install and configure SAP Netweaver secondary application server.
Please note that Ansible is started by Terraform and must be available on the same host.

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).

### Input parameter file
The solution is configured by asigning the appropriate values to the variables in `input.auto.tfvars`.
Edit the file `input.auto.tfvars` and asign the appropriate values like in the example bellow:

**VSI input parameters:**

```shell
##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

REGION = "eu-de"  
# The cloud region where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST)
# The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-1"    
# The cloud zone where to deploy the solution.
# The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

VPC = "ic4sap"
# The name of an EXISTING VPC where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST)
# The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# The name of an EXISTING Security group for the same VPC. Must be the same as for the primary application server (SAP CI HOST)
# The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet" 
# The name of an EXISTING Subnet in the same VPC and same zone.
# The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c"]
# List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys should be created for the same region as the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The file path for the private ssh key. The private ssh key must be in OpenSSH format, and the persmission on the file must be set to 0600.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path on the BASTION Server (Deployment Server).
# Examples: "ansible/id_rsa_abap_ase-syb_std" , "~/.ssh/id_rsa_abap_ase-syb_std" , "/root/.ssh/id_rsa".

##########################################################
# Activity Tracker variables:
##########################################################

ATR_NAME = "Activity-Tr"
# The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tr"

##########################################################
# VSI variables:
##########################################################

HOSTNAME = "ic4sap-aas"
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: "Hostnames of SAP ABAP Platform servers".
# Example: DB-HOSTNAME = "ic4sapsys"

PROFILE = "bx2-4x16"
# The instance profile used for the VSI. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211
# The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
```

Parameter | Description
----------|------------
ID_RSA_FILE_PATH | The file path for PRIVATE_SSH_KEY. The private ssh key must be in OpenSSH format, and the persmission on the file must be set to 0600. This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
REGION | The cloud region where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST). The available regions and zones for VPC can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). Supported locations for IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations)
ZONE | The cloud zone where to deploy the solution. The available regions and zones for VPC can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc)
VPC | The name of an EXISTING VPC where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST). The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SECURITY_GROUP | The name of an EXISTING Security group. Must be the same as for the primary application server (SAP CI HOST). The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups)
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets)
SSH_KEYS | List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys should be created for the same region as the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys)
HOSTNAME | The Hostname for the VSI. The hostname must be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
PROFILE | The instance profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)
IMAGE | The OS image used for the VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images)
ATR_NAME | The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available [here](https://cloud.ibm.com/observe/activitytracker)

**Obs***: <br />
- **IBM Cloud API Key**  - You will be asked for your IBM Cloud API Key (Sensitive* value), interactively, during `terraform plan` step.

**SAP input parameters:**

```shell
##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# The SAP system ID. Identifies the entire SAP system. 
# The SAP SID must be the same as the one on the primary application server (SAP CI HOST)
# Consists of exactly three alphanumeric characters and the first character must be a letter.
# Does not include any of the reserved IDs listed in SAP Note 1979280

SAP_CI_HOST = "10.241.64.7"
# The IP address of the existing SAP Central Instance VSI
# Example: SAP_CI_HOST = "10.241.64.7"

SAP_CI_HOSTNAME = ""
# The hostname of the existing SAP Central Instance VSI
# Example: SAP_CI_HOSTNAME = "sap-ci-asestd"

SAP_CI_INSTANCE_NUMBER = "00"
# The SAP central instance number. Technical identifier for internal processes of CI.
# Consists of a two-digit number from 00 to 97. 
# Must be unique on a host. Must follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "06"

SAP_ASCS_INSTANCE_NUMBER = "01"
# The central ABAP service instance number. Technical identifier for internal processes of ASCS. 
# Consists of a two-digit number from 00 to 97. 
# Must be unique on a host. Must follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "01"

SAP_AAS_INSTANCE_NUMBER = "00"
# The SAP additional application server instance number. Technical identifier for internal processes of AAS. 
# Consists of a two-digit number from 00 to 97. 
# Must be unique on a host. Must follow the SAP rules for instance number naming
# Example: SAP_AAS_INSTANCE_NUMBER = "00"

##########################################################
# Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75SYB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE =  "/storage/NW75SYB/SWPM10SP31_7-20009701.SAR"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75SYB/SAPHOSTAGENT51_51-20009394.SAR"
```

Parameter | Description | Requirements
----------|-------------|-------------
SAP_SID | The SAP system ID. Identifies the entire SAP system.<br /> _(See Obs.*)_ | Must be the same as the one on the primary application server (SAP CI HOST). Consists of exactly three alphanumeric characters and the first character must be a letter. Does not include any of the reserved IDs listed in SAP Note 1979280
SAP_CI_HOST | The IP address of the existing SAP Central Instance VSI |
SAP_CI_HOSTNAME | The hostname of the existing SAP Central Instance VSI |
SAP_ASCS_INSTANCE_NUMBER | The central ABAP service instance number. Technical identifier for internal processes of ASCS| <ul><li>Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_CI_INSTANCE_NUMBER | The SAP central instance number. Technical identifier for internal processes of CI| <ul><li>Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
SAP_AAS_INSTANCE_NUMBER | The SAP additional application server instance number. Technical identifier for internal processes of the additional application server| <ul><li>Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li><li>Must follow the SAP rules for instance number naming</li></ul>
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SAPCAR_1010-70006178.EXE
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal.<br /> Default: /storage/NW75HDB/SWPM10SP31_7-20009701.SAR
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal. <br /> Default: /storage/NW75HDB/SAPHOSTAGENT51_51-20009394.SAR

**SAP Main Password**
The password for the SAP system will be asked interactively during terraform plan step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation (Sensitive* value).<br /> _(See Obs.*)_ | <ul><li>It must be 10 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It can only contain the following characters: a-z, A-Z, 0-9, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> 

**Obs***: <br />
- The following parameters should have the same values as the ones set for the BASTION server and the primary application server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.
- OS **image** for **SAP APP VSI**. Supported OS images for APP VSIs: ibm-sles-15-3-amd64-sap-applications-9, ibm-sles-15-4-amd64-sap-applications-6, ibm-redhat-8-4-amd64-sap-applications-7, ibm-redhat-8-6-amd64-sap-applications-4. 
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable: APP-IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
- The following SAP **"_SID_"** values are _reserved_ and are _not allowed_ to be used: ADD, ALL, AMD, AND, ANY, ARE, ASC, AUX, AVG, BIT, CDC, COM, CON, DBA, END, EPS, FOR, GET, GID, IBM, INT, KEY, LOG, LPT, MAP, MAX, MIN, MON, NIX, NOT, NUL, OFF, OLD, OMS, OUT, PAD, PRN, RAW, REF, ROW, SAP, SET, SGA, SHG, SID, SQL, SUM, SYS, TMP, TOP, UID, USE, USR, VAR.

### Steps to follow:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY' and 'SAP_MAIN_PASSWORD'
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase: 'IBMCLOUD_API_KEY' and 'SAP_MAIN_PASSWORD'
```

## 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
- [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov)
