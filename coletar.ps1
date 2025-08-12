# Coleta de informações do sistema
$nome = $env:COMPUTERNAME
$cpu = (Get-WmiObject Win32_Processor).Name
$ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
$id_dispositivo = (Get-WmiObject Win32_ComputerSystemProduct).UUID

$versao = (Get-WmiObject Win32_OperatingSystem).Version
$edicao = (Get-WmiObject Win32_OperatingSystem).Caption
$data_instalacao = ([System.Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate)).ToString("yyyy-MM-dd HH:mm:ss")

# IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 `
    | Where-Object { $_.IPAddress -notlike "169.*" -and $_.InterfaceAlias -notlike "*Loopback*" } `
    | Select-Object -First 1).IPAddress

# Armazenamento
$disco = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$armazenamento_total = if ($disco) { [math]::Round($disco.Size / 1GB, 2) } else { 0 }
$armazenamento_livre = if ($disco) { [math]::Round($disco.FreeSpace / 1GB, 2) } else { 0 }

# Tipo de disco
$tipo_disco = (Get-PhysicalDisk | Select-Object -First 1).MediaType

# Placa-mãe
$placa_mae = (Get-CimInstance Win32_BaseBoard).Product

# MAC e conexão
$net = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
$mac = $net.MacAddress
$conexao = if ($net.InterfaceDescription -match "Wi-Fi") { "Wi-Fi" } else { "Ethernet" }

$modelo = (Get-CimInstance Win32_ComputerSystem).Model

# Corpo da requisição
$body = @{
    nome = $nome
    cpu = $cpu
    ram = $ram
    id_dispositivo = $id_dispositivo
    versao = $versao
    edicao = $edicao
    data_instalacao = $data_instalacao
    ip = $ip
    armazenamento_total = $armazenamento_total
    armazenamento_livre = $armazenamento_livre
    tipo_disco = $tipo_disco
    placa_mae = $placa_mae
    mac = $mac
    conexao = $conexao
    modelo = $modelo
}

# Envio
$uri = "http://10.0.30.172:5000/coletar"
try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body ($body | ConvertTo-Json -Depth 3) -ContentType "application/json"
    Write-Output "✅ Dados enviados com sucesso!"
    Write-Output "Resposta do servidor: $response"
} catch {
    Write-Output "❌ Erro ao enviar dados: $_"
}
