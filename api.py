import os
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from model import Model
from request import ModelRequest

app = Flask(__name__)

@app.route('/speech_to_text', methods=['POST'])
def speech_to_text():
    if 'wav_file' not in request.files:
        return jsonify({'success': False, 'error': 'No file part in the request'}), 400

    file = request.files['wav_file']

    if file.filename == '':
        return jsonify({'success': False, 'error': 'No selected file'}), 400

    if file:
        filename = secure_filename(file.filename)
        filepath = os.path.join("/temp_dir", filename)
        file.save(filepath)
        print(f"Received file: {filename}, saved at: {filepath}")

        model_request = ModelRequest(wav_file=filepath)

        model = Model()
        result = model.inference(model_request)

        return jsonify(result)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0')
