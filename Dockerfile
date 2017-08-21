FROM openjdk:slim

RUN apt-get update && \
    apt-get install unzip wget -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
WORKDIR $PWD/JadeProject

#Set JADE_BIN_URL if you want to use another source for Jade.
ENV JADE_BIN_URL ${JADE_BIN_URL:-"http://jade.tilab.com/dl.php?file=JADE-bin-4.5.0.zip"}
ENV JADE_ARCHIVE ${JADE_ARCHIVE:-JadeArchive.zip}
RUN wget -O $PWD/$JADE_ARCHIVE $JADE_BIN_URL && \
    unzip -Z $JADE_ARCHIVE && unzip $JADE_ARCHIVE -d $PWD && \
    rm -Rf $JADE_ARCHIVE

#src are your source files. They should be in the directory you build
COPY src src/
#TODO: add bash script to generate jar from .java files.
WORKDIR src
#your Jar file containing your agent source file
ENV AGENT_JAR_FILE ${AGENT_JAR_FILE:-"jadeExamples.jar"}
ENV CONTAINER_NAME ${CONTAINER_NAME:-"exampleContainer"}
ENV AGENT_NAME ${AGENT_NAME:-"exampleAgent"}
#The agent you want to launch.
ENV AGENT_CLASS ${AGENT_CLASS:-"examples.hello.HelloWorldAgent"}
#This is the standard port for Jade. You also need to expose the Jade port.
ENV JADE_PORT ${JADE_PORT:-1099}
EXPOSE $JADE_PORT

CMD echo "Your jar file:" ${AGENT_JAR_FILE} && \
    AGENTS=${AGENT_TABLE:-$AGENT_NAME\:$AGENT_CLASS} && \
    echo "\nCommand executed: jade.Boot -container-name" ${CONTAINER_NAME} "-local-port" ${JADE_PORT} "-agents" "$AGENTS"  && \
    java -cp "../jade/lib/jade.jar:${AGENT_JAR_FILE}" jade.Boot -container-name ${CONTAINER_NAME} -local-port ${JADE_PORT} -agents "$AGENTS"
