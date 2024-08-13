# Define the API credentials
$tokenUrl = "-"
$baseUrl = "-"
$client_id = "-"
$secret = "-"

# Import the CSV file
$csvPath = "PATH"
$users = Import-Csv -Path $csvPath

# Step 1. Create a client_id:secret pair
$credPair = "$($client_id):$($secret)"
# Step 2. Encode the pair to Base64 string
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
# Step 3. Form the header and add the Authorization attribute to it
$headersCred = @{ Authorization = "Basic $encodedCredentials" }
# Step 4. Make the request and get the token
$responsetoken = Invoke-RestMethod -Uri "$tokenUrl" -Method Post -Body "grant_type=client_credentials" -Headers $headersCred
$token = $responsetoken.access_token
$headersToken = @{ Authorization = "Bearer $token" }
# Step 5. Prepare the header for future request
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")
$headers.Add("Authorization", "Bearer $token")
#endregion
###########################################################################



# Iterate through each row in the CSV file and create users
foreach ($user in $users) {

    # Map CSV columns to variables
    $PDS_var = $user.Name
    $username_var = $user.Username
    $enabled_var = if ($user.Enabled -eq $null) { $true } else { [bool]$user.Enabled }
    $expires_var = $user.Expires
    $email_var = $user.Email
    $password_var = if ($user.Password -eq $null) { "Qwer123$" } else { $user.Password }

    # Construct the JSON body for the request
    $UserCreateBody = @{
        "public_display_name"= "$PDS_var"
        "username"= "$username_var"
        "password"= "$password_var"
        "email_address"= "$email_var"
        "two_factor_required"= $true
        "enabled"= $enabled_var
        "password_reset_next_login"= $true
    } | ConvertTo-Json

    # Print the JSON body
    Write-Output "JSON Body for user ${PDS_var}:"
    Write-Output $UserCreateBody

    # Construct the full URL for the user creation request
    $UserCreateURL = "$baseUrl/user"

    # Invoke the REST method to create a user
    try {
        $UserCreateResponse = Invoke-RestMethod -Uri $UserCreateURL -Method Post -Headers $headers -Body $UserCreateBody

        # Output the response
        Write-Output "New user created with ID:"
        $UserCreateResponse.id

    } catch {
        # Catch and output any errors
        Write-Error "Error occurred: $_"
    }
}
