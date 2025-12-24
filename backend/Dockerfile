FROM odoo:17.0

USER root

# Copy requirements
COPY requirements.txt /tmp/requirements.txt
COPY requirements-dev.txt /tmp/requirements-dev.txt

# Update pyopenssl to fix cryptography compatibility issue
RUN pip3 install --no-cache-dir --upgrade pyopenssl

# Install Python dependencies
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Create directories for addons and filestore
RUN mkdir -p /mnt/extra-addons /var/lib/odoo/filestore

# Copy custom addons
COPY odoo/addons /mnt/extra-addons

# Set proper permissions for addons and filestore
RUN chown -R odoo:odoo /mnt/extra-addons /var/lib/odoo

USER odoo

# Expose ports
EXPOSE 8069 8072

# Default command - uses Odoo standard environment variables
# HOST, PORT, USER, PASSWORD, DATABASE are set by docker-compose
CMD ["sh", "-c", "odoo --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons -d ${DATABASE:-kerjaflow} --db_host=${HOST:-db} --db_user=${USER:-odoo} --db_password=${PASSWORD}"]
