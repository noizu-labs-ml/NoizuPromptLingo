# Longhorn node prerequisites for NixOS
# =============================================================================
# Reference module — the actual node configs live OUTSIDE this repo (the NixOS
# host/flake repo). Import this into every node that should run Longhorn:
#
#     # configuration.nix / a host module
#     imports = [ ./longhorn-node.nix ];
#
# Then rebuild and switch on each node:
#
#     sudo nixos-rebuild switch         # (or `colmena apply` / `deploy` per your tooling)
#
# Why this is needed
# ------------------
# Longhorn 1.12 attaches volumes over iSCSI and runs share-manager (RWX) over
# NFS, execing host binaries (iscsiadm, mount.nfs) via `nsenter` into PID 1's
# mount namespace. A stock NixOS node has neither iscsid nor nfs client tooling,
# so longhorn-manager crash-loops and its :9502 readiness probe is refused —
# exactly what we saw on the k8s-mvm-* members while noizu-server (which already
# had iSCSI) ran fine.

{ config, pkgs, lib, ... }:

{
  # iSCSI initiator. Enabling this installs open-iscsi, starts iscsid, and puts
  # `iscsiadm` on the host PATH where Longhorn's nsenter calls expect it. The
  # initiator name must be unique per node.
  services.openiscsi = {
    enable = true;
    name   = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
  };

  # NFS client support for Longhorn RWX (share-manager) volumes.
  boot.supportedFilesystems = [ "nfs" ];
  environment.systemPackages = [ pkgs.nfs-utils ];

  # Kernel modules Longhorn relies on (load at boot rather than on-demand).
  boot.kernelModules = [ "iscsi_tcp" "nfs" "dm_crypt" ];

  # Replica data path — must match defaultSettings.defaultDataPath in
  # longhorn.tf (/var/lib/longhorn). Ensure it exists with sane perms.
  systemd.tmpfiles.rules = [ "d /var/lib/longhorn 0755 root root - -" ];
}
