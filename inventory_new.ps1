$yaml = "/root/ansible/hosts.yaml"
$hostnames = "/root/scripts/sethostname/hostnames"
Remove-Item $yaml -ErrorAction SilentlyContinue
Remove-Item $hostnames -ErrorAction SilentlyContinue
$ips = @"
192.168.197.198
192.168.197.199
192.168.197.200
192.168.197.201
"@ -split "`r`n"
$metallbips = @"
192.168.197.202
192.168.197.203
"@ -split "`r`n"
$mastercount = 2
$count = 1
$hosts = foreach ($ip in $ips){
@"
    node$($count):
      ansible_host: $ip
      ip: $ip
      access_ip: $ip
"@
$count = $count + 1
}


$all = @"
all:
  hosts:
"@
$all|Out-File $yaml -Append
$hosts|Out-File $yaml -Append

$children = @"
  children:
    init_master:
      hosts:
"@
$children|Out-File $yaml -Append
$master = 
@"
        node1:
"@        
$master|Out-File $yaml -Append
$master.Replace("node","Master") |Out-File $hostnames -Append
if ($mastercount -gt 1){
$controlplain = @"
    kube_control_plane:
      hosts:
"@
$controlplain|Out-File $yaml -Append
}

if ($mastercount -gt 1){
$controlplains = for ($i = 2; $i -le $mastercount; $i++){ 
@"
        node$($i):
"@ 
}
$controlplains|Out-File $yaml -Append
$controlplains.Replace("node","Master")|Out-File $hostnames -Append
}


$nodes = @"
    kube_node:
      hosts:
"@
$nodes|Out-File $yaml -Append

$nodes = for ($i = $mastercount + 1; $i -le ($ips|measure).Count - $mastercount + $mastercount; $i++){ 
@"
        node$($i):
"@ 
}
$nodes|Out-File $yaml -Append
$nodesforhost = for ($i = 1; $i -le ($nodes|measure).Count; $i++){ 
@"
        node$($i):
"@ 
}
$nodesforhost.Replace("node","Worker")|Out-File $hostnames -Append
(Get-Content $hostnames).Replace(" ","").Replace(":","") | Out-File $hostnames
$ips|Out-File /root/scripts/copysshid/ips
(Get-Content /root/manifests/metallb_addresspool_Template.yaml).Replace("ipvar1","$($metallbips[0])").Replace("ipvar2","$($metallbips[1])") `
|Out-File /root/manifests/metallb_addresspool.yaml
