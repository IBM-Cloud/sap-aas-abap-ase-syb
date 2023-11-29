variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "Path to sapcar binary, as downloaded from SAP Support Portal"
    validation {
    condition = fileexists("${var.KIT_SAPCAR_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "Path to SWPM archive (SAR), as downloaded from SAP Support Portal"
    validation {
    condition = fileexists("${var.KIT_SWPM_FILE}") == true
    error_message = "The PATH does not exist."
    }
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "Path to SAP Host Agent archive (SAR), as downloaded from SAP Support Portal"
    validation {
    condition = fileexists("${var.KIT_SAPHOSTAGENT_FILE}") == true
    error_message = "The PATH does not exist."
    }
}
