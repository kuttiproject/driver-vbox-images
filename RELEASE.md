# Releases

Each release from this repository contains .ova files for supported versions of Kubernetes, and a file called **driver-vbox-images.json** which describes these releases. The location on these files in the GitHub release is burned into the corresponding version of the vbox driver.

## driver-vbox-images.json

The schema for this file is as follows:

```json
{
    "KUBERNETES VERSION": {
        "ImageK8sVersion": "KUBERNETES VERSION (must match key above)",
        "ImageChecksum": "SHA256 CHECKSUM OF OVA FILE",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "PATH TO OVA FILE IN RELEASE",
        "ImageDeprecated": false
    },...
}
```

A sample is provided below:

```json
{
    "1.24": {
        "ImageK8sVersion": "1.24",
        "ImageChecksum": "94e6ae9d4238a740dff0dd8156c0da4b23b5d969d5c94116c257bbc2533258b4",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-vbox-images/releases/download/v0.2/kutti-k8s-1.24.ova",
        "ImageDeprecated": false
    },
    "1.23": {
        "ImageK8sVersion": "1.23",
        "ImageChecksum": "8b18b91c670b62e91a0b179753a1c1b778ea5e1ffa300ca1309ec7098d8dbbc3",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-vbox-images/releases/download/v0.2/kutti-k8s-1.23.ova",
        "ImageDeprecated": false
    },
    "1.22": {
        "ImageK8sVersion": "1.22",
        "ImageChecksum": "538e0841d6addae7e136b700bba6b506bd92396e862bb13c66c84454e058b5a7",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-vbox-images/releases/download/v0.2/kutti-k8s-1.22.ova",
        "ImageDeprecated": false
    },
    "1.21": {
        "ImageK8sVersion": "1.21",
        "ImageChecksum": "5ceebd3c8949b8c169fc5e12e0d590e08f64feea85f47a437e21c48eb49ec6f5",
        "ImageStatus": "NotDownloaded",
        "ImageSourceURL": "https://github.com/kuttiproject/driver-vbox-images/releases/download/v0.2/kutti-k8s-1.21.ova",
        "ImageDeprecated": true
    }
}
```
