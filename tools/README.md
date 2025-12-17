# Tooling for Gemara Policy → CALM Pattern Generation

This directory contains tools and documentation for resolving controls from Gemara Layer 3 Policies and generating CALM patterns.

## Overview

To create CALM patterns that address "resolved controls" from Gemara Layer 3 Policy references, you need tooling that:

1. **Resolves controls** from policy `control-references`
2. **Applies policy modifications** to base controls
3. **Generates CALM artifacts** (patterns, control files, URL mappings)

## Files

- **`gemara-resolve-example.py`**: Proof-of-concept Python script demonstrating the resolver approach
- **`gemara-policy-resolver-tooling.md`**: Detailed design document for the tooling components

## Quick Start

### Using the Proof-of-Concept Script

```bash
# Run the example resolver (demonstrates the concept)
python tools/gemara-resolve-example.py \
  --policy my-org-payment-security-policy-001 \
  --generate-pattern \
  --generate-controls \
  --generate-mapping \
  --output-dir generated/
```

**Note**: This is a proof-of-concept. A real implementation would:
1. Fetch policies from the Gemara MCP server
2. Resolve all control-references
3. Apply policy modifications
4. Generate actual CALM artifacts

## Example Workflow

```bash
# 1. Resolve controls from policy
gemara-resolve \
  --policy my-org-payment-security-policy-001 \
  --output resolved.json

# 2. Generate CALM artifacts
calm-pattern-from-policy \
  --resolved-controls resolved.json \
  --generate-control-files \
  --output-dir patterns/payment-security/

# 3. Validate architecture
calm validate \
  -p patterns/payment-security/payment-security-policy.pattern.json \
  -a architecture/payment-system.json \
  -u patterns/payment-security/url-mapping.json
```

## Integration Points

### With Existing Tools

1. **CALM CLI**: Use generated patterns with `calm validate -p pattern.json -a architecture.json`
2. **Makefile**: Add targets for policy resolution and pattern generation
3. **MCP Server**: Extend Gemara MCP with resolution tools
4. **CI/CD**: Validate architectures against policy patterns

### Workflow Integration

```makefile
# Resolve policy and generate artifacts
resolve-policy:
	gemara-resolve --policy $(POLICY_ID) --output .resolved/$(POLICY_ID).json
	calm-pattern-from-policy --resolved .resolved/$(POLICY_ID).json --output patterns/

# Validate architecture against policy
validate-policy: resolve-policy
	calm validate -p patterns/$(POLICY_ID).pattern.json -a architecture.json
```

## Resources

- **Design Document**: `tools/gemara-policy-resolver-tooling.md`
- **Proof of Concept**: `tools/gemara-resolve-example.py`
- **CALM Specification**: https://calm.finos.org
- **Gemara MCP Server**: Available via MCP tools

