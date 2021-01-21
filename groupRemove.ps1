 #задается список оушек(организационных единиц в домене)

$OUs = 'OU=Disabled_Users,DC=action-crm,DC=local'

#дергаем из списка оушек всех отключенных пользователей

$users = $OUs | % {Get-ADUser -Filter {Enabled -eq $FALSE} -SearchBase $PSItem}

#для каждого пользователя из списка

foreach ($user in $users)
{
#проверяем если в имени пользователя есть последовательность *_*адм* то пользователя игнорируем

  if ($user.SamAccountName -like "*_*adm*") {Continue}

#иначе получаем список всех секурити груп(игнорируем дестрибушен группы(списки рассылок))

    $Groups = Get-ADPrincipalGroupMembership -Identity $user| ? {$_.GroupCategory -eq "Security"}
#если у пользователя нашлась всего одна группа(не важно какая) пользователя игнорируем
    if (($Groups |measure ).count -eq "1") {Continue}
#иначе для каждой группы пользователя
    foreach ($group in $groups)
    {

# задаем в переменную групнейм имя текущей группы

        $GroupName = $Group.Name  

# если имя текущей группы не доменные пользователи

        if ($GroupName -like "*Domain Users*") {Continue} 

#пишем красненьким по буржуйски что удаляем группу у пользователя

        Write-Host "Removing $user from $GroupName" -ForegroundColor Red

#собственно удаляем

        Remove-ADGroupMember -Identity $GroupName -Member $user -Confirm:$FALSE
    }
}