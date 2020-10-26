$Avg = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select Average).Average
If ($Avg -gt 90) {
  Throw "Instance is unhealthy - Windows"
}
Write-Output "Instance is healthy - Windows"