FROM ghcr.io/ylianst/meshcentral:master

# Set 'allowedOrigin' origin config option so
# Docker ports can be mapped to non-standard ones
RUN python3 <<'EOF'
import json
with open('config.json.template', 'r') as f:
  data = json.load(f)

data['domains']['']['allowedOrigin'] = True

with open('config.json.template', 'w') as f:
  data = json.dump(data, f)
EOF
