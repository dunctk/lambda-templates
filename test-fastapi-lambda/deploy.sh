#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy.sh <function-name> <role-arn> [region]
FUNCTION_NAME=${1:-"{{project_name}}"}
ROLE_ARN=${2:-}
REGION=${3:-"{{aws_region}}"}

if [ -z "$ROLE_ARN" ]; then
    echo "Usage: $0 <function-name> <role-arn> [region]"
    echo "Example: $0 my-fastapi-app arn:aws:iam::123456789012:role/lambda-execution-role us-east-1"
    exit 1
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
    echo "Error: OPENAI_API_KEY environment variable is required"
    echo "Export it first: export OPENAI_API_KEY=your-key-here"
    exit 1
fi

echo "Deploying $FUNCTION_NAME to AWS Lambda in region $REGION..."

# Create deployment package
ZIP_FILE="${FUNCTION_NAME}.zip"
rm -f "$ZIP_FILE"

echo "Installing dependencies..."
pip install -r requirements.txt -t .

echo "Creating deployment package..."
zip -r "$ZIP_FILE" . -x "*.git*" "*.DS_Store*" "deploy.sh" "__pycache__/*" "*.pyc"

# Deploy to AWS Lambda
echo "Deploying to AWS Lambda..."

# Try to create the function first
if aws lambda create-function \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --runtime python3.11 \
    --handler app.lambda_handler \
    --role "$ROLE_ARN" \
    --zip-file "fileb://$ZIP_FILE" \
    --timeout 30 \
    --memory-size 512 \
    --environment "Variables={OPENAI_API_KEY=$OPENAI_API_KEY}" \
    --description "FastAPI Lambda function for {{project_name}}" 2>/dev/null; then
    echo "✅ Function created successfully!"
else
    echo "Function exists, updating code..."
    aws lambda update-function-code \
        --region "$REGION" \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$ZIP_FILE"
    
    echo "Updating environment variables..."
    aws lambda update-function-configuration \
        --region "$REGION" \
        --function-name "$FUNCTION_NAME" \
        --environment "Variables={OPENAI_API_KEY=$OPENAI_API_KEY}"
    
    echo "✅ Function updated successfully!"
fi

# Create or update function URL (optional, for direct HTTP access)
echo "Setting up function URL..."
if aws lambda create-function-url-config \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --auth-type NONE \
    --cors "AllowCredentials=false,AllowHeaders=*,AllowMethods=*,AllowOrigins=*,ExposeHeaders=*,MaxAge=86400" 2>/dev/null; then
    echo "✅ Function URL created!"
else
    echo "Function URL already exists, updating CORS..."
    aws lambda update-function-url-config \
        --region "$REGION" \
        --function-name "$FUNCTION_NAME" \
        --cors "AllowCredentials=false,AllowHeaders=*,AllowMethods=*,AllowOrigins=*,ExposeHeaders=*,MaxAge=86400" 2>/dev/null || true
fi

# Get the function URL
FUNCTION_URL=$(aws lambda get-function-url-config \
    --region "$REGION" \
    --function-name "$FUNCTION_NAME" \
    --query 'FunctionUrl' \
    --output text 2>/dev/null || echo "")

# Clean up
rm -f "$ZIP_FILE"
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true

echo ""
echo "🚀 Deployment complete!"
echo "Function Name: $FUNCTION_NAME"
echo "Region: $REGION"
if [ -n "$FUNCTION_URL" ]; then
    echo "Function URL: $FUNCTION_URL"
    echo ""
    echo "You can access your app directly at: $FUNCTION_URL"
fi
echo ""
echo "To test locally:"
echo "  pip install -r requirements.txt"
echo "  export OPENAI_API_KEY=your-key"
echo "  uvicorn app:app --reload"