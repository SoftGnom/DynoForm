FROM python:3.11-slim

WORKDIR /app

# Instal·lació de dependències del sistema necessàries per a 'cryptography' i altres
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Crear un entorn virtual intern i assegurar que s'usa sempre
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copiar dependències del projecte
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el codi de la teva aplicació
#COPY . .

# Informem que l'aplicació escolta pel port 8000
EXPOSE 8000

# Execució amb Uvicorn
# --host 0.0.0.0 és vital perquè el contenidor sigui accessible des de fora
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
