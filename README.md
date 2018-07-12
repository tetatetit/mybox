# mybox

Install boxstarter:\
`Set-ExecutionPolicy -Force RemoteSigned; . { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force`

Run this boxstarter by calling the following from an **elevated** command-prompt: \
start http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1 \
(learn more: http://boxstarter.org/Learn/WebLauncher) \
or \
`Install-BoxstarterPackage -Credential $(Get-Credential) -PackageName https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1`
