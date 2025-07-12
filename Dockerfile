FROM debian:bullseye

# Install required packages
RUN apt-get update && \
    apt-get install -y g++ apache2 apache2-utils && \
    apt-get clean

# Enable CGI
RUN a2enmod cgi

# Setup working directory
WORKDIR /var/www/html
COPY . /var/www/html

# Ensure words.txt and compiled trie.cgi are in the correct place
RUN mkdir -p /usr/lib/cgi-bin
COPY words.txt /usr/lib/cgi-bin/
RUN g++ -o /usr/lib/cgi-bin/trie.cgi trie.cpp
RUN chmod +x /usr/lib/cgi-bin/trie.cgi
RUN chmod 755 /usr/lib/cgi-bin/words.txt

# Configure Apache for CGI execution
RUN echo "<Directory \"/usr/lib/cgi-bin\">" >> /etc/apache2/apache2.conf && \
    echo "    AllowOverride None" >> /etc/apache2/apache2.conf && \
    echo "    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/apache2/apache2.conf && \
    echo "    Require all granted" >> /etc/apache2/apache2.conf && \
    echo "</Directory>" >> /etc/apache2/apache2.conf

# Fix the ServerName warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 80 and start Apache
EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
