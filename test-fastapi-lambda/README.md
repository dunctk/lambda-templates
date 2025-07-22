# {{project_name}}

A FastAPI + Tailwind CSS + OpenAI GPT-4.1 template for AWS Lambda, designed for rapid MVP development.

## Features

- 🚀 FastAPI with AWS Lambda integration via Mangum
- 🎨 Tailwind CSS via CDN (no build process)
- 🤖 OpenAI GPT-4.1 integration 
- 📄 Jinja2 templating
- 🔒 Environment-based secrets management
- ⚡ One-command deployment

## Quick Start

### Prerequisites

- Python 3.11+
- AWS CLI configured with appropriate permissions
- OpenAI API key

### Local Development

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set your OpenAI API key:
```bash
export OPENAI_API_KEY=your-openai-api-key-here
```

3. Run locally:
```bash
uvicorn app:app --reload
```

Visit http://localhost:8000 to see your app.

### Deploy to AWS Lambda

1. Create a Lambda execution role in AWS IAM with basic execution permissions.

2. Set your OpenAI API key:
```bash
export OPENAI_API_KEY=your-openai-api-key-here
```

3. Deploy:
```bash
./deploy.sh my-app-name arn:aws:iam::123456789012:role/lambda-execution-role
```

The script will:
- Install dependencies
- Package your code
- Deploy to Lambda
- Set up a Function URL for direct HTTP access
- Configure environment variables

## Project Structure

```
{{project_name}}/
├── app.py              # FastAPI app with Lambda handler
├── requirements.txt    # Python dependencies
├── deploy.sh          # AWS Lambda deployment script
└── templates/
    └── index.html     # Jinja2 template with Tailwind CSS
```

## API Endpoints

- `GET /` - Main page with chat interface
- `POST /api/chat` - Chat with GPT-4.1
- `GET /health` - Health check endpoint

## Customization

### Adding New Routes

Add routes to `app.py`:

```python
@app.get("/api/example")
async def example():
    return {"message": "Hello from your new endpoint!"}
```

### New Templates

Add HTML files to the `templates/` directory and reference them in your routes:

```python
@app.get("/new-page", response_class=HTMLResponse)
async def new_page(request: Request):
    return templates.TemplateResponse("new-page.html", {"request": request})
```

### Styling

The template uses Tailwind CSS via CDN. Modify classes in your HTML templates or add custom CSS as needed.

## Environment Variables

- `OPENAI_API_KEY` - Your OpenAI API key (required)

## Development Tips

- Use `uvicorn app:app --reload` for local development with auto-reload
- The Lambda handler is automatically created by Mangum
- Function URLs provide direct HTTP access without API Gateway
- Keep your OpenAI API key secure and never commit it to version control

## Troubleshooting

### Local Development Issues
- Make sure Python 3.11+ is installed
- Verify OPENAI_API_KEY is set in your environment
- Check that all dependencies are installed

### Deployment Issues
- Ensure AWS CLI is configured with proper credentials
- Verify your Lambda execution role has necessary permissions
- Check that your OPENAI_API_KEY environment variable is set

For more help, check the AWS Lambda and FastAPI documentation.