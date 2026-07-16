import os
from datetime import datetime, timezone

from flask import Flask, jsonify

app = Flask(__name__)

# Set/overridden by the Docker image build or Helm values — lets you see
# *which* deployed version you're hitting when you check the app in a browser.
APP_VERSION = os.environ.get("APP_VERSION", "dev")


@app.route("/")
def index():
    return jsonify(
        {
            "message": "Hello from the CI/CD pipeline project!",
            "version": APP_VERSION,
            "time": datetime.now(timezone.utc).isoformat(),
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
