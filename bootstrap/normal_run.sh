exec >> /var/log/normal_run.sh.log 2>&1
set -x

pre_start_action() {
  # Ensure mysql owns the DATA_DIR
  chown -R mysql $DATA_DIR
  # Ensure we have the right permissions set on the DATA_DIR
  chmod -R 700 $DATA_DIR
}

post_start_action() {
  :
}