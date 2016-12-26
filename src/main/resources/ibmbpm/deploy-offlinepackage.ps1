$_WsAdminExe = $($deployed.container.wsadminBinPath) + "wsadmin"
$_WsAdminUser = $($deployed.container.wsadminUser)
$_WsAdminPassword = $($deployed.container.wsadminPassword)
$_TempPath = $($deployed.container.TempPath)

function ExecuteDeployment()
{
	# Call function to copy all deployables to target directory
	CopyDeployables

	# Call function to install the Windows Service
	InstallOfflinePackage
}

function CopyDeployables
{	
	if (Test-Path $_TempPath) 
	{
		PrintMessage "Deleting all previous offline packages from temp folder..."
		Get-ChildItem -Path $_TempPath -Recurse | Remove-Item -Force -Recurse | Out-Null
		Write-Host "Done!"
	}
	else
	{
		PrintMessage "Creating temp folder..."
		New-Item -ItemType "directory" -Path $_TempPath
		Write-Host "Done!"
	}
	
	PrintMessage "Copying new offline package to target directory..."
	Write-Host "Copying $($deployed.file)..."
	Copy-Item $deployed.file $_TempPath	
	Write-Host "Done!"
}

function InstallOfflinePackage
{
	$_OfflinePackageName = split-path $($deployed.file) -Leaf
	$_OfflinePackageToInstall = $_TempPath + $_OfflinePackageName

	PrintMessage "Executing wsadmin to perform deployment for the offline package '$_OfflinePackageName'..."
	Write-Host $_WsAdminExe -lang jython -user $_WsAdminUser -password ******** -c "AdminTask.BPMInstallOfflinePackage('[-inputFile $_OfflinePackageToInstall]')"
	& $_WsAdminExe -lang jython -user $_WsAdminUser -password $_WsAdminPassword -c "AdminTask.BPMInstallOfflinePackage('[-inputFile $_OfflinePackageToInstall]')"
}

function PrintMessage($message)
{
	Write-Host "-----------------------------------------------------------------------------------------------------"
	Write-Host "---- $message"	
}

ExecuteDeployment