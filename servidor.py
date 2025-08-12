from flask import Flask, request
import mysql.connector
from datetime import datetime

app = Flask(__name__)

# Conexão com o MySQL local
def conectar_mysql():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="12345678",
        database="inventario"
    )

@app.route('/coletar', methods=['POST'])
def coletar():
    dados = request.json
    conn = conectar_mysql()
    cursor = conn.cursor()

    # Verificar se o MAC já existe na base de dados
    query_verificar_mac = "SELECT COUNT(*) FROM computadores WHERE mac = %s"
    cursor.execute(query_verificar_mac, (dados['mac'],))
    resultado = cursor.fetchone()

    if resultado[0] > 0:
        # Se o MAC já existe, atualize os dados
        query_update = """
        UPDATE computadores SET
            nome = %s, cpu = %s, ram = %s, id_dispositivo = %s, versao = %s,
            edicao = %s, data_instalacao = %s, ip = %s, armazenamento_total = %s,
            armazenamento_livre = %s, tipo_disco = %s, placa_mae = %s, conexao = %s,
            modelo = %s
        WHERE mac = %s
        """
        valores_update = (
            dados['nome'],
            dados['cpu'],
            dados['ram'],
            dados['id_dispositivo'],
            dados['versao'],
            dados['edicao'],
            dados['data_instalacao'],
            dados['ip'],
            dados['armazenamento_total'],
            dados['armazenamento_livre'],
            dados['tipo_disco'],
            dados['placa_mae'],
            dados['conexao'],
            dados['modelo'],
            dados['mac']
        )
        cursor.execute(query_update, valores_update)
    else:
        # Se o MAC não existe, insira um novo registro
        query_insert = """
        INSERT INTO computadores (
            nome, cpu, ram, id_dispositivo, versao, edicao, data_instalacao, ip,
            armazenamento_total, armazenamento_livre, tipo_disco, placa_mae, mac,
            conexao, modelo
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        valores_insert = (
            dados['nome'],
            dados['cpu'],
            dados['ram'],
            dados['id_dispositivo'],
            dados['versao'],
            dados['edicao'],
            dados['data_instalacao'],
            dados['ip'],
            dados['armazenamento_total'],
            dados['armazenamento_livre'],
            dados['tipo_disco'],
            dados['placa_mae'],
            dados['mac'],
            dados['conexao'],
            dados['modelo']
        )
        cursor.execute(query_insert, valores_insert)

    # Confirmar as alterações no banco de dados
    conn.commit()
    cursor.close()
    conn.close()

    return {'status': 'sucesso'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
