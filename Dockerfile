# Python 3.10 pre-installed on Alpine Linux
FROM python:3.10-alpine3.18
WORKDIR /app

# Install Python utilities
RUN apk add --no-cache --update alpine-sdk wget ca-certificates musl-dev libc-dev gcc bash linux-headers

# Install latest Node.js and npm
RUN apk add --no-cache nodejs npm
# Downgrade Node.js to v18 due to arm v7 architecture incompatibility: https://github.com/parse-community/parse-server/pull/8905
RUN npm install -g node@18

# Install pm2
RUN npm install pm2 -g

# Copy requirements.txt from build machine to WORKDIR (/app) folder (important we do this BEFORE copying the rest of the files to avoid re-running pip install on every code change)
COPY requirements.txt requirements.txt

# Install Python requirements
RUN pip3 install --no-cache-dir -r requirements.txt

# Make Docker /config volume for optional config file
VOLUME /config

# Copy example config file from build machine to Docker /config folder
# Also copies any existing config.yaml file from build machine to Docker /config folder, (will cause the bot to use the existing config file if it exists)
COPY config.yaml* /config/

# Make Docker /logs volume for log file
VOLUME /logs

# Copy source code from build machine to WORKDIR (/app) folder
COPY . .

# Delete unnecessary files in WORKDIR (/app) folder (not caught by .dockerignore)
RUN echo "**** removing unneeded files ****"
RUN rm -rf /app/requirements.txt

# Run the app
CMD [ "pm2-runtime", "start", "ecosystem.config.json"]
