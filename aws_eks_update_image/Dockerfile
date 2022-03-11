FROM guitarrapc/docker-awscli-kubectl:latest
COPY .step/*.sh /root/
COPY aws_eks_update_image/step.sh /root/step.sh
RUN chmod +x /root/*.sh
ENTRYPOINT [ "/root/entry.sh"]
