# Notes

> Important notes for reference in the future.

---

## Start a container with volume
```bash
docker run -it \
    --rm \
    -v $(pwd)/test:/app/test \
    --entrypoint=bash \
    python:3.9.16-slim
```

## Virtual environment
```bash
pip install uv
uv init --python=3.13
# Adding Dependencies
uv add pandas pyarrow
# Adding Dependencies
uv run python pipeline.py 10
```

## Simple Dockerfile with pip

```dockerfile
# base Docker image that we will build on
FROM python:3.13.11-slim

# set up our image by installing prerequisites; pandas in this case
RUN pip install pandas pyarrow

# set up the working directory inside the container
WORKDIR /app
# copy the script to the container. 1st name is source file, 2nd is destination
COPY pipeline.py pipeline.py

# define what to do first when the container runs
# in this example, we will just run the script
ENTRYPOINT ["python", "pipeline.py"]
```

### Build and Run
```bash
docker build -t test:pandas .
```
run the container and pass an argument
```bash
docker run -it test:pandas some_number
```

## Dockerfile with uv

```dockerfile
# Start with slim Python 3.13 image
FROM python:3.13.10-slim

# Copy uv binary from official uv image (multi-stage build pattern)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# Set working directory
WORKDIR /app

# Add virtual environment to PATH so we can use installed packages
ENV PATH="/app/.venv/bin:$PATH"

# Copy dependency files first (better layer caching)
COPY "pyproject.toml" "uv.lock" ".python-version" ./
# Install dependencies from lock file (ensures reproducible builds)
RUN uv sync --locked

# Copy application code
COPY pipeline.py pipeline.py

# Set entry point
ENTRYPOINT ["uv", "run", "python", "pipeline.py"]
```


## Running PostgreSQL in a Container

```bash
docker run -it --rm \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18
```

### Alternative Approach - Bind Mount

First create the directory, then map it:

```bash
mkdir ny_taxi_postgres_data

docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18
```

### Named Volume vs Bind Mount

* **Named volume** (`name:/path`): Managed by Docker, easier
* **Bind mount** (`/host/path:/container/path`): Direct mapping to host filesystem, more control

## Connecting to PostgreSQL

Install pgcli:

```bash
uv add --dev pgcli
```
Use it to connect to Postgres:

```bash
uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
```

## Basic SQL Commands

Try some SQL commands:

```sql
-- List tables
\dt
-- Exit
\q
```

## Setting up Jupyter

Install Jupyter:

```bash
uv add --dev jupyter
```

create a Jupyter notebook to explore the data:

```bash
uv run jupyter notebook
```

## Convert Notebook to Script

```bash
uv run jupyter nbconvert --to=script notebook.ipynb
mv notebook.py ingest_data.py
```

## Click Integration

The script uses `click` for command-line argument parsing:

```python
import click

@click.command()
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--target-table', default='yellow_taxi_data', help='Target table name')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table):
    # Ingestion logic here
    pass
```

## Running the Script
```bash
uv run python ingest_data.py \
  --pg-user=root \
  --pg-pass=root \
  --pg-host=localhost \
  --pg-port=5432 \
  --pg-db=ny_taxi \
  --target-table=yellow_taxi_trips
```

## Docker Networks

reate a virtual Docker network  `pg-network`:

```bash
docker network create pg-network
```

### Run Containers on the Same Network


```bash
# Run PostgreSQL on the network
docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18

# In another terminal, run pgAdmin on the same network
docker run -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4
```


# Docker Compose
launch multiple containers using a single configuration file。

Docker compose makes use of YAML files.

```yaml
services:
  pgdatabase:
    image: postgres:18
    environment:
      POSTGRES_USER: "root"
      POSTGRES_PASSWORD: "root"
      POSTGRES_DB: "ny_taxi"
    volumes:
      - "ny_taxi_postgres_data:/var/lib/postgresql"
    ports:
      - "5432:5432"

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: "admin@admin.com"
      PGADMIN_DEFAULT_PASSWORD: "root"
    volumes:
      - "pgadmin_data:/var/lib/pgadmin"
    ports:
      - "8085:80"



volumes:
  ny_taxi_postgres_data:
  pgadmin_data:
```

## Start Services with Docker Compose

```bash
docker-compose up
```

### Detached Mode
in the background rather than in the foreground (thus freeing up your terminal)

```bash
docker-compose up -d
```

## Stop Services
```bash
docker-compose down
```

## Other Useful Commands

```bash
# View logs
docker-compose logs

# Stop and remove volumes
docker-compose down -v
```


```bash
# check the network link:
docker network ls
```