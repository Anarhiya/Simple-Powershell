<#
    .SYNOPSIS
    Скрипт для полного резервного копирования одной или нескольких VM

    .DESCRIPTION
    Скприпт использует командлет Start-VBRZip Veeam Backup & Replication Community Edition
    https://helpcenter.veeam.com/docs/backup/powershell/start-vbrzip.html?ver=100

    .PARAMETER BackupFolder
    Папка резервного копирования верхнего уровня, необходимо создать заранее

    .PARAMETER VMs
    Одно или несколько имен виртуальных машин для резервного копирования, указывать через запятую

    .PARAMETER DeleteAfter
    Задает настройки хранения
    Варианты:  Never, Tonight, TomorrowNight, In3days, In1Week, In2Weeks, In1Month, In3Months, In6Months, In1Year
    
    .PARAMETER BotToken
    Токен бота в телеграм

    .PARAMETER Group_id
    Группа для отправки отчетов о неудачном резервном копировании
    
    .EXAMPLE
    Пример резервного копирования одной VM:
    .\VBRZip_VM.ps1 -BackupFolder "D:\Backup" -VMs VMName01 -DeleteAfter "In2Weeks" -BotToken "0000000000:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -Group_id "-XXXXXXXXX"
    
    .EXAMPLE
    Пример резервного копирования нескольких VM:
    .\VBRZip_VM.ps1 -BackupFolder "D:\Backup" -VMs VMName01, VMName02 -DeleteAfter "In2Weeks" -BotToken "0000000000:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -Group_id "-XXXXXXXXX"
#>


Param (
[string]$BackupFolder,
[string[]]$VMs=@(),
[string]$DeleteAfter,
[string]$BotToken,
[string]$Group_id
)

Add-PSSnapin VeeamPSSnapIn

foreach ($VM in $VMs){

$Date = Get-Date -UFormat "%d.%m.%Y %R"

$VMName = Find-VBRHvEntity -Name $VM
$BackupFolderVM = $BackupFolder + "\VBRZip" + " " + "$VM"
$BackupLogFile  = $BackupFolder + "\VBRZip" + " " + "$VM" + "\" + "VBRZip" + " " + "$VM" + ".txt"

if (!$(Test-Path $BackupFolderVM)) {
mkdir $BackupFolderVM
}

Start-VBRZip -Folder "$BackupFolderVM" -Entity $VMName -Compression 5 -AutoDelete $DeleteAfter

$Results =  Get-VBRBackupSession | Where-Object {$_.Name -match $VM} | Sort-Object EndTime -Descending | select -First 1
$ResultsLog = $Results.Result 
$Date + " " + "Backup" + "$VM" + " " + "$ResultsLog" | Out-File -FilePath $BackupLogFile -Append

    if ($Results.Result -eq "Failed") {
    $Text        = "$Date Backup Server $VM FAILED"
    $TelegramURL = "https://api.telegram.org/bot" + $BotToken + "/sendMessage?chat_id=" + $Group_id + "&text=" + $Text
    $Request     = Invoke-WebRequest -URI ($TelegramURL) 
    }
}
