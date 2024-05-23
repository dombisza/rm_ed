terraform {
  required_version = ">=v1.4.6"
  backend "s3" {
    endpoint                    = "obs.eu-de.otc.t-systems.com"
    bucket                      = "rmed-tfstate"
    key                         = "tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    region                      = "eu-de"
  }

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">=1.35.6"
    }
  }
}
