{ pkgs, ... }: {
  boot.kernelParams = [ "intel_iommu=on" ];

  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      extraPackages = with pkgs; [
        libva-full
        intel-media-driver
        intel-compute-runtime
      ];
    };
  };

  services.xserver.useGlamor = true;
}
