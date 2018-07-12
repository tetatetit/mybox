# mybox

# Install boxstarter:
# 	. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# You might need to set: Set-ExecutionPolicy RemoteSigned
#
# NOTE/WARNING BEFORE RUNNING SCRIPT:
# On Windoes 10 Enterprise 1803 (at least) we need in gpedit.msc in 
# "Computer Configuration\Administrative Templates\Windows Components\Windows Update"
# to set ANY (NO MATTER WHAT) item as configured, in order to get Windows Update policies
# configured in this script actually applied and work (otherwise they don't for some reason
# while e.g. Windows Defender policies are applied and work successfuly configured same way)
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?<URL-TO-RAW-GIST>
# OR
# 	Install-BoxstarterPackage -PackageName <URL-TO-RAW-GIST> -DisableReboots
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1
