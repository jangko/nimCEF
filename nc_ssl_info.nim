import cef/cef_ssl_info_api, cef/cef_string_list_api, cef/cef_time_api
import nc_util, nc_types, nc_value

type
  # Structure representing the issuer or subject field of an X.509 certificate.
  NCSslCertPrincipal* = ptr cef_sslcert_principal

  # Structure representing SSL information.
  NCSslInfo* = ptr cef_sslinfo


# Returns a name that can be used to represent the issuer.  It tries in this
# order: CN, O and OU and returns the first non-NULL one found.
# The resulting string must be freed by calling string_free().
proc GetDisplayName*(self: NCSslCertPrincipal): string =
  result = to_nim(self.get_display_name(self))

# Returns the common name.
# The resulting string must be freed by calling string_free().
proc GetCommonName*(self: NCSslCertPrincipal): string =
  result = to_nim(self.get_common_name(self))

# Returns the locality name.
# The resulting string must be freed by calling string_free().
proc GetLocalityName*(self: NCSslCertPrincipal): string =
  result = to_nim(self.get_locality_name(self))

# Returns the state or province name.
# The resulting string must be freed by calling string_free().
proc GetStateOrProvinceName*(self: NCSslCertPrincipal): string =
  result = to_nim(self.get_state_or_province_name(self))

# Returns the country name.
# The resulting string must be freed by calling string_free().
proc GetCountryName*(self: NCSslCertPrincipal): string =
  result = to_nim(self.get_country_name(self))

# Retrieve the list of street addresses.
proc GetStreetAddresses*(self: NCSslCertPrincipal): seq[string] =
  var clist = cef_string_list_alloc()
  self.get_street_addresses(self, clist)
  result = to_nim(clist)

# Retrieve the list of organization names.
proc GetOrganizationNames*(self: NCSslCertPrincipal): seq[string] =
  var clist = cef_string_list_alloc()
  self.get_organization_names(self, clist)
  result = to_nim(clist)

# Retrieve the list of organization unit names.
proc GetOrganizationUnitNames*(self: NCSslCertPrincipal): seq[string] =
  var clist = cef_string_list_alloc()
  self.get_organization_unit_names(self, clist)
  result = to_nim(clist)

# Retrieve the list of domain components.
proc GetDomainComponents*(self: NCSslCertPrincipal): seq[string] =
  var clist = cef_string_list_alloc()
  self.get_domain_components(self, clist)
  result = to_nim(clist)

# Returns a bitmask containing any and all problems verifying the server
# certificate.
proc GetCertStatus*(self: NCSslInfo): cef_cert_status =
  result = self.get_cert_status(self)

# Returns true (1) if the certificate status has any error, major or minor.
proc IsCertStatusError*(self: NCSslInfo): bool =
  result = self.is_cert_status_error(self) == 1.cint

# Returns true (1) if the certificate status represents only minor errors
# (e.g. failure to verify certificate revocation).
proc IsCertStatusMinorError*(self: NCSslInfo): bool =
  result = self.is_cert_status_minor_error(self) == 1.cint

# Returns the subject of the X.509 certificate. For HTTPS server certificates
# this represents the web server.  The common name of the subject should
# match the host name of the web server.
proc GetSubject*(self: NCSslInfo): NCSslCertPrincipal =
  result = self.get_subject(self)

# Returns the issuer of the X.509 certificate.
proc GetIssuer*(self: NCSslInfo): NCSslCertPrincipal =
  result = self.get_issuer(self)

# Returns the DER encoded serial number for the X.509 certificate. The value
# possibly includes a leading 00 byte.
proc GetSerialNumber*(self: NCSslInfo): NCBinaryValue =
  result = self.get_serial_number(self)

# Returns the date before which the X.509 certificate is invalid.
# CefTime.GetTimeT() will return 0 if no date was specified.
proc GetValidStart*(self: NCSslInfo): cef_time =
  result = self.get_valid_start(self)

# Returns the date after which the X.509 certificate is invalid.
# CefTime.GetTimeT() will return 0 if no date was specified.
proc GetValidExpiry*(self: NCSslInfo): cef_time =
  result = self.get_valid_expiry(self)

# Returns the DER encoded data for the X.509 certificate.
proc GetDerencoded*(self: NCSslInfo): NCBinaryValue =
  result = self.get_derencoded(self)

# Returns the PEM encoded data for the X.509 certificate.
proc GetPemencoded*(self: NCSslInfo): NCBinaryValue =
  result = self.get_pemencoded(self)

# Returns the number of certificates in the issuer chain. If 0, the
# certificate is self-signed.
proc GetIssuerChainSize*(self: NCSslInfo): int =
  result = self.get_issuer_chain_size(self).int

# Returns the DER encoded data for the certificate issuer chain. If we failed
# to encode a certificate in the chain it is still present in the array but
# is an NULL string.
proc GetDerencodedIssuerChain*(self: NCSslInfo): seq[NCBinaryValue] =
  var size = self.get_issuer_chain_size(self)
  result = newSeq[NCBinaryValue](size.int)
  self.get_derencoded_issuer_chain(self, size, result[0].addr)

# Returns the PEM encoded data for the certificate issuer chain. If we failed
# to encode a certificate in the chain it is still present in the array but
# is an NULL string.
proc GetPemencodedIssuerChain*(self: NCSslInfo): seq[NCBinaryValue] =
  var size = self.get_issuer_chain_size(self)
  result = newSeq[NCBinaryValue](size.int)
  self.get_pemencoded_issuer_chain(self, size, result[0].addr)