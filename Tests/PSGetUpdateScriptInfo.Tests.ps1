﻿<#####################################################################################
 # File: PSGetUpdateScriptInfo.Tests.ps1
 # Tests for PSGet ScriptFileInfo functionality
 #
 # Copyright (c) Microsoft Corporation, 2015
 #####################################################################################>

<#
   Name: PowerShell.PSGet.UpdateScriptInfo.Tests
   Description: Tests for Update-ScriptFileInfo cmdlet functionality

   Local PSGet Test Gallery (ex: http://localhost:8765/packages) is pre-populated with static scripts:
        Fabrikam-ClientScript: versions 1.0, 1.5, 2.0, 2.5
        Fabrikam-ServerScript: versions 1.0, 1.5, 2.0, 2.5
#>

function SuiteSetup {
    Import-Module "$PSScriptRoot\PSGetTestUtils.psm1" -WarningAction SilentlyContinue
    Import-Module "$PSScriptRoot\Asserts.psm1" -WarningAction SilentlyContinue

    $script:ProgramFilesScriptsPath = Get-AllUsersScriptsPath 
    $script:MyDocumentsScriptsPath = Get-CurrentUserScriptsPath 
    $script:PSGetLocalAppDataPath = Get-PSGetLocalAppDataPath
    $script:TempPath = Get-TempPath

    #Bootstrap NuGet binaries
    Install-NuGetBinaries

    $psgetModuleInfo = Import-Module PowerShellGet -Global -Force -Passthru
    Import-LocalizedData  script:LocalizedData -filename PSGet.Resource.psd1 -BaseDirectory $psgetModuleInfo.ModuleBase

    $script:moduleSourcesFilePath= Join-Path $script:PSGetLocalAppDataPath "PSRepositories.xml"
    $script:moduleSourcesBackupFilePath = Join-Path $script:PSGetLocalAppDataPath "PSRepositories.xml_$(get-random)_backup"
    if(Test-Path $script:moduleSourcesFilePath)
    {
        Rename-Item $script:moduleSourcesFilePath $script:moduleSourcesBackupFilePath -Force
    }

    GetAndSet-PSGetTestGalleryDetails -IsScriptSuite -SetPSGallery

    Get-InstalledScript -Name Fabrikam-ServerScript -ErrorAction SilentlyContinue | Uninstall-Script -Force
    Get-InstalledScript -Name Fabrikam-ClientScript -ErrorAction SilentlyContinue | Uninstall-Script -Force

    if($PSEdition -ne 'Core')
    {
        $script:userName = "PSGetUser"
        $password = "Password1"
        $null = net user $script:userName $password /add
        $secstr = ConvertTo-SecureString $password -AsPlainText -Force
        $script:credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $script:userName, $secstr
    }

    $script:assertTimeOutms = 20000
    
    # Create temp folder for saving the scripts
    $script:TempSavePath="$env:LocalAppData\temp\PSGet_$(Get-Random)"
    $null = New-Item -Path $script:TempSavePath -ItemType Directory -Force

    $script:AddedAllUsersInstallPath    = Set-PATHVariableForScriptsInstallLocation -Scope AllUsers
    $script:AddedCurrentUserInstallPath = Set-PATHVariableForScriptsInstallLocation -Scope CurrentUser
}

function SuiteCleanup {
    if(Test-Path $script:moduleSourcesBackupFilePath)
    {
        Move-Item $script:moduleSourcesBackupFilePath $script:moduleSourcesFilePath -Force
    }
    else
    {
        RemoveItem $script:moduleSourcesFilePath
    }

    # Import the PowerShellGet provider to reload the repositories.
    $null = Import-PackageProvider -Name PowerShellGet -Force

    if($PSEdition -ne 'Core')
    {
        # Delete the user
        net user $script:UserName /delete | Out-Null
        # Delete the user profile
        $userProfile = (Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -match $script:UserName})
        if($userProfile)
        {
            RemoveItem $userProfile.LocalPath
        }
    }
    RemoveItem $script:TempSavePath


    if($script:AddedAllUsersInstallPath)
    {
        Reset-PATHVariableForScriptsInstallLocation -Scope AllUsers
    }

    if($script:AddedCurrentUserInstallPath)
    {
        Reset-PATHVariableForScriptsInstallLocation -Scope CurrentUser
    }
}

