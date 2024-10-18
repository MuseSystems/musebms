# Use the official Elixir image as a parent image
FROM elixir:latest

# Install PowerShell
RUN apt-get update && apt-get install -y wget apt-transport-https software-properties-common && \
    wget -q "https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb" && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Set the user to   
ARG USERNAME=musedev

# Create the user and group
RUN apt-get update && apt-get install -y sudo && \
    groupadd -g 1000 ${USERNAME} && \
    useradd -m -g ${USERNAME} -G sudo -s /usr/bin/pwsh ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# Download the oh-my-posh binary
RUN mkdir -p /home/${USERNAME}/bin; \
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-$(dpkg --print-architecture) -O /home/${USERNAME}/bin/oh-my-posh; \
    chmod +x /home/${USERNAME}/bin/oh-my-posh; \
    chown ${USERNAME} /home/${USERNAME}/bin;

# NOTE: devcontainers are Linux-only at this time but when
# Windows or Darwin is supported someone will need to improve
# the code logic above.

# Setup a neat little PowerShell experience
RUN pwsh -Command Install-Module posh-git -Scope AllUsers -Force; \
    pwsh -Command Install-Module z -Scope AllUsers -Force; \
    pwsh -Command Install-Module Terminal-Icons -Scope AllUsers -Force;


# Set up .pgpass file for passwordless PostgreSQL access
RUN echo "*:*:postgres:postgres:musesystems-insecure-password" > /home/${USERNAME}/.pgpass && \
    chmod 600 /home/${USERNAME}/.pgpass && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.pgpass

# Add PGPASSFILE environment variable
ENV PGPASSFILE=/home/${USERNAME}/.pgpass

# Set the DBADMIN_PASSWORD environment variable
ENV DBADMIN_PASSWORD="musesystems-insecure-password"

# add the oh-my-posh path to the PATH variable
ENV PATH "$PATH:/home/${USERNAME}/bin"

# Can be used to override the devcontainer prompt default theme:
ENV POSH_THEME="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.omp.json"

# Deploy oh-my-posh prompt to Powershell:
COPY Microsoft.PowerShell_profile.ps1 /home/${USERNAME}/.config/powershell/Microsoft.PowerShell_profile.ps1

# Install PostgreSQL client tools
# Add PostgreSQL repository
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y postgresql-client

# Everything runs as root during build time, so we want
# to make sure the user can edit these paths too:
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
RUN chmod 777 -R /home/${USERNAME}/.config

# Install Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && sudo install lazygit /usr/local/bin \
    && rm lazygit lazygit.tar.gz

# Add Lazygit to PATH
ENV PATH="/usr/local/bin:${PATH}"


# Set container timezone:
ARG TZ="UTC"
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# Set the default shell to PowerShell
SHELL ["pwsh", "-Command"]

# Copy bootstrap script
COPY bootstrap_database.psql /tmp/bootstrap_database.psql
COPY run_bootstrap.ps1 /tmp/run_bootstrap.ps1

USER ${USERNAME}

# Set the working directory
WORKDIR /musebms
