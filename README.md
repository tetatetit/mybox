# mybox

Install boxstarter:\
`. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force` \
You might need to set: \
`Set-ExecutionPolicy RemoteSigned`

Run this boxstarter by calling the following from an **elevated** command-prompt: \
start http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1 \
(learn more: http://boxstarter.org/Learn/WebLauncher) \
or \
`Install-BoxstarterPackage -Credential $(Get-Credential) -PackageName https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1`
