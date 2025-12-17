# Created by: Composer (Cursor AI)

*#!/bin/bash
# Example: Generate CALM pattern from Gemara policy
# This demonstrates the workflow for creating patterns from policies

set -e

POLICY_ID="${1:-cloud-policy-001}"
OUTPUT_DIR="generated/${POLICY_ID}"

echo "🔍 Generating CALM pattern from Gemara policy: ${POLICY_ID}"
echo ""

# Step 1: Resolve policy controls (would use MCP in real implementation)
echo "Step 1: Resolving controls from policy..."
echo "  (In Cursor, would use: mcp_gemara-mcp_get_layer3_policy)"
echo "  (Then resolve each control-reference via mcp_gemara-mcp_get_layer2_control)"
echo ""

# Step 2: Generate pattern
echo "Step 2: Generating CALM pattern..."
python3 tools/generate-pattern-from-policy.py \
  --policy "${POLICY_ID}" \
  --generate-controls \
  --generate-mapping \
  --output-dir "${OUTPUT_DIR}"

echo ""
echo "✅ Pattern generation complete!"
echo ""
echo "Generated files:"
echo "  - Pattern: ${OUTPUT_DIR}/${POLICY_ID}.pattern.json"
echo "  - Controls: ${OUTPUT_DIR}/controls/${POLICY_ID}/"
echo "  - URL Mapping: ${OUTPUT_DIR}/${POLICY_ID}-url-mapping.json"
echo ""
echo "To validate an architecture against this pattern:"
echo "  calm validate \\"
echo "    -p ${OUTPUT_DIR}/${POLICY_ID}.pattern.json \\"
echo "    -a architecture/your-architecture.json \\"
echo "    -u ${OUTPUT_DIR}/${POLICY_ID}-url-mapping.json"
