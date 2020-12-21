FROM argoproj/argoexec:v2.11.8
RUN mv /usr/local/bin/argoexec /usr/local/bin/argoexec-bin
COPY timeout.sh /usr/local/bin/argoexec
ENTRYPOINT ["argoexec"]
