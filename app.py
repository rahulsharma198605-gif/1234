from flask import Flask
app = Flask(__name__)

@app.get("/")
def home():
    return "Hello, This is the testing of complete automation till Git to Docker, If successfull "HURRAH"!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
