# Gemara Policy Resolver Tooling

## Overview

Tooling to resolve assessment requirements from Gemara Layer 3 Policy references and generate CALM control requirement files (one per assessment requirement).

## Problem Statement

Currently, CALM architectures manually reference assessment requirements via `gemara://` URLs. To create patterns that validate architectures against a complete policy, we need to:

1. **Resolve assessment requirements** from a Layer 3 Policy's `control-references`
2. **Apply policy modifications** to assessment requirements (assessment-requirement-modifications)
3. **Generate CALM control requirement files** (one file per assessment requirement) that represent the resolved requirements

## Tooling Components

### 1. **Gemara Policy Resolver CLI** (`gemara-resolve`)

A command-line tool that:
- Reads a Gemara Layer 3 Policy (YAML or via MCP)
- Resolves all `control-references` to Layer 2 control definitions
- Applies policy-specific modifications
- Outputs resolved controls in various formats

#### Usage

```bash
# Resolve controls from a policy
gemara-resolve \
  --policy my-org-payment-security-policy-001 \
  --output resolved-controls.json

# Resolve and apply modifications
gemara-resolve \
  --policy my-org-payment-security-policy-001 \
  --apply-modifications \
  --output resolved-controls.json

# Resolve with MCP server
gemara-resolve \
  --policy my-org-payment-security-policy-001 \
  --mcp-server gemara-mcp \
  --output resolved-controls.json
```

#### Output Format

```json
{
  "policy-id": "my-org-payment-security-policy-001",
  "resolved-requirements": [
    {
      "requirement-id": "CCC.C01.TR01",
      "control-id": "CCC.C01",
      "catalog-id": "FINOS-CCC",
      "text": "All communications containing payment processing data must use TLS 1.2 or higher",
      "applicability": ["payment-processing", "aws"],
      "is-modified": true,
      "gemara-url": "gemara://policies/my-org-payment-security-policy-001/controls/CCC.C01/requirements/CCC.C01.TR01",
      "base-requirement-url": "gemara://controls/FINOS-CCC/CCC.C01/requirements/CCC.C01.TR01",
      "control-title": "Enhanced Encryption for Payment Data"
    }
  ]
}
```

**Note**: The output contains one entry per assessment requirement. Each entry will generate one control requirement file.

### 2. **CALM Pattern Generator** (`calm-pattern-from-policy`)

Generates CALM patterns that enforce resolved controls:

```bash
# Generate pattern from resolved controls
calm-pattern-from-policy \
  --resolved-controls resolved-controls.json \
  --output patterns/payment-security-policy.pattern.json

# Generate with control requirement files
calm-pattern-from-policy \
  --resolved-controls resolved-controls.json \
  --generate-control-files \
  --output-dir patterns/payment-security-policy/
```

#### Generated Pattern Structure

```json
{
  "$schema": "https://calm.finos.org/release/1.1/meta/calm.json",
  "$id": "https://patterns.complytime.org/payment-security-policy.pattern.json",
  "title": "Payment Security Policy Pattern",
  "description": "Pattern enforcing controls from my-org-payment-security-policy-001",
  "type": "object",
  "properties": {
    "nodes": {
      "type": "array",
      "items": {
        "allOf": [
          { "$ref": "https://calm.finos.org/release/1.1/meta/core.json#/defs/node" },
          {
            "type": "object",
            "properties": {
              "controls": {
                "type": "object",
                "patternProperties": {
                  "^[a-zA-Z0-9-]+$": {
                    "type": "object",
                    "properties": {
                      "requirements": {
                        "type": "array",
                        "items": {
                          "oneOf": [
                            {
                              "properties": {
                                "requirement-url": {
                                  "enum": [
                                    "gemara://policies/my-org-payment-security-policy-001/controls/CCC.C01/requirements/CCC.C01.TR01",
                                    "gemara://policies/my-org-payment-security-policy-001/controls/OSPS-AC-01/requirements/OSPS-AC-01.01"
                                  ]
                                }
                              },
                              "required": ["requirement-url"]
                            }
                          ]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        ]
      }
    }
  }
}
```

