#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y python3 python3-pip

# Placeholder for the real application
cat > /opt/app.py <<'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"APP TIER OK\n")

HTTPServer(("0.0.0.0", 8080), H).serve_forever()
EOF

cat > /etc/systemd/system/app.service <<'EOF'
[Unit]
Description=Tier-2 application
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now app.service

