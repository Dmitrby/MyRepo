cls
$OUN = "OU=Test1,OU=Employees,DC=moskvich,DC=ru"

# check OU function
function global:OUsearch{
param([string]$inString)
if([bool] (Get-ADOrganizationalUnit -Filter * | ? {$_.Distinguishedname -eq $inString} ))
{ return 1  }
else { return 0 } 
}#end function global:OUsearch

# create OU function
function global:Create{
    param([string]$OUName)
        $create = $searh  = "OU=Employees,DC=moskvich,DC=ru" # начальная OU для создания ерархии
            if (OUsearch($OUName) -eq 1) {return "earli created"} 
                else {$path1 = $OUName.split(",")
                      $i =$path1.count -4  #так как с 0 нужно отнять 4 (3 элемента)
                      $count =0
                        while($i -ge $count)
                            {$result=$path1[$i]
                                $searh = "$result"+",$searh"
                                $text=$result.trim("OU=")
                               if (OUsearch($searh) -eq 1) {} else {New-ADOrganizationalUnit -name "$text" -Path "$create"}
                                $create= "$result"+",$create"
                                $i -=1
                        }# end while
                }#end if
}#end function global:Create

create $OUN
