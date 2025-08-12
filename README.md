### **README**

---

# **Sistema de Coleta de Inventário de Hardware e Envio para Banco de Dados**

Este repositório contém duas partes principais: um **script PowerShell** (`.ps1`) responsável pela coleta das informações do sistema de hardware, e um **servidor Flask** (`servidor.py`) que recebe essas informações via uma API REST e armazena os dados em um banco de dados MySQL.

O objetivo desse sistema é coletar informações detalhadas sobre o hardware e a configuração do computador e armazená-las em um banco de dados para facilitar o gerenciamento e o controle de inventário de dispositivos.

---

## **1. Arquitetura**

A arquitetura do sistema é composta por duas partes:

### **1.1 PowerShell Script (`coletar_informacoes.ps1`)**

O script PowerShell é responsável por coletar as informações do sistema, incluindo:

* Nome do computador
* Processador (CPU)
* Memória RAM total
* ID do dispositivo
* Sistema operacional (versão, edição, data de instalação)
* Endereço IP
* Armazenamento (disco rígido)
* Tipo de disco (HDD ou SSD)
* Placa-mãe
* Endereço MAC e tipo de conexão (Wi-Fi ou Ethernet)
* Modelo do computador

Essas informações são coletadas utilizando cmdlets do PowerShell e enviadas para o servidor Flask através de uma requisição POST para a API `/coletar`.

### **1.2 Servidor Flask (`servidor.py`)**

O servidor Flask é responsável por:

* Receber os dados via API (POST para `/coletar`).
* Conectar ao banco de dados MySQL.
* Verificar se o MAC do dispositivo já está registrado.
* Se o dispositivo já existe no banco, os dados são **atualizados**.
* Se o dispositivo não existe, um **novo registro** é criado.
* Retornar a resposta para o PowerShell informando o sucesso ou erro do processo.

---

## **2. Pré-requisitos**

### **2.1 Ambiente para o PowerShell Script**

* Sistema operacional **Windows**.
* **PowerShell** (versão 5.0 ou superior).
* **Acesso à internet** para enviar os dados via requisição HTTP para o servidor Flask.

### **2.2 Ambiente para o Servidor Flask**

* **Python 3.x**.
* **Flask** para criar a API REST.
* **MySQL** ou **MariaDB** (configurado localmente ou remotamente).
* Dependências do Python:

  * `flask`
  * `mysql-connector-python`
  * `datetime`

### **2.3 Banco de Dados MySQL**

O banco de dados precisa ter uma tabela com a seguinte estrutura para armazenar as informações:

```sql
CREATE TABLE computadores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    cpu VARCHAR(255),
    ram DECIMAL(5,2),
    id_dispositivo VARCHAR(255),
    versao VARCHAR(255),
    edicao VARCHAR(255),
    data_instalacao DATETIME,
    ip VARCHAR(50),
    armazenamento_total DECIMAL(5,2),
    armazenamento_livre DECIMAL(5,2),
    tipo_disco VARCHAR(50),
    placa_mae VARCHAR(255),
    mac VARCHAR(255) UNIQUE,
    conexao VARCHAR(50),
    modelo VARCHAR(255)
);
```

---

## **3. Como Usar**

### **3.1 Configuração do Servidor Flask**

1. **Instale as dependências** necessárias para o Flask e o MySQL:

   ```bash
   pip install flask mysql-connector-python
   ```

2. **Configure o banco de dados MySQL**:

   * Crie o banco de dados `inventario` e a tabela `computadores` conforme a estrutura acima.

3. **Inicie o servidor Flask**:

   Execute o servidor Flask no terminal:

   ```bash
   python servidor.py
   ```

   O servidor será executado na URL `http://0.0.0.0:5000`, ouvindo requisições POST na rota `/coletar`.

---

### **3.2 Execução do PowerShell Script**

1. **Configure o PowerShell Script**:

   * Edite a variável `$uri` no script PowerShell para apontar para o endereço correto do seu servidor Flask.

   ```powershell
   $uri = "http://<IP_DO_SERVIDOR>:5000/coletar"
   ```

2. **Execute o script**:
   Execute o script PowerShell para coletar as informações do sistema e enviá-las para o servidor Flask:

   ```powershell
   .\coletar_informacoes.ps1
   ```

   O script vai coletar as informações, enviá-las para o servidor Flask e, se tudo ocorrer corretamente, exibirá a mensagem "✅ Dados enviados com sucesso!" no PowerShell.

---

## **4. Fluxo de Dados**

1. O script PowerShell coleta as informações do sistema.
2. Envia uma requisição POST com os dados coletados para o servidor Flask.
3. O servidor Flask verifica se o endereço MAC já existe no banco de dados.

   * Se **não** existir, o servidor insere um novo registro.
   * Se **já** existir, o servidor atualiza o registro com os novos dados.
4. O servidor retorna uma resposta de sucesso ou erro para o PowerShell.

---

## **5. Estrutura do Código**

### **5.1 PowerShell Script**

O script PowerShell realiza as seguintes etapas:

* Coleta informações usando `Get-WmiObject` e `Get-NetIPAddress`.
* Formata os dados coletados em um objeto JSON.
* Envia os dados para o servidor Flask usando `Invoke-RestMethod`.

### **5.2 Servidor Flask**

O servidor Flask realiza as seguintes etapas:

* Recebe os dados via POST na rota `/coletar`.
* Conecta-se ao banco de dados MySQL.
* Verifica se o dispositivo com o mesmo MAC já está registrado.
* Insere ou atualiza os dados do dispositivo no banco de dados.
* Retorna a resposta ao cliente.

---

## **6. Considerações Finais**

* **Segurança**: Certifique-se de configurar corretamente a autenticação e segurança na API, especialmente se o servidor for exposto à internet.
* **Manutenção**: Este sistema pode ser expandido para coletar mais informações ou para suportar múltiplos servidores de banco de dados.
* **Escalabilidade**: Para um uso em larga escala, considere otimizações no banco de dados, como índices para campos como `mac`.

---

## **7. Licença**

Este projeto está sob a licença [MIT](LICENSE).

---

Com este **README**, você tem uma explicação clara de como o sistema funciona, como configurá-lo e como utilizá-lo para coletar dados de hardware e armazená-los em um banco de dados MySQL.
