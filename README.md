# ComplyTime Policies

This repository contains CALM (Common Architecture Language Model) architectures, standards, and controls for the ComplyTime ecosystem.

## Quick Start

### View Available Commands

```bash
make help
```

### Validate Architecture Against Pattern

```bash
# Validate agent mode example
make validate-agent-mode-example-1
```

## Deployment Patterns

### Agent Mode Deployment

The `complytime-deployment.pattern.json` pattern focuses on **agent mode** deployments where the OTEL Collector runs as a sidecar or daemonset:

- **Architecture**: Direct ProofWatch → Collector Agent connection
- **Processing**: Local processing with TruthBeam processor component
- **Observability Stack**:
  - **Loki**: Log aggregation for compliance evidence logs
  - **Grafana**: Visualization and dashboards for compliance monitoring
  - **S3**: Long-term immutable evidence storage
- **Example**: `complytime-example.arch.json`

## Control Requirements

- **[Control Requirements Guide](CONTROL_REQUIREMENTS.md)**: Which components must reference Gemara assessment requirements (as CALM control requirements)
- **[Creating Control Files](tools/CONTROL_REQUIREMENTS.md)**: How to create control requirement files from Gemara policies, including MCP server integration

**Note**: In CALM, a control requirement is a Gemara assessment requirement. Each assessment requirement becomes its own control requirement file with resolved text as the description.

## License

See [LICENSE](LICENSE) file for details.
