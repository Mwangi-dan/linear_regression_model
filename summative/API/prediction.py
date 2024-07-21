from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np

# Load the trained model
model = joblib.load('trained_model.pkl')

# Define the FastAPI app
app = FastAPI()

# Define the input data model
class InputData(BaseModel):
    weight: float
    resoloution: float
    ppi: float
    cpu_core: int
    cpu_freq: float
    internal_mem: float
    ram: float
    RearCam: float
    Front_Cam: float
    battery: int
    thickness: float

# Define the predict endpoint
@app.post("/predict/")
def predict(data: InputData):
    # Convert input data to numpy array
    input_data = np.array([[data.weight, data.resoloution, data.ppi, data.cpu_core, data.cpu_freq,
                            data.internal_mem, data.ram, data.RearCam, data.Front_Cam, data.battery,
                            data.thickness]])
    
    # Make prediction
    prediction = model.predict(input_data)
    
    # Return the prediction
    return {"predicted_price": prediction[0]}
