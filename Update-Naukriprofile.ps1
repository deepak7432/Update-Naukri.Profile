#Update naukri Profile Daily Time Stam by - Deepak Raghuwanshi
#use Task Scheduler or job Sceduler to Schedule it Daily

[CmdletBinding()] 
Param 
( 
[ Parameter (Mandatory = $false, Position = 0 ) ] $WebDriverdll = "C:\Selenium\WebDriver.dll",
[ Parameter (Mandatory = $false, Position = 1 ) ] $Username = "raghuwanshideepak79.dr@gmail.com",
[ Parameter (Mandatory = $false, Position = 2 ) ] $password = "C:\Users\siris\Desktop\Some\Selenium\Update Naukri Profile\Secret.Credential",
[ Parameter (Mandatory = $false, Position = 3 ) ] $LogFile = "C:\Users\siris\Desktop\Some\Selenium\Update Naukri Profile\NaukriUpdateLogs.txt",
[ Parameter (Mandatory = $false, Position = 4 ) ] $ResumePath = "C:\Users\siris\Desktop\Some\Selenium\Update Naukri Profile\Resume\Deepak Raghuwanshi.pdf"

)

Try{

if(!$WebDriverdll -or !$Username -or !$password -or !$LogFile -or !$ResumePath ){
    Throw "Input Values not Correct `n 1. WebDriverdll - $WebDriverdll, `n 2. Username - $Username `n 3. password - $password, `n 4. LogFile - $LogFile, `n 5. ResumePath - $ResumePath."    
}

$ErrorActionPreference = "Stop"

Write-Logs -LogLine "Starting Update Naukri Script"

Import-Module "$WebDriverdll" -ErrorAction Stop

#region Function

Function Write-logs {
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] [string]$LogLine,
    [ Parameter (Mandatory = $false, Position = 1 ) ] $LogFilepath = $LogFile
  )

  Add-content $LogFilepath -value $($("[{0:dd-MM-yy} {0:HH:mm:ss}]" -f (Get-Date))+" $LogLine `n") -ErrorAction Stop

}

Function Create-Instance {
  
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $false, Position = 0 ) ] [Bool] $IsChrome = $false,
    [ Parameter (Mandatory = $false, Position = 1 ) ] [int]$WaitTimeinSec = 5,
    [switch] $Help
  )

  if($Help)
  {
    Write-Output "Function to Load the Web Driver Instance, Set IsChrome param -eq $true for Chrome, Default is Edge Driver. `n 1. Edge >> Create-Instance, `n 2. Chrome >> Create-Instance -IsChrome $true"
    return $Help
  }


  if($Name)
  {
    #Load Chrome Driver
    $Instance = New-Object OpenQA.Selenium.Chrome.ChromeDriver -ErrorAction Stop;
    
  }
  else
  {
    $Instance = New-Object OpenQA.Selenium.Edge.EdgeDriver -ErrorAction Stop;      
    
  }
  
  #Set the Wait for the Element to load, Before throwing Exception
  $Instance.Manage().Timeouts().ImplicitWait = (New-TimeSpan -Hours 0 -Minutes 0 -Seconds $WaitTimeinSec);
  $Instance.manage().Window.minimize()

  return $Instance
}

Function Open-Webpage {
  
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] [string] $URL,
    [ Parameter (Mandatory = $false, Position = 1 ) ] $Instance = $Instance,
    [switch] $Help
  )

  if($Help)
  {
    Write-Output "Function to Load the Web Page or URL, Default is Edge Driver. `n 1. Edge >> Open-Webpage -URL 'https://tinyurl.com/DeepakRaghuwanshi/'"
    return $Help
  }

  $Instance.Navigate().GoToUrl("$URL")

  Return $true
}

Function Sign-In {
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] [string] $Site_Username,
    [ Parameter (Mandatory = $true, Position = 1 ) ] [string] $Site_Secretkey,
    [ Parameter (Mandatory = $true, Position = 2 ) ] $Instance = $Instance,
    [switch] $Help
  )

  if($Help)
  {
    Write-Output "Function to Sign in to the WebPage. `n 1. Edge >> Open-Webpage -URL 'https://tinyurl.com/DeepakRaghuwanshi/'"
    return $Help
  }
    ($Instance.FindElementById('usernameField')).SendKeys("$Site_Username")
    ($Instance.FindElementById('passwordField')).SendKeys("$Site_Secretkey")
    $Instance.FindElementByTagName('button').Click()
    
    Return $True
}

