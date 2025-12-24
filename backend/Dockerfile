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

# Default command
CMD ["odoo", "--addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons", "-d", "kerjaflow", "--db_host=db", "--db_user=odoo", "--db_password=odoo"]
