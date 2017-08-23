


function RegisterTestRepository {

    # Register test repository
    $testRepoRegistered = Get-PSRepository -Name $TestRepositoryName -ErrorAction SilentlyContinue
    if (-not $testRepoRegistered) {
        Register-PSRepository -Name $TestRepositoryName -SourceLocation $TestRepositorySource -InstallationPolicy Trusted  
        
        $testRepoRegistered = Get-PSRepository -Name $TestRepositoryName

        if (-not $testRepoRegistered)
        {
            Throw "Could not register test repository."
        }
    }
}




#------------------
#   Global Setup
#------------------

Import-Module "$PSScriptRoot\PSGetTestUtils.psm1" -WarningAction SilentlyContinue

$psgetModuleInfo = Import-Module PowerShellGet -Global -Force -Passthru
Import-LocalizedData LocalizedData -Filename "PSGet.Resource.psd1" -BaseDirectory $psgetModuleInfo.ModuleBase

#Bootstrap NuGet binaries
Install-NuGetBinaries

# Set script install path (in case isn't already set)
$script:AddedAllUsersInstallPath    = Set-PATHVariableForScriptsInstallLocation -Scope AllUsers
$script:AddedCurrentUserInstallPath = Set-PATHVariableForScriptsInstallLocation -Scope CurrentUser

$ProgramFilesWindowsPowerShellPath = Microsoft.PowerShell.Management\Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell"
$ProgramFilesModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $ProgramFilesWindowsPowerShellPath -ChildPath "Modules"
$ProgramFilesScriptsPath = Microsoft.PowerShell.Management\Join-Path -Path $ProgramFilesWindowsPowerShellPath -ChildPath "Scripts"

$MyDocumentsWindowsPowerShellPath = Microsoft.PowerShell.Management\Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell"
$MyDocumentsModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $MyDocumentsWindowsPowerShellPath -ChildPath "Modules"
$MyDocumentsScriptsPath = Microsoft.PowerShell.Management\Join-Path -Path $MyDocumentsWindowsPowerShellPath -ChildPath "Scripts"

$PSGetLocalAppDataPath = Microsoft.PowerShell.Management\Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Windows\PowerShell\PowerShellGet\'
$TempPath = ([System.IO.DirectoryInfo]$env:TEMP).FullName

# Register test repository
$TestRepositoryName = "Local"
$TestRepositorySource = "https://psgallery.localtest.me/api/v2/"
RegisterTestRepository

# Test Items
$PrereleaseTestModule = "TestPackage"
$PrereleaseModuleLatestPrereleaseVersion = "3.0.0-alpha9"
$PrereleaseTestScript = "TestScript"
$PrereleaseScriptLatestPrereleaseVersion = "3.0.0-beta2"
$DscTestModule = "DscTestModule"
$DscTestModuleLatestVersion = "2.5.0-gamma"
$CommandInPrereleaseTestModule = "Test-PSGetTestCmdlet"
$DscResourceInPrereleaseTestModule = "DscTestResource"
$RoleCapabilityInPrereleaseTestModule = "Lev1Maintenance"










#========================
#    MODULE CMDLETS
#========================

Describe "--- New-ModuleManifest ---" -Tags "" {
    # N/A - implementation and tests in PowerShell code.
}

Describe "--- Test-ModuleManifest ---" -Tags "" {
    # N/A - implementation and tests in PowerShell code.
}

