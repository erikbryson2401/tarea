from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics
import os

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route("/")
def home():
    mensaje = os.environ.get("MENSAJE", "Hola!")
    version = os.environ.get("VERSION", "?")
    ambiente = os.environ.get("AMBIENTE", "?")
    return f"{mensaje} | v{version} | {ambiente}"

@app.route("/salud")
def salud():
    return "OK"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
