# Delete and stop the service if it already exists.
if (Get-Service filebeat -ErrorAction SilentlyContinue) {
  Stop-Service filebeat
  (Get-Service filebeat).WaitForStatus('Stopped')
  Start-Sleep -s 1
  sc.exe delete filebeat
}

$workdir = Split-Path $MyInvocation.MyCommand.Path

# Create the new service.
New-Service -name filebeat `
  -displayName Filebeat `
  -binaryPathName "`"$workdir\filebeat.exe`" --environment=windows_service -c `"$workdir\filebeat.yml`" --path.home `"$workdir`" --path.data `"$env:PROGRAMDATA\filebeat`" --path.logs `"$env:PROGRAMDATA\filebeat\logs`" -E logging.files.redirect_stderr=true"

# Attempt to set the service to delayed start using sc config.
Try {
  Start-Process -FilePath sc.exe -ArgumentList 'config filebeat start= delayed-auto'
}
Catch { Write-Host -f red "An error occurred setting the service to delayed start." }
