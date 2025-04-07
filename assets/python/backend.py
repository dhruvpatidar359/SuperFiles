# backend.py
import os
import torch
from flask import Flask, request, jsonify
from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM

app = Flask(__name__)

# Set PyTorch performance settings
import multiprocessing

num_cores = multiprocessing.cpu_count()
torch.set_num_threads(num_cores)
torch.set_num_interop_threads(num_cores)
torch.set_grad_enabled(False)

# Environment variables
os.environ["OMP_NUM_THREADS"] = str(num_cores)
os.environ["MKL_NUM_THREADS"] = str(num_cores)

# Directory to store the models locally
MODEL_CACHE_DIR = os.path.join(os.path.dirname(__file__), 'models')

if not os.path.exists(MODEL_CACHE_DIR):
    os.makedirs(MODEL_CACHE_DIR)

# Dictionary to cache models
models = {}

def get_model(model_name):
    if model_name not in models:
        print(f"Loading model: {model_name}")
        # Load the tokenizer and model with the specified cache directory
        tokenizer = AutoTokenizer.from_pretrained(model_name, cache_dir=MODEL_CACHE_DIR)
        model = AutoModelForSeq2SeqLM.from_pretrained(model_name, cache_dir=MODEL_CACHE_DIR)

        # Quantize the model for faster CPU inference (optional)
        model = torch.quantization.quantize_dynamic(
            model, {torch.nn.Linear}, dtype=torch.qint8
        )

        summarizer = pipeline(
            "summarization",
            model=model,
            tokenizer=tokenizer,
            device=-1  # Use CPU; set to 0 if using GPU
        )
        models[model_name] = summarizer
    return models[model_name]

@app.route('/summarize', methods=['POST'])
def summarize():
    data = request.get_json()
    text = data.get('text', '')
    model_name = data.get('model_name', 'Falconsai/text_summarization')
    if not text:
        return jsonify({'error': 'No text provided'}), 400
    summarizer = get_model(model_name)
    summary = summarizer(
        text,
        max_length=150,
        min_length=100,
        do_sample=False,
        num_beams=1  # Faster decoding
    )
    return jsonify({'summary': summary[0]['summary_text']})

if __name__ == '__main__':
    # It's better to use Gunicorn for multi-processing
    app.run(host='127.0.0.1', port=5000, threaded=True)
