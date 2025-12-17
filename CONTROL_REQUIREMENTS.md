# Control Requirements for ComplyTime Components

This document defines which ComplyTime components must reference Gemara assessment requirements and why.

## Overview

CALM (declarative architecture) and Gemara (runtime validation) work together: **CALM declares which assessment requirements apply, Gemara validates implementation matches**.

## Lexicon Mapping

**Key Concept**: In CALM, a **control requirement** is a **Gemara assessment requirement**.

- **CALM Term**: "Control Requirement" = A testable compliance statement
- **Gemara Term**: "Assessment Requirement" = A testable compliance statement (Layer 2 or Layer 3)
- **Relationship**: They are the same thing - Gemara assessment requirements are represented as CALM control requirements

## Integration Flow

```
Architecture → Pattern Validation → Control Resolution → Runtime Validation
     ↓                ↓                    ↓                    ↓
  Declares        Validates           Resolves            Validates
  assessment      references          gemara:// URLs      implementation
  requirements    to requirements     to requirement      against requirement
```

## Roles

- **CALM**: Documents architecture and declares assessment requirements (as control requirements) via `gemara://` URLs
- **Gemara**: Defines assessment requirements (Layer 2/3) and validates runtime implementation matches declared requirements

## Example Flow

1. **Architecture** declares: `"requirement-url": "gemara://policies/cloud-policy-001/controls/CCC.Core.CN01/requirements/CCC.Core.CN01.TR01"`
2. **Pattern** validates: Ensures security-critical components reference assessment requirements
3. **Control file** resolves: Maps URL to assessment requirement definition with resolved text
4. **Gemara runtime** validates: Verifies actual implementation matches the requirement (e.g., TLS 1.3 enabled)

## Key Concept

**Separation**: Architecture declares *what* assessment requirements apply, Gemara validates *how* they're implemented.

## Assessment Requirement Reference Format

All assessment requirement references must follow this structure:

```json
{
  "controls": {
    "{control-category}": {
      "description": "Description of why these assessment requirements apply",
      "requirements": [
        {
          "requirement-url": "gemara://policies/{policy-id}/controls/{control-id}/requirements/{requirement-id}",
          "description": "Human-readable description of the assessment requirement",
          "config": {
            "implementation-specific-config": "value"
          }
        }
      ]
    }
  }
}
```

**Note**: The `requirement-url` must reference a specific assessment requirement (not just a control). Each assessment requirement is a CALM control requirement.

## Control Categories

Common control categories:
- `security`: Security-related assessment requirements (encryption, access control)
- `data-protection`: Data protection assessment requirements (encryption, replication)
- `access-control`: Access control and authentication assessment requirements
- `audit`: Audit and logging assessment requirements

## Pattern Enforcement

The `complytime-deployment.pattern.json` enforces:
- **Compass**: Must reference assessment requirements (required)
- **Collector**: Should reference assessment requirements (recommended, pattern allows but doesn't require)
- **Evidence Store**: Should reference assessment requirements (recommended, pattern allows but doesn't require)

## Validation

Assessment requirement references are validated:
1. **Pattern Validation**: Ensures requirement URLs follow `gemara://` scheme with `/requirements/` path
2. **File Existence**: Validates that control requirement files exist for referenced assessment requirements
3. **Standard Conformance**: Validates control files conform to `complytime-gemara-policy-inclusion.standard.json`
4. **Runtime Validation**: Gemara validates actual implementation matches the assessment requirement

## Creating Control Requirements

See [tools/CONTROL_REQUIREMENTS.md](tools/CONTROL_REQUIREMENTS.md) for detailed instructions on creating control requirement files from Gemara policies.

## Best Practices

1. **Reference Policy Assessment Requirements**: Prefer Layer 3 policy assessment requirements over Layer 2 catalog requirements when available
2. **Document Rationale**: Include descriptions explaining why assessment requirements apply
3. **Include Config**: Add implementation-specific configuration in `config` field
4. **Keep Updated**: Update assessment requirement references when policies change
5. **Validate Regularly**: Run `make validate-control-files` before committing
6. **Use Specific Requirements**: Always reference specific assessment requirements (with `/requirements/{requirement-id}`), not just controls

## Related Documentation

- [Creating Control Requirement Files](tools/CONTROL_REQUIREMENTS.md) - How to create control requirement files from Gemara policies
- [Gemara Policy Inclusion Standard](standards/complytime-gemara-policy-inclusion.standard.json) - Schema for assessment requirements as control requirements
- [Control Metadata Standard](standards/complytime-control-metadata.standard.json)
