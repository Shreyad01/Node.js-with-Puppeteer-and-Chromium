# Stage 1: Scraper
FROM node:18-slim AS scraper

WORKDIR /app

#copy your app files
COPY scrape.js . 
COPY package*.json . 

#Install dependencies
RUN npm install

# Install Chromium dependencies
RUN apt-get update && apt-get install -y \
    chromium \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Copy your app code
COPY . .

# Let Puppeteer know where Chromium is
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium




# Set environment variable for URL in runtime
ARG SCRAPE_URL
ENV SCRAPE_URL=$SCRAPE_URL

#Run the Script
RUN node scrape.js

# Stage 2: Python server
FROM python:3.10-slim AS server

WORKDIR /app
COPY --from=scraper /app/scraped_data.json ./scraped_data.json
COPY server.py .
COPY requirements.txt .
RUN pip install -r requirements.txt

EXPOSE 5000
CMD ["python", "server.py"]
