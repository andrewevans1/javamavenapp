FROM ubuntu



# Install OpedJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y maven && \
    apt-get clean;

# Install git
RUN apt-get -y install git

# Clone github repo
RUN git clone https://github.com/SimplilearnDevOpsOfficial/javamavenapp.git

# change the working directory
WORKDIR javamavenapp

# compile java app
RUN mvn package

#execute app when image is run
ENTRYPOINT java -cp target/my-app-1.0-SNAPSHOT.jar com.mycompany.app.App
