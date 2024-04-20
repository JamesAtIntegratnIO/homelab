{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            terraform
            tflint
            terraform-docs
            k3sup
            curl
            kubectl
            kubeseal
            kustomize
            kubernetes-helm
            krew
            k0sctl
            clusterctl
            yq
          ];
          shellHook = ''
            set -a
            source ./key.env
            set +a
          '';
        };
      }
    );
}
