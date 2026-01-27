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

    # Use --output-format stream-json for real-time streaming
    # Parse JSON lines and extract text content
    $AllOutput = ""

    $PromptContent | claude -p `
        --dangerously-skip-permissions `
        --verbose `
        --output-format stream-json `
        --allowedTools "Read,Write,Edit,MultiEdit,Glob,Grep,Bash,WebFetch,WebSearch,Task,NotebookEdit,TodoWrite" 2>&1 |
    ForEach-Object {
        $line = $_
        if ($line -is [string]) {
            $AllOutput += $line + "`n"

            # Try to parse as JSON and extract content
            try {
                $json = $line | ConvertFrom-Json -ErrorAction SilentlyContinue
                $textToPrint = $null

                if ($json.type -eq "assistant" -and $json.message.content) {
                    foreach ($block in $json.message.content) {
                        if ($block.type -eq "text") {
                            $textToPrint = $block.text
                        }
                    }
                }
                elseif ($json.type -eq "content_block_delta" -and $json.delta.text) {
                    $textToPrint = $json.delta.text
                }
                elseif ($json.type -eq "result" -and $json.result) {
                    Write-Host ""
                    Write-Host $json.result -ForegroundColor Gray
                }

                # Print text - handle newlines correctly
                # Note: Write-Host -NoNewline strips ALL newlines, not just trailing
                # So we only use -NoNewline for text without embedded newlines
                if ($null -ne $textToPrint -and $textToPrint -ne "") {
                    if ($textToPrint.Contains("`n")) {
                        # Has embedded newlines - print without -NoNewline
                        # Trim trailing newline to reduce extra spacing
                        Write-Host $textToPrint.TrimEnd("`r`n")
                    } else {
                        # No newlines - use -NoNewline for smooth streaming
                        Write-Host $textToPrint -NoNewline
                    }
                }
            } catch {
                # Not JSON, just print as-is
                Write-Host $line
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
