from flask import Flask, jsonify, request
import time
import pymysql
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
def get_db_connection(retries=5, delay=3):
    for i in range(retries):
        try:
            connection = pymysql.connect(
                host='db',
                user='root',
                password='root',
                database='DBuser',
                port=3306
            )
            print("Conectou ao banco!")
            return connection
        except pymysql.err.OperationalError:
            print(f"Conexão falhou. Tentando novamente em {delay} segundos...")
            time.sleep(delay)
    raise Exception("Não foi possível conectar ao banco após várias tentativas.")

@app.route('/')
def index():
    return jsonify({"message": "API Flask rodando dentro do container!"})

@app.route('/users',methods=['GET'])
def get_users():
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT id, name, phone, date, hour FROM users")
    users = cursor.fetchall()
    cursor.close()
    connection.close()

    users_list = []
    for user in users:
        users_list.append({
            "id": user[0],
            "name": user[1],
            "phone": user[2],
            "date": str(user[3]),
            "hour": str(user[4])
        })

    return jsonify({"users": users_list})

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT id, name, phone, date, hour FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()
    connection.close()

    if user:
        return jsonify({
            "id": user[0],
            "name": user[1],
            "phone": user[2],
            "date": str(user[3]),
            "hour": str(user[4])
        })
    else:
        return jsonify({"message": "Usuário não encontrado."}), 404

@app.route('/post/users', methods=['POST'])
def save_user():
    date = request.get_json()
    name = date.get('name')
    phone = date.get('phone')
    date_str = date.get('date')
    hour_str = date.get('hour')

    if not all([name, phone, date_str, hour_str]):
        return jsonify({"error": "Por favor, forneça todos os detalhes do usuário."}), 400

    connection = get_db_connection()
    cursor = connection.cursor()
    query = """
    INSERT INTO users (name, phone, date, hour)
    VALUES (%s, %s, %s, %s)
    """
    try:
        cursor.execute(query, (name, phone, date_str, hour_str))
        connection.commit()
        user_id = cursor.lastrowid

        cursor.execute("SELECT id, name, phone, date, hour FROM users WHERE id = %s", (user_id,))
        new_user = cursor.fetchone()

        cursor.close()
        connection.close()

        return jsonify({
            "user": {
                "id": new_user[0],
                "name": new_user[1],
                "phone": new_user[2],
                "date": str(new_user[3]),
                "hour": str(new_user[4])
            }
        }), 201

    except pymysql.Error as e:
        connection.rollback()
        cursor.close()
        connection.close()
        return jsonify({"error": f"Erro ao salvar o usuário: {e}"}), 500

@app.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    date = request.get_json()
    name = date.get('name')
    phone = date.get('phone')
    date_str = date.get('date')
    hour_str = date.get('hour')

    if not any([name, phone, date_str, hour_str]):
        return jsonify({"error": "Por favor, forneça ao menos um detalhe para atualizar."}), 400

    connection = get_db_connection()
    cursor = connection.cursor()
    query_parts = []
    values = []

    if name:
        query_parts.append("name = %s")
        values.append(name)
    if phone:
        query_parts.append("phone = %s")
        values.append(phone)
    if date_str:
        query_parts.append("date = %s")
        values.append(date_str)
    if hour_str:
        query_parts.append("hour = %s")
        values.append(hour_str)

    query = f"UPDATE users SET {', '.join(query_parts)} WHERE id = %s"
    values.append(user_id)

    try:
        cursor.execute(query, tuple(values))
        connection.commit()

        if cursor.rowcount > 0:
            cursor.execute("SELECT id, name, phone, date, hour FROM users WHERE id = %s", (user_id,))
            updated_user = cursor.fetchone()
            cursor.close()
            connection.close()
            return jsonify({"message": "Usuário atualizado com sucesso!", "user": {
                "id": updated_user[0],
                "name": updated_user[1],
                "phone": updated_user[2],
                "date": str(updated_user[3]),
                "hour": str(updated_user[4])
            }}), 200
        else:
            cursor.close()
            connection.close()
            return jsonify({"message": "Usuário não encontrado."}), 404

    except pymysql.Error as e:
        connection.rollback()
        cursor.close()
        connection.close()
        return jsonify({"error": f"Erro ao atualizar o usuário: {e}"}), 500

@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
    connection.commit()

    if cursor.rowcount > 0:
        response = jsonify({"message": "Usuário deletado com sucesso!"}), 200
    else:
        response = jsonify({"message": "Este usuário não foi encontrado."}), 404

    cursor.close()
    connection.close()
    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)