### 3. **Control Requirement File Generator**

Generates CALM control requirement files from resolved controls:

```bash
# Generate control requirement files
calm-controls-from-policy \
  --resolved-controls resolved-controls.json \
  --output-dir controls/payment-security-policy/
```

#### Generated Control File

```json
{
  "$schema": "https://calm.finos.org/release/1.1/meta/control-requirement.json",
  "$id": "gemara://policies/my-org-payment-security-policy-001/controls/CCC.C01/requirements/CCC.C01.TR01",
  "control-id": "CCC.C01.TR01",
  "name": "Enhanced Encryption - TLS 1.2+ Required",
  "description": "All communications containing payment processing data must use TLS 1.2 or higher",
  "metadata": {
    "gemara": {
      "layer": "Layer 3",
      "policy-id": "my-org-payment-security-policy-001",
      "control-id": "CCC.C01",
      "requirement-id": "CCC.C01.TR01",
      "source": {
        "type": "policy",
        "policy-id": "my-org-payment-security-policy-001",
        "control-id": "CCC.C01"
      },
      "base-requirement": {
        "reference-url": "gemara://controls/FINOS-CCC/CCC.C01/requirements/CCC.C01.TR01",
        "catalog-id": "FINOS-CCC"
      },
      "applicability": ["payment-processing", "aws"]
    }
  }
}
```

### 4. **URL Mapping Generator**

Generates URL mapping files for local development:

```bash
# Generate URL mapping
calm-url-mapping-from-policy \
  --resolved-controls resolved-controls.json \
  --control-files-dir controls/payment-security-policy/ \
  --output url-mappings/payment-security-policy.json
```

#### Generated URL Mapping

```json
{
  "gemara://policies/my-org-payment-security-policy-001/controls/CCC.C01/requirements/CCC.C01.TR01": "../controls/payment-security-policy/ccc-c01-tr01.requirement.json",
  "gemara://policies/my-org-payment-security-policy-001/controls/CCC.C01/requirements/CCC.C01.TR02": "../controls/payment-security-policy/ccc-c01-tr02.requirement.json",
  "gemara://controls/FINOS-CCC/CCC.C01/requirements/CCC.C01.TR01": "../controls/base/ccc-c01-tr01.requirement.json",
  "gemara://controls/FINOS-CCC/CCC.C01/requirements/CCC.C01.TR02": "../controls/base/ccc-c01-tr02.requirement.json"
}
```

### 5. **Validation Pattern Generator**

Generates patterns that validate architectures implement all required controls:

```bash
# Generate validation pattern
calm-validation-pattern-from-policy \
  --resolved-controls resolved-controls.json \
  --policy-scope payment-processing \
  --output patterns/payment-security-validation.pattern.json
```

#### Generated Validation Pattern

```json
{
  "$schema": "https://calm.finos.org/release/1.1/meta/calm.json",
  "$id": "https://patterns.complytime.org/payment-security-validation.pattern.json",
  "title": "Payment Security Policy Validation Pattern",
  "description": "Validates that architectures implement all controls from my-org-payment-security-policy-001",
  "type": "object",
  "properties": {
    "nodes": {
      "type": "array",
      "items": {
        "allOf": [
          { "$ref": "https://calm.finos.org/release/1.1/meta/core.json#/defs/node" },
          {
            "if": {
              "properties": {
                "metadata": {
                  "properties": {
                    "technologies": {
                      "contains": {
                        "enum": ["payment-processing", "cloud", "aws"]
                      }
                    }
                  }
                }
              }
            },
            "then": {
              "properties": {
                "controls": {
                  "required": ["security"],
                  "properties": {
                    "security": {
                      "properties": {
                        "requirements": {
                          "type": "array",
                          "minItems": 1,
                          "items": {
                            "oneOf": [
                              {
                                "properties": {
                                  "requirement-url": {
                                    "enum": [
                                      "gemara://policies/my-org-payment-security-policy-001/controls/CCC.C01/requirements/CCC.C01.TR01"
                                    ]
                                  }
                                }
                              }
                            ]
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        ]
      }
    }
  }
}
```

