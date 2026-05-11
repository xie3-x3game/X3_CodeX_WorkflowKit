[CmdletBinding()]
param(
    [string]$KitRoot,

    [string[]]$ProjectRoot,

    [string]$ProjectsFile,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($KitRoot)) {
    if ($PSScriptRoot) {
        $KitRoot = Join-Path $PSScriptRoot '..'
    } else {
        $KitRoot = (Get-Location).Path
    }
}

$KitRoot = (Resolve-Path -LiteralPath $KitRoot).Path
$manifestPath = Join-Path $KitRoot 'docs/workflow/rule-update-manifest.json'
$templatePath = Join-Path $KitRoot 'docs/workflow/rule-update-inbox.md'

if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Missing rule update manifest: $manifestPath"
}

function ConvertTo-ValueArray {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [System.Array]) {
        return @($Value)
    }

    return @($Value)
}

function Add-ProjectPath {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$List,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not $List.Contains($fullPath)) {
        $List.Add($fullPath)
    }
}

$projectPaths = New-Object System.Collections.Generic.List[string]

foreach ($rawPath in (ConvertTo-ValueArray $ProjectRoot)) {
    foreach ($path in ($rawPath -split ',')) {
        Add-ProjectPath -List $projectPaths -Path $path
    }
}

if (-not [string]::IsNullOrWhiteSpace($ProjectsFile)) {
    $projectsFilePath = [System.IO.Path]::GetFullPath($ProjectsFile)
    if (-not (Test-Path -LiteralPath $projectsFilePath -PathType Leaf)) {
        throw "Projects file does not exist: $projectsFilePath"
    }

    $projectConfig = Get-Content -LiteralPath $projectsFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($project in (ConvertTo-ValueArray $projectConfig.projects)) {
        if ($project.enabled -eq $false) {
            continue
        }

        Add-ProjectPath -List $projectPaths -Path $project.path
    }
}

if ($projectPaths.Count -eq 0) {
    throw 'No target projects provided. Use -ProjectRoot <path> or -ProjectsFile <json-file>.'
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$updates = @(ConvertTo-ValueArray $manifest.updates)
if ($updates.Count -eq 0) {
    throw "Rule update manifest has no updates: $manifestPath"
}

$receivedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$totalAdded = 0
$totalSkipped = 0
$errors = New-Object System.Collections.Generic.List[string]

foreach ($projectPath in $projectPaths) {
    try {
        if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
            throw "Project directory does not exist: $projectPath"
        }

        $workflowDir = Join-Path $projectPath 'docs/workflow'
        $inboxPath = Join-Path $workflowDir 'rule-update-inbox.md'

        if (-not $DryRun) {
            New-Item -ItemType Directory -Force -Path $workflowDir | Out-Null
        }

        if (-not (Test-Path -LiteralPath $inboxPath -PathType Leaf)) {
            if ($DryRun) {
                Write-Output "DRY-RUN create: $inboxPath"
            } elseif (Test-Path -LiteralPath $templatePath -PathType Leaf) {
                Copy-Item -LiteralPath $templatePath -Destination $inboxPath -Force
            } else {
                Set-Content -LiteralPath $inboxPath -Encoding UTF8 -Value @(
                    '# Rule Update Inbox',
                    '',
                    '## Pending Updates',
                    '',
                    'Append received updates below this heading.'
                )
            }
        }

        $content = ''
        if (Test-Path -LiteralPath $inboxPath -PathType Leaf) {
            $content = Get-Content -LiteralPath $inboxPath -Raw -Encoding UTF8
        }

        $existingIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($match in [regex]::Matches($content, '(?m)^Update ID:\s*(\S+)\s*$')) {
            [void]$existingIds.Add($match.Groups[1].Value)
        }

        $projectAdded = 0
        foreach ($update in $updates) {
            if ($existingIds.Contains($update.id)) {
                $totalSkipped += 1
                continue
            }

            $lines = New-Object System.Collections.Generic.List[string]
            $lines.Add('')
            $lines.Add("## $($update.id) - $($update.title)")
            $lines.Add('')
            $lines.Add("Update ID: $($update.id)")
            $lines.Add('Status: Pending')
            $lines.Add("Stage: $($update.stage)")
            $lines.Add("Priority: $($update.priority)")
            $lines.Add("Target: $($update.target)")
            $lines.Add("Source Manifest: $($manifest.manifestVersion)")
            $lines.Add("Received At: $receivedAt")
            $lines.Add('Source: X3_CodeX_WorkflowKit')
            $lines.Add('')
            $lines.Add('### Summary')
            $lines.Add('')
            $lines.Add("$($update.summary)")
            $lines.Add('')
            $lines.Add('### Affected Files')
            $lines.Add('')
            foreach ($item in (ConvertTo-ValueArray $update.affectedFiles)) {
                $lines.Add('- `' + $item + '`')
            }
            $lines.Add('')
            $lines.Add('### Suggested Project-Control Action')
            $lines.Add('')
            foreach ($item in (ConvertTo-ValueArray $update.suggestedAction)) {
                $lines.Add("- $item")
            }
            $lines.Add('')
            $lines.Add('### Distribution Rule')
            $lines.Add('')
            $lines.Add("$($update.distributionRule)")
            $lines.Add('')
            $lines.Add('### Verification')
            $lines.Add('')
            foreach ($item in (ConvertTo-ValueArray $update.verification)) {
                $lines.Add("- [ ] $item")
            }
            $lines.Add('')
            $lines.Add('### Project Decision')
            $lines.Add('')
            $lines.Add('- [ ] Apply')
            $lines.Add('- [ ] Defer')
            $lines.Add('- [ ] Reject')
            $lines.Add('- [ ] Supersede')
            $lines.Add('')
            $lines.Add('### Local Notes')
            $lines.Add('')
            $lines.Add('- ')

            if ($DryRun) {
                Write-Output "DRY-RUN append $($update.id) -> $inboxPath"
            } else {
                Add-Content -LiteralPath $inboxPath -Encoding UTF8 -Value $lines.ToArray()
            }

            $projectAdded += 1
            $totalAdded += 1
            [void]$existingIds.Add($update.id)
        }

        Write-Output "Project: $projectPath"
        Write-Output "  Inbox: $inboxPath"
        Write-Output "  Added: $projectAdded"
        Write-Output "  Already present: $($updates.Count - $projectAdded)"
    } catch {
        $errors.Add("$projectPath :: $($_.Exception.Message)")
    }
}

Write-Output 'Rule update sync complete.'
Write-Output "Projects checked: $($projectPaths.Count)"
Write-Output "Updates added: $totalAdded"
Write-Output "Updates already present: $totalSkipped"

if ($errors.Count -gt 0) {
    Write-Output 'Errors:'
    foreach ($errorItem in $errors) {
        Write-Output "  $errorItem"
    }
    exit 1
}
