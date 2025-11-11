$path = 'C:\Users\Public\Downloads' # Path to downloaded dell firmware updates
# build list of EXE and Expand them into folders
$files = Get-ChildItem -Path $path -File -Filter *.EXE
# $details = @()
# foreach ($file in $files) { $details += (Get-Item $file).VersionInfo }
foreach ($file in $files) { 
    New-Item -ItemType Directory -Path $file.FullName.Replace(".EXE","")
    Expand-Archive -Path $file.FullName -DestinationPath $file.FullName.Replace("EXE","")
}

# Now move them into SAS and SATA Dirs
$files = Get-ChildItem -Path $path -Directory -Filter SAS*
$files | ForEach-Object { 
    $newname = ($_.name.Split('_'))[4]
    move-item $_.FullName -Destination $path\SAS\$newname
}
$files = Get-ChildItem -Path $path -Directory -Filter *SATA*
$files | ForEach-Object { 
    $newname = ($_.name.Split('_'))[4]
    move-item $_.FullName -Destination $path\SATA\$newname
}
# Now remove all the extra leaving just the definition and FW files
$filter = ("*.cat","*.ini","*.exe","*.dll","*.sys","*.zip","*.xml.sign","*.bat","*.txt","*.inf","spconfig.xml","PIEConfig.xml")
$files = Get-ChildItem -Path $path -File -include $filter -Recurse
$files | ForEach-Object { Remove-Item $_.fullname -ErrorAction SilentlyContinue }

# Now start the sort
<#
The firmware version is always listed here
$data.SoftwareComponent.VendorVersion

The model number is usually listed here but may be grouped
$data.SoftwareComponent.name.Display.'#cdata-section'

For newer firmware packages, the model number is listed here
$data.SoftwareComponent.SupportedDevices.Device.Display.'#cdata-section'

#>
$path = 'E:\DEVL\GitHub\Dell-Drive-Firmware\downloads\SAS'
$files = Get-ChildItem -Path $path -File -Recurse -Filter package.xml
$tempdata = @()
foreach ($file in $files) {
    [xml]$data = Get-Content -Path $file.fullname
    $fwver = $data.SoftwareComponent.VendorVersion
    $filedescription = $data.SoftwareComponent.name.Display.'#cdata-section'
    $devices = @()
    foreach ($item in $data.SoftwareComponent.SupportedDevices) { 
        $devices += @($item.Device.Display.'#cdata-section')
    }
    $models = @()
    foreach ($item in $devices) {
        try {
            $models += ($item -split "`n")[1].Replace(" ","").Split(":")[1]
        }
        catch {
            $models += $item
        }
    }
    $tests = $devices[0] -split " "
    switch ($tests) {
        'Fujitsu' {$mfg="Fujitsu";Break}
        'HGST' {$mfg="HGST";Break}
        'Hynix' {$mfg="Hynix";Break}
        'Intel' {$mfg="Intel";Break}
        'LiteOn' {$mfg="LiteOn";Break}
        'Micron' {$mfg="Micron";Break}
        'Samsung' {$mfg="Samsung";Break}
        'Sandisk' {$mfg="Sandisk";Break}
        'Seagate' {$mfg="Seagate";Break}
        'Kioxia' {$mfg="Toshiba";Break}
        'PM6' {$mfg="Toshiba";Break}
        'Toshiba' {$mfg="Toshiba";Break}
        'Western Digital' {$mfg="WD";Break}
        'WD' {$mfg="WD";Break}
        'WDC' {$mfg="WD";Break}
        Default {$mfg=$tests}
    }
    switch ($tests) {
        'AL-10LX' {$family="AL-10LX";$mfg="Fujitsu";Break}
        'AL-10SX' {$family="AL-10SX";$mfg="Fujitsu";Break}
        'AL11SE' {$family="AL11SE";$mfg="Fujitsu";Break}
        'AL11SX' {$family="AL11SX";$mfg="Fujitsu";Break}
        'AL-10SE' {$family="AL-10SE";$mfg="Fujitsu";Break}
        'PM1633a' {$family="PM1633a";$mfg="Samsung";Break}
        'PM1635a' {$family="PM1635a";$mfg="Samsung";Break}
        'PM1643' {$family="PM1643";$mfg="Samsung";Break}
        'PM1643a' {$family="PM1643a";$mfg="Samsung";Break}
        'PM1645' {$family="PM1645";$mfg="Samsung";Break}
        'PM1645a' {$family="PM1645a";$mfg="Samsung";Break}
        'SM883' {$family="SM883";$mfg="Samsung";Break}
        'everest' {$family="everest";$mfg="Sandisk";Break}
        'kilimanjaro' {$family="kilimanjaro";Break}
        'BCQ' {$family="BCQ";$mfg="WD";Break}
        'Bach' {$family="Bach";$mfg="WD";Break}
        'kilimanjaro' {$family="kilimanjaro";Break}
        'Rigel' {$family="Rigel";$mfg="WD";Break}
        'Sirius' {$family="Sirius";$mfg="WD";Break}
        'Vega' {$family="Vega";$mfg="WD";Break}
        'Vela_AX' {$family="Vela_AX";$mfg="WD";Break}
        'Verdi' {$family="Verdi";$mfg="WD";Break}
        Default {$family=''}
    }
    $tempdata += @{mfg=$mfg;family=$family;fw=$fwver;fwpath=$fwpath;models=$models}
}

$expanded = @()
$expanded += "mfg,family,fw,model,fwpath"
$tempdata | ForEach-Object {
    $mfg = $_.mfg
    $family = $_.family
    $fwver = $_.fw
    $fwpath = $_.fwpath
    $models = $_.models
    foreach ($model in $models) {
        $expanded += "$mfg,$family,$fwver,$model,$fwpath"
    }
}
"Start" > .\data.txt
$expanded | ForEach-Object {$_ >> .\data.txt}

& 'C:\Program Files\Notepad++\Notepad++.exe' $path\data.txt

$tests = $tempdata[0].models[0] -split " "
switch ($tests) {
    'HSGT' {$mfg="HSGT";Break}
    'Sandisk' {$mfg="Sandisk";Break}
    'Seagate' {$mfg="Seagate";Break}
    'Kioxia' {$mfg="Toshiba";Break}
    'PM6' {$mfg="Toshiba";Break}
    'Toshiba' {$mfg="Toshiba";Break}
    'Western Digital' {$mfg="WD";Break}
    'WD' {$mfg="WD";Break}
    'WDC' {$mfg="WD";Break}
    Default {$mfg=''}
}

# [xml]$data = Get-Content -Path .\SAS-Drive_Firmware_0NKFF_WN64_J17L_A00\package.xml
# $data.SoftwareComponent.VendorVersion # Firmware Version
# $data.SoftwareComponent.SupportedDevices.Device.Display.'#cdata-section' # Drive ID

$details = @()
foreach ($item in $data.SoftwareComponent.SupportedDevices) { 
    $details += @($item.Device.Display.'#cdata-section')
}
foreach ($item in $details) {
    $lines = @()
    $lines += @($item -split "`n")
    $lines[1].Replace("Model Number: ","")
}
