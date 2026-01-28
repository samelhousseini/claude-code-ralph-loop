# loop.ps1 - External Ralph Loop with fresh context each iteration (PowerShell version)
# Usage: .\loop.ps1 [mode] [max_iterations]

param(
    [string]$Mode = "build",
    [int]$MaxIterations = 50
)

# Set console encoding to UTF-8 for proper newline handling
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$PromptFile = "PROMPT_$Mode.md"
$Iteration = 0

Write-Host "================================" -ForegroundColor Blue
Write-Host "  Ralph Loop - Fresh Context    " -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue
Write-Host "Mode: $Mode" -ForegroundColor Green
Write-Host "Prompt file: $PromptFile" -ForegroundColor Green
Write-Host "Max iterations: $MaxIterations" -ForegroundColor Green
Write-Host ""

if (-not (Test-Path $PromptFile)) {
    Write-Host "Error: $PromptFile not found" -ForegroundColor Red
    exit 1
}

Write-Host "Auth: OK" -ForegroundColor Green

while ($true) {
    $Iteration++

    Write-Host ""
    Write-Host "========== Iteration $Iteration ==========" -ForegroundColor Yellow
    Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss")

    if ($MaxIterations -gt 0 -and $Iteration -gt $MaxIterations) {
        Write-Host "Reached max iterations: $MaxIterations" -ForegroundColor Red
        break
    }

    # Read prompt
    $PromptContent = Get-Content $PromptFile -Raw

    Write-Host "--- Claude Output ---" -ForegroundColor Cyan

    # Collect all output for checking completion signals
    $AllOutput = ""

    # Stream JSON and extract text content
    $PromptContent | claude -p `
        --dangerously-skip-permissions `
        --verbose `
        --output-format stream-json `
        --allowedTools "Read,Write,Edit,MultiEdit,Glob,Grep,Bash,WebFetch,WebSearch,Task,NotebookEdit,TodoWrite" 2>&1 |
    ForEach-Object {
        $line = $_
        if ($line -is [string] -and $line.Length -gt 0) {
            $AllOutput += $line + "`n"

            # Try to parse JSON and extract text
            try {
                $json = $line | ConvertFrom-Json -ErrorAction Stop

                # Handle different message types
                if ($json.type -eq "assistant" -and $json.message.content) {
                    foreach ($block in $json.message.content) {
                        if ($block.type -eq "text" -and $block.text) {
                            Write-Host ""
                            Write-Host $block.text
                            Write-Host ""
                        }
                    }
                }
                elseif ($json.type -eq "content_block_delta") {
                    if ($json.delta.text) {
                        [Console]::Write($json.delta.text)
                    }
                }
                elseif ($json.type -eq "content_block_stop") {
                    Write-Host ""
                }
                elseif ($json.type -eq "result") {
                    Write-Host ""
                    Write-Host "Result: $($json.result)" -ForegroundColor Gray
                    Write-Host ""
                }
            } catch {
                # Not valid JSON - print raw if it looks like content
                if (-not $line.StartsWith("{")) {
                    Write-Host $line
                }
            }
        }
    }

    Write-Host ""

    # Log iteration
    Add-Content -Path "progress.txt" -Value ""
    Add-Content -Path "progress.txt" -Value "## Iteration $Iteration - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    # Check for completion signal in output
    if ($AllOutput -match "<promise>COMPLETE</promise>") {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  All tasks complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Add-Content -Path "progress.txt" -Value "## COMPLETED - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        exit 0
    }

    if ($AllOutput -match "<promise>EXIT</promise>") {
        Write-Host "Exit signal received" -ForegroundColor Yellow
        exit 0
    }

    # Git push
    try {
        $Branch = git branch --show-current 2>$null
        if ($Branch) { git push origin $Branch 2>$null }
    } catch { }

    Start-Sleep -Seconds 2
}

Write-Host "Ralph Loop finished after $Iteration iterations" -ForegroundColor Blue
