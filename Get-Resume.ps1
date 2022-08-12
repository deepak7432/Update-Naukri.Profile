[CmdletBinding()] 
Param 
( 

[ Parameter (Mandatory = $false, Position = 1 ) ] $SaveResume = "C:\deepak_workspace\Update-Naukri.Profile\Resume\Deepak Raghuwanshi.pdf",
[ Parameter (Mandatory = $false, Position = 2 ) ] $DownloadResume = "https://tinyurl.com/ResumeofDeepak",
[ Parameter (Mandatory = $false, Position = 3 ) ] $LogFile = "C:\deepak_workspace\Update-Naukri.Profile\NaukriUpdateLogs.txt"

)

Function Write-logs {
  [CmdletBinding()] 
  Param 
  ( 
    [ Parameter (Mandatory = $true, Position = 0 ) ] [string]$LogLine,
    [ Parameter (Mandatory = $false, Position = 1 ) ] $LogFilepath = $LogFile
  )

  Add-content $LogFilepath -value $($("[{0:dd-MM-yy} {0:HH:mm:ss}]" -f (Get-Date))+" $LogLine `n") -ErrorAction Stop

}

Try{

    Invoke-WebRequest -DisableKeepAlive -Uri "$DownloadResume" -OutFile $ResumePath -ErrorAction Stop
}
Catch{
    Write-logs -LogLine "Error encountered While Downloading Resume $_"
}
