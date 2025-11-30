{ inputs, outputs, pkgs, config, username, lib, ... }:
{
    users.users.${username}.packages = with pkgs; [
        grpc-tools
    ];

    environment.sessionVariables = {
        "PROTOBUF_PROTOC" = "${pkgs.grpc-tools}/bin/protoc";
    };
}
