#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y nginx

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${project_name} - ${environment}</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 3rem; background: #ffffff; color: #000000; }
    h1   { color: #000000; }
    code { background: #f0f0f0; color: #000000; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Welcome to ${project_name} - ${environment}</h1>
  <p>Instance: <code>${instance_name}</code></p>
  <p>Hostname: <code>$(hostname)</code></p>
  <p>AZ: <code>${availability_zone}</code></p>
  <p>Deployed at: <code>$(date -u +"%Y-%m-%dT%H:%M:%SZ")</code></p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
