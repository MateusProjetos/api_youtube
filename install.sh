#!/bin/bash

# Atualiza o sistema
sudo apt update
sudo apt upgrade -y

# Instala o Python, pip, e pacotes para ambientes virtuais
sudo apt install -y python3.8 python3-pip python3-venv git

# Instala o Nginx
sudo apt install -y nginx

# Clona o repositório
git clone https://github.com/MateusProjetos/api_youtube.git

# Entra na pasta do projeto
cd api_youtube

# Cria e ativa o ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instala as dependências
pip install -r requirements.txt

# Configura o Gunicorn como um serviço systemd
sudo tee /etc/systemd/system/gunicorn.service <<EOF
[Unit]
Description=Gunicorn instance to serve api_youtube
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/home/root/api_youtube
Environment="PATH=/home/root/api_youtube/venv/bin"
ExecStart=/home/root/api_youtube/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 main:app

[Install]
WantedBy=multi-user.target
EOF

# Inicia e habilita o serviço Gunicorn
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# Remove a configuração padrão do Nginx
sudo rm /etc/nginx/sites-enabled/default

# Cria o arquivo de configuração do Nginx
sudo tee /etc/nginx/sites-available/api_youtube <<EOF
server {
    listen 80;
    server_name api-youtube.dcodeclub.top www.api-youtube.dcodeclub.top;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Cria o link simbólico para o site habilitado
sudo ln -s /etc/nginx/sites-available/api_youtube /etc/nginx/sites-enabled/

# Testa a configuração do Nginx
sudo nginx -t

# Reinicia o Nginx
sudo systemctl restart nginx
