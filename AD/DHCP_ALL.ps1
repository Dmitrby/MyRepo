
$ServerName = "dc01.amedia.loc"
$checkDHCP = Get-DHCPServerv4Scope -ComputerName $ServerName |
    ForEach {$SubnetMasK = $_.SubnetMasK; $_ | Get-DHCPServerv4Lease -AllLeases |
    Select HostName,@{N='SubnetMasK';E={$SubnetMasK}},ScopeId,IPAddress,AddressState}
