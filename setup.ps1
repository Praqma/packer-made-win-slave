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
    # Suppress output from cygwin installer - just to much of text that makes log unreadable
    Start-Process $remotePath -RedirectStandardOutput Out-Null -NoNewWindow -Wait -Argument '--no-desktop --no-shortcuts --no-startmenu --quiet-mode --site http://cygwin.mirror.constant.com'
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

Write-Host 'Download and setup Jenkins swarm agent...'
New-Item 'C:\jenkins' -type directory -force | Out-Null
$autostart_script = "C:\jenkins\slave-startup.ps1"
$filename = "swarm-client-2.0-jar-with-dependencies.jar";
$link = "http://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/2.0/$filename";
$remotePath = Join-Path 'C:\jenkins' $filename;
Try {
    $webClient.DownloadFile($link, $remotePath);
} Catch {
    Write-Host $_.Exception|format-list -force
}
Write-Host 'Swarm agent is ready!'

# Create new AD user
#New-ADUser -Name "Phil Gibbins" -GivenName Phil -Surname Gibbins -SamAccountName pgibbins -UserPrincipalName pgibbins@corp.contoso.com -AccountPassword (Read-Host -AsSecureString "AccountPassword") -PassThru | Enable-ADAccount

# No AD so for now use local user
Write-Host 'Create local user...'
$computername = $env:computername   # place computername here for remote access
$master_url = (Get-Content jenkins.txt -TotalCount 1)
$username = (Get-Content jenkins.txt -TotalCount 2)[-1]
$password = (Get-Content jenkins.txt -TotalCount 3)[-1]
$desc = 'Automatically created local admin account'
Try {
    $computer = [ADSI]"WinNT://$computername,computer"
    $user = $computer.Create("user", $username)
    $user.SetPassword($password)
    $user.SetInfo()
    $user.description = $desc
    $user.SetInfo()
    $user.UserFlags = 65536 # ADS_UF_DONT_EXPIRE_PASSWD
    $user.SetInfo()
    $group = [ADSI]("WinNT://$computername/administrators,group")
    $group.add("WinNT://$username,user")
} Catch {
    Write-Host $_.Exception|format-list -force
}
Write-Host 'Local user created!'

Write-Host 'Create startup script...'
# TODO: This is a potential problem because password will be saved in the plain text. On the other hand if you are able to login - then you already know the password.
# Conclusion - it is not perfect but good enough solution for a time being
$command = @"
`$stdOutLog = 'C:\jenkins\stdout.log';
`$stdErrLog = 'C:\jenkins\stderr.log';
`$java = 'C:\Program Files\Java\jdk1.8.0_74\bin\java.exe';
`$jar = 'C:\jenkins\swarm-client-2.0-jar-with-dependencies.jar';
`$args = " -jar `$jar -executors 5 -fsroot c:\jenkins\workspace -labels windows -name azure-slave -master $master_url -username $username -password $password";
Start-Process `$java -RedirectStandardOutput `$stdOutLog -RedirectStandardError `$stdErrLog -NoNewWindow -Argument `$args;
"@
$command | Out-File $autostart_script;
Write-Host 'Start up script is ready!'

Write-Host 'Setup on boot trigger...';
Try {
    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:01:00;
    $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePassword
    Register-ScheduledJob -Credential $credentials -Trigger $trigger -FilePath $autostart_script -Name JenkinsSlave;
} catch {
    Write-Host $_.Exception|format-list -force
}
Write-Host 'Startup script registered!';

Write-Host 'Ready to go!';