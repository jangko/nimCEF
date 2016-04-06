import cef_base, cef_values, cef_time
include cef_import

type
  # Structure representing the issuer or subject field of an X.509 certificate.
  cef_sslcert_principal* = object
    base*: cef_base

    # Returns a name that can be used to represent the issuer.  It tries in this
    # order: CN, O and OU and returns the first non-NULL one found.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_display_name*: proc(self: ptr cef_sslcert_principal): cef_string_userfree {.cef_callback.}
    
    # Returns the common name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_common_name*: proc(self: ptr cef_sslcert_principal): cef_string_userfree {.cef_callback.}
    
    # Returns the locality name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_locality_name*: proc(self: ptr cef_sslcert_principal): cef_string_userfree {.cef_callback.}
    
    # Returns the state or province name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_state_or_province_name*: proc(self: ptr cef_sslcert_principal): cef_string_userfree {.cef_callback.}
    
    # Returns the country name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_country_name*: proc(self: ptr cef_sslcert_principal): cef_string_userfree {.cef_callback.}
    
    # Retrieve the list of street addresses.
    get_street_addresses*: proc(self: ptr cef_sslcert_principal, addresses: cef_string_list) {.cef_callback.}
    
    # Retrieve the list of organization names.
    get_organization_names*: proc(self: ptr cef_sslcert_principal, names: cef_string_list) {.cef_callback.}
    
    # Retrieve the list of organization unit names.
    get_organization_unit_names*: proc(self: ptr cef_sslcert_principal, names: cef_string_list) {.cef_callback.}
    
    # Retrieve the list of domain components.
    get_domain_components*: proc(self: ptr cef_sslcert_principal, components: cef_string_list) {.cef_callback.}
    
  # Structure representing SSL information.
  cef_sslinfo* = object
    # Base structure.
    base*: cef_base
    
    # Returns a bitmask containing any and all problems verifying the server
    # certificate.
    get_cert_status*: proc(self: ptr cef_sslinfo): cef_cert_status {.cef_callback.}
    
    # Returns true (1) if the certificate status has any error, major or minor.
    is_cert_status_error*: proc(self: ptr cef_sslinfo): int {.cef_callback.}
    
    # Returns true (1) if the certificate status represents only minor errors
    # (e.g. failure to verify certificate revocation).
    is_cert_status_minor_error*: proc(self: ptr cef_sslinfo): int {.cef_callback.}
    
    # Returns the subject of the X.509 certificate. For HTTPS server certificates
    # this represents the web server.  The common name of the subject should
    # match the host name of the web server.
    get_subject*: proc(self: ptr cef_sslinfo): ptr cef_sslcert_principal {.cef_callback.}
    
    # Returns the issuer of the X.509 certificate.
    get_issuer*: proc(self: ptr cef_sslinfo): ptr cef_sslcert_principal {.cef_callback.}
    
    # Returns the DER encoded serial number for the X.509 certificate. The value
    # possibly includes a leading 00 byte.
    get_serial_number*: proc(self: ptr cef_sslinfo): ptr cef_binary_value {.cef_callback.}
    
    # Returns the date before which the X.509 certificate is invalid.
    # CefTime.GetTimeT() will return 0 if no date was specified.
    get_valid_start*: proc(self: ptr cef_sslinfo): cef_time {.cef_callback.}
    
    # Returns the date after which the X.509 certificate is invalid.
    # CefTime.GetTimeT() will return 0 if no date was specified.
    get_valid_expiry*: proc(self: ptr cef_sslinfo): cef_time {.cef_callback.}
    
    # Returns the DER encoded data for the X.509 certificate.
    get_derencoded*: proc(self: ptr cef_sslinfo): ptr cef_binary_value {.cef_callback.}
    
    # Returns the PEM encoded data for the X.509 certificate.
    get_pemencoded*: proc(self: ptr cef_sslinfo): ptr cef_binary_value {.cef_callback.}
    
    # Returns the number of certificates in the issuer chain. If 0, the
    # certificate is self-signed.
    get_issuer_chain_size*: proc(self: ptr cef_sslinfo): csize {.cef_callback.}
    
    # Returns the DER encoded data for the certificate issuer chain. If we failed
    # to encode a certificate in the chain it is still present in the array but
    # is an NULL string.
    get_derencoded_issuer_chain*: proc(self: ptr cef_sslinfo,
      chainCount: var csize, chain: ptr ptr cef_binary_value) {.cef_callback.}
    
    # Returns the PEM encoded data for the certificate issuer chain. If we failed
    # to encode a certificate in the chain it is still present in the array but
    # is an NULL string.
    get_pemencoded_issuer_chain*: proc(self: ptr cef_sslinfo,
      chainCount: var csize, chain: ptr ptr cef_binary_value) {.cef_callback.}