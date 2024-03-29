##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

REGION = ""  
# The cloud region where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST)
# The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = ""    
# The cloud zone where to deploy the solution.
# The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

VPC = ""
# The name of an EXISTING VPC where to deploy the solution. Must be the same as for the primary application server (SAP CI HOST)
# The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = ""
# The name of an EXISTING Security group for the same VPC. Must be the same as for the primary application server (SAP CI HOST)
# The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = ""
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "" 
# The name of an EXISTING Subnet in the same VPC and same zone.
# The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [""]
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

ATR_NAME = ""
# The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tr"

##########################################################
# VSI variables:
##########################################################

HOSTNAME = ""
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: "Hostnames of SAP ABAP Platform servers".
# Example: DB-HOSTNAME = "ic4sapsys"

PROFILE = "bx2-4x16"
# The instance profile used for the VSI. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211
# The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images

##########################################################
# SAP system configuration
##########################################################

SAP_SID = "NWD"
# The SAP system ID. Identifies the entire SAP system. 
# The SAP SID must be the same as the one on the primary application server (SAP CI HOST)
# Consists of exactly three alphanumeric characters and the first character must be a letter.
# Does not include any of the reserved IDs listed in SAP Note 1979280

SAP_CI_HOST = ""
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
