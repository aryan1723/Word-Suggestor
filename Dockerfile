FROM debian:bullseye

# Install dependencies
RUN apt-get update && \
    apt-get install -y g++ apache2 apache2-utils && \
    apt-get clean

# Enable CGI
RUN a2enmod cgi

# Create and set web directory
WORKDIR /var/www/html
COPY . /var/www/html

# Setup CGI directory
RUN mkdir -p /usr/lib/cgi-bin
COPY words.txt /usr/lib/cgi-bin/
RUN g++ -o /usr/lib/cgi-bin/trie.cgi trie.cpp
RUN chmod +x /usr/lib/cgi-bin/trie.cgi
RUN chmod 755 /usr/lib/cgi-bin/words.txt

# Apache CGI configuration
RUN echo "<Directory \"/usr/lib/cgi-bin\">" >> /etc/apache2/apache2.conf && \
    echo "    AllowOverride None" >> /etc/apache2/apache2.conf && \
    echo "    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/apache2/apache2.conf && \
    echo "    Require all granted" >> /etc/apache2/apache2.conf && \
    echo "</Directory>" >> /etc/apache2/apache2.conf

# Fix the ServerName warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port and start Apache
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
