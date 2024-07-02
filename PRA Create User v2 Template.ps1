# Define the API credentials
$tokenUrl = "-"
$baseUrl = "-"
$client_id = "-"
$secret = "-"

#endregion creds
###########################################################################

#region Authent 
###########################################################################

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

####Create a User####
# Construct the JSON body for the request



$PDS_var = Read-Host -Prompt "Enter the public display name that you want to give your new user:"
$password_var = "Qwer123$"
$email_var = "test.email@email.com"

$UserCreateBody = @{
  "public_display_name"= "$PDS_var"
  "username"= "$PDS_var"
  "password"= "$password_var"
  "email_address"= "$email_var"
  "two_factor_required"= $true
  "enabled"= $true
  "password_reset_next_login"= $true
  "perm_access_allowed"= "full_support"
  "perm_share_other_team"= $true
  "perm_invite_external_user"= $false
  "perm_extended_availability_mode_allowed"= $false
  "perm_session_idle_timeout"= -1
  "perm_collaborate"= $false
  "perm_collaborate_control"= $false
  "perm_jump_client"= $true
  "perm_local_jump"= $true
  "perm_remote_jump"= $true
  "perm_remote_vnc"= $true
  "perm_remote_rdp"= $true
  "perm_shell_jump"= $true
  "default_jump_item_role_id"= 1
  "private_jump_item_role_id"= 1
  "inferior_jump_item_role_id"= 1
  "unassigned_jump_item_role_id"= 1
  "perm_web_jump"= $true
  "perm_protocol_tunnel"= $true
  "perm_vault"= $true
} | ConvertTo-Json


# Construct the full URL for the group policy request
$UserCreateURL = "$baseUrl/user"



# Invoke the REST method to create a Group Policy
try {
    $UserCreateResponse = Invoke-RestMethod -Uri $UserCreateURL -Method Post -Headers $headers -Body $UserCreateBody


    # Output the response
    Write-Output "New user ID:"
    $UserCreateResponse.id


} catch {
    # Catch and output any errors
    Write-Error "Error occurred: $_"
}