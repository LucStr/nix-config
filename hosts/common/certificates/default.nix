{ config, pkgs, ... }:
{
  environment.etc."ssl/certs/ca-certificates.crt".enable = false;

  system.activationScripts.custom-ca-bundle = {
    text = ''
      # Setup CA certificates for linux trust store
      mkdir -p /etc/ssl/certs
      cp -f "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" /etc/ssl/certs/ca-certificates.crt
      chmod 644 /etc/ssl/certs/ca-certificates.crt
      cat "${config.sops.secrets."development_root_ca".path}" >> /etc/ssl/certs/ca-certificates.crt
      cat "${config.sops.secrets."trusted_certificates".path}" >> /etc/ssl/certs/ca-certificates.crt

      mkdir -p /var/lib/mkcert
      rm /var/lib/mkcert/rootCA.pem
      rm /var/lib/mkcert/rootCA-key.pem
      ln -s "${config.sops.secrets."development_root_ca".path}" /var/lib/mkcert/rootCA.pem
      ln -s "${config.sops.secrets."development_root_ca_key".path}" /var/lib/mkcert/rootCA-key.pem
    '';
    deps = [ "setupSecrets" ];
  };

  environment.sessionVariables = rec {
    CAROOT = "/var/lib/mkcert";
  };

  environment.systemPackages = with pkgs; [
    mkcert
    nssTools
  ];
}
