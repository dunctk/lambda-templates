import os
from typing import Optional
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from mangum import Mangum
from openai import OpenAI

app = FastAPI(title="{{project_name}}")
templates = Jinja2Templates(directory="templates")

# Initialize OpenAI client with GPT-4.1
client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY")
)

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse("index.html", {
        "request": request,
        "title": "{{project_name}}"
    })

@app.post("/api/chat")
async def chat(request: Request):
    data = await request.json()
    message = data.get("message", "")
    
    if not message:
        return {"error": "Message is required"}
    
    try:
        response = client.chat.completions.create(
            model="gpt-4-turbo-2024-04-09",  # GPT-4.1
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": message}
            ],
            max_tokens=150
        )
        
        return {
            "response": response.choices[0].message.content,
            "model": "gpt-4-turbo-2024-04-09"
        }
    except Exception as e:
        return {"error": str(e)}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "{{project_name}}"}

# AWS Lambda handler
lambda_handler = Mangum(app)