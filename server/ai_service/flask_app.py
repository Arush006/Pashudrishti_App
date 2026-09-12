from flask import Flask, request, jsonify
import os
import sys

# Add the AI module path using relative path
ai_module_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Pashudrishti_ai"))
sys.path.insert(0, ai_module_path)

from PashuDrishti_Api import predict_disease

app = Flask(__name__)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER


@app.route("/")
def home():
    return jsonify({
        "success": True,
        "message": "PashuDrishti AI API Running"
    })


@app.route("/health")
def health():
    return jsonify({
        "success": True,
        "status": "running"
    })


@app.route("/predict", methods=["POST"])
def predict():
    try:
        # Check image
        if "image" not in request.files:
            return jsonify({
                "success": False,
                "error": "No image uploaded"
            }), 400

        file = request.files["image"]

        if file.filename == "":
            return jsonify({
                "success": False,
                "error": "No file selected"
            }), 400

        filepath = os.path.join(app.config["UPLOAD_FOLDER"], file.filename)
        file.save(filepath)
        print("FORM DATA:", request.form)
        
        # Get values from frontend
        fever = request.form.get("fever", "").lower()
        appetite = request.form.get("appetite", "").lower()
        lesions = request.form.get("lesions", "").lower()
        
        # Mapping
        fever_map = {
            "high": "high",
            "medium": "mild",
            "low": "low",
            "none": "mild"
        }

        appetite_map = {
            "normal": "slight",
            "low": "low",
            "very low": "low",
            "not eating": "low"
        }

        lesion_map = {
            "skin": "skin",
            "eyes": "eye+mouth",
            "mouth": "mouth+hoof",
            "udder": "udder",
            "none": "skin"
        }

       # Final symptoms dictionary
        symptoms = {
            "fever": fever_map.get(fever, fever),
            "appetite": appetite_map.get(appetite, appetite),
            "lesions": lesion_map.get(lesions, lesions)
        }

        print("Symptoms:", symptoms)
        print("Image:", filepath)

        # AI Prediction
        result = predict_disease(filepath, symptoms)

        disease = result.get("disease", "Unknown Disease")
        confidence = result.get("confidence", 0)
        top3 = result.get("top3", [])

        response = {
            "success": True,
            "primary_disease": disease,
            "confidence": confidence,
            "top_3_predictions": top3,
            "treatment_info": {
                "message": "Consult a veterinarian for proper diagnosis and treatment."
            }
        }

        print("Response:", response)

        return jsonify(response)

    except Exception as e:
        print("Prediction Error:", str(e))

        return jsonify({
            "success": False,
            "error": str(e)
        }), 500


@app.route("/diseases", methods=["GET"])
def diseases():
    return jsonify({
        "success": True,
        "diseases": [
            "Foot and Mouth Disease",
            "Mastitis",
            "Lumpy Skin Disease",
            "Anthrax",
            "Black Quarter"
        ]
    })


@app.route("/disease-info/<disease>", methods=["GET"])
def disease_info(disease):
    return jsonify({
        "success": True,
        "disease": disease,
        "description": f"Information about {disease}",
        "treatment": "Consult veterinarian",
        "prevention": "Maintain hygiene and vaccination schedule"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)