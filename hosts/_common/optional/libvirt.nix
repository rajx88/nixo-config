{...}: {
  # KVM/QEMU hypervisor via libvirt (native Linux virtualization).
  # Requires boot.kernelModules = ["kvm-intel"] (already set in hardware-configuration.nix).
  virtualisation.libvirtd.enable = true;

  # GUI frontend; wires dconf to qemu:///system.
  # polkit rule from the libvirtd module grants the `libvirtd` group passwordless access.
  programs.virt-manager.enable = true;
}
