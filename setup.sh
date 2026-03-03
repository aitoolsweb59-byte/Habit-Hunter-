#!/bin/bash
echo "Adding render redirect fix..."

cat > client/public/_redirects << 'EOF'
/* /index.html 200
EOF
echo "_redirects done!"