Function Validate-Page {
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] [string] $PageTitle,
    [ Parameter (Mandatory = $true, Position = 1 ) ] $Instance = $Instance,
    [ Parameter (Mandatory = $false, Position = 2 ) ] [int] $Maxrun = 7,
    [ Parameter (Mandatory = $false, Position = 3 ) ] [int] $Run = 2,
    [ Parameter (Mandatory = $false, Position = 4 ) ] [Bool] $Ispass = $False
  )

  if($PageTitle -eq "" -or $PageTitle -eq $null)
  {
     Return $Ispass
  }
  
  While ($Run -le $Maxrun){
  
      $Run += 2
      
      if($Instance.Title -like $($PageTitle+"*"))
      {
        $Ispass = $true;
        $Run = 10
      }

      Start-Sleep -Seconds 2;
  }

  Return $Ispass
}

Function Update-Profile{
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] $Instance = $Instance
  )

    ($Instance.FindElementsByXPath('//em[@class="icon edit"]')).Click();
    Start-Sleep -Milliseconds 400;
    $Instance.FindElementsById('saveBasicDetailsBtn').Click();

}

Function Get-LastUpdate{

  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 1 ) ] $Instance = $Instance,
    [Switch] $Resume
  )

   if($Resume)
   {
    Return $($Instance.FindElementByXPath(('//*[contains(@class, "updateOn")]')))
   }
   
   Return $(($Instance.FindElementsByXPath('//span [@class="fw700"]')).Text)

}

Function Update-Resume {
    
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] $Instance = $Instance,
    [ Parameter (Mandatory = $false, Position = 1 ) ] $ResumePath = $ResumePath,
    [ Parameter (Mandatory = $false, Position = 1 ) ] $MaxTime = 10
  )

  
  $LastUpdate = Get-LastUpdate -Resume 
  Write-Logs -LogLine "Last Updated Resume On - $LastUpdate"

  ($Instance.FindElementByXPath('//*[@id="attachCV"]') ).SendKeys("$ResumePath")

  [int] $Time = 0

  while($Time -le $MaxTime){
    
    if($(Get-LastUpdate -Resume ) -ne $LastUpdate){
          Write-Logs -LogLine "Succefully Updated Resume On - $(Get-LastUpdate -Resume)"; Return $True
    }

    Start-Sleep -Seconds 2;
    $Time += 2;
  }

  Write-Logs -LogLine "Failed to Updated Resume";

  Return $false

}

Function Destroy-Instance{
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $false, Position = 1 ) ] $Instance = $Instance,
    [switch] $Help
  )
  
  if($Help)
  {
    Write-Output "Function to Destroy Instance. `n 1. Destroy-Instance"
    return $Help
  }
  
  $Instance.Quit()

  Return $true

}

#endregion

#$password = Get-Content -Path "$password" -ErrorAction Stop

#region Main Flow
$Instance = Create-Instance -IsChrome $False #launch Edge

Open-Webpage -URL "https://www.naukri.com/nlogin/login" -Instance $Instance #Open Naukri WebSite

if(Validate-Page -PageTitle "Jobseeker's Login:" -Instance $Instance) 
{
    #Check if Not Loggged Then Sign In 
    Sign-In -Site_Username "$Username" -Site_Secretkey "$(Get-Content -Path "$password" -ErrorAction Stop)" -Instance $Instance; #$password = $null;
}

if(!(Validate-Page -PageTitle "Home |" -Instance $Instance))
{
     #Check if Sign in Suceesfull
     Throw "Update Failed, Unexpected Web Page - $($Instance.Title)"
}

Open-Webpage -URL "https://my.naukri.com/Profile/edit?id=&altresid=" -Instance $Instance #Open Profile

if(!(Validate-Page -PageTitle "Profile |" -Instance $Instance))
{
     #Validate Profiel
     Throw "Update Failed, Unexpected Web Page - $($Instance.Title)"
}

$Old_Time = Get-LastUpdate -Instance $Instance
Write-Logs -LogLine "Last Status - $Old_Time"

Update-Profile -Instance $Instance; #Update Profile TimeStamp

Open-Webpage -URL "https://my.naukri.com/Profile/edit?id=&altresid=" -Instance $Instance #ReFresh Profile

if(!(Validate-Page -PageTitle "Profile |" -Instance $Instance))
{
     #Validated Refreshed Profile Page
     Throw "Update Failed, Unexpected Web Page - $($Instance.Title)"
}

$Updated_Time = Get-LastUpdate -Instance $Instance
Write-Logs -LogLine "Current Status - $Updated_Time"

Destroy-Instance -Instance $Instance; #kills the Edge Instance.

#endregion


##Validate
if($Updated_Time -eq "today" -or $Old_Time -ne $Updated_Time)
{
    Write-Logs -LogLine "Successfull Profile Update at Time - $Updated_Time"    
}
Else
{
    Throw "Unable to Update as Last update was at $Old_Time | $Updated_Time" 
}

}

Catch{
    Write-logs -LogLine "Error encountered While Update Profile- $_"
    try{ Destroy-Instance -Instance $Instance -ErrorAction Stop } catch{ "Error - $_ "}
}

finally{
    "Logs Availble at Logpath - $LogFile"
}
