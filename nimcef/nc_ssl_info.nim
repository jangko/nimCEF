import nc_util, nc_types, nc_value, nc_time

# Structure representing SSL information.
wrapAPI(NCSslInfo, cef_sslinfo)

# Structure representing the issuer or subject field of an X.509 certificate.
wrapAPI(NCSslCertPrincipal, cef_sslcert_principal, false)

# Returns a name that can be used to represent the issuer.  It tries in this
# order: CN, O and OU and returns the first non-NULL one found.
proc getDisplayName*(self: NCSslCertPrincipal): string =
  self.wrapCall(get_display_name, result)

# Returns the common name.
proc getCommonName*(self: NCSslCertPrincipal): string =
  self.wrapCall(get_common_name, result)

# Returns the locality name.
proc getLocalityName*(self: NCSslCertPrincipal): string =
  self.wrapCall(get_locality_name, result)

# Returns the state or province name.
proc getStateOrProvinceName*(self: NCSslCertPrincipal): string =
  self.wrapCall(get_state_or_province_name, result)

# Returns the country name.
proc getCountryName*(self: NCSslCertPrincipal): string =
  self.wrapCall(get_country_name, result)

# Retrieve the list of street addresses.
proc getStreetAddresses*(self: NCSslCertPrincipal): seq[string] =
  self.wrapCall(get_street_addresses, result)

# Retrieve the list of organization names.
proc getOrganizationNames*(self: NCSslCertPrincipal): seq[string] =
  self.wrapCall(get_organization_names, result)

# Retrieve the list of organization unit names.
proc getOrganizationUnitNames*(self: NCSslCertPrincipal): seq[string] =
  self.wrapCall(get_organization_unit_names, result)

# Retrieve the list of domain components.
proc getDomainComponents*(self: NCSslCertPrincipal): seq[string] =
  self.wrapCall(get_domain_components, result)

# Returns a bitmask containing any and all problems verifying the server
# certificate.
proc getCertStatus*(self: NCSslInfo): cef_cert_status =
  self.wrapCall(get_cert_status, result)

# Returns true (1) if the certificate status has any error, major or minor.
proc isCertStatusError*(self: NCSslInfo): bool =
  self.wrapCall(is_cert_status_error, result)

# Returns true (1) if the certificate status represents only minor errors
# (e.g. failure to verify certificate revocation).
proc isCertStatusMinorError*(self: NCSslInfo): bool =
  self.wrapCall(is_cert_status_minor_error, result)

# Returns the subject of the X.509 certificate. For HTTPS server certificates
# this represents the web server.  The common name of the subject should
# match the host name of the web server.
proc getSubject*(self: NCSslInfo): NCSslCertPrincipal =
  self.wrapCall(get_subject, result)

# Returns the issuer of the X.509 certificate.
proc getIssuer*(self: NCSslInfo): NCSslCertPrincipal =
  self.wrapCall(get_issuer, result)

# Returns the DER encoded serial number for the X.509 certificate. The value
# possibly includes a leading 00 byte.
proc getSerialNumber*(self: NCSslInfo): NCBinaryValue =
  self.wrapCall(get_serial_number, result)

# Returns the date before which the X.509 certificate is invalid.
# CefTime.GetTimeT() will return 0 if no date was specified.
proc getValidStart*(self: NCSslInfo): NCTime =
  self.wrapCall(get_valid_start, result)

# Returns the date after which the X.509 certificate is invalid.
# CefTime.GetTimeT() will return 0 if no date was specified.
proc getValidExpiry*(self: NCSslInfo): NCTime =
  self.wrapCall(get_valid_expiry, result)

# Returns the DER encoded data for the X.509 certificate.
proc getDERencoded*(self: NCSslInfo): NCBinaryValue =
  self.wrapCall(get_derencoded, result)

# Returns the PEM encoded data for the X.509 certificate.
proc getPEMencoded*(self: NCSslInfo): NCBinaryValue =
  self.wrapCall(get_pemencoded, result)

# Returns the number of certificates in the issuer chain. If 0, the
# certificate is self-signed.
proc getIssuerChainSize*(self: NCSslInfo): int =
  self.wrapCall(get_issuer_chain_size, result)

# Returns the DER encoded data for the certificate issuer chain. If we failed
# to encode a certificate in the chain it is still present in the array but
# is an NULL string.
proc getDERencodedIssuerChain*(self: NCSslInfo): seq[NCBinaryValue] =
  var size = self.getIssuerChainSize()
  self.wrapCall(get_derencoded_issuer_chain, result, size)

# Returns the PEM encoded data for the certificate issuer chain. If we failed
# to encode a certificate in the chain it is still present in the array but
# is an NULL string.
proc getPEMencodedIssuerChain*(self: NCSslInfo): seq[NCBinaryValue] =
  var size = self.getIssuerChainSize()
  self.wrapCall(get_pemencoded_issuer_chain, result, size)