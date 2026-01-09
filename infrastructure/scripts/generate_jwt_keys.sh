#!/bin/bash
# =============================================================================
# KerjaFlow JWT Key Generator
# =============================================================================
# Generates RSA 2048-bit keypair for RS256 JWT authentication.
#
# Usage:
#   ./generate_jwt_keys.sh [output_dir]
#
# Output:
#   - private.pem: Private key (keep secret!)
#   - public.pem: Public key (can be shared)
#   - jwt_keys.env: Environment variables ready to paste
#
# SECURITY NOTES:
# - NEVER commit private.pem to version control
# - Store keys securely (vault, secrets manager)
# - Rotate keys periodically (recommended: every 90 days)
# =============================================================================

set -e

# Configuration
KEY_SIZE=2048
OUTPUT_DIR="${1:-./jwt_keys}"
PRIVATE_KEY="$OUTPUT_DIR/private.pem"
PUBLIC_KEY="$OUTPUT_DIR/public.pem"
ENV_FILE="$OUTPUT_DIR/jwt_keys.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "KerjaFlow JWT Key Generator"
echo "=============================================="
echo ""

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}ERROR: openssl is required but not installed.${NC}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if keys already exist
if [ -f "$PRIVATE_KEY" ]; then
    echo -e "${YELLOW}WARNING: Private key already exists at $PRIVATE_KEY${NC}"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "Generating $KEY_SIZE-bit RSA keypair..."
echo ""

# Generate private key
echo "[1/3] Generating private key..."
openssl genrsa -out "$PRIVATE_KEY" $KEY_SIZE 2>/dev/null
chmod 600 "$PRIVATE_KEY"
echo -e "${GREEN}✓ Private key saved to: $PRIVATE_KEY${NC}"

# Generate public key from private key
echo "[2/3] Extracting public key..."
openssl rsa -in "$PRIVATE_KEY" -pubout -out "$PUBLIC_KEY" 2>/dev/null
chmod 644 "$PUBLIC_KEY"
echo -e "${GREEN}✓ Public key saved to: $PUBLIC_KEY${NC}"

# Generate environment variable format
echo "[3/3] Creating environment file..."

# Read keys and format for environment variables
PRIVATE_KEY_CONTENT=$(cat "$PRIVATE_KEY" | tr '\n' '\\n' | sed 's/\\n$//')
PUBLIC_KEY_CONTENT=$(cat "$PUBLIC_KEY" | tr '\n' '\\n' | sed 's/\\n$//')

cat > "$ENV_FILE" << EOF
# KerjaFlow JWT Keys (RS256)
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
# Key Size: ${KEY_SIZE}-bit RSA
#
# SECURITY: Keep JWT_PRIVATE_KEY secret! Never commit to version control.
#
# To use these keys:
# 1. Copy the values below to your .env file
# 2. Or export directly: source jwt_keys.env

# Private key for signing tokens (KEEP SECRET!)
JWT_PRIVATE_KEY="$(cat "$PRIVATE_KEY")"

# Public key for verifying tokens (can be shared)
JWT_PUBLIC_KEY="$(cat "$PUBLIC_KEY")"

# Algorithm (do not change)
JWT_ALGORITHM="RS256"
EOF

chmod 600 "$ENV_FILE"
echo -e "${GREEN}✓ Environment file saved to: $ENV_FILE${NC}"

echo ""
echo "=============================================="
echo -e "${GREEN}SUCCESS!${NC} JWT keys generated."
echo "=============================================="
echo ""
echo "Files created:"
echo "  $PRIVATE_KEY  - Private key (KEEP SECRET!)"
echo "  $PUBLIC_KEY   - Public key"
echo "  $ENV_FILE     - Environment variables"
echo ""
echo -e "${YELLOW}IMPORTANT SECURITY NOTES:${NC}"
echo "  1. NEVER commit private.pem to version control"
echo "  2. Add jwt_keys/ to .gitignore"
echo "  3. Store keys in a secrets manager for production"
echo "  4. Rotate keys every 90 days"
echo ""
echo "To use in development:"
echo "  1. Copy contents of jwt_keys.env to your .env file"
echo "  2. Or run: source $ENV_FILE"
echo ""
echo "To verify keys work:"
echo "  openssl rsa -in $PRIVATE_KEY -check -noout"
echo ""
