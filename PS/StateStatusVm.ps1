$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Param ([Parameter(Position=0, Mandatory=$False)][string]$action,
       [Parameter(Position=1, Mandatory=$False)][int]$Parameter
      )


Switch($action)
{
  
"Status" {

            $Status = get-vm -Name $Parameter | foreach {$_.Status}
            IF ($Status -eq "Running") {write-host 1} else {write-host 0}
                       
        }

"State" {
            $State = get-vm -Name $Parameter | foreach {$_.State}
            IF ($State -eq "Operating normally") {write-host 1} else {write-host 0}
                                  
        }

}
exit