
function Menu1 () {
    Write-Host "its 1"
}

function Menu2 () {
    Write-Host "its 2"
}

while (1 -eq 1) {
    Write-Host -ForegroundColor Green "Please Choose what you whant to do: `n"
    Write-Host -ForegroundColor Yellow "1=do stuff     2=do other stuff `n3=do both      0=exit"
    $choice = Read-Host
    if ($choice -eq 1) {
        Menu1    
    }
    if ($choice -eq 2) {
        Menu2
    }
    if ($choice -eq 3) {
        Menu1
        Menu2
    }
    if ($choice -eq 0) {
        exit
    }
}
