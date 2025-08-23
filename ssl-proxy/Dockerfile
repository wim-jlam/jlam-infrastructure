FROM openjdk:11-jre-slim

WORKDIR /app

# Copy Java source file
COPY SSLProxy.java .

# Compile Java
RUN javac SSLProxy.java

# Expose proxy port
EXPOSE 9001

# Run the proxy
CMD ["java", "SSLProxy"]