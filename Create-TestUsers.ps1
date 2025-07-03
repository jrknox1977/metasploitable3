# Create-TestUsers.ps1
# Creates 30 random test users for Windows Server 2019

$firstNames = @("John", "Jane", "Mike", "Sarah", "Tom", "Lisa", "Bob", "Alice", "David", "Emma", 
                "James", "Mary", "Robert", "Patricia", "Michael", "Jennifer", "William", "Linda",
                "Richard", "Barbara", "Joseph", "Susan", "Thomas", "Jessica", "Charles", "Karen",
                "Chris", "Nancy", "Daniel", "Betty")

$lastNames = @("Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
               "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
               "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
               "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson")

Write-Host "Creating 30 test users..." -ForegroundColor Yellow

for ($i = 1; $i -le 30; $i++) {
    $firstName = $firstNames | Get-Random
    $lastName = $lastNames | Get-Random
    $username = "$firstName.$lastName".ToLower()
    $fullName = "$firstName $lastName"
    
    # Simple password pattern: FirstnameLastname123!
    $password = "$firstName$lastName$(Get-Random -Minimum 100 -Maximum 999)!"
    
    try {
        # Create the user
        net user $username $password /add /fullname:"$fullName" /comment:"Test User $i" 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[+] Created user: $username (Password: $password)" -ForegroundColor Green
        } else {
            # If username exists, try with a number
            $username = "$username$(Get-Random -Minimum 1 -Maximum 99)"
            net user $username $password /add /fullname:"$fullName" /comment:"Test User $i" 2>$null
            Write-Host "[+] Created user: $username (Password: $password)" -ForegroundColor Green
        }
        
        # Add some variety - make a few users have passwords that never expire
        if ($i % 5 -eq 0) {
            wmic useraccount where name="$username" set PasswordExpires=false 2>$null
        }
        
    } catch {
        Write-Host "[-] Failed to create user: $username" -ForegroundColor Red
    }
}

Write-Host "`nUser creation complete!" -ForegroundColor Green
Write-Host "Created 30 test users with passwords in format: FirstnameLastname###!" -ForegroundColor Yellow