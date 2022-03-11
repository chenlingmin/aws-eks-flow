FROM guitarrapc/docker-awscli-kubectl:latest

COPY .step/*.sh /root/
COPY aws_ecr_push/step.sh /root/step.sh

RUN chmod +x /root/*.sh

ENTRYPOINT [ "/root/entry.sh"]
