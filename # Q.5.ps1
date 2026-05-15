# Q.5.7

Function Random-Password
{
    param ([Int]$Length = 8)
    
    $Punc = 46..46
    $Digits = 48..57
    $Letters = 65..90 + 97..122

    $Password = Get-Random -Count $Length -Input ($Punc + $Digits + $Letters) |`
        ForEach -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $Password.ToString()
}


Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

# Q.5.3 Modifier le -Skip 2 en -Skip 1
# Q.5.5 Enlever les headers non utilisé
$Users = Import-Csv -Path $CsvFile -Delimiter ";" `
    -Header "prenom","nom","fonction","description" `
    -Encoding UTF8 | Select-Object -Skip 1

foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.Nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = Random-Password
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.Description) - $($User.Fonction)"
        # Q.5.4 Rajouter la ligne description en dessous de password
        # Q.5.11
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
            Password             = $Password
	    Description		 = $Description
            AccountNeverExpires  = $True
            PasswordNeverExpires = $False
        }

        New-LocalUser @UserInfo
        #Q.5.10
        Add-LocalGroupMember -Group "Utilisateurs" -Member "
}                                                      