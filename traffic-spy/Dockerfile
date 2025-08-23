FROM openjdk:11-jdk-slim

WORKDIR /app

# Copy Java source
COPY TrafficSpy.java .

# Compile
RUN javac TrafficSpy.java

# Run the spy
CMD ["java", "TrafficSpy"]