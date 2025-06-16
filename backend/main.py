from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import string

# Create FastAPI app
app = FastAPI(title="Password Generator API")

# Add CORS middleware to allow Flutter app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request model
class PasswordRequest(BaseModel):
    length: int
    include_numbers: bool
    include_special_chars: bool

# Password generation logic
def generate_password(length: int, include_numbers: bool, include_special_chars: bool) -> str:
    # Start with basic letters
    characters = string.ascii_letters  # a-z, A-Z
    
    # Add numbers if requested
    if include_numbers:
        characters += string.digits  # 0-9
    
    # Add special characters if requested
    if include_special_chars:
        characters += "!@#$%^&*()_+-=[]{}|;:,.<>?"
    
    # Generate random password
    password = ''.join(random.choice(characters) for _ in range(length))
    return password

# API endpoint to generate password
@app.post("/generate-password")
async def create_password(request: PasswordRequest):
    try:
        password = generate_password(
            length=request.length,
            include_numbers=request.include_numbers,
            include_special_chars=request.include_special_chars
        )
        return {"password": password, "success": True}
    except Exception as e:
        return {"error": str(e), "success": False}

# Health check endpoint
@app.get("/")
async def root():
    return {"message": "Password Generator API is running!"}

# Run the server
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)