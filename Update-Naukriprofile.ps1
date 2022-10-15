#Update naukri Profile Daily Time Stam by - Deepak Raghuwanshi
#use Task Scheduler or job Sceduler to Schedule it Daily

[CmdletBinding()] 
Param 
( 
[ Parameter (Mandatory = $false, Position = 0 ) ] $Scriptpath         = 'C:\deepak_workspace\Update-Naukri.Profile', ##Comment Below, If Need to pass manually in the Params
[ Parameter (Mandatory = $false, Position = 1 ) ] $WebDriverdll       = "Requirements\WebDriver.dll",
[ Parameter (Mandatory = $false, Position = 2 ) ] $Username           = "raghuwanshideepak79.dr@gmail.com",
[ Parameter (Mandatory = $false, Position = 3 ) ] $password           = "Requirements\Secret.Credential",
[ Parameter (Mandatory = $false, Position = 4 ) ] $LogFile            = "Logs\NaukriUpdateLogs.txt",
[ Parameter (Mandatory = $false, Position = 5 ) ] $ResumePath         = "Resume\Deepak Raghuwanshi.pdf",
[ Parameter (Mandatory = $false, Position = 6 ) ] [bool]$manul_path   = $false
)

Try{

  ##Output Save to Script Stored Directory
  if($manul_path -eq $false){ $Scriptpath = Split-Path $MyInvocation.MyCommand.Path }

  $WebDriverdll = $Scriptpath+"\"+$WebDriverdll
  $password = $Scriptpath+"\"+$password
  $LogFile = $Scriptpath+"\"+$LogFile
  $ResumePath = $Scriptpath+"\"+$ResumePath 

  if(!$WebDriverdll -or !$Username -or !$password -or !$LogFile -or !$ResumePath ){
      Throw "Input Values not Correct `n 1. WebDriverdll - $WebDriverdll, `n 2. Username - $Username `n 3. password - $password, `n 4. LogFile - $LogFile, `n 5. ResumePath - $ResumePath."    
  }

  $ErrorActionPreference = "Stop"

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
      Write-Logs -LogLine "Opening Chrome"
    }
    else
    {
      $Instance = New-Object OpenQA.Selenium.Edge.EdgeDriver -ErrorAction Stop;      
      Write-Logs -LogLine "Opening Edge"
    }
    
    #Set the Wait for the Element to load, Before throwing Exception
    $Instance.Manage().Timeouts().ImplicitWait = (New-TimeSpan -Hours 0 -Minutes 0 -Seconds $WaitTimeinSec);
    $Instance.manage().Window.minimize()

    Write-Logs -LogLine "Minimizing Browzer"

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

    Write-Logs -LogLine "Loading Addreess- $URL"
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
      $Instance.FindElementByXPath('//*[@id="loginForm"]/div[2]/div[3]/div/button[1]').Click()
      Write-Logs -LogLine "Login Suceess"
      Return $True
  }

  Function Validate-Page {
    [CmdletBinding()] 
    Param 
    ( 
      [ Parameter (Mandatory = $true, Position = 0 ) ] [string] $PageTitle,
      [ Parameter (Mandatory = $false, Position = 1 ) ] $Instance = $Instance,
      [ Parameter (Mandatory = $false, Position = 2 ) ] [int] $Maxrun = 7,
      [ Parameter (Mandatory = $false, Position = 3 ) ] [int] $Run = 2,
      [ Parameter (Mandatory = $false, Position = 4 ) ] [Bool] $Ispass = $False
    )

    if($PageTitle -eq "" -or $PageTitle -eq $null)
    {
      
        Write-Logs -LogLine "Page Validation Failed - $PageTitle"
        Return $Ispass
    }
    
    While ($Run -le $Maxrun){
    
        $Run += 2
        
        if($($Instance.Title) -like $($PageTitle+"*"))
        {
          Write-Logs -LogLine "Page Validation Suceesfull - $($Instance.Title)"
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

      Write-Logs -LogLine "Update Profile"

  }

  Function Get-LastUpdate{

    [CmdletBinding()] 
    Param 
    ( 
      [ Parameter (Mandatory = $false, Position = 1 ) ] $Instance = $Instance,
      [Switch] $Resume
    )

    if($Resume)
    {
      Return $($Instance.FindElementByXPath(('//*[contains(@class, "updateOn")]')).Text)
    }
    
    Return $(($Instance.FindElementsByXPath('//span [@class="fw700"]')).Text)

  }

  Function Update-Resume {
      
    [CmdletBinding()] 
    Param 
    ( 
      [ Parameter (Mandatory = $false, Position = 0 ) ] $Instance = $Instance,
      [ Parameter (Mandatory = $false, Position = 1 ) ] $ResumePath = $ResumePath,
      [ Parameter (Mandatory = $false, Position = 2 ) ] $MaxTime = 10
    )

    
    $LastUpdate = Get-LastUpdate -Instance $Instance -Resume
    Write-Logs -LogLine "Last Updated Resume On - $LastUpdate"

    ($Instance.FindElementByXPath('//*[@id="attachCV"]') ).SendKeys("$ResumePath")

    [int] $Time = 0

    while($Time -le $MaxTime){
      
      $FinalStatus = Get-LastUpdate -Resume -Instance $Instance

      if($FinalStatus-ne $LastUpdate){
            Write-Logs -LogLine "Succefully Updated Resume On - $FinalStatus "; Return $True
      }

      Start-Sleep -Seconds 2;
      $Time += 2;
    }

    Write-Logs -LogLine "Failed to Updated Resume where - Final Status > $FinalStatus";

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
    Write-Logs -LogLine "Browser Session Destroyed"
    Return $true

  }

  Function Get-Resume{

    [CmdletBinding()] 
    Param 
    ( 
      [ Parameter (Mandatory = $false, Position = 1 ) ] $SaveResume = "C:\deepak_workspace\Update-Naukri.Profile\Resume\Deepak Raghuwanshi.pdf",
      [ Parameter (Mandatory = $false, Position = 2 ) ] $DownloadResume = "https://tinyurl.com/ResumeofDeepak"
    )

      Try{
          Invoke-WebRequest -UseBasicParsing -DisableKeepAlive -Uri "$DownloadResume" -OutFile $ResumePath -ErrorAction Stop; Write-host "Success"
          Write-logs -LogLine "Success While Downloading Resume Path - $ResumePath, from - $DownloadResume"
          #start-Sleep -Seconds 1
      }
      Catch{
          Write-logs -LogLine "Error encountered While Downloading Resume $_"
          
      }

  }

  #endregion

  Write-Logs -LogLine "`n `nStarting Update Naukri Script #################################################################"
  #$password = Get-Content -Path "$password" -ErrorAction Stop

  #Download Latest Reume
  Get-Resume

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

  Update-Resume -Instance $Instance;

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
