Install boxstarter:
`. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force`
You might need to set: `Set-ExecutionPolicy RemoteSigned`

# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
# OR
# 	Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1
