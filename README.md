# fairseq_gpu_deployment
Deploying new fairseq models through APIs


To test the api run the follwing curl : 

curl -X POST -F "wav_file=@\"wav_audio_anorexia prevention odia.wav"\" http://localhost:5000/speech_to_text


I have added both the deploy.sh and the docker requried to run the repo. 
Currently, I'm facing issues regarding cuda installation in both setups.  