## Implementation Approach

### Option 1: Standalone CLI Tool (Recommended)

**Language**: Go or Python  
**Dependencies**:
- Gemara MCP client (or direct YAML parsing)
- CALM schema libraries
- JSON Schema generation

**Structure**:
```
gemara-policy-resolver/
├── cmd/
│   ├── resolve/          # gemara-resolve command
│   ├── pattern-gen/      # calm-pattern-from-policy command
│   ├── control-gen/      # calm-controls-from-policy command
│   └── mapping-gen/      # calm-url-mapping-from-policy command
├── pkg/
│   ├── resolver/          # Policy resolution logic
│   ├── modifier/         # Modification application logic
│   ├── calm/             # CALM artifact generation
│   └── mcp/              # MCP client integration
└── schemas/              # Output schemas
```

### Option 2: MCP Server Extension

Extend the Gemara MCP server with new tools:
- `resolve_policy_controls`: Resolve controls from a policy
- `generate_calm_pattern`: Generate CALM pattern from resolved controls
- `generate_control_files`: Generate control requirement files

### Option 3: Python Library + CLI

**Package**: `gemara-calm-bridge`

```python
from gemara_calm_bridge import PolicyResolver, CALMPatternGenerator

# Resolve controls
resolver = PolicyResolver(mcp_server="gemara-mcp")
resolved = resolver.resolve("my-org-payment-security-policy-001")

# Generate CALM artifacts
generator = CALMPatternGenerator(resolved)
pattern = generator.generate_pattern()
control_files = generator.generate_control_files()
url_mapping = generator.generate_url_mapping()
```

## Integration with Existing Workflow

### Makefile Integration

```makefile
# Resolve policy and generate CALM artifacts
resolve-policy: check-gemara-resolver
	@echo "Resolving policy controls..."
	gemara-resolve \
		--policy my-org-payment-security-policy-001 \
		--output .resolved/payment-security-policy.json
	@echo "Generating CALM patterns..."
	calm-pattern-from-policy \
		--resolved-controls .resolved/payment-security-policy.json \
		--output patterns/payment-security-policy.pattern.json
	@echo "Generating control files..."
	calm-controls-from-policy \
		--resolved-controls .resolved/payment-security-policy.json \
		--output-dir controls/payment-security-policy/
	@echo "Generating URL mapping..."
	calm-url-mapping-from-policy \
		--resolved-controls .resolved/payment-security-policy.json \
		--control-files-dir controls/payment-security-policy/ \
		--output url-mappings/payment-security-policy.json

# Validate architecture against policy
validate-policy: resolve-policy
	calm validate \
		-p patterns/payment-security-policy.pattern.json \
		-a architecture/my-architecture.json \
		-u url-mappings/payment-security-policy.json
```

## Key Features

### 1. **Modification Resolution**

Applies policy modifications to assessment requirements:
- `control-modifications`: Modifications to control metadata (title, objective)
- `assessment-requirement-modifications`: Changes to testable requirement text and applicability
- `guideline-modifications`: Updates to Layer 1 mappings

### 2. **Scope Filtering**

Respects policy scope (boundaries, technologies, providers):
- Only includes controls applicable to architecture scope
- Filters assessment requirements by applicability

### 3. **Control Deduplication**

Handles controls referenced multiple times:
- Merges modifications from different policy sections
- Resolves conflicts (policy-level wins)

### 4. **Traceability**

Maintains full traceability:
- Links resolved controls back to base controls
- Documents all modifications applied
- Preserves Layer 1 → Layer 2 → Layer 3 lineage

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

## Benefits

1. **Automation**: Eliminates manual control file creation
2. **Consistency**: Ensures all policy controls are represented
3. **Traceability**: Maintains full Gemara → CALM linkage
4. **Validation**: Enables pattern-based architecture validation
5. **Maintainability**: Policy changes automatically propagate to CALM artifacts

