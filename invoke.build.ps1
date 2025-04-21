param(
    $VersionMajor  = (property VERSION_MAJOR "0"),
    $VersionMinor  = (property VERSION_MINOR "3"),
    $BuildNumber   = (property BUILD_NUMBER  "3"),
    $PatchString   = (property PATCH_NUMBER  ""),
    $OSISOPath     = (property OS_ISO_PATH "iso/debian-12.10.0-amd64-netinst.iso"),
    $OSISOChecksum = (property OS_ISO_CHECKSUM "sha256:ee8d8579128977d7dc39d48f43aec5ab06b7f09e1f40a9d98f2a9d149221704a"),
    $KubeVersion   = (property KUBE_VERSION "1.32")
)

$VersionString = "$($VersionMajor).$($VersionMinor).$($BuildNumber)$($PatchString)"

If ($KubeVersion -ne "") {
    $KubeVersionDescription = $KubeVersion
}
else {
    $KubeVersionDescription = "latest"
}

$VMDescription = @"
Kutti VirtualBox Image version: $($VersionString)

Debian base image: $($OSISOPath)
Kubernetes version: $($KubeVersionDescription)
"@

# Synopsis: Show usage
task . {
    Write-Host "Usage: Invoke-Build step1|step2|clean-step1|clean-step2|clean"
}

# Synopsis: Build debian base image
task step1 -Outputs output-kutti-base/kutti-base.ova -Inputs kutti.step1.pkr.hcl {
    exec { 
        packer build -var "iso-url=$($OSISOPath)" -var "iso-checksum=$($OSISOChecksum)" $Inputs
    }
}

# Synopsis: Build kutti image
task step2 -Outputs output-kutti-vbox/kutti-vbox.ova -Inputs kutti.step2.pkr.hcl, output-kutti-base/kutti-base.ova {
    Write-Host "Building..."
    Write-Host $VMDescription
    exec {
        packer build -var "vm-version=$($VersionString)" -var "kube-version=$($KubeVersion)" -var "vm-description=$($VMDescription)" kutti.step2.pkr.hcl
    }
}

# Synopsis: Build everything
task all step1, step2

# Synopsis: Delete built debian base image
task clean-step1 {
    Remove-Item -Recurse -Force output-kutti-base
}

# Synopsis: Delete built kutti image
task clean-step2 {
    Remove-Item -Recurse -Force output-kutti-vbox
}

# Synopsis: Delete all output
task clean clean-step2, clean-step1