$ScriptFileInfoProperties = @{
	Version='1.2.3.4'
	Author='john@fabrikam.com'
	Guid='cb0ec9a8-b1a8-4701-8b85-3e9a8341eba4'
	Description='Test Script Description'
	PrivateData='ScriptControlInfo=1.2.3.4.5abcd'
	CompanyName='Fabrikam'
	Copyright='@R'
	RequiredModules='PowerShellGet'
	ExternalModuleDependencies='PowerShellGet'
	RequiredScripts='Fabrikam-ServerScript2'
	ExternalScriptDependencies='Fabrikam-ServerScript2'
	Tags='Tag1','Tag2'
	ProjectUri='https://www.fabrikam-psprojects.com/'
	LicenseUri='https://www.fabrikam-pslicense.com/'
	IconUri='https://www.fabrikam-psicon.com/'
	ReleaseNotes='Test Script version 1.2.3.4'
}


Describe "Update Existing Script Info" -tag CI {

    BeforeAll {
        SuiteSetup
    }

    AfterAll {
        SuiteCleanup
    }

    BeforeEach {
        $scriptName = 'Fabrikam-ServerScript'
        Install-Script $scriptName
		$Script = Get-InstalledScript -Name $scriptName
		$script:ScriptFilePath = Join-Path -Path $script.InstalledLocation -ChildPath "$scriptName.ps1"
    }

    AfterEach {
        Get-InstalledScript -Name Fabrikam-ServerScript -ErrorAction SilentlyContinue | Uninstall-Script -Force
        Get-InstalledScript -Name Fabrikam-ClientScript -ErrorAction SilentlyContinue | Uninstall-Script -Force
    }

    # Purpose: Update a script file info with all parameters
    #
    # Action: Update-ScriptFileInfo [path] -Version -Author -Guid -Description ...
    #
    # Expected Result: Script should update all fields.
    #
    It "UpdateScriptFileWithAllFields" {
        Update-ScriptFileInfo -Path $script:ScriptFilePath @ScriptFileInfoProperties

		$ScriptFileInfo = Test-ScriptFileInfo -Path $script:ScriptFilePath

		foreach ($Prop in $ScriptFileInfoProperties.Keys)
		{
            $ScriptFileInfo.$Prop | Should be $ScriptFileInfoProperties[$Prop]
		}
    }

    # Purpose: Update a script file info with an invalid PreRelease string
    #
    # Action: Update-ScriptFileInfo [path] -Version 3.2.1-alpha+001
    #
    # Expected Result: Update-ScriptFileInfo should throw InvalidCharactersInPreReleaseString errorid.
    #
    It "UpdateScriptFileWithInvalidPreReleaseString" {
        $Version = "3.2.1-alpha+001"

        $expectedErrorMessage = "The PreRelease string contains invalid characters. Please ensure that only characters 'a-zA-Z0-9' and possibly hyphen ('-') at the beginning are in the PreRelease string."
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPreReleaseString,Validate-PreReleaseString"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    # Purpose: Update a script file info with an PreRelease string when the version has insufficient parts.
    #
    # Action: Update-ScriptFileInfo [path] -Version 3.2-alpha+001
    #
    # Expected Result: Update-ScriptFileInfo should throw InsufficientVersionPartsForPreReleaseString errorid.
    #
    It "UpdateScriptFileWithPreReleaseStringAndShortVersion" {
        $Version = "3.2-alpha001"

        $expectedErrorMessage = "Version has less than 3 parts and a PreRelease string is specified. Version must have at least 3 parts for a PreRelease string to be used."
        $expectedFullyQualifiedErrorId = "InsufficientVersionPartsForPreReleaseStringUsage,Validate-PreReleaseString"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
    
    # Purpose: Update a script file info with a valid PreRelease string and a version with sufficient parts.
    #
    # Action: Update-ScriptFileInfo [path] -Version 3.2.1-alpha001
    #
    # Expected Result: Update-ScriptFileInfo should successfully update the version field.
    #
    It "UpdateScriptFileWithValidPreReleaseAndVersion" {
        $Version = "3.2.1-alpha001"

        Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version

        $newScriptInfo = Test-ScriptFileInfo -Path $script:ScriptFilePath

        $newScriptInfo.Version | Should -Match $Version
    }
}
