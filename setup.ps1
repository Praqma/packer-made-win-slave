# Fail on first error
$ErrorActionPreference = "Stop"

$dstDir = "c:\scratch";
New-Item $dstDir -type directory -force | Out-Null

$webClient = new-object System.Net.WebClient
# specify your proxy address and port
# $proxy = new-object System.Net.WebProxy "proxy.MyDomain.com:8080"
# replace your credential by your domain, username, and pasword
# $proxy.Credentials = New-Object System.Net.NetworkCredential ("Domain\UserName", "Password")
# $webclient.proxy=$proxy
# specify an header if you want to check info in your logs on your proxy

Write-Host 'Installing Git Bash...' 
$filename = "Git-2.7.2-64-bit.exe";
$link = "https://github.com/git-for-windows/git/releases/download/v2.7.2.windows.1/$filename";
$remotePath = Join-Path $dstDir $filename;
Try {
    $webClient.DownloadFile($link, $remotePath);
    Start-Process $remotePath -NoNewWindow -Wait -Argument '/VERYSILENT /CLOSEAPPLICATIONS';
} Catch {
    Write-Host $_.Exception|format-list -force
}
Write-Host 'Git installation complete!'

Write-Host 'Installing Cygwin...'
$filename = "setup-x86_64.exe";
$link = "https://cygwin.com/$filename";
$remotePath = Join-Path $dstDir $filename;
Try {
    $webClient.DownloadFile($link, $remotePath);
    Start-Process $remotePath -NoNewWindow -Wait -Argument '--no-desktop --no-shortcuts --no-startmenu --quiet-mode --site http://cygwin.mirror.constant.com' | Out-Null;
} Catch {
    Write-Host $_.Exception|format-list -force
}
Write-Host 'Cygwin installation complete!'

Write-Host 'Installing Java 8u74...'
$filename = "jdk-8u74-windows-x64.exe";
$link = "http://download.oracle.com/otn-pub/java/jdk/8u74-b02/$filename";
$remotePath = Join-Path $dstDir $filename;
$cookie = "oraclelicense=accept-securebackup-cookie"
$webClient.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie) 
Try
{
    $webClient.DownloadFile($link, $remotePath);
    Start-Process $remotePath -NoNewWindow -Wait -Argument '/s';
} Catch {
    Write-Host $_.Exception|format-list -force
}
Write-Host 'Java installation complete!'

Write-Host 'Ready to go!';