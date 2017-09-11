$CSS='<style>table{margin:left; width:60%}

              body {font-family: Tahoma; background-color:#fff;}
              table {font-family: Tahoma;width: $($rptWidth)px;font-size: 12px;border-collapse:collapse;}
              <!-- table tr:nth-child(odd) td {background: #e2e2e2;} -->
              th {background-color: #cccc99;border: 1px solid #a7a9ac;border-bottom: none;}
              td {background-color: #ffffff;border: 1px solid #a7a9ac;padding: 2px 3px 2px 3px;vertical-align: middle;text-align:inherit;}
     </style>'

$DateTime     = (Get-Date).ToString('yyyyMMdd-HHmm')

$AllServers   = Get-ADComputer -Filter  {OperatingSystem -Like '*server*' } -Properties lastlogondate,operatingsystem |
                Where-Object {$_.LastLogonDate -ge (Get-Date).AddDays(-30)} | 
#               Where-Object {$_.Name -NotLike "ServerName"} |
                Sort-Object name


                ConvertTo-Html -Head "<h1>PowerShell Service REPORT</h1>" -Body "$CSS" | 
                Out-File C:\Scripts\Service\Services_PathName.$DateTime.html -Append


ForEach ($Server in $AllServers.Name) 
{
                Get-WmiObject win32_service -ComputerName $Server |
                Sort-Object startname, name |
                Where-Object {$_.startname -notlike '*Local*' -and $_.startname -notlike '*NT*' } |
                select PSComputerName, name, startname, started, startmode, PathName |
                Export-Csv -Append -Path "C:\Scripts\Service\Services_PathName.$DateTime.csv"
#               ConvertTo-Html -Body "$CSS" |
#               Out-File C:\Scripts\Services_PathName.$DateTime.html -Append
}


$ServiceHTML  = Import-Csv c:\scripts\Service\Services_PathName.csv | 
                ConvertTo-Html -Body "$CSS" | 
                Out-File C:\Scripts\Service\Services_PathName.$DateTime.html -Append
