import os
import mysql.connector
from flask import Flask, jsonify

app = Flask(__name__)

db_config = {
    'host': os.environ.get('DB_HOST', '192.168.56.10'),
    'user': os.environ.get('DB_USER', 'app2_user'),
    'password': os.environ.get('DB_PASSWORD', 'password_app2'),
    'database': os.environ.get('DB_NAME', 'app2_db')
}

@app.route('/')
def index():
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM tasks;")
        tasks = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify({
            'message': 'App2 is running!',
            'data': tasks
        }), 200
    except mysql.connector.Error as err:
        return jsonify({
            'error': f'Database connection failed: {err}'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)