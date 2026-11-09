#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>${project_name} — ${environment}</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 3rem; background: #0f172a; color: #e2e8f0; }
    h1   { color: #38bdf8; }
    code { background: #1e293b; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Welcome to ${project_name} — ${environment}</h1>
  <p>Instance: <code>${instance_name}</code></p>
  <p>Hostname: <code>$(hostname)</code></p>
  <p>AZ: <code>${availability_zone}</code></p>
  <p>Deployed at: <code>$(date -u +"%Y-%m-%dT%H:%M:%SZ")</code></p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
