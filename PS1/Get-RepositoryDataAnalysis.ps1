Function Get-RepositoryDataAnalysis
{
<#
.SYNOPSIS
Analyze the results from a repository information dataset.

.DESCRIPTION
This function will take the results of the Get-RepositoryData function and calculate matches for critical columns.
Those results can then be consumed by further logic or exported for analysis in another tool.  Because there are so 
many variables in terms of what values may or may not be available or may be a slight mismatch it is difficult to 
judge with any accuracy if an overall mismatch is indicative of an issue or a failure because one piece of data is missing.

This code was originally created to support ICSWhiteList.com inventory of ICS related software installation media.

Special Note: 

.PARAMETER RepositoryData
The data from the output of the Get-RepositoryData function

.EXAMPLE
PS C:\> $RepositoryData = Get-FileSignatures 'C:\Program Files (x86)\Notepad++\notepad++.exe' -IncludeVersionData $true -IncludeAuthenticodeData $false -IncludeRootPath $false  | Get-RepositoryData
PS C:\> Get-RepositoryDataAnalysis -RepositoryData $RepositoryData

Get repository data into a variable and send that to this function.  Pipelining is currently broken.

.LINK
http://www.icswhitelist.com/
.LINK
http://www.phase2automation.com 

.INPUTS
Dataset from Get-RepositoryData function

.OUTPUTS
Dataset showing analysis of comparison of key fields for a match
#>
	[cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Low")]
	Param (
	  [Parameter(
	  	Position=0,
		Mandatory=$True,
		HelpMessage="Repository Data Array",
	  	ValueFromPipeline=$True,
		parametersetname="nopipeline",
		ValueFromPipelineByPropertyName=$True
		)
		]
	  [ValidateNotNullorEmpty()]	  
	  [System.Array]$RepositoryData
	)


Begin
	{	
		
		Write-Host "$(Get-Date) Starting $($myinvocation.mycommand)"	
		
		#Internal Globals		
		$StartTime = Get-Date
		$AnalysisCount = 0		
		$PowerShellFileSystemPath = "Microsoft.PowerShell.Core\FileSystem::"

		#Create a new object for analysis
		$Results = $RepositoryData.PSObject.Copy()
		
		# Add the properties we are going to be using later
		$Results | Add-Member -Name "FileNameMatch" -Value "" -MemberType NoteProperty 
		$Results | Add-Member -Name "MD5Match" -Value "" -MemberType NoteProperty
		$Results | Add-Member -Name "SHA1Match" -Value "" -MemberType NoteProperty
		$Results | Add-Member -Name "SHA256Match" -Value "" -MemberType NoteProperty
		$Results | Add-Member -Name "VersionMatch" -Value "" -MemberType NoteProperty
		$Results | Add-Member -Name "VersionMinorMatch" -Value "" -MemberType NoteProperty
		$Results | Add-Member -Name "VersionMajorMatch" -Value "" -MemberType NoteProperty				
		
	} #Begin

Process
	{	
		# Loop through all of the signatures
		foreach($Item in $Results)
		{
			$Item.FileNameMatch = ($($Item.FileFilename) -eq $($Item.Repositoryfilename))
			$Item.MD5Match = ($($Item.MD5Hash) -eq $($Item.Repositorymd5hash))
			$Item.SHA1Match = ($($Item.SHA1Hash) -eq $($Item.Repositorysha1hash))
			$Item.SHA256Match = ($($Item.SHA256Hash) -eq $($Item.Repositorysha256hash))
			$Item.VersionMatch = ($($Item.VersionInfoFileVersion) -eq $($Item.Repositoryversion ))
			$Item.VersionMinorMatch = ($($Item.VersionInfoFileVersion).Split('.',2)[1] -eq $($Item.Repositoryversionminor))
			$Item.VersionMajorMatch = ($($Item.VersionInfoFileVersion).Split('.',2)[0] -eq $($Item.Repositoryversionmajor))

		} # foreach($Item in $RepositoryData)
	} # process
		
End
	{	
		
		#Calculate total script duration	
		$Duration = New-TimeSpan $StartTime (Get-Date)		
		
		#Calculate average duration
		$AverageDuration = ($($Duration.TotalMilliseconds) / $Results.Length)
		
		Write-Host "$(Get-Date) Total Duration $($Duration.ToString())"
		Write-Host "$(Get-Date) Total Items $($Results.Length)"	
		$LogMessage = "$(Get-Date) Average Duration per item (ms) {0:N2}" -f ($AverageDuration)	
		Write-Host $LogMessage
		
		Write-Host "$(Get-Date) Completed $($myinvocation.mycommand)"
		
		#Return the Results Array
				#>
						
		return $Results
		
	} #end
	
} #End Function
