#!/usr/bin/env bash
# Agrandit la partition racine LVM après avoir augmenté le disque dans VMware.
# Prérequis : VM éteinte → VMware > Settings > Hard Disk > Expand, puis redémarrer.
# Usage : sudo bash extend-disk-lvm.sh [disque] [num_partition]   (défaut : /dev/sda 2)
set -euo pipefail

DISK="${1:-/dev/sda}"
PART="${2:-2}"

echo "== Avant =="; lsblk; df -h /

dnf install -y cloud-utils-growpart >/dev/null
growpart "$DISK" "$PART" || echo "(partition déjà à la taille maximale)"
pvresize "${DISK}${PART}"

LV=$(findmnt -n -o SOURCE /)          # ex. /dev/mapper/rhel-root
lvextend -l +100%FREE "$LV"
xfs_growfs /

echo "== Après =="; df -h /
