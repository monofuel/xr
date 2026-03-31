{
  description = "Nim OpenXR development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    {
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            nim
            nimble
            openxr-loader
            xorg.libX11
            xorg.libXext
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            libGL
            libuuid
            vulkan-loader
          ];

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.openxr-loader}/lib:${pkgs.xorg.libX11}/lib:${pkgs.xorg.libXext}/lib:${pkgs.xorg.libXcursor}/lib:${pkgs.xorg.libXrandr}/lib:${pkgs.xorg.libXi}/lib:${pkgs.libGL}/lib:${pkgs.libuuid.lib}/lib:${pkgs.vulkan-loader}/lib:$LD_LIBRARY_PATH
          '';
        };
    };
}
