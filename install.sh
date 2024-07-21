#!/bin/bash

# Atualiza o sistema
sudo apt update
sudo apt upgrade

# Instala o Python, pip e o pacote para ambientes virtuais
sudo apt install python3.8 python3-pip python3-venv

# Clona o repositório
git clone https://github.com/MateusProjetos/api_youtube.git

# Entra na pasta do projeto
cd api_youtube

# Cria e ativa o ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instala as dependências
pip install -r requirements.txt

# Instala o Nginx e o Certbot
sudo apt install nginx certbot python3-certbot-nginx

# Remove a configuração padrão do Nginx
sudo rm /etc/nginx/sites-enabled/default

# Cria o arquivo de configuração do Nginx
sudo tee /etc/nginx/sites-available/api_youtube <<EOF
server {
    listen 80;
    server_name api-youtube.dcodeclub.top www.api-youtube.dcodeclub.top;

    # Redireciona todo o tráfego HTTP para HTTPS
    return 301 https://$host$request_uri; 
}

server {
    listen 443 ssl;
    server_name api-youtube.dcodeclub.top www.api-youtube.dcodeclub.top;

    # Caminhos dos certificados SSL (serão gerados pelo Certbot)
    ssl_certificate /etc/letsencrypt/live/api-youtube.dcodeclub.top/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api-youtube.dcodeclub.top/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Cria o link simbólico para o site habilitado
sudo ln -s /etc/nginx/sites-available/api_youtube /etc/nginx/sites-enabled/

# Obtém e instala o certificado SSL com o Certbot
sudo certbot --nginx -d api-youtube.dcodeclub.top -d www.api-youtube.dcodeclub.top

# Testa a configuração do Nginx
sudo nginx -t

# Reinicia o Nginx
sudo systemctl restart nginx

# Inicia o Gunicorn (em segundo plano)
gunicorn -c gunicorn.conf.py main:app &
