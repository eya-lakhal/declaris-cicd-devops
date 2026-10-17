# Exporte la configuration des 4 VM depuis Windows, sans WinSCP.
# Utilise ssh/scp, intégrés à Windows 10/11.
# Usage (PowerShell, dans C:\declaris-devops) :
#   powershell -ExecutionPolicy Bypass -File scripts\export-all-vms.ps1 -User <utilisateur_vm>

param([Parameter(Mandatory = $true)][string]$User)

$vms = [ordered]@{
    "jenkins"   = "192.168.187.132"
    "sonarqube" = "192.168.187.130"
    "nexus"     = "192.168.187.131"
    "elk"       = "192.168.187.129"
}

$root   = Split-Path $PSScriptRoot -Parent
$script = Join-Path $PSScriptRoot "export-vm-configs.sh"
$out    = Join-Path $root "exports"
New-Item -ItemType Directory -Force -Path $out | Out-Null

foreach ($name in $vms.Keys) {
    $ip = $vms[$name]
    Write-Host "`n===== $name ($ip) =====" -ForegroundColor Cyan

    # 1. Envoyer le script
    scp $script "${User}@${ip}:~/export-vm-configs.sh"

    # 2. L'exécuter (le mot de passe sudo sera demandé) et placer l'archive dans /tmp
    # (le joker /root/* doit être développé par root, d'où sudo sh -c ;
    #  l'archive est renommée avec le nom de la VM car les clones ont tous le même hostname)
    ssh -t "${User}@${ip}" "sed -i 's/\r$//' ~/export-vm-configs.sh && sudo bash ~/export-vm-configs.sh && sudo sh -c 'cp /root/export-*.tar.gz /tmp/export-$name.tar.gz && chmod 644 /tmp/export-$name.tar.gz'"

    # 3. Rapatrier l'archive
    scp "${User}@${ip}:/tmp/export-$name.tar.gz" $out
}

Write-Host "`nArchives récupérées dans $out :" -ForegroundColor Green
Get-ChildItem $out