Describe "--- Update-ModuleManifest ---" -Tags "" {

    BeforeEach {
        # Create temp moduleManifest to be updated
        $script:TempModulesPath = Join-Path $TempPath "PSGet_$(Get-Random)"
        $null = New-Item -Path $script:TempModulesPath -ItemType Directory -Force
        $script:UpdateModuleManifestName = "ContosoPublishModule"
        $script:UpdateModuleManifestBase = Join-Path $script:TempModulesPath $script:UpdateModuleManifestName
        $null = New-Item -Path $script:UpdateModuleManifestBase -ItemType Directory -Force

        $script:testManifestPath = Microsoft.PowerShell.Management\Join-Path -Path $script:UpdateModuleManifestBase -ChildPath "$script:UpdateModuleManifestName.psd1"
    }

    AfterEach {
        RemoveItem "$script:TempModulesPath\*"
    }

    It "UpdateModuleManifestWithAllFields" {

        Set-Content "$script:UpdateModuleManifestBase\$script:UpdateModuleManifestName.psm1" -Value "function Get-$script:UpdateModuleManifestName { Get-Date }"
        $Guid =  [System.Guid]::Newguid().ToString()
        $Version = "2.0.0"
        $Description = "$script:UpdateModuleManifestName module"
        $ProcessorArchitecture = $env:PROCESSOR_ARCHITECTURE
        $ReleaseNotes = "$script:UpdateModuleManifestName release notes"
        $Prerelease = "-alpha001"
        $Tags = "PSGet","DSC"
        $ProjectUri = "http://$script:UpdateModuleManifestName.com/Project"
        $IconUri = "http://$script:UpdateModuleManifestName.com/Icon"
        $LicenseUri = "http://$script:UpdateModuleManifestName.com/license"
        $Author = "AuthorName"
        $CompanyName = "CompanyName"
        $CopyRight = "CopyRight"
        $RootModule = "$script:UpdateModuleManifestName.psm1"
        $PowerShellVersion = "3.0"
        $ClrVersion = "2.0"
        $DotNetFrameworkVersion = "2.0"
        $PowerShellHostVersion = "0.1"
        $TypesToProcess = "types","typesTwo"
        $FormatsToPorcess = "formats","formatsTwo"
        $RequiredAssemblies = "system.management.automation"
        $ModuleList = 'Microsoft.PowerShell.Management', 
               'Microsoft.PowerShell.Utility'
        $FunctionsToExport = "function1","function2"
        $AliasesToExport = "alias1","alias2"
        $VariablesToExport = "var1","var2"
        $CmdletsToExport="get-test1","get-test2"
        $HelpInfoURI = "http://$script:UpdateModuleManifestName.com/HelpInfoURI"
        $RequiredModules = @('Microsoft.PowerShell.Management',@{ModuleName='Microsoft.PowerShell.Utility';ModuleVersion='1.0.0.0';GUID='1da87e53-152b-403e-98dc-74d7b4d63d59'})
        $NestedModules = "Microsoft.PowerShell.Management","Microsoft.PowerShell.Utility"
        $ExternalModuleDependencies = "Microsoft.PowerShell.Management","Microsoft.PowerShell.Utility"

        $ParamsV3 = @{}
        $ParamsV3.Add("Guid",$Guid)
        $ParamsV3.Add("Author",$Author)
        $ParamsV3.Add("CompanyName",$CompanyName)
        $ParamsV3.Add("CopyRight",$CopyRight)
        $ParamsV3.Add("RootModule",$RootModule)
        $ParamsV3.Add("ModuleVersion",$Version)
        $ParamsV3.Add("Description",$Description)
        $ParamsV3.Add("ProcessorArchitecture",$ProcessorArchitecture)
        $ParamsV3.Add("PowerShellVersion",$PowerShellVersion)
        $ParamsV3.Add("ClrVersion",$ClrVersion)
        $ParamsV3.Add("DotNetFrameworkVersion",$DotNetFrameworkVersion)
        $ParamsV3.Add("PowerShellHostVersion",$PowerShellHostVersion)
        $ParamsV3.Add("RequiredModules",$RequiredModules)
        $ParamsV3.Add("RequiredAssemblies",$RequiredAssemblies)
        $ParamsV3.Add("NestedModules",$NestedModules)
        $ParamsV3.Add("ModuleList",$ModuleList)
        $ParamsV3.Add("FunctionsToExport",$FunctionsToExport)
        $ParamsV3.Add("AliasesToExport",$AliasesToExport)
        $ParamsV3.Add("VariablesToExport",$VariablesToExport)
        $ParamsV3.Add("CmdletsToExport",$CmdletsToExport)
        $ParamsV3.Add("HelpInfoURI",$HelpInfoURI)
        $ParamsV3.Add("Path",$script:testManifestPath)
        $ParamsV3.Add("ExternalModuleDependencies",$ExternalModuleDependencies)

        $paramsV5= $ParamsV3.Clone()
        $paramsV5.Add("Tags",$Tags)
        $ParamsV5.Add("ProjectUri",$ProjectUri)
        $ParamsV5.Add("LicenseUri",$LicenseUri)
        $ParamsV5.Add("IconUri",$IconUri)
        $ParamsV5.Add("ReleaseNotes",$ReleaseNotes)
        $ParamsV5.Add("Prerelease",$Prerelease)

        if(($PSVersionTable.PSVersion -ge '3.0.0') -or ($PSVersionTable.Version -le '4.0.0'))
        {
            New-ModuleManifest  -path $script:testManifestPath -Confirm:$false 
            Update-ModuleManifest @ParamsV3 -Confirm:$false
        }
        elseif($PSVersionTable.PSVersion -ge '5.0.0')
        {
            New-ModuleManifest  -path $script:testManifestPath -Confirm:$false 
            Update-ModuleManifest @ParamsV5 -Confirm:$false
        }
        $newModuleInfo = Test-ModuleManifest -Path $script:testManifestPath



        $newModuleInfo.Guid | Should Be $Guid 
        $newModuleInfo.Author | Should Be $Author
        $newModuleInfo.CompanyName | Should Be $CompanyName
        $newModuleInfo.CopyRight | Should Be $CopyRight
        $newModuleInfo.RootModule | Should Be $RootModule
        $newModuleInfo.Version | Should Be $Version
        $newModuleInfo.Description | Should Be $Description
        $newModuleInfo.ProcessorArchitecture | Should Be $ProcessorArchitecture
        $newModuleInfo.ClrVersion | Should Be $ClrVersion
        $newModuleInfo.DotNetFrameworkVersion | Should Be $DotNetFrameworkVersion
        $newModuleInfo.PowerShellHostVersion | Should Be $PowerShellHostVersion
        $newModuleInfo.RequiredAssemblies | Should Be $RequiredAssemblies
        $newModuleInfo.PowerShellHostVersion | Should Be $PowerShellHostVersion
        ($newModuleInfo.ModuleList.Name -contains $ModuleList[0]) | Should Be "True"
        ($newModuleInfo.ExportedFunctions.Keys -contains $FunctionsToExport[0]) | Should Be "True"
        ($newModuleInfo.ExportedFunctions.Keys -contains $FunctionsToExport[1]) | Should Be "True"
        ($newModuleInfo.ExportedAliases.Keys -contains $AliasesToExport[0]) | Should Be "True"
        ($newModuleInfo.ExportedAliases.Keys -contains $AliasesToExport[1]) | Should Be "True"
        ($newModuleInfo.ExportedVariables.Keys -contains $VariablesToExport[0]) | Should Be "True"
        ($newModuleInfo.ExportedVariables.Keys -contains $VariablesToExport[1]) | Should Be "True"
        ($newModuleInfo.ExportedCmdlets.Keys -contains ($CmdletsToExport[0])) | Should Be "True"
        ($newModuleInfo.ExportedCmdlets.Keys -contains ($CmdletsToExport[1])) | Should Be "True"
        if($PSVersionTable.Version -gt '5.0.0')
        {
            ($newModuleInfo.Tags -contains $Tags[0]) | Should Be "True"
            ($newModuleInfo.Tags -contains $Tags[1]) | Should Be "True"
            $newModuleInfo.ProjectUri | Should Be $ProjectUri 
            $newModuleInfo.LicenseUri | Should Be $LicenseUri
            $newModuleInfo.IconUri | Should Be $IconUri 
            $newModuleInfo.ReleaseNotes | Should Be $ReleaseNotes 
            $newModuleInfo.PrivateData.PSData.Prerelease | Should Be $Prerelease
        }
       
        $newModuleInfo.HelpInfoUri | Should Be $HelpInfoURI
        ($newModuleInfo.PrivateData.PSData.ExternalModuleDependencies -contains $ExternalModuleDependencies[0]) | Should Be "True"
        ($newModuleInfo.PrivateData.PSData.ExternalModuleDependencies -contains $ExternalModuleDependencies[1]) | Should Be "True"
    } `
    -Skip:$($IsWindows -eq $False) 

    It UpdateModuleManifestWithInvalidPrereleaseString {
        $Prerelease = "-alpha+001" 
        $Version = "3.2.1"

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Update-ModuleManifest"

        $ScriptBlock = {
            New-ModuleManifest -path $script:testManifestPath
            Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    } 

    It UpdateModuleManifestWithInvalidPrereleaseString2 {
        $Prerelease = "-alpha-beta.01" 
        $Version = "3.2.1"

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Update-ModuleManifest"

        $ScriptBlock = {
            New-ModuleManifest -path $script:testManifestPath
            Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    } 

    It UpdateModuleManifestWithInvalidPrereleaseString3 {
        $Prerelease = "-alpha.1" 
        $Version = "3.2.1"

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Update-ModuleManifest"

        $ScriptBlock = {
            New-ModuleManifest -path $script:testManifestPath
            Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    } 

    It UpdateModuleManifestWithInvalidPrereleaseString4 {
        $Prerelease = "-error.0.0.0.1" 
        $Version = "3.2.1"

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Update-ModuleManifest"

        $ScriptBlock = {
            New-ModuleManifest -path $script:testManifestPath
            Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    } 

    It UpdateModuleManifestWithPrereleaseStringAndShortModuleVersion {
        $Prerelease = "-alpha001" 
        $Version = "3.2"

        $expectedErrorMessage = $LocalizedData.IncorrectVersionPartsCountForPrereleaseStringUsage
        $expectedFullyQualifiedErrorId = "IncorrectVersionPartsCountForPrereleaseStringUsage,Update-ModuleManifest"

        $ScriptBlock = {
            New-ModuleManifest -path $script:testManifestPath
            Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    } 
    
    It UpdateModuleManifestWithValidPrereleaseAndModuleVersion {
        $Prerelease = "alpha001" 
        $Version = "3.2.1"

        New-ModuleManifest -path $script:testManifestPath 
        Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false

        $newModuleInfo = Test-ModuleManifest -Path $script:testManifestPath

        $newModuleInfo.Version | Should -Match $Version
        $newModuleInfo.PrivateData.PSData.Prerelease | Should -Match $Prerelease
    } 

    It UpdateModuleManifestWithValidPrereleaseAndModuleVersion2 {
        $Prerelease = "-gamma001" 
        $Version = "3.2.1"

        New-ModuleManifest -path $script:testManifestPath 
        Update-ModuleManifest -Path $script:testManifestPath -Prerelease $Prerelease -ModuleVersion $Version -Confirm:$false

        $newModuleInfo = Test-ModuleManifest -Path $script:testManifestPath

        $newModuleInfo.Version | Should -Match $Version
        $newModuleInfo.PrivateData.PSData.Prerelease | Should -Match $Prerelease
    }
}

Describe "--- Publish-Module ---" -Tags "" {
    
    BeforeAll {

        # Create file-based repository from scratch
        $script:PSGalleryRepoPath="$env:SystemDrive\PSGalleryRepo"
        RemoveItem $script:PSGalleryRepoPath
        $null = New-Item -Path $script:PSGalleryRepoPath -ItemType Directory -Force
    
        # Backup existing repositories config file
        $script:moduleSourcesFilePath= Join-Path $PSGetLocalAppDataPath "PSRepositories.xml"
        $script:moduleSourcesBackupFilePath = Join-Path $PSGetLocalAppDataPath "PSRepositories.xml_$(get-random)_backup"
        if(Test-Path $script:moduleSourcesFilePath)
        {
            Rename-Item $script:moduleSourcesFilePath $script:moduleSourcesBackupFilePath -Force
        }
    
        # Set file-based repo as default PSGallery repo
        Set-PSGallerySourceLocation -Location $script:PSGalleryRepoPath -PublishLocation $script:PSGalleryRepoPath
    
        $modSource = Get-PSRepository -Name "PSGallery"
        $modSource.SourceLocation | Should Be $script:PSGalleryRepoPath
        $modSource.PublishLocation | Should Be $script:PSGalleryRepoPath 
    
        $script:ApiKey="TestPSGalleryApiKey"
    
        # Create temp module to be published
        $script:TempModulesPath="$env:LocalAppData\temp\PSGet_$(Get-Random)"
        $null = New-Item -Path $script:TempModulesPath -ItemType Directory -Force
        $script:PublishModuleName = "ContosoPublishModule"
        $script:PublishModuleBase = Join-Path $script:TempModulesPath $script:PublishModuleName
        $null = New-Item -Path $script:PublishModuleBase -ItemType Directory -Force
    }

    AfterAll {
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
    
        RemoveItem $script:PSGalleryRepoPath
        RemoveItem $script:TempModulesPath
    }

    BeforeEach {
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psm1" -Value "function Get-$script:PublishModuleName { Get-Date }"
    }

    AfterEach {
        RemoveItem "$script:PSGalleryRepoPath\*"
        RemoveItem "$ProgramFilesModulesPath\$script:PublishModuleName"
        RemoveItem "$script:PublishModuleBase\*"
    }

    
    It "PublishModuleSameVersionHigherPreRelease" {
        $version = "1.0.0"
        $preRelease = "-alpha001"
        
        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module" -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease

        #Copy module to $ProgramFilesModulesPath
        Copy-Item $script:PublishModuleBase $ProgramFilesModulesPath -Recurse -Force

        Publish-Module -Name $script:PublishModuleName -NuGetApiKey $script:ApiKey -ReleaseNotes "$script:PublishModuleName release notes" -Tags PSGet -LicenseUri "http://$script:PublishModuleName.com/license" -ProjectUri "http://$script:PublishModuleName.com" -WarningAction SilentlyContinue
        
        $psgetItemInfo = Find-Module -Name $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Be $true

        # Publish new prerelease version
        $preRelease = "-beta002"

        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease

        #Copy module to $ProgramFilesModulesPath
        Copy-Item $script:PublishModuleBase $ProgramFilesModulesPath -Recurse -Force
        
        $scriptBlock = {
            Publish-Module -Name $script:PublishModuleName -NuGetApiKey $script:ApiKey -ReleaseNotes "$script:PublishModuleName release notes" -Tags PSGet -LicenseUri "http://$script:PublishModuleName.com/license" -ProjectUri "http://$script:PublishModuleName.com" -WarningAction SilentlyContinue
        }
        $scriptBlock | Should Not Throw
        
        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PublishModuleWithForceSameVersionLowerPreRelease" {
        $version = "1.0.0"
        $preRelease = "-beta002"

        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease

        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"


        # Publish lower prerelease version
        $preRelease = "-alpha001"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease
        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -Force
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
    
    It "PublishModuleWithoutForceSameVersionLowerPreRelease" {
        $version = "1.0.0"
        $preRelease = "-beta002"

        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease
        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"


        # Publish lower prerelease version
        $preRelease2 = "-alpha001"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease2
        
        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey
        }

        $expectedErrorMessage = $LocalizedData.ModuleVersionShouldBeGreaterThanGalleryVersion -f ($script:PublishModuleName,$version,$($version + $preRelease),$script:PSGalleryRepoPath)
        $expectedFullyQualifiedErrorId = "ModuleVersionShouldBeGreaterThanGalleryVersion,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishModuleSameVersionSamePreRelease" {
        $version = "1.0.0"
        $preRelease = "-alpha001"

        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease
        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey
        }

        $expectedErrorMessage = $LocalizedData.ModuleVersionIsAlreadyAvailableInTheGallery -f ($script:PublishModuleName,$version,$($version + $preRelease),$script:PSGalleryRepoPath)
        $expectedFullyQualifiedErrorId = "ModuleVersionIsAlreadyAvailableInTheGallery,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
    
    It "PublishModuleSameVersionNoPreRelease" {
        $version = "1.0.0"
        $preRelease = "-alpha001"

        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease
        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"

        # Publish the stable version

        # create a new module manifest with same version but now no prerelease
        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    It "PublishModuleWithForceNewPreReleaseAfterStableVersion" {
        $version = "1.0.0"

        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1"
        
        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"


        # Publish prerelease version
        $preRelease = "-alpha001"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease
        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -Force -WarningAction SilentlyContinue
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $($version + $preRelease) -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PublishModuleWithoutForceNewPreReleaseAfterStableVersion" {
        $version = "1.0.0"
        New-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -ModuleVersion $version -Description "$script:PublishModuleName module"  -NestedModules "$script:PublishModuleName.psm1"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1"
        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"


        # Publish prerelease version
        $preRelease = "-alpha001"
        Update-ModuleManifest -Path "$script:PublishModuleBase\$script:PublishModuleName.psd1" -PreRelease $preRelease
        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }

        $expectedErrorMessage = $LocalizedData.ModuleVersionShouldBeGreaterThanGalleryVersion -f ($script:PublishModuleName,$version,$version,$script:PSGalleryRepoPath)
        $expectedFullyQualifiedErrorId = "ModuleVersionShouldBeGreaterThanGalleryVersion,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishModuleWithInvalidPrereleaseString" {
        
        # Create manifest without using Update-ModuleManifest, it will throw validation error.
        $invalidPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Invalid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-alpha+001'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $invalidPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPreReleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPreReleaseString,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishModuleWithInvalidPrereleaseString2" {

        # Create manifest without using Update-ModuleManifest, it will throw validation error.
        $invalidPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Invalid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-alpha-beta.01'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $invalidPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPreReleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPreReleaseString,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishModuleWithInvalidPrereleaseString3" {

        # Create manifest without using Update-ModuleManifest, it will throw validation error.
        $invalidPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Invalid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-alpha.1'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $invalidPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPreReleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPreReleaseString,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishModuleWithInvalidPrereleaseString4" {

        # Create manifest without using Update-ModuleManifest, it will throw validation error.
        $invalidPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Invalid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-error.0.0.0.1'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $invalidPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPreReleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPreReleaseString,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishModuleWithPrereleaseStringAndShortVersion" {

        # Create manifest without using Update-ModuleManifest, it will throw validation error.
        $invalidPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '3.2'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Invalid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-alpha001'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $invalidPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }

        $expectedErrorMessage = $LocalizedData.IncorrectVersionPartsCountForPrereleaseStringUsage
        $expectedFullyQualifiedErrorId = "IncorrectVersionPartsCountForPrereleaseStringUsage,Publish-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
    
    It "PublishModuleWithPrereleaseStringAndLongVersion" {

        # Create manifest without using Update-ModuleManifest, it will throw validation error.
        $invalidPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '3.2.1.0.5'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Invalid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-alpha001'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $invalidPreReleaseModuleManifestContent


        Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -ErrorVariable ev -ErrorAction SilentlyContinue

        $ev.Count | Should Not Be 0
        $ev[1].FullyQualifiedErrorId | Should Be "Modules_InvalidManifest,Microsoft.PowerShell.Commands.TestModuleManifestCommand"
    }

    It "PublishModuleWithValidPrereleaseAndVersion" {

        # Create manifest without using Update-ModuleManifest
        $validPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Valid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = 'alpha001'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $validPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion "1.0.0-alpha001" -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PublishModuleWithValidPrereleaseAndVersion2" {

        # Create manifest without using Update-ModuleManifest
        $validPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Valid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = '-gamma002'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
        Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $validPreReleaseModuleManifestContent

        $scriptBlock = {
            Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion "1.0.0.0-gamma002" -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishModuleName
        $psgetItemInfo.Version | Should Match $($version + $preRelease)
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PublishModuleWithEmptyPrereleaseFieldShouldSucceed" {
        
        # Create manifest without using Update-ModuleManifest
        $validPreReleaseModuleManifestContent = @"
@{
    # Version number of this module.
    ModuleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = 'e359354f-93ff-449e-8ae1-3173245215bd'

    # Author of this module
    Author = 'rebro'

    # Company or vendor of this module
    CompanyName = 'Unknown'

    # Copyright statement for this module
    Copyright = '(c) 2017 rebro. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Valid PreRelease module manifest'

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Prerelease string, part of Version
            PreRelease = ''
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
"@
                Set-Content "$script:PublishModuleBase\$script:PublishModuleName.psd1" -Value $validPreReleaseModuleManifestContent
        
                $scriptBlock = {
                    Publish-Module -Path $script:PublishModuleBase -NuGetApiKey $script:ApiKey -WarningAction SilentlyContinue
                }
                $scriptBlock | Should Not Throw
        
                $psgetItemInfo = Find-Module $script:PublishModuleName -RequiredVersion "1.0.0" -AllowPrerelease
                $psgetItemInfo.Name | Should Be $script:PublishModuleName
                $psgetItemInfo.Version | Should Match $version
                $psgetItemInfo.AdditionalMetadata | Should Not Be $null
                $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
    }
}


Describe "--- Find-Module ---" -Tags "" {

    It FindModuleReturnsLatestStableVersion {
        $psgetModuleInfo = Find-Module -Name $PrereleaseTestModule -Repository $TestRepositoryName

        # check that IsPrerelease = false, and Prerelease string is null.
        $psgetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
        $psgetModuleInfo.Version | Should Not Match '-'
    }

    It FindModuleAllowPrereleaseReturnsLatestPrereleaseVersion {
        $psgetModuleInfo = Find-Module -Name $PrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
        $psgetModuleInfo.Version | Should Match '-'
    }
    
    It FindModuleAllowPrereleaseAllVersions {
        $results = Find-Module -Name $PrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -AllVersions

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }
    
    It FindModuleAllVersionsShouldReturnOnlyStableVersions {
        $results = Find-Module -Name $PrereleaseTestModule -Repository $TestRepositoryName -AllVersions

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should Not BeGreaterThan 0
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }

    It FindModuleSpecificPrereleaseVersionWithAllowPrerelease {
        $version = "2.0.0-beta500"
        $psgetModuleInfo = Find-Module -Name $PrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -AllowPrerelease

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetModuleInfo.Version | Should Match $version
        $psgetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It FindModuleSpecificPrereleaseVersionWithoutAllowPrerelease {
        $version = "2.0.0-beta500"

        $scriptBlock = {
            Find-Module -Name $PrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName
        }

        $expectedErrorMessage = $LocalizedData.AllowPrereleaseRequiredToUsePrereleaseStringInVersion
        $expectedFullyQualifiedErrorId = "AllowPrereleaseRequiredToUsePrereleaseStringInVersion,Find-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    <#
    It FindModuleAllowPrereleaseIncludeDependencies {

        # try to get only one prerelease version
        $resultsSingle = Find-Module -Name $PrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -MinimumVersion "0.1" -MaximumVersion "1.0" 
        $resultsSingle.Count | Should Be 1
        $resultsSingle.Name | Should Be $PrereleaseTestModule

        # try to get only one prerelease version and its dependencies
        $resultsDependencies = Find-Module -Name $PrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -MinimumVersion "0.1" -MaximumVersion "1.0"  -IncludeDependencies
        $resultsDependencies.Count | Should BeGreaterThan $DependencyModuleNames.Count+1

        # Check that it returns all dependencies and at least one dependency is a prerelease
        $DependencyModuleNames = $resultsSingle.Dependencies.Name
        $DependencyModuleNames | ForEach-Object { $resultsDependencies.Name -Contains $_.Name | Should Be $true }
        $resultsDependencies | Where-Object { ($_.Name -ne $PrereleaseTestModule) -and ($_.AdditionalMetadata.IsPrerelease -eq $true) } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }
    #>

    It FindModuleByNameWithAllowPrereleaseDownlevel {
        $script = {
            Find-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It FindSpecificPrereleaseModuleVersionByNameWithoutAllowPrereleaseFlagDownlevel {
        $script = {
            Find-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It FindSpecificPrereleaseModuleVersionByNameWithAllowPrereleaseFlagDownlevel {
        $script = {
            Find-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')
}

Describe "--- Find-DscResource ---" -Tags "" {

    It FindDscResourceReturnsLatestStableVersion {
        $psgetCommandInfo = Find-DscResource -Name $DscResourceInPrereleaseTestModule -Repository $TestRepositoryName

        # check that IsPrerelease = false, and Prerelease string is null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Not Match '-'
    }

    It FindDscResourceAllowPrereleaseReturnsLatestPrereleaseVersion {
        $psgetCommandInfo = Find-DscResource -Name $DscResourceInPrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -ModuleName $DscTestModule

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Match '-'
    }
    
    It FindDscResourceAllowPrereleaseAllVersions {
        $results = Find-DscResource -Name $DscResourceInPrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -AllVersions -ModuleName $DscTestModule

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.PSGetModuleInfo.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.PSGetModuleInfo.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }
     
    It FindDscResourceAllVersionsShouldReturnOnlyStableVersions {
        $results = Find-DscResource -Name $DscResourceInPrereleaseTestModule -Repository $TestRepositoryName -AllVersions -ModuleName $DscTestModule

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.PSGetModuleInfo.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should Not BeGreaterThan 0
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.PSGetModuleInfo.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }

    It FindDscResourceSpecificPrereleaseVersionWithAllowPrerelease {
        $version = "2.0.0-beta200"
        $psgetCommandInfo = Find-DscResource -Name $DscResourceInPrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -AllowPrerelease -ModuleName $DscTestModule

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Match $version
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It FindDscResourceSpecificPrereleaseVersionWithoutAllowPrerelease {
        $version = "2.0.0-beta200"

        $scriptBlock = {
            Find-DscResource -Name $DscResourceInPrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -ModuleName $DscTestModule
        }

        $expectedErrorMessage = $LocalizedData.AllowPrereleaseRequiredToUsePrereleaseStringInVersion
        $expectedFullyQualifiedErrorId = "AllowPrereleaseRequiredToUsePrereleaseStringInVersion,Find-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
}

Describe "--- Find-Command ---" -Tags "" {

    It FindCommandReturnsLatestStableVersion {
        $psgetCommandInfo = Find-Command -Name $CommandInPrereleaseTestModule -Repository $TestRepositoryName

        # check that IsPrerelease = false, and Prerelease string is null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Not Match '-'
    }

    It FindCommandAllowPrereleaseReturnsLatestPrereleaseVersion {
        $psgetCommandInfo = Find-Command -Name $CommandInPrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -ModuleName $DscTestModule

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Match '-'
    }

    It FindCommandAllowPrereleaseAllVersions {
        $results = Find-Command -Name $CommandInPrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -AllVersions -ModuleName $DscTestModule

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.PSGetModuleInfo.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.PSGetModuleInfo.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }

    It FindCommandAllVersionsShouldReturnOnlyStableVersions {
        $results = Find-Command -Name $CommandInPrereleaseTestModule -Repository $TestRepositoryName -AllVersions -ModuleName $DscTestModule

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.PSGetModuleInfo.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should Not BeGreaterThan 0
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.PSGetModuleInfo.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }

    It FindCommandSpecificPrereleaseVersionWithAllowPrerelease {
        $version = "2.0.0-beta200"
        $psgetCommandInfo = Find-Command -Name $CommandInPrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -AllowPrerelease -ModuleName $DscTestModule

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Match $version
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It FindCommandSpecificPrereleaseVersionWithoutAllowPrerelease {
        $version = "2.0.0-beta200"

        $scriptBlock = {
            Find-Command -Name $CommandInPrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -ModuleName $DscTestModule
        }

        $expectedErrorMessage = $LocalizedData.AllowPrereleaseRequiredToUsePrereleaseStringInVersion
        $expectedFullyQualifiedErrorId = "AllowPrereleaseRequiredToUsePrereleaseStringInVersion,Find-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

}

Describe "--- Find-RoleCapability ---" -Tags "" {
    
    It FindRoleCapabilityReturnsLatestStableVersion {
        $psgetCommandInfo = Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -Repository $TestRepositoryName

        # check that IsPrerelease = false, and Prerelease string is null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Not Match '-'
    }

    It FindRoleCapabilityAllowPrereleaseReturnsLatestPrereleaseVersion {
        $psgetCommandInfo = Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -ModuleName $DscTestModule

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Match '-'
    }
    
    It FindRoleCapabilityAllowPrereleaseAllVersions {
        $results = Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -Repository $TestRepositoryName -AllowPrerelease -AllVersions -ModuleName $DscTestModule

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.PSGetModuleInfo.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.PSGetModuleInfo.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }
    
    It FindRoleCapabilityAllVersionsShouldReturnOnlyStableVersions {
        $results = Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -Repository $TestRepositoryName -AllVersions -ModuleName $DscTestModule

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.PSGetModuleInfo.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should Not BeGreaterThan 0
        $results | Where-Object { ($_.PSGetModuleInfo.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.PSGetModuleInfo.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }

    It FindRoleCapabilitySpecificPrereleaseVersionWithAllowPrerelease {
        $version = "2.0.0-beta200"
        $psgetCommandInfo = Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -AllowPrerelease -ModuleName $DscTestModule

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetCommandInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.Version | Should Match $version
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata | Should Not Be $null
        $psgetCommandInfo.PSGetModuleInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It FindRoleCapabilitySpecificPrereleaseVersionWithoutAllowPrerelease {
        $version = "2.0.0-beta200"

        $scriptBlock = {
            Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -RequiredVersion $version -Repository $TestRepositoryName -ModuleName $DscTestModule
        }

        $expectedErrorMessage = $LocalizedData.AllowPrereleaseRequiredToUsePrereleaseStringInVersion
        $expectedFullyQualifiedErrorId = "AllowPrereleaseRequiredToUsePrereleaseStringInVersion,Find-Module"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
}

Describe "--- Install-Module ---" -Tags "" {
    
    BeforeAll {
        PSGetTestUtils\Uninstall-Module TestPackage
        PSGetTestUtils\Uninstall-Module DscTestModule
    }

    AfterEach {
        PSGetTestUtils\Uninstall-Module TestPackage
        PSGetTestUtils\Uninstall-Module DscTestModule
    }


    # Piping tests 
    #--------------
    
    It "PipeFindToInstallModuleByNameAllowPrerelease" {
        Find-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName | Install-Module
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match $PrereleaseModuleLatestPrereleaseVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindToInstallModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName | Install-Module
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "2.0.0-beta500"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindToInstallModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName | Install-Module
        }
        $script | Should Throw
    }
    
    # Find-Command | Install-Module
    #--------------------------------
    It "PipeFindCommandToInstallModuleByNameAllowPrerelease" {
        Find-Command -Name $CommandInPrereleaseTestModule -ModuleName $DscTestModule -Repository $TestRepositoryName -AllowPrerelease | Install-Module
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match $DscTestModuleLatestVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindCommandToInstallModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-Command -Name $CommandInPrereleaseTestModule -ModuleName $DscTestModule -Repository $TestRepositoryName -AllowPrerelease -RequiredVersion "2.0.0-beta200" | Install-Module
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match "2.0.0-beta200"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindCommandToInstallModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-Command -Name $CommandInPrereleaseTestModule -ModuleName $DscTestModule -Repository $TestRepositoryName -RequiredVersion "2.0.0-beta200" | Install-Module
        }
        $script | Should Throw
    }

    # Find-DscResource | Install-Module
    #-----------------------------------
    It "PipeFindDscResourceToInstallModuleByNameAllowPrerelease" {
        Find-DscResource -Name $DscResourceInPrereleaseTestModule -ModuleName $DscTestModule -AllowPrerelease -Repository $TestRepositoryName | Install-Module
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match $DscTestModuleLatestVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindDscResourceToInstallModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-DscResource -Name $DscResourceInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -AllowPrerelease -Repository $TestRepositoryName | Install-Module
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match "2.0.0-beta200"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindDscResourceToInstallModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-DscResource -Name $DscResourceInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -Repository $TestRepositoryName | Install-Module
        }
        $script | Should Throw
    }

    # Find-RoleCapability | Install-Module
    #---------------------------------------
    It "PipeFindRoleCapabilityToInstallModuleByNameAllowPrerelease" {
        Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -ModuleName $DscTestModule -AllowPrerelease -Repository $TestRepositoryName | Install-Module
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match $DscTestModuleLatestVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindRoleCapabilityToInstallModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -AllowPrerelease -Repository $TestRepositoryName | Install-Module
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match "2.0.0-beta200"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindRoleCapabilityToInstallModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -Repository $TestRepositoryName | Install-Module
        }
        $script | Should Throw
    }
    


    # Regular Install Tests 
    #-----------------------

    It "InstallPrereleaseModuleByName" {
        Install-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not BeNullOrEmpty
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Be $PrereleaseModuleLatestPrereleaseVersion
    }
    
    It "InstallSpecificPrereleaseModuleVersionByNameWithAllowPrerelease" {
        Install-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not BeNullOrEmpty
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Be "2.0.0-beta500"
    }
    
    It "InstallSpecificPrereleaseModuleVersionByNameWithoutAllowPrerelease" {
        $script = {
            Install-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName
        }
        $script | Should Throw
    }



    # Downlevel Tests
    #-----------------

    It "InstallModuleByNameWithAllowPrereleaseDownlevel" {
        $script = {
            Install-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "InstallSpecificPrereleaseModuleVersionByNameWithoutAllowPrereleaseFlagDownlevel" {
        $script = {
            Install-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "InstallSpecificPrereleaseModuleVersionByNameWithAllowPrereleaseFlagDownlevel" {
        $script = {
            Install-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')
    


}

Describe "--- Save-Module ---" -Tags "" {
    
    BeforeAll {
        PSGetTestUtils\Uninstall-Module TestPackage
        PSGetTestUtils\Uninstall-Module DscTestModule
    }

    AfterEach {
        PSGetTestUtils\Uninstall-Module TestPackage
        PSGetTestUtils\Uninstall-Module DscTestModule
    }

    # Piping tests 
    #--------------
    
    It "PipeFindToSaveModuleByNameAllowPrerelease" {
        Find-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match $PrereleaseModuleLatestPrereleaseVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindToSaveModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "2.0.0-beta500"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindToSaveModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw
    }
    

    # Find-Command | Save-Module
    #-----------------------------
    It "PipeFindCommandToSaveModuleByNameAllowPrerelease" {
        Find-Command -Name $CommandInPrereleaseTestModule -ModuleName $DscTestModule -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match $DscTestModuleLatestVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindCommandToSaveModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-Command -Name $CommandInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match "2.0.0-beta200"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindCommandToSaveModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-Command -Name $CommandInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw
    }

    # Find-DscResource | Save-Module
    #--------------------------------
    It "PipeFindDscResourceToSaveModuleByNameAllowPrerelease" {
        Find-DscResource -Name $DscResourceInPrereleaseTestModule -ModuleName $DscTestModule -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match $DscTestModuleLatestVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindDscResourceToSaveModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-DscResource -Name $DscResourceInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match "2.0.0-beta200"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindDscResourceToSaveModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-DscResource -Name $DscResourceInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw
    }

    # Find-RoleCapability | Save-Module
    #-----------------------------------
    It "PipeFindRoleCapabilityToSaveModuleByNameAllowPrerelease" {
        Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -ModuleName $DscTestModule -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match $DscTestModuleLatestVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindRoleCapabilityToSaveModuleSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -AllowPrerelease -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $script:DscTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $script:DscTestModule
        $res.Version | Should Match "2.0.0-beta200"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PipeFindRoleCapabilityToSaveModuleSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-RoleCapability -Name $RoleCapabilityInPrereleaseTestModule -ModuleName $DscTestModule -RequiredVersion "2.0.0-beta200" -Repository $TestRepositoryName | Save-Module -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw
    }
    


    # Regular Save Tests 
    #-----------------------
    
    It "SavePrereleaseModuleByName" {
        Save-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not BeNullOrEmpty
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Be $PrereleaseModuleLatestPrereleaseVersion
    }
    
    It "SaveSpecificPrereleaseModuleVersionByNameWithAllowPrerelease" {
        Save-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsModulesPath
        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not BeNullOrEmpty
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Be "2.0.0-beta500"
    }
    
    It "SaveSpecificPrereleaseModuleVersionByNameWithoutAllowPrerelease" {
        $script = {
            Save-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw
    }



    # Downlevel Tests
    #-----------------
    
    It "SaveModuleByNameWithAllowPrereleaseDownlevel" {
        $script = {
            Save-Module -Name $PrereleaseTestModule -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "SaveSpecificPrereleaseModuleVersionByNameWithoutAllowPrereleaseFlagDownlevel" {
        $script = {
            Save-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "SaveSpecificPrereleaseModuleVersionByNameWithAllowPrereleaseFlagDownlevel" {
        $script = {
            Save-Module -Name $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsModulesPath
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')
    
}

Describe "--- Update-Module ---" -Tags "" {
    
    BeforeAll {
        PSGetTestUtils\Uninstall-Module TestPackage
    }

    AfterEach {
        PSGetTestUtils\Uninstall-Module TestPackage
    }


    # Updated to latest release version by default: When release version is installed (ex. 1.0.0 --> 2.0.0)
    It "UpdateModuleFromReleaseToReleaseVersionByDefault" {
        Install-Module $PrereleaseTestModule -RequiredVersion "1.0.0" -Repository $TestRepositoryName
        Update-Module $PrereleaseTestModule # Should update to latest stable version 2.0.0

        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "2.0.0"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    # Updated to latest release version by default: When prerelease version is installed (ex. 1.0.0-omega55 --> 2.0.0)
    It "UpdateModuleFromPrereleaseToReleaseVersionByDefault" {
        Install-Module $PrereleaseTestModule -RequiredVersion "1.0.0-omega55" -AllowPrerelease -Repository $TestRepositoryName
        Update-Module $PrereleaseTestModule # Should update to latest stable version 2.0.0

        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "2.0.0"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    # (In place update): prerelease to release, same root version.  (ex. 2.0.0-beta500 --> 2.0.0)
    It "UpdateModuleSameVersionPrereleaseToReleaseInPlaceUpdate" {
        Install-Module $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        Update-Module $PrereleaseTestModule # Should update to latest stable version 2.0.0

        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Be "2.0.0"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    # (In place update): prerelease to prerelease, same root version.  (ex. 2.0.0-beta500 --> 2.0.0-gamma300)    
    It "UpdateModuleSameVersionPrereleaseToPrereleaseInPlaceUpdate" {
        Install-Module $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        Update-Module  $PrereleaseTestModule -RequiredVersion "2.0.0-gamma300" -AllowPrerelease # Should update to latest prerelease version 2.0.0-gamma300

        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "2.0.0-gamma300"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    # Updated from stable to prerelease in new version (ex. 2.0.0 --> 3.0.0-alpha9)
    It "UpdateModuleFromReleaseToPrereleaseDifferentVersion" {
        Install-Module $PrereleaseTestModule -RequiredVersion "2.0.0" -Repository $TestRepositoryName
        Update-Module  $PrereleaseTestModule -AllowPrerelease # Should update to latest prerelease version 3.0.0-alpha9

        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "3.0.0-alpha9"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    # prerelease --> prerelease  (different root version) (ex. 2.0.0-beta500 --> 3.0.0-alpha9)
    It "UpdateModuleFromPrereleaseToPrereleaseDifferentRootVersion" {
        Install-Module $PrereleaseTestModule -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        Update-Module  $PrereleaseTestModule -AllowPrerelease # Should update to latest prerelease version 3.0.0-alpha9

        $res = Get-InstalledModule -Name $PrereleaseTestModule

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestModule
        $res.Version | Should Match "3.0.0-alpha9"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
}

Describe "--- Uninstall-Module ---" -Tags "" {
    
    BeforeAll {
        PSGetTestUtils\Uninstall-Module TestPackage
    }

    AfterEach {
        PSGetTestUtils\Uninstall-Module TestPackage
    }


    # Uninstall a prerelease module
    It UninstallPrereleaseModule {

        $moduleName = "TestPackage"

        PowerShellGet\Install-Module -Name $moduleName -RequiredVersion "1.0.0" -Repository $TestRepositoryName -Force
        $mod = Get-InstalledModule -Name $moduleName
        $mod | Should Not Be $null
        $mod | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $mod.Name | Should Be $moduleName
        $mod.Version | Should Match "1.0.0"
        $mod.AdditionalMetadata | Should Not Be $null
        $mod.AdditionalMetadata.IsPrerelease | Should Match "false"

        PowerShellGet\Install-Module -Name $moduleName -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName -Force
        $mod = Get-InstalledModule -Name $moduleName
        $mod | Should Not Be $null
        $mod | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $mod.Name | Should Be $moduleName
        $mod.Version | Should Match "2.0.0-beta500"
        $mod.AdditionalMetadata | Should Not Be $null
        $mod.AdditionalMetadata.IsPrerelease | Should Match "true"

        PowerShellGet\Update-Module -Name $moduleName -RequiredVersion "3.0.0-alpha9" -AllowPrerelease
        $mod2 = Get-InstalledModule -Name $moduleName
        $mod2 | Should Not Be $null
        $mod2 | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $mod2.Name | Should Be $moduleName
        $mod2.Version | Should Match "3.0.0-alpha9"
        $mod2.AdditionalMetadata | Should Not Be $null
        $mod2.AdditionalMetadata.IsPrerelease | Should Match "true"
        
        $modules2 = Get-InstalledModule -Name $moduleName -AllVersions

        if($PSVersionTable.PSVersion -gt '5.0.0')
        {
            $modules2 | Measure-Object | ForEach-Object { $_.Count } | Should Be 3
        }
        else
        {
            $mod2.Name | Should Be $moduleName
        }   

        PowerShellGet\Uninstall-Module -Name $moduleName -AllVersions
        $installedModules = Get-InstalledModule -Name $moduleName -AllVersions -ErrorAction SilentlyContinue

        $installedModules | Should Be $null
    }
}







#========================
#     SCRIPT CMDLETS
#========================

Describe "--- New-ScriptFileInfo ---" -Tags "" {
    # N/A - tested below
}

Describe "--- Test-ScriptFileInfo ---" -Tags "" {
    
    BeforeAll {
        # Create temp module to be published
        $script:TempScriptsPath="$env:LocalAppData\temp\PSGet_$(Get-Random)"
        $null = New-Item -Path $script:TempScriptsPath -ItemType Directory -Force
    
        $script:PublishScriptName = 'Fabrikam-TestScript'
        $script:PublishScriptVersion = '1.0'
        $script:PublishScriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "$script:PublishScriptName.ps1"
    }

    AfterAll {
        RemoveItem $script:TempScriptsPath
    }

    BeforeEach {
        
        $null = New-ScriptFileInfo -Path $script:PublishScriptFilePath `
                               -Version $script:PublishScriptVersion `
                               -Author Manikyam.Bavandla@microsoft.com `
                               -Description 'Test script description goes here ' `
                               -Force

        Add-Content -Path $script:PublishScriptFilePath `
                    -Value "
                        Function Test-ScriptFunction { 'Test-ScriptFunction' }

                        Workflow Test-ScriptWorkflow { 'Test-ScriptWorkflow' }

                        Test-ScriptFunction
                        Test-ScriptWorkflow"
    }

    AfterEach {     
        RemoveItem $script:PublishScriptFilePath
        RemoveItem "$script:TempScriptsPath\*.ps1"
    }


    # Purpose: Test a script file info with an invalid Prerelease string
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1-alpha+001
    #
    # Expected Result: Test-ScriptFileInfo should throw InvalidCharactersInPrereleaseString errorid.
    #
    It "TestScriptFileWithInvalidPrereleaseString" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha+001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $ScriptBlock = {
            Test-ScriptFileInfo -Path $scriptFilePath
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    # Purpose: Test a script file info with an invalid Prerelease string
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1-alpha-beta.01
    #
    # Expected Result: Test-ScriptFileInfo should throw InvalidCharactersInPrereleaseString errorid.
    #
    It "TestScriptFileWithInvalidPrereleaseString2" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha-beta.01
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $ScriptBlock = {
            Test-ScriptFileInfo -Path $scriptFilePath 
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    # Purpose: Test a script file info with an invalid Prerelease string
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1-alpha.1
    #
    # Expected Result: Test-ScriptFileInfo should throw InvalidCharactersInPrereleaseString errorid.
    #
    It "TestScriptFileWithInvalidPrereleaseString3" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha.1
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $ScriptBlock = {
            Test-ScriptFileInfo -Path $scriptFilePath
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    # Purpose: Test a script file info with an invalid Prerelease string
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1-error.0.0.0.1
    #
    # Expected Result: Test-ScriptFileInfo should throw InvalidCharactersInPrereleaseString errorid.
    #
    It "TestScriptFileWithInvalidPrereleaseString4" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-error.0.0.0.1
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $ScriptBlock = {
            Test-ScriptFileInfo -Path $scriptFilePath
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    # Purpose: Test a script file info with an Prerelease string when the version has insufficient parts.
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2-alpha+001
    #
    # Expected Result: Test-ScriptFileInfo should throw IncorrectVersionPartsCountForPrereleaseStringUsage errorid.
    #
    It "TestScriptFileWithPrereleaseStringAndShortVersion" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2-alpha001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $ScriptBlock = {
            Test-ScriptFileInfo -Path $scriptFilePath
        }

        $expectedErrorMessage = $LocalizedData.IncorrectVersionPartsCountForPrereleaseStringUsage
        $expectedFullyQualifiedErrorId = "IncorrectVersionPartsCountForPrereleaseStringUsage,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
    
    # Purpose: Test a script file info with an Prerelease string when the version has too many parts.
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1.0.5-alpha001
    #
    # Expected Result: Test-ScriptFileInfo should throw IncorrectVersionPartsCountForPrereleaseStringUsage errorid.
    #
    It "TestScriptFileWithPrereleaseStringAndLongVersion" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1.0.5-alpha001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        $ScriptBlock = {
            Test-ScriptFileInfo -Path $scriptFilePath
        }

        $expectedErrorMessage = $LocalizedData.InvalidVersion -f '3.2.1.0.5-alpha001'
        $expectedFullyQualifiedErrorId = "InvalidVersion,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    # Purpose: Test a script file info with a valid Prerelease string and a version with sufficient parts.
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1-alpha001
    #
    # Expected Result: Test-ScriptFileInfo should successfully validate the version field.
    #
    It "TestScriptFileWithValidPrereleaseAndVersion" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        $testScriptInfo = Test-ScriptFileInfo -Path $scriptFilePath
        $testScriptInfo.Version | Should -Match "3.2.1-alpha001"
    }

    # Purpose: Test a script file info with a valid Prerelease string and a version with sufficient parts.
    #
    # Action: Test-ScriptFileInfo [path] -Version 3.2.1.0-gamma001
    #
    # Expected Result: Test-ScriptFileInfo should successfully validate the version field.
    #
    It "TestScriptFileWithValidPrereleaseAndVersion2" {
        $scriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "Get-ProcessScript.ps1"
        Set-Content -Path $scriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1.0-gamma001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        $testScriptInfo = Test-ScriptFileInfo -Path $scriptFilePath
        $testScriptInfo.Version | Should -Match "3.2.1.0-gamma001"
    }
}

Describe "--- Update-ScriptFileInfo ---" -Tags "" {
    
    BeforeAll {
        Get-InstalledScript -Name Fabrikam-ServerScript -ErrorAction SilentlyContinue | Uninstall-Script -Force
    }

    AfterAll {
        if($script:AddedAllUsersInstallPath)
        {
            Reset-PATHVariableForScriptsInstallLocation -Scope AllUsers
        }
    
        if($script:AddedCurrentUserInstallPath)
        {
            Reset-PATHVariableForScriptsInstallLocation -Scope CurrentUser
        }
    }

    BeforeEach {
        $scriptName = 'Fabrikam-ServerScript'
        Install-Script $scriptName
		$Script = Get-InstalledScript -Name $scriptName
		$script:ScriptFilePath = Join-Path -Path $script.InstalledLocation -ChildPath "$scriptName.ps1"
    }

    AfterEach {
        Get-InstalledScript -Name Fabrikam-ServerScript -ErrorAction SilentlyContinue | Uninstall-Script -Force
    }

    It "UpdateScriptFileWithInvalidPrereleaseString" {
        $Version = "3.2.1-alpha+001"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "UpdateScriptFileWithInvalidPrereleaseString2" {
        $Version = "3.2.1-alpha-beta.01"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "UpdateScriptFileWithInvalidPrereleaseString3" {
        $Version = "3.2.1-alpha.1"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "UpdateScriptFileWithInvalidPrereleaseString4" {
        $Version = "3.2.1-error.0.0.0.1"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $expectedErrorMessage = $LocalizedData.InvalidCharactersInPrereleaseString
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "UpdateScriptFileWithPrereleaseStringAndShortVersion" {
        $Version = "3.2-alpha001"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $expectedErrorMessage = $LocalizedData.IncorrectVersionPartsCountForPrereleaseStringUsage
        $expectedFullyQualifiedErrorId = "IncorrectVersionPartsCountForPrereleaseStringUsage,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
    
    It "UpdateScriptFileWithPrereleaseStringAndLongVersion" {
        $Version = "3.2.1.0.5-alpha001"

        $ScriptBlock = {
            Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version
        }

        $expectedErrorMessage = $LocalizedData.InvalidVersion -f $Version
        $expectedFullyQualifiedErrorId = "InvalidVersion,Test-ScriptFileInfo"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "UpdateScriptFileWithValidPrereleaseAndVersion" {
        $Version = "3.2.1-alpha001"

        Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version

        $newScriptInfo = Test-ScriptFileInfo -Path $script:ScriptFilePath

        $newScriptInfo.Version | Should -Match $Version
    }

    It "UpdateScriptFileWithValidPrereleaseAndVersion2" {
        $Version = "3.2.1-gamma001"

        Update-ScriptFileInfo -Path $script:ScriptFilePath -Version $Version

        $newScriptInfo = Test-ScriptFileInfo -Path $script:ScriptFilePath

        $newScriptInfo.Version | Should -Match $Version
    }
}

Describe "--- Publish-Script ---" -Tags "" {
    
    BeforeAll {

        # Create file-based repository from scratch
        $script:PSGalleryRepoPath="$env:SystemDrive\PSGallery Repo With Spaces\"
        RemoveItem $script:PSGalleryRepoPath
        $null = New-Item -Path $script:PSGalleryRepoPath -ItemType Directory -Force
    
        # Backup existing repositories config file
        $script:moduleSourcesFilePath= Join-Path $script:PSGetLocalAppDataPath "PSRepositories.xml"
        $script:moduleSourcesBackupFilePath = Join-Path $script:PSGetLocalAppDataPath "PSRepositories.xml_$(get-random)_backup"
        if(Test-Path $script:moduleSourcesFilePath)
        {
            Rename-Item $script:moduleSourcesFilePath $script:moduleSourcesBackupFilePath -Force
        }
    
        # Set file-based repo as default PSGallery repo
        Set-PSGallerySourceLocation -Location $script:PSGalleryRepoPath `
                                    -PublishLocation $script:PSGalleryRepoPath `
                                    -ScriptSourceLocation $script:PSGalleryRepoPath `
                                    -ScriptPublishLocation $script:PSGalleryRepoPath
    
        $modSource = Get-PSRepository -Name "PSGallery"
        $modSource.SourceLocation | Should Be $script:PSGalleryRepoPath
        $modSource.PublishLocation | Should Be $script:PSGalleryRepoPath
    
        $script:ApiKey="TestPSGalleryApiKey"
    
        # Create temp module to be published
        $script:TempScriptsPath="$env:LocalAppData\temp\PSGet_$(Get-Random)"
        $null = New-Item -Path $script:TempScriptsPath -ItemType Directory -Force
        $script:TempScriptsLiteralPath = Join-Path -Path $script:TempScriptsPath -ChildPath 'Lite[ral]Path'
        $null = New-Item -Path $script:TempScriptsLiteralPath -ItemType Directory -Force
    
        $script:PublishScriptName = 'Fabrikam-TestScript'
        $script:PublishScriptVersion = '1.0'
        $script:PublishScriptFilePath = Join-Path -Path $script:TempScriptsPath -ChildPath "$script:PublishScriptName.ps1"
    }

    AfterAll {
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
    
        RemoveItem $script:PSGalleryRepoPath
        RemoveItem $script:TempScriptsPath
    }

    BeforeEach {
        
        $null = New-ScriptFileInfo -Path $script:PublishScriptFilePath `
                               -Version $script:PublishScriptVersion `
                               -Author Manikyam.Bavandla@microsoft.com `
                               -Description 'Test script description goes here ' `
                               -Force

        Add-Content -Path $script:PublishScriptFilePath `
                    -Value "
                        Function Test-ScriptFunction { 'Test-ScriptFunction' }

                        Workflow Test-ScriptWorkflow { 'Test-ScriptWorkflow' }

                        Test-ScriptFunction
                        Test-ScriptWorkflow"
    }

    AfterEach {
        RemoveItem "$script:PSGalleryRepoPath\*"        
        RemoveItem $script:PublishScriptFilePath
    }

    
    It "PublishScriptSameVersionHigherPreRelease" {
        
        # Publish first version
        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"

        # Publish second version
        $version = "1.0.0-beta002"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PublishScriptSameVersionLowerPreReleaseWithForce" {
        
        # Publish first version
        $version = "1.0.0-beta002"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"


        # Publish second version
        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey -Force
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
    
    It "PublishScriptSameVersionLowerPreReleaseWithoutForce" {
        
        # Publish first version
        $version = "1.0.0-beta002"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw

        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"

        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should -Throw -ErrorId "ScriptPrereleaseStringShouldBeGreaterThanGalleryPrereleaseString,Publish-Script"
    }
    
    It "PublishScriptSameVersionSamePreRelease" {
        
        # Publish first version
        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"

        # Publish same version again
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should -Throw -ErrorId "ScriptVersionIsAlreadyAvailableInTheGallery,Publish-Script"
    }

    It "PublishScriptSameVersionNoPreRelease" {
        
        # Publish first version
        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"


        # Publish the stable version
        $version = "1.0.0"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    It "PublishScriptWithForceNewPreReleaseAfterStableVersion" {
        
        # Publish stable version
        $version = "1.0.0"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"

        # Publish prerelease version
        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey -Force
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
    
    It "PublishScriptWithoutForceNewPreReleaseAfterStableVersion" {
        
        # Publish stable version
        $version = "1.0.0"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should Not Throw
        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion $version -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should Be $version
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "false"

        # Publish prerelease version
        $version = "1.0.0-alpha001"
        Update-ScriptFileInfo -Path $script:PublishScriptFilePath -Version $version
        $scriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath -NuGetApiKey $script:ApiKey
        }
        $scriptBlock | Should -Throw -ErrorId "ScriptPrereleaseStringShouldBeGreaterThanGalleryPrereleaseString,Publish-Script"
    }

    It "PublishScriptWithInvalidPrereleaseString" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha+001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $expectedErrorMessage = "The Prerelease string contains invalid characters. Please ensure that only characters 'a-zA-Z0-9' and possibly hyphen ('-') at the beginning are in the Prerelease string."
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"

        $ScriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishScriptWithInvalidPrereleaseString2" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha-beta.01
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $expectedErrorMessage = "The Prerelease string contains invalid characters. Please ensure that only characters 'a-zA-Z0-9' and possibly hyphen ('-') at the beginning are in the Prerelease string."
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"

        $ScriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath 
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishScriptWithInvalidPrereleaseString3" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha.1
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        $expectedErrorMessage = "The Prerelease string contains invalid characters. Please ensure that only characters 'a-zA-Z0-9' and possibly hyphen ('-') at the beginning are in the Prerelease string."
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"

        $ScriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishScriptWithInvalidPrereleaseString4" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-error.0.0.0.1
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@

        $expectedErrorMessage = "The Prerelease string contains invalid characters. Please ensure that only characters 'a-zA-Z0-9' and possibly hyphen ('-') at the beginning are in the Prerelease string."
        $expectedFullyQualifiedErrorId = "InvalidCharactersInPrereleaseString,Test-ScriptFileInfo"

        $ScriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishScriptWithPrereleaseStringAndShortVersion" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2-alpha001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        $expectedErrorMessage = "Version must have a minimum of 3 parts and a maximum of 4 parts for a Prerelease string to be used."
        $expectedFullyQualifiedErrorId = "IncorrectVersionPartsCountForPrereleaseStringUsage,Test-ScriptFileInfo"

        $ScriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }
    
    It "PublishScriptWithPrereleaseStringAndLongVersion" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1.0.5-alpha001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        $expectedErrorMessage = "Cannot convert value '3.2.1.0.5-alpha001' to type 'System.Version'."
        $expectedFullyQualifiedErrorId = "InvalidVersion,Test-ScriptFileInfo"

        $ScriptBlock = {
            Publish-Script -Path $script:PublishScriptFilePath
        }

        $ScriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    It "PublishScriptWithValidPrereleaseAndVersion" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1-alpha001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        Publish-Script -Path $script:PublishScriptFilePath

        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion "3.2.1-alpha001" -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should -Match "3.2.1-alpha001"
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It "PublishScriptWithValidPrereleaseAndVersion2" {
        Set-Content -Path $script:PublishScriptFilePath -Value @"
<#PSScriptInfo
    .DESCRIPTION 
    Performs a collection of admin tasks (Update, Virus Scan, Clean-up, Repair & Defrag) that might speed-up a computers performance.
    .VERSION 
    3.2.1.0-gamma001
    .GUID 
    35eb535b-7e54-4412-a58b-8a0c588c0b30
    .AUTHOR 
    Rebecca Roenitz @RebRo
    .TAGS 
    ManualScriptInfo
    .RELEASENOTES
    Release notes for this script file.
#>
"@
        
        Publish-Script -Path $script:PublishScriptFilePath

        $psgetItemInfo = Find-Script $script:PublishScriptName -RequiredVersion "3.2.1.0-gamma001" -AllowPrerelease
        $psgetItemInfo.Name | Should Be $script:PublishScriptName
        $psgetItemInfo.Version | Should -Match "3.2.1.0-gamma001"
        $psgetItemInfo.AdditionalMetadata | Should Not Be $null
        $psgetItemInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
}

Describe "--- Find-Script ---" -Tags "" {
    
    # Downlevel Tests
    #-----------------
    It FindScriptByNameWithAllowPrereleaseDownlevel {
        $script = {
            Find-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It FindSpecificPrereleaseScriptVersionByNameWithoutAllowPrereleaseFlagDownlevel {
        $script = {
            Find-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-beta500" -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It FindSpecificPrereleaseScriptVersionByNameWithAllowPrereleaseFlagDownlevel {
        $script = {
            Find-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-beta500" -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')


    # Find-Script Tests
    #-------------------
    It FindScriptReturnsLatestStableVersion {
        $psgetScriptInfo = Find-Script -Name $PrereleaseTestScript -Repository $TestRepositoryName

        # check that IsPrerelease = false, and Prerelease string is null.
        $psgetScriptInfo.AdditionalMetadata | Should Not Be $null
        $psgetScriptInfo.AdditionalMetadata.IsPrerelease | Should Match "false"
        $psgetScriptInfo.Version | Should Not Match '-'
    }

    It FindScriptAllowPrereleaseReturnsLatestPrereleaseVersion {
        $psgetScriptInfo = Find-Script -Name $PrereleaseTestScript -Repository $TestRepositoryName -AllowPrerelease

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetScriptInfo.AdditionalMetadata | Should Not Be $null
        $psgetScriptInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
        $psgetScriptInfo.Version | Should Match '-'
    }
    
    It FindScriptAllowPrereleaseAllVersions {
        $results = Find-Script -Name $PrereleaseTestScript -Repository $TestRepositoryName -AllowPrerelease -AllVersions

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }
    
    # >>>>>>> Failing (as expected, not yet implemented) <<<<<
    It FindScriptAllVersionsShouldReturnOnlyStableVersions {
        $results = Find-Script -Name $PrereleaseTestScript -Repository $TestRepositoryName -AllVersions

        $results.Count | Should BeGreaterThan 1
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $true) -and ($_.Version -match '-') } | Measure-Object | ForEach-Object { $_.Count } | Should Not BeGreaterThan 0
        $results | Where-Object { ($_.AdditionalMetadata.IsPrerelease -eq $false) -and ($_.Version -notmatch '-') } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }

    It FindScriptSpecificPrereleaseVersionWithAllowPrerelease {
        $version = "3.0.0-beta2"
        $psgetScriptInfo = Find-Script -Name $PrereleaseTestScript -RequiredVersion $version -Repository $TestRepositoryName -AllowPrerelease

        # check that IsPrerelease = true, and Prerelease string is not null.
        $psgetScriptInfo.Version | Should Match $version
        $psgetScriptInfo.AdditionalMetadata | Should Not Be $null
        $psgetScriptInfo.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    It FindScriptSpecificPrereleaseVersionWithoutAllowPrerelease {
        $scriptBlock = {
            Find-Script -Name $PrereleaseTestScript -RequiredVersion "3.0.0-beta2" -Repository $TestRepositoryName
        }
        $expectedErrorMessage = $LocalizedData.AllowPrereleaseRequiredToUsePrereleaseStringInVersion
        $expectedFullyQualifiedErrorId = "AllowPrereleaseRequiredToUsePrereleaseStringInVersion,Find-Script"
        $scriptBlock | Should -Throw $expectedErrorMessage -ErrorId $expectedFullyQualifiedErrorId
    }

    <#
    # Purpose: Validate Find-Script -AllowPrerelease -IncludeDependencies
    #
    # Action: Find-Script -AllowPrerelease -IncludeDependencies
    #
    # Expected Result: Find-Script -AllowPrerelease -IncludeDependencies should return the prerelease versions of the script and its dependencies.
    #
    It FindScriptAllowPrereleaseIncludeDependencies {

        # try to get only one prerelease version
        $resultsSingle = Find-Script -Name $PrereleaseTestScript -Repository $TestRepositoryName -AllowPrerelease -MinimumVersion "0.1" -MaximumVersion "1.0" 
        $resultsSingle.Count | Should Be 1
        $resultsSingle.Name | Should Be $PrereleaseTestScript

        # try to get only one prerelease version and its dependencies
        $resultsDependencies = Find-Script -Name $PrereleaseTestScript -Repository $TestRepositoryName -AllowPrerelease -MinimumVersion "0.1" -MaximumVersion "1.0"  -IncludeDependencies
        $resultsDependencies.Count | Should BeGreaterThan $DependencyScriptNames.Count+1

        # Check that it returns all dependencies and at least one dependency is a prerelease
        $DependencyScriptNames = $resultsSingle.Dependencies.Name
        $DependencyScriptNames | ForEach-Object { $resultsDependencies.Name -Contains $_.Name | Should Be $true }
        $resultsDependencies | Where-Object { ($_.Name -ne $PrereleaseTestScript) -and ($_.AdditionalMetadata.IsPrerelease -eq $true) } | Measure-Object | ForEach-Object { $_.Count } | Should BeGreaterThan 0
    }
    #>
}

Describe "--- Install-Script ---" -Tags "" {
    
    BeforeAll {
        Get-InstalledScript -Name "TestScript" -ErrorAction SilentlyContinue | Uninstall-Script -Force
    }

    AfterEach {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    } 


    # Piping tests 
    #--------------
    
    It "PipeFindToInstallScriptByNameAllowPrerelease" {
        Find-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName | Install-Script
        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match $PrereleaseScriptLatestPrereleaseVersion
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
    
    It "PipeFindToInstallScriptSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName | Install-Script
        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "2.0.0-alpha005"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
    
    It "PipeFindToInstallScriptSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -Repository $TestRepositoryName | Install-Script
        }
        $script | Should Throw
    }
    


    # Regular Install Tests 
    #-----------------------
    
    It "InstallPrereleaseScriptByName" {
        Install-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName
        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not BeNullOrEmpty
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Be $PrereleaseScriptLatestPrereleaseVersion
    }
    
    It "InstallSpecificPrereleaseScriptVersionByNameWithAllowPrerelease" {
        Install-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName
        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not BeNullOrEmpty
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Be "2.0.0-alpha005"
    }
    
    It "InstallSpecificPrereleaseScriptVersionByNameWithoutAllowPrerelease" {
        $script = {
            Install-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -Repository $TestRepositoryName
        }
        $script | Should Throw
    }



    # Downlevel Tests
    #-----------------

    It "InstallScriptByNameWithAllowPrereleaseDownlevel" {
        $script = {
            Install-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "InstallSpecificPrereleaseScriptVersionByNameWithoutAllowPrereleaseFlagDownlevel" {
        $script = {
            Install-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "InstallSpecificPrereleaseScriptVersionByNameWithAllowPrereleaseFlagDownlevel" {
        $script = {
            Install-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')
}

Describe "--- Save-Script ---" -Tags "" {

    BeforeAll {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    }

    AfterEach {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    } 


    # Piping tests 
    #--------------
    It "PipeFindToSaveScriptByNameAllowPrerelease" {
        Find-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName | Save-Script -LiteralPath $MyDocumentsScriptsPath

        $scriptPath = Join-Path -Path $MyDocumentsScriptsPath -ChildPath $PrereleaseTestScript

        Test-Path -Path "$scriptPath.ps1" -PathType Leaf | Should Be $true

        $versionContent = Select-String -Path "$scriptPath.ps1" -Pattern ".VERSION"
        $savedVersion = $versionContent -split ' ',2 | Select-Object -Skip 1

        $savedVersion | Should Be $PrereleaseScriptLatestPrereleaseVersion
    }
    
    It "PipeFindToSaveScriptSpecificPrereleaseVersionByNameWithAllowPrerelease" {
        Find-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName | Save-Script -LiteralPath $MyDocumentsScriptsPath

        $scriptPath = Join-Path -Path $MyDocumentsScriptsPath -ChildPath $PrereleaseTestScript

        Test-Path -Path "$scriptPath.ps1" -PathType Leaf | Should Be $true

        $versionContent = Select-String -Path "$scriptPath.ps1" -Pattern ".VERSION"
        $savedVersion = $versionContent -split ' ',2 | Select-Object -Skip 1

        $savedVersion | Should Be "2.0.0-alpha005"
    }

    It "PipeFindToSaveScriptSpecificPrereleaseVersionByNameWithoutAllowPrerelease" {
        $script = {
            Find-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -Repository $TestRepositoryName | Save-Script -LiteralPath $MyDocumentsScriptsPath
        }
        $script | Should Throw
    }
    
    
    # Regular Save Tests 
    #-----------------------
    It "SavePrereleaseScriptByName" {
        Save-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsScriptsPath

        $scriptPath = Join-Path -Path $MyDocumentsScriptsPath -ChildPath $PrereleaseTestScript

        Test-Path -Path "$scriptPath.ps1" -PathType Leaf | Should Be $true

        $versionContent = Select-String -Path "$scriptPath.ps1" -Pattern ".VERSION"
        $savedVersion = $versionContent -split ' ',2 | Select-Object -Skip 1

        $savedVersion | Should Be $PrereleaseScriptLatestPrereleaseVersion
    }
    
    It "SaveSpecificPrereleaseScriptVersionByNameWithAllowPrerelease" {
        Save-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsScriptsPath
        
        $scriptPath = Join-Path -Path $MyDocumentsScriptsPath -ChildPath $PrereleaseTestScript

        Test-Path -Path "$scriptPath.ps1" -PathType Leaf | Should Be $true

        $versionContent = Select-String -Path "$scriptPath.ps1" -Pattern ".VERSION"
        $savedVersion = $versionContent -split ' ',2 | Select-Object -Skip 1

        $savedVersion | Should Be "2.0.0-alpha005"
    }
    
    It "SaveSpecificPrereleaseScriptVersionByNameWithoutAllowPrerelease" {
        $script = {
            Save-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -Repository $TestRepositoryName -LiteralPath $MyDocumentsScriptsPath
        }
        $script | Should Throw
    }


    # Downlevel Tests
    #-----------------
    It "SaveScriptByNameWithAllowPrereleaseDownlevel" {
        $script = {
            Save-Script -Name $PrereleaseTestScript -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsScriptsPath
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "SaveSpecificPrereleaseScriptVersionByNameWithoutAllowPrereleaseFlagDownlevel" {
        $script = {
            Save-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -Repository $TestRepositoryName -LiteralPath $MyDocumentsScriptsPath
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')

    It "SaveSpecificPrereleaseScriptVersionByNameWithAllowPrereleaseFlagDownlevel" {
        $script = {
            Save-Script -Name $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName -LiteralPath $MyDocumentsScriptsPath
        }
        $script | Should Throw

    } -Skip:$($PSVersionTable.PSVersion -ge '5.0.0')
}

Describe "--- Update-Script ---" -Tags "" {
    
    BeforeAll {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    }

    AfterEach {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    } 

    # Updated to latest release version by default: When release version is installed (ex. 1.0.0 --> 2.0.0)
    It "UpdateScriptFromReleaseToReleaseVersionByDefault" {
        Install-Script $PrereleaseTestScript -RequiredVersion 1.0.0 -Repository $TestRepositoryName
        Update-Script $PrereleaseTestScript # Should update to latest stable version 2.0.0

        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "2.0.0"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    # Updated to latest release version by default: When prerelease version is installed (ex. 1.0.0-alpha001 --> 2.0.0)
    It "UpdateScriptFromPrereleaseToReleaseVersionByDefault" {
        Install-Script $PrereleaseTestScript -RequiredVersion "1.0.0-alpha001" -AllowPrerelease -Repository $TestRepositoryName
        Update-Script $PrereleaseTestScript # Should update to latest stable version 2.0.0

        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "2.0.0"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "false"
    }
    
    # (In place update): prerelease to release, same root version.  (ex. 2.0.0-alpha005 --> 2.0.0)
    It "UpdateScriptSameVersionPrereleaseToReleaseInPlaceUpdate" {
        Install-Script $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName
        Update-Script $PrereleaseTestScript # Should update to latest stable version 2.0.0

        $res = Get-InstalledScript -Name $PrereleaseTestScript

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "2.0.0"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "false"
    }

    # (In place update): prerelease to prerelease, same root version.  (ex. 2.0.0-alpha005 --> 2.0.0-beta1234)    
    It "UpdateScriptSameVersionPrereleaseToPrereleaseInPlaceUpdate" {
        Install-Script $PrereleaseTestScript -RequiredVersion "2.0.0-alpha005" -AllowPrerelease -Repository $TestRepositoryName
        Update-Script $PrereleaseTestScript -RequiredVersion "2.0.0-beta1234" -AllowPrerelease

        $res = Get-InstalledScript -Name $PrereleaseTestScript -AllowPrerelease

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "2.0.0-beta1234"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    # Updated from stable to prerelease in new version (ex. 1.0.0 --> 3.0.0-beta2)
    It "UpdateScriptFromReleaseToPrereleaseDifferentVersion" {
        Install-Script $PrereleaseTestScript -RequiredVersion "1.0.0" -Repository $TestRepositoryName
        Update-Script $PrereleaseTestScript -AllowPrerelease # Should update to latest prerelease version 3.0.0-beta2

        $res = Get-InstalledScript -Name $PrereleaseTestScript -AllowPrerelease

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "3.0.0-beta2"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }

    # prerelease --> prerelease  (different root version) (ex. 2.0.0-beta1234 --> 3.0.0-beta2)
    It "UpdateScriptFromPrereleaseToPrereleaseDifferentRootVersion" {
        Install-Script $PrereleaseTestScript -RequiredVersion "2.0.0-beta1234" -AllowPrerelease -Repository $TestRepositoryName
        Update-Script $PrereleaseTestScript -RequiredVersion "3.0.0-beta2" -AllowPrerelease

        $res = Get-InstalledScript -Name $PrereleaseTestScript -AllowPrerelease

        $res | Should Not Be $null
        $res | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $res.Name | Should Be $PrereleaseTestScript
        $res.Version | Should Match "3.0.0-beta2"
        $res.AdditionalMetadata | Should Not Be $null
        $res.AdditionalMetadata.IsPrerelease | Should Match "true"
    }
}

Describe "--- Uninstall-Script ---" -Tags "" {
    BeforeAll {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    }

    AfterEach {
        PSGetTestUtils\RemoveItem -path $(Join-Path $ProgramFilesScriptsPath "TestScript.ps1")
        PSGetTestUtils\RemoveItem -path $(Join-Path $MyDocumentsScriptsPath "TestScript.ps1")
    } 

    It UninstallPrereleaseScript {

        $scriptName = "TestScript"

        PowerShellGet\Install-Script -Name $scriptName -RequiredVersion "1.0.0" -Repository $TestRepositoryName
        $mod = Get-InstalledScript -Name $scriptName
        $mod | Should Not Be $null
        $mod | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $mod.Name | Should Be $scriptName
        $mod.Version | Should Match "1.0.0"
        $mod.AdditionalMetadata | Should Not Be $null
        $mod.AdditionalMetadata.IsPrerelease | Should Match "false"

        PowerShellGet\Update-Script -Name $scriptName -RequiredVersion "2.0.0-alpha005" -AllowPrerelease
        $mod = Get-InstalledScript -Name $scriptName -AllowPrerelease
        $mod | Should Not Be $null
        $mod | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $mod.Name | Should Be $scriptName
        $mod.Version | Should Match "2.0.0-alpha005"
        $mod.AdditionalMetadata | Should Not Be $null
        $mod.AdditionalMetadata.IsPrerelease | Should Match "true"

        PowerShellGet\Update-Script -Name $scriptName -RequiredVersion "3.0.0-beta2" -AllowPrerelease
        $mod2 = Get-InstalledScript -Name $scriptName -AllowPrerelease
        $mod2 | Should Not Be $null
        $mod2 | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        $mod2.Name | Should Be $scriptName
        $mod2.Version | Should Match "3.0.0-beta2"
        $mod2.AdditionalMetadata | Should Not Be $null
        $mod2.AdditionalMetadata.IsPrerelease | Should Match "true"
        
        $scripts2 = PowerShellGet\Get-InstalledScript -Name $scriptName -AllowPrerelease

        if($PSVersionTable.PSVersion -gt '5.0.0')
        {
            $scripts2 | Measure-Object | ForEach-Object { $_.Count } | Should Be 1
        }
        else
        {
            $mod2.Name | Should Be $scriptName
        }   


        PowerShellGet\Uninstall-Script -Name $scriptName
        $installedScripts = Get-InstalledScript -Name $scriptName -AllowPrerelease -ErrorAction SilentlyContinue

        $installedScripts | Should Be $null
    }
}