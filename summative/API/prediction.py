from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import numpy as np

# Load the trained model
model = joblib.load('new_trained_model.pkl')

# Define the FastAPI app
app = FastAPI()

# Resolving Cross Origin Resource Sharing error
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define the input data model
class InputData(BaseModel):
    ppi: float
    cpu_freq: float
    internal_mem: float
    ram: float
    RearCam: float
    Front_Cam: float
    battery: int

# Define the predict endpoint
@app.post("/predict/")
def predict(data: InputData):
    # Convert input data to numpy array
    input_data = np.array([[data.ppi, data.cpu_freq, data.internal_mem, data.ram, data.RearCam, data.Front_Cam, data.battery,]])
    
    # Make prediction
    prediction = model.predict(input_data)
    
    # Return the prediction
    return {"predicted_price": prediction[0]}
