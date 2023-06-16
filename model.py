import os
import subprocess
from request import ModelRequest

def run_command(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return stdout, stderr, process.returncode

class Model:
    def __new__(cls):
        if not hasattr(cls, 'instance'):
            cls.instance = super(Model, cls).__new__(cls)
        return cls.instance

    def inference(self, request: ModelRequest):
        print(f"Input file path: {request.wav_file}")
        if not os.path.exists(request.wav_file):
            print(f"Input file does not exist")
            return {
                "success": False,
                "error": "Input file does not exist",
            }


        os.makedirs("/temp_dir", exist_ok=True)
        conversion_file_path = "/temp_dir/audio16.wav"
        stdout, stderr, returncode = run_command(["ffmpeg", "-y", "-i", request.wav_file, "-ar", "16000", conversion_file_path])
        if returncode != 0:
            print(f"Error running ffmpeg: {stderr.decode('utf-8')}")
            return {
                "success": False,
                "error": stderr.decode('utf-8'),
            }

        fairseq_dir = "/app/fairseq"
        inference_cmd = [
            "python", "examples/mms/asr/infer/mms_infer.py",
            "--model", "models_new/mms1b_fl102.pt",
            "--lang", "ory",
            "--audio", conversion_file_path
        ]

        current_dir = os.getcwd()
        os.chdir(fairseq_dir)  # Change working directory to fairseq folder
        
        stdout, stderr, returncode = run_command(inference_cmd)
        if returncode != 0:
            print(f"Error running mms_infer.py: {stderr.decode('utf-8')}")
            return {
                "success": False,
                "error": stderr.decode('utf-8'),
            }

        # Get only the output from stdout
        output_lines = stdout.decode('utf-8').split("\n")
        output = output_lines[-2]  # Assuming the desired output is the second-to-last line

        os.chdir(current_dir)  # Change back to the original working directory

        return {
            "success": True,
            "speech_to_text": output
        }
