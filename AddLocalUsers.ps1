# Q.5.7 On importe la fonction log qui s'appelle Functions.psm1
Import-Module "C:\Scripts\Functions.psm1"
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
# Q.5.5 Ne laisser que les champs utiles pour la variable $Users
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
        # Q.5.4 Rajouter la ligne description dans la variable $UserInfo
        # Q.5.11 Modifier PasswordNeverExpires en mettant false au lieu de true
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
            Password             = $Password
	        Description		     = $Description
            AccountNeverExpires  = $True
            PasswordNeverExpires = $False
        }

        New-LocalUser @UserInfo
        # Q.5.10 Ajout de la variable $Name
        Add-LocalGroupMember -Group "Utilisateurs" -Member "$Name"
        # Q.5.6 ecriture de la commande write-host avec l'ajout de la couleur verte dans la réponse
        Write-Host "Le compte $Name a été créé avec le mot de passe $Pass " -ForegroundColor Green.
    }
        # Q.5.9 Ajout du else si jamais l'utilisateur existe deja.
    else
    {
        # Q.5.8 ajout de la journalisation avec Write-Log.
        Write-Log -Message "Le compte $Name existe déjà." -Type "Warning"
        Write-Host "Le compte $Name existe déjà" -ForegroundColor Red
    }
}                                  
