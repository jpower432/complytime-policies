# Creating Control Requirements from Gemara Policies

This guide explains how to create CALM control requirement files from Gemara Layer 3 Policies, including integration with the Gemara MCP server.

## Overview

**Key Concept**: In CALM, a control requirement is a Gemara assessment requirement. Each assessment requirement becomes its own control requirement file.

Control requirement files link CALM architectures to Gemara compliance policies. They provide:

- **Traceability**: Link from architecture to policy assessment requirements
- **Resolved Text**: Assessment requirement text becomes the control requirement description
- **Base Requirement References**: Maintain lineage to Layer 2 assessment requirements

## Process Flow

```
Gemara Layer 3 Policy
    ↓
Fetch via MCP Server
    ↓
Resolve control-references → Layer 2 Controls
    ↓
Extract assessment requirements
    ↓
Apply policy modifications to assessment requirements
    ↓
Generate one Control Requirement File per Assessment Requirement
```

## Step-by-Step Guide

### 1. Fetch Gemara Layer 3 Policy

Use the Gemara MCP server to fetch the policy:

```python
# In Cursor/Composer, MCP tools are available:
policy = mcp_gemara-mcp_get_layer3_policy(policy_id="your-policy-id")
```

The policy contains:
- `metadata`: Policy identification and metadata
- `control-references`: References to Layer 2 control catalogs
- `control-modifications`: Policy-specific modifications to controls
- `assessment-requirement-modifications`: Modifications to testable requirements

### 2. Resolve Control References

For each `control-reference` in the policy:

```python
# Get the control reference
control_ref = policy["control-references"][0]
catalog_id = control_ref["reference-id"]  # e.g., "FINOS-CCC"

# For each control modification, fetch the base control
for mod in control_ref["control-modifications"]:
    control_id = mod["target-id"]  # e.g., "CCC.C01"
    
    # Fetch base Layer 2 control via MCP
    base_control = mcp_gemara-mcp_get_layer2_control(
        control_id=control_id
    )
```

### 3. Extract and Resolve Assessment Requirements

**Important**: Generate one control requirement file per assessment requirement, not per control.

```python
# Apply control-level modifications
resolved_control = base_control.copy()
if mod.get("title"):
    resolved_control["title"] = mod["title"]
if mod.get("objective"):
    resolved_control["objective"] = mod["objective"]

# Resolve assessment requirements
resolved_reqs = []

# Process base assessment requirements
for base_req in base_control.get("assessment-requirements", []):
    req_id = base_req["id"]
    
    # Check if this requirement is modified
    mod = next(
        (am for am in assessment_mods if am.get("target-id") == req_id),
        None
    )
    
    if mod:
        # Use modified requirement text
        resolved_reqs.append({
            "id": req_id,
            "text": mod["text"],  # This becomes the control requirement description
            "applicability": mod.get("applicability", base_req.get("applicability", []))
        })
    else:
        # Keep base requirement
        resolved_reqs.append(base_req)

# Generate one control requirement file per assessment requirement
for req in resolved_reqs:
    requirement_id = req["id"]  # e.g., "CCC.C01.TR01"
    requirement_text = req["text"]  # This becomes the description
```

### 4. Generate Control Requirement File

Create one control requirement file per assessment requirement:

```json
{
  "$schema": "https://calm.finos.org/release/1.1/meta/control-requirement.json",
  "$id": "gemara://policies/{policy-id}/controls/{control-id}/requirements/{requirement-id}",
  "control-id": "{requirement-id}",
  "name": "{control-title} - {requirement-id}",
  "description": "{resolved-assessment-requirement-text}",
  "metadata": {
    "gemara": {
      "layer": "Layer 3",
      "policy-id": "{policy-id}",
      "control-id": "{control-id}",
      "requirement-id": "{requirement-id}",
      "source": {
        "type": "policy",
        "policy-id": "{policy-id}",
        "control-id": "{control-id}"
      },
      "base-requirement": {
        "reference-url": "gemara://controls/{catalog-id}/{control-id}/requirements/{requirement-id}",
        "catalog-id": "{catalog-id}"
      },
      "applicability": ["default"]
    }
  }
}
```

**Key Points**:
- `$id` includes `/requirements/{requirement-id}` path
- `control-id` is the requirement ID (e.g., `CCC.C01.TR01`)
- `description` is the resolved assessment requirement text
- `base-requirement` references the Layer 2 assessment requirement

## MCP Server Integration

### Fetching Controls

```python
def resolve_control_via_mcp(catalog_id: str, control_id: str):
    """
    Resolve a control from a catalog via MCP server.
    
    In production, this would use:
    mcp_gemara-mcp_get_layer2_control(control_id=control_id)
    """
    # Real implementation
    control = mcp_gemara-mcp_get_layer2_control(control_id=control_id)
    
    # Control contains assessment-requirements array
    # Each assessment requirement becomes a control requirement file
    return control
```

### Example: Complete Resolution Function

