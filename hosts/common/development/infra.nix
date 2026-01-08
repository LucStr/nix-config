{pkgs, username, ...}:{
  users.users.${username}.packages = with pkgs; [
    stable.awscli2
    (stable.google-cloud-sdk.withExtraComponents [stable.google-cloud-sdk.components.gke-gcloud-auth-plugin])
    terraform
    act
    kubectl
    kubernetes-helm
    argocd
    s3fs
    gcsfuse
    kustomize
    stripe-cli
    k9s
    redis
    mongosh
    mongodb-tools
    filezilla
    k6
    openssl
    talosctl
    fluxcd
  ];

  boot.supportedFilesystems = [ "fuse" "ntfs" ];
  # for FUSE3
  boot.kernelModules = [ "fuse" ];
  programs.fuse.userAllowOther = true;
}
