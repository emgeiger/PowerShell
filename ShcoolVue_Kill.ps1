$key = New-Object Byte[] 32
[Security.Cryptography.RNGcRYPTOServiceProvider]::Create().getBytes($key)
$key | out-file
