FROM odoo:17.0

USER root

# Install additional system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt /tmp/requirements.txt
COPY requirements-dev.txt /tmp/requirements-dev.txt

# Install Python dependencies
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Create directories for addons
RUN mkdir -p /mnt/extra-addons

# Copy custom addons
COPY odoo/addons /mnt/extra-addons

# Set proper permissions
RUN chown -R odoo:odoo /mnt/extra-addons

USER odoo

# Expose ports
EXPOSE 8069 8072

# Environment variables for database connection
# CRITICAL: These must be set in production, never use defaults
ENV DB_HOST=${DB_HOST:-db}
ENV DB_USER=${DB_USER:-odoo}
ENV DB_PASSWORD=${DB_PASSWORD}
ENV DB_NAME=${DB_NAME:-kerjaflow}

# Default command - uses environment variables
CMD ["sh", "-c", "odoo --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons -d ${DB_NAME} --db_host=${DB_HOST} --db_user=${DB_USER} --db_password=${DB_PASSWORD}"]