```python
def resolve_policy_assessment_requirements(policy_id: str):
    """
    Resolve all assessment requirements from a Gemara Layer 3 Policy.
    
    Args:
        policy_id: Gemara Layer 3 Policy ID
        
    Returns:
        List of resolved assessment requirements (one per requirement)
    """
    # Fetch policy via MCP
    policy = mcp_gemara-mcp_get_layer3_policy(policy_id=policy_id)
    
    resolved_requirements = []
    
    # Process each control reference
    for control_ref in policy.get("control-references", []):
        catalog_id = control_ref["reference-id"]
        control_mods = control_ref.get("control-modifications", [])
        assessment_mods = control_ref.get("assessment-requirement-modifications", [])
        
        # Resolve each modified control
        for mod in control_mods:
            control_id = mod["target-id"]
            
            # Fetch base control via MCP
            base_control = mcp_gemara-mcp_get_layer2_control(control_id=control_id)
            
            # Apply modifications
            resolved_control = apply_modifications(
                base_control,
                mod,
                assessment_mods
            )
            
            # Generate one control requirement per assessment requirement
            for req in resolved_control.get("assessment-requirements", []):
                requirement_id = req["id"]
                
                resolved_requirements.append({
                    "requirement-id": requirement_id,
                    "control-id": control_id,
                    "catalog-id": catalog_id,
                    "policy-id": policy_id,
                    "text": req["text"],
                    "applicability": req.get("applicability", []),
                    "gemara-url": f"gemara://policies/{policy_id}/controls/{control_id}/requirements/{requirement_id}",
                    "base-requirement-url": f"gemara://controls/{catalog_id}/{control_id}/requirements/{requirement_id}"
                })
    
    return resolved_requirements
```

## Control Requirement File Structure

### Required Fields

- `$schema`: CALM control requirement schema
- `$id`: Gemara URL identifier (`gemara://policies/{policy-id}/controls/{control-id}/requirements/{requirement-id}`)
- `control-id`: Assessment requirement identifier (e.g., `CCC.C01.TR01`)
- `name`: Human-readable name
- `description`: **Resolved assessment requirement text** (the testable statement)
- `metadata.gemara`: Gemara metadata (see below)

### Gemara Metadata Structure

```json
{
  "metadata": {
    "gemara": {
      "layer": "Layer 3",
      "policy-id": "required-for-layer-3",
      "control-id": "required",
      "requirement-id": "required",
      "source": {
        "type": "policy",
        "policy-id": "required",
        "control-id": "required"
      },
      "base-requirement": {
        "reference-url": "required",
        "catalog-id": "required"
      },
      "applicability": ["required"]
    }
  }
}
```

### Layer 2 vs Layer 3 Requirements

**Layer 2 Requirements** (direct from catalog):
- `layer`: "Layer 2"
- `catalog-id`: Required
- `source.type`: "catalog"
- No `policy-id` or `base-requirement`

**Layer 3 Requirements** (from policy):
- `layer`: "Layer 3"
- `policy-id`: Required
- `source.type`: "policy"
- `base-requirement`: Required (references Layer 2 requirement)

## Example: Complete Workflow

```python
# 1. Fetch policy
policy = mcp_gemara-mcp_get_layer3_policy(
    policy_id="cloud-policy-001"
)

# 2. Resolve assessment requirements
resolved_requirements = resolve_policy_assessment_requirements(
    policy["metadata"]["id"]
)

# 3. Generate control requirement files (one per assessment requirement)
for req in resolved_requirements:
    control_file = {
        "$schema": "https://calm.finos.org/release/1.1/meta/control-requirement.json",
        "$id": req["gemara-url"],
        "control-id": req["requirement-id"],
        "name": f"Control {req['control-id']} - {req['requirement-id']}",
        "description": req["text"],  # Assessment requirement text
        "metadata": {
            "gemara": {
                "layer": "Layer 3",
                "policy-id": req["policy-id"],
                "control-id": req["control-id"],
                "requirement-id": req["requirement-id"],
                "source": {
                    "type": "policy",
                    "policy-id": req["policy-id"],
                    "control-id": req["control-id"]
                },
                "base-requirement": {
                    "reference-url": req["base-requirement-url"],
                    "catalog-id": req["catalog-id"]
                },
                "applicability": req["applicability"]
            }
        }
    }
    
    # Write to file
    filename = f"{req['requirement-id'].replace('.', '-').lower()}.requirement.json"
    with open(f"controls/{filename}", "w") as f:
        json.dump(control_file, f, indent=2)
```

## URL Mapping

Create a URL mapping file to map `gemara://` URLs to local files:

```json
{
  "gemara://policies/{policy-id}/controls/{control-id}/requirements/{requirement-id}": "../controls/{filename}.requirement.json",
  "gemara://controls/{catalog-id}/{control-id}/requirements/{requirement-id}": "../controls/base/{filename}.requirement.json"
}
```

Use this mapping with CALM CLI:

```bash
calm validate \
  -p pattern.json \
  -a architecture.json \
  -u url-mapping.json
```

## Best Practices

1. **One File Per Requirement**: Generate one control requirement file per assessment requirement
2. **Use Resolved Text**: Assessment requirement text becomes the control requirement description
3. **Reference Base Requirements**: Maintain traceability to Layer 2 requirements via `base-requirement`
4. **Use Consistent Naming**: Follow `{requirement-id}.requirement.json` naming convention
5. **Validate Before Committing**: Ensure files conform to standards
6. **Version Control**: Track control requirement files in git

## Related Documentation

- [Control Requirements Guide](../CONTROL_REQUIREMENTS.md) - Which components must reference assessment requirements
- [Gemara Policy Inclusion Standard](../standards/complytime-gemara-policy-inclusion.standard.json) - Schema for assessment requirements as control requirements
