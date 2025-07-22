# Lambda Templates

A collection of cargo-generate templates for AWS Lambda functions.

## Available Templates

### Python FastAPI
Location: `templates/python-fastapi`

FastAPI-based Lambda function with Mangum adapter for handling HTTP requests.

## Usage

Generate a new project using any template:

```bash
# Using subfolder path directly
cargo generate --git https://github.com/your-username/lambda-templates.git templates/python-fastapi --name my-project

# Or using --subfolder flag
cargo generate --git https://github.com/your-username/lambda-templates.git --subfolder templates/python-fastapi --name my-project
```

## Adding New Templates

1. Create a new directory under `templates/`
2. Add your template files including `cargo-generate.toml`
3. Update this README with the new template information