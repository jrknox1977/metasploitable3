# Randomize-UserPasswords.ps1
# Changes user passwords to weak, random passwords for security testing
# WARNING: This creates intentionally weak passwords for pentesting scenarios

$weakPasswords = @(
    "password", "123456", "password123", "12345678", "qwerty", "abc123", "monkey", "1234567",
    "letmein", "trustno1", "dragon", "baseball", "111111", "iloveyou", "master", "sunshine",
    "ashley", "bailey", "passw0rd", "shadow", "123123", "654321", "superman", "qazwsx",
    "michael", "football", "welcome", "jesus", "ninja", "mustang", "password1", "123456789",
    "adobe123", "admin", "1234567890", "photoshop", "1234", "pussy", "12345", "princess",
    "azerty", "000000", "access", "696969", "batman", "1qaz2wsx", "login", "qwertyuiop"
)

$simplePatterns = @(
    "Spring2019", "Summer2019", "Fall2019", "Winter2019", "Spring2020", "Summer2020", 
    "Fall2020", "Winter2020", "January1", "February2", "March3", "April4", "May5", 
    "June6", "July7", "August8", "September9", "October10", "November11", "December12",
    "Monday1", "Tuesday2", "Wednesday3", "Thursday4", "Friday5", "Saturday6", "Sunday7",
    "Passw0rd", "P@ssw0rd", "Pa55word", "P@55w0rd", "Pas5word", "Pa55w0rd"
)

Write-Host "============================================" -ForegroundColor Red
Write-Host "WARNING: Setting WEAK passwords for testing!" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red

# Get all local users except built-in accounts
$users = Get-LocalUser | Where-Object { 
    $_.Name -notin @("Administrator", "Guest", "DefaultAccount", "WDAGUtilityAccount") -and
    $_.Enabled -eq $true
}

Write-Host "`nChanging passwords for $($users.Count) users..." -ForegroundColor Yellow

$passwordList = @()

foreach ($user in $users) {
    # Mix of completely weak and pattern-based passwords
    if ((Get-Random -Maximum 100) -lt 60) {
        # 60% get common weak passwords
        $newPassword = $weakPasswords | Get-Random
    } else {
        # 40% get pattern-based passwords
        $newPassword = $simplePatterns | Get-Random
    }
    
    # Some users get their username as password
    if ((Get-Random -Maximum 100) -lt 15) {
        $newPassword = $user.Name
    }
    
    # Some get username with simple additions
    if ((Get-Random -Maximum 100) -lt 15) {
        $additions = @("123", "!", "2019", "2020", "@123", "1!", "pwd", "temp")
        $newPassword = $user.Name + ($additions | Get-Random)
    }
    
    try {
        net user $user.Name $newPassword 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[+] Changed password for $($user.Name) to: $newPassword" -ForegroundColor Green
            $passwordList += "$($user.Name):$newPassword"
        } else {
            Write-Host "[-] Failed to change password for $($user.Name)" -ForegroundColor Red
        }
    } catch {
        Write-Host "[-] Error changing password for $($user.Name): $_" -ForegroundColor Red
    }
}

# Save passwords to file for reference
$passwordList | Out-File "C:\weak-passwords.txt"

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "Password changes complete!" -ForegroundColor Green
Write-Host "Passwords saved to: C:\weak-passwords.txt" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Green