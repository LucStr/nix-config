{pkgs, username, ...}:{
  users.users.${username}.packages = with pkgs; [
    stable.awscli2
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    terraform
    act
    kubectl
    kubernetes-helm
    argocd
    s3fs
    gcsfuse
    kustomize
    stripe-cli
  ];
}
