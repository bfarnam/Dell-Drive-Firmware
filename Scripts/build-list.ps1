$path = 'C:\DELL Drive Firmware\downloads\SAS\' # Path to downloaded dell firmware updates
$files = Get-ChildItem -Path $path -File -Filter *.EXE
$details = @()
foreach ($file in $files) { $details += (Get-Item $file).VersionInfo }

foreach ($file in $files) { 
    New-Item -ItemType Directory -Path $file.FullName.Replace(".EXE","")
    Expand-Archive -Path $file.FullName -DestinationPath $file.FullName.Replace("EXE","")
}

$files = Get-ChildItem -Path $path -File -Recurse -Filter package.xml
$tempdata = @()
foreach ($file in $files) {
    [xml]$data = Get-Content -Path $file.fullname
    $fwver = $data.SoftwareComponent.VendorVersion
    $fwpath = (split-path $file.fullname -parent)+"\payload"
    $details = @()
    foreach ($item in $data.SoftwareComponent.SupportedDevices) { 
        $details += @($item.Device.Display.'#cdata-section')
    }
    $models = @()
    $details -split "`n" | ForEach-Object { $models += @($_) }
    $tests = $models[0] -split " "
    switch ($tests) {
        'HGST' {$mfg="HGST";Break}
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
    $family = $models[0]
    $tempdata += @{mfg=$mfg;family=$family;fw=$fwver;fwpath=$fwpath;models=$models}
}

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
