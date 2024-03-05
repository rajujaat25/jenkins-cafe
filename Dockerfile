FROM ubuntu

# Update package index
RUN apt-get update

# Install Apache
RUN apt-get install -y apache2

# Copy files into Apache HTML directory
COPY . /var/www/html/

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port 80
EXPOSE 80

# Restart Apache service when the container starts
CMD service apache2 restart && tail -f /dev/null

