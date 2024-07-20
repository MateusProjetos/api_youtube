# gunicorn.conf.py
bind = "0.0.0.0:8000"  # Ouça em todas as interfaces na porta 8000
workers = 4           # Número de processos worker
