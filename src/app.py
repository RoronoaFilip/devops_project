import os

from flask import Flask
from flask_wtf import CSRFProtect

app = Flask(__name__)
csrf = CSRFProtect()
csrf.init_app(app)


@app.route('/')
def hello_world():
    file_path = os.path.join(os.path.dirname(__file__), 'main.html')
    with open(file_path, 'r') as file:
        file_content = file.read()
    return file_content


if __name__ == '__main__':
    # Note the extra host argument. If we didn't have it, our Flask app
    # would only respond to requests from inside our container
    app.run(host='0.0.0.0')
