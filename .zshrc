jlab() {
  local PORT=9903
  local HOST="makoto@192.168.10.19"
  local ROOT_DIR="/mnt/jet12/makoto"
  local CHROME_PROFILE="Profile 1"
  local LOG_FILE="/tmp/jupyterlab-${PORT}.log"

  echo "Stopping old local tunnel on port $PORT..."
  lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null | xargs kill 2>/dev/null || true

  echo "Stopping old remote Jupyter..."
  ssh "$HOST" "pkill -f 'jupyter.*--port=${PORT}'" 2>/dev/null || true

  echo "Starting remote Jupyter with conda env makecsv..."
  ssh "$HOST" "bash -lc '
    source /home/makoto/miniconda3/etc/profile.d/conda.sh
    conda activate makecsv
    rm -f \"$LOG_FILE\"
    nohup jupyter lab \
      --no-browser \
      --ip=127.0.0.1 \
      --port=${PORT} \
      --ServerApp.port_retries=0 \
      --ServerApp.root_dir=\"$ROOT_DIR\" \
      > \"$LOG_FILE\" 2>&1 < /dev/null &
  '" || return 1

  sleep 3

  echo "Checking remote log..."
  ssh "$HOST" "tail -n 15 '$LOG_FILE'"

  echo "Starting tunnel..."
  ssh -f -N -L ${PORT}:127.0.0.1:${PORT} "$HOST" || return 1

  sleep 1

  echo "Getting token URL..."
  local JLAB_URL
  JLAB_URL=$(ssh "$HOST" "python - <<'PY'
import re
logfile = '$LOG_FILE'
url = ''
with open(logfile, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        m = re.search(r'(http://127\\.0\\.0\\.1:$PORT/lab\\?token=[^[:space:]]+)', line)
        if m:
            url = m.group(1)
print(url)
PY
")

  if [ -z "$JLAB_URL" ]; then
    JLAB_URL="http://127.0.0.1:${PORT}/lab"
  fi

  echo "Opening Chrome..."
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
    --profile-directory="$CHROME_PROFILE" \
    "$JLAB_URL" >/dev/null 2>&1 &
}

jlab-stop() {
  local PORT=9903
  local HOST="makoto@192.168.10.19"

  echo "Stopping remote Jupyter..."
  ssh "$HOST" "pkill -f 'jupyter.*--port=${PORT}'" 2>/dev/null || true

  echo "Stopping local tunnel..."
  lsof -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null | xargs kill 2>/dev/null || true

  echo "Stopped JupyterLab and tunnel"
}